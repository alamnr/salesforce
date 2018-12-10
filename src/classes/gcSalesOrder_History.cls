public with sharing class gcSalesOrder_History {
	public gcSalesOrder_History() {}

	@RemoteAction @ReadOnly
	public static list<gcObj> retrieveHistory(string strDateThru, integer monthCount, list<string> listIdCustomer, list<string> listIdVendor, list<string> listIdProduct)
	{
		set<Id> setIdProduct = new set<Id>();
		for(string idProduct : listIdProduct) setIdProduct.add(Id.valueOf(idProduct));
		setIdProduct.remove(null);

		set<Id> setIdCustomer = new set<Id>();
		for(string idCustomer : listIdCustomer) setIdCustomer.add(Id.valueOf(idCustomer));
		setIdCustomer.remove(null);

		set<Id> setIdVendor = new set<Id>();
		for(string idVendor : listIdVendor) setIdVendor.add(Id.valueOf(idVendor));
		setIdVendor.remove(null);

		map<Id,map<Id,map<Date,cube>>> mapCPDC = new map<Id,map<Id,map<Date,cube>>>(); //map customer-product-date-cube

		Date dateRangeEnd = date.parse(strDateThru);
		Date dateRangeStart = dateRangeEnd.addMonths(monthCount*(-1)).toStartOfMonth();

		String  soql =  ' SELECT ';
				soql += ' AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c idCustomer, ';
				soql += ' AcctSeedERP__Sales_Order__r.Fill_Date__c dateFill, ';
				soql += ' AcctSeedERP__Product__c idProduct, ';
				soql += ' sum(Quantity_Filled__c) qtyFilled, ';
				soql += ' sum(Total_Filled__c) amtFilled ';
				soql += ' FROM AcctSeedERP__Sales_Order_Line__c ';
				soql += ' WHERE ';
				soql += '     AcctSeedERP__Sales_Order__r.Fill_Date__c <= :dateRangeEnd ';
				soql += ' AND AcctSeedERP__Sales_Order__r.Fill_Date__c >= :dateRangeStart ';
				soql += ' AND (Quantity_Filled__c < 0 OR Quantity_Filled__c > 0) ';

		if(setIdProduct.size() > 0)
				soql += ' AND AcctSeedERP__Product__c IN :setIdProduct ';
		if(setIdCustomer.size() > 0)
				soql += ' AND AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c IN :setIdCustomer ';
		if(setIdVendor.size() > 0)
				soql += ' AND AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c IN :setIdVendor ';

				soql += ' GROUP BY ';
				soql += ' AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c, ';
				soql += ' AcctSeedERP__Sales_Order__r.Fill_Date__c, ';
				soql += ' AcctSeedERP__Product__c ';

				soql += ' HAVING ';
				soql += ' sum(Quantity_Filled__c) < 0 OR sum(Quantity_Filled__c) > 0 ';

		list<sObject> listAggRes = new list<sObject>();
		listAggRes.addAll(Database.query(soql));

		list<cube> listCube = new list<cube>();

		for(sObject aggRes : listAggRes)
		{
			Id idCustomer = (Id)aggRes.get('idCustomer');
			Id idProduct = (Id)aggRes.get('idProduct');
			Date dateFill = ((Date)aggRes.get('dateFill')).toStartOfMonth();
			Decimal qtyFilled  = (Decimal)aggRes.get('qtyFilled');
			Decimal amtFilled  = (Decimal)aggRes.get('amtFilled');

			if(qtyFilled == null) qtyFilled = 0;
			if(amtFilled == null) amtFilled = 0;

			if(!mapCPDC.containsKey(idCustomer))
				mapCPDC.put(idCustomer, new map<Id,map<Date,cube>>());

			if(!mapCPDC.get(idCustomer).containsKey(idProduct))
				mapCPDC.get(idCustomer).put(idProduct, new map<Date,cube>());

			if(!mapCPDC.get(idCustomer).get(idProduct).containsKey(dateFill))
			{
				mapCPDC.get(idCustomer).get(idProduct).put(dateFill, new cube(idProduct, idCustomer, dateFill));
				listCube.add(mapCPDC.get(idCustomer).get(idProduct).get(dateFill));
			}

			cube cube = mapCPDC.get(idCustomer).get(idProduct).get(dateFill);

			cube.qtyFilled += qtyFilled;
			cube.amtFilled += amtFilled;
		}

		list<gcObj> listObj = new list<gcObj>();
		for(cube c : listCube)
		{
			gcObj obj = new gcObj();
			obj.mapProperty.put('idProduct', c.idProduct);
			obj.mapProperty.put('idCustomer', c.idCustomer);
			if(c.dateFill != null)
			obj.mapProperty.put('dateFill', c.dateFill.format());

			obj.mapDecimal.put('qtyFilled', c.qtyFilled);
			obj.mapDecimal.put('amtFilled', c.amtFilled);

			listObj.add(obj);
		}

		return listObj;
	}

	public class cube
	{
		Decimal qtyFilled{get;set;}
		Decimal amtFilled{get;set;}

		Id idProduct{get;set;}
		Id idCustomer{get;set;}
		Date dateFill{get;set;}

		public void init()
		{
			qtyFilled = 0;
			amtFilled = 0;
		}
		public cube()
		{
			init();
		}
		public cube(Id pIdProduct, Id pIdCustomer, Date pDateFill)
		{
			init();
			idProduct = pIdProduct;
			idCustomer = pIdCustomer;
			dateFill = pDateFill;
		}
	}
}