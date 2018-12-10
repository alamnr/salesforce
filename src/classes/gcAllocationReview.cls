public with sharing class gcAllocationReview {
	public gcAllocationReview() {}

	@RemoteAction
	public static OpportunityLineItem updateOpportunityLine(string idOpportunityLine, string idCustomer, string idProduct, string strDateThru, Decimal qty, Decimal unitPrice)
	{
		Date dateRangeEnd = date.parse(strDateThru);

		OpportunityLineItem oli = new OpportunityLineItem();

		//try to find an existing oli
		for(OpportunityLineItem x : [SELECT Id, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE Id = :idOpportunityLine])
		{
			if(qty == 0)
			{
				delete x;
				oli.Id = null;
				oli.Quantity = null;
				oli.TotalPrice = null;
				return oli;
			}

			oli = x;
			oli.Quantity = qty;
			oli.UnitPrice = unitPrice;
			update oli;
			return [SELECT Id, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE Id = :oli.Id][0];
		}

		//if an oli is not found, try to create one.
		//try to find an allocation opportunity for this customer
		for(Opportunity o :
				[SELECT Id, Pricebook2Id 
				 FROM Opportunity
				 WHERE AccountId = :idCustomer
				   AND CloseDate <= :dateRangeEnd
				   AND Pricebook2Id != null
				   AND Type = 'Allocation'
				 ORDER BY CloseDate DESC, CreatedDate DESC, Id DESC
				 LIMIT 1])
		{
			for(PricebookEntry pbe : 
				[SELECT Id, UnitPrice
				 FROM PricebookEntry
				 WHERE Pricebook2Id = :o.Pricebook2Id
				   AND Product2Id = :idProduct
				 LIMIT 1])
			{
				oli.OpportunityId = o.Id;
				oli.PricebookEntryId = pbe.Id;
				oli.Quantity = qty;
				oli.UnitPrice = pbe.UnitPrice;	

				insert oli;
				return [SELECT Id, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE Id = :oli.Id][0];					
			}
		}

		return oli;
	}

	@RemoteAction @ReadOnly
	public static list<gcObj> retrieveAllocation(string strDateThru, integer monthCount, list<string> listIdCustomer, list<string> listIdVendor, list<string> listIdProduct)
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

		Date dateRangeEnd = date.parse(strDateThru);
		Date dateRangeStart = dateRangeEnd.addMonths(monthCount*(-1)).toStartOfMonth();

		map<string,Integer> mapDateIndex = new map<string,Integer>();

		for(Integer idx = 0; idx < = monthCount; idx++)
		{
			mapDateIndex.put(dateRangeStart.addMonths(idx).format(),(monthCount-idx));
		}

		String soql = ' SELECT ';
				soql += ' Opportunity.AccountId, ';
				soql += ' Product2Id, ';
				soql += ' Quantity, ';
				soql += ' TotalPrice ';
				soql += ' FROM OpportunityLineItem ';
			    soql += ' WHERE Opportunity.Type = \'Allocation\' ';
			    soql += ' AND Product2.AcctSeed__Inventory_Product__c = true ';
			    soql += ' AND (Quantity < 0 OR Quantity > 0) ';
			    soql += ' AND Opportunity.CloseDate <= :dateRangeEnd ';

		if(setIdProduct.size() > 0)
				soql += ' AND Product2Id IN :setIdProduct ';
		if(setIdCustomer.size() > 0)
				soql += ' AND Opportunity.AccountId IN :setIdCustomer ';
		if(setIdVendor.size() > 0)
				soql += ' AND Product2.AcctSeedERP__Default_Vendor__c IN :setIdVendor ';

				soql += ' ORDER BY ';
				soql += ' Opportunity.CloseDate DESC, ';
				soql += ' Opportunity.CreatedDate DESC, ';
				soql += ' Opportunity.Id DESC ';

		map<Id,map<Id,gcObj>> mapObj = new map<Id,map<Id,gcObj>>();
		list<gcObj> listObj = new list<gcObj>();

		for(OpportunityLineItem oli : Database.query(soql))
		{
			Id idCustomer = oli.Opportunity.AccountId;
			Id idProduct = oli.Product2Id;
			Decimal qty = oli.Quantity;
			Decimal amt = oli.TotalPrice;

			if(qty == null) qty = 0;
			if(amt == null) amt = 0;

			if(!mapObj.containsKey(idCustomer))
				mapObj.put(idCustomer, new map<Id,gcObj>());

			if(!mapObj.get(idCustomer).containsKey(idProduct))
			{
				gcObj obj = new gcobj();
				obj.mapProperty.put('idCustomer', idCustomer);
				obj.mapProperty.put('idProduct', idProduct);
				obj.mapProperty.put('qtyAllocated', string.valueOf(qty.setScale(0)));
				obj.mapProperty.put('amtAllocated', string.valueOf(amt.setScale(0)));
				obj.mapProperty.put('idOpportunityLine', oli.Id);

				mapObj.get(idCustomer).put(idProduct,obj);
				listObj.add(obj);
			}
		}

		for(gcObj objHist : gcSalesOrder_History.retrieveHistory(strDateThru,monthCount, listIdCustomer, listIdVendor, listIdProduct))
		{
			String idCustomer = objHist.mapProperty.get('idCustomer');
			String idProduct = objHist.mapProperty.get('idProduct');
			String dateFill = objHist.mapProperty.get('dateFill');

			Decimal qty = objHist.mapDecimal.get('qtyFilled');
			Decimal amt = objHist.mapDecimal.get('amtFilled');

			if(qty == null) qty = 0;
			if(amt == null) amt = 0;

			if(!mapObj.containsKey(idCustomer))
				mapObj.put(idCustomer, new map<Id,gcObj>());

			if(!mapObj.get(idCustomer).containsKey(idProduct))
			{
				gcObj obj = new gcobj();
				obj.mapProperty.put('idCustomer', idCustomer);
				obj.mapProperty.put('idProduct', idProduct);

				mapObj.get(idCustomer).put(idProduct,obj);
				listObj.add(obj);
			}

			gcObj obj = mapObj.get(idCustomer).get(idProduct);

			Integer idx2 = mapDateIndex.get(dateFill);
			string strIdx2 = string.valueOf(idx2);
			if(idx2 < 10) strIdx2 = '0'+strIdx2;

			obj.mapProperty.put('qtyMONTH'+strIdx2,string.valueOf(qty.setScale(0)));
			obj.mapProperty.put('amtMONTH'+strIdx2,string.valueOf(amt.setScale(0)));

		}
		map<Id,Product2> mapProduct = new map<Id,Product2>();
		map<Id,Account> mapAccount = new map<Id,Account>();
		for(gcObj obj : listObj)
		{
			mapProduct.put(obj.mapProperty.get('idProduct'),null);
			mapAccount.put(obj.mapProperty.get('idCustomer'),null);
		}
		mapProduct.remove(null);
		mapAccount.remove(null);

		for(Product2 p : 
				[SELECT Id, Name, Family, ProductCode, AcctSeedERP__Default_Vendor__r.Name
				 FROM Product2
				 WHERE Id IN :mapProduct.keySet()])
		mapProduct.put(p.Id,p);

		for(Account a : [SELECT Id, Name FROM Account WHERE Id IN :mapAccount.keySet()])
		mapAccount.put(a.Id,a);

		for(gcObj obj : listObj)
		{
			Id idProduct = obj.mapProperty.get('idProduct');
			Id idCustomer = obj.mapProperty.get('idCustomer');

			if(mapProduct.containsKey(idProduct))
			{
				Product2 product = mapProduct.get(idProduct);
				obj.mapProperty.put('productName',product.Name);
				obj.mapProperty.put('productCode',product.ProductCode);
				obj.mapProperty.put('productFamily',product.Family);
				obj.mapProperty.put('vendorName',product.AcctSeedERP__Default_Vendor__r.Name);
				obj.mapProperty.put('idVendor',product.AcctSeedERP__Default_Vendor__c);
			}
			if(mapAccount.containsKey(idCustomer))
			{
				obj.mapProperty.put('customerName',mapAccount.get(idCustomer).Name);
			}
		}

		return listObj;
	}
}