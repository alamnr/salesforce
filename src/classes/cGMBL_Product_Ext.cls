global without sharing class cGMBL_Product_Ext {

	global Id idProduct{get;set;}
	global cGMBL_Product_Ext(ApexPages.StandardController c) 
	{
		idProduct = c.getId();
	}

	@RemoteAction @ReadOnly
	global static list<obj> retrievePrices(Id idProduct)
	{
		list<obj> listObj = new list<obj>();
		for(PriceBookEntry pbe :
			[SELECT Id, 
					IsActive,
					Margin__c,
					PriceBook2.Name,
					PriceBook2.IsStandard,
					PriceBook2.Uniquefier__c,
					UnitPrice,
					UseStandardPrice,
					Effective_Date__c
				 FROM PriceBookEntry
				 WHERE Product2Id = :idProduct
				 ORDER BY PriceBook2.IsStandard DESC, Pricebook2.Uniquefier__c DESC, Pricebook2.Name, Effective_Date__c DESC])
		{
			obj obj = new obj();
			obj.mapProperty.put('idPBE',pbe.Id);
			if(pbe.isActive)
				 obj.mapProperty.put('isActive','true');
			else obj.mapProperty.put('isActive','false');
			if(pbe.PriceBook2.IsStandard)
				 obj.mapProperty.put('isStandardPriceBook','true');
			else obj.mapProperty.put('isStandardPriceBook','false');	
			if(pbe.PriceBook2.Uniquefier__c == 'PurchaseOrder')
				 obj.mapProperty.put('isDefaultPurchasing','true');
			else obj.mapProperty.put('isDefaultPurchasing','false');	
			if(pbe.PriceBook2.Uniquefier__c == 'MarginBasis')
				 obj.mapProperty.put('isMarginBasis','true');
			else obj.mapProperty.put('isMarginBasis','false');
			if(pbe.UseStandardPrice)
				 obj.mapProperty.put('useStandardPrice','true');
			else obj.mapProperty.put('useStandardPrice','false');

			if(pbe.Effective_Date__c != null)
				obj.mapProperty.put('effectiveDate',pbe.Effective_Date__c.format());

			obj.mapProperty.put('margin',String.valueOf(pbe.Margin__c));
			obj.mapProperty.put('unitPrice',String.valueOf(pbe.UnitPrice));
			obj.mapProperty.put('priceBookName',pbe.PriceBook2.Name);

			listObj.add(obj);
		}
		return listObj;
	}

	@RemoteAction @ReadOnly
	global static list<obj> retrievePricesAll()
	{
		//Parameter
		//Map<String,String> mapFilters
		/*String 	soqlWHERE = ' WHERE PriceBook2.IsStandard = false ';
		if(mapFilters.containsKey('ProductFamily'))
			soqlWHERE += ' AND Product2.Family = ' + mapFilters.get('ProductFamily');
		if(mapFilters.containsKey('ProductCat1'))
			soqlWHERE += ' AND Product2.Category_1__c = ' + mapFilters.get('ProductCat1');
		if(mapFilters.containsKey('ProductCat2'))
			soqlWHERE += ' AND Product2.Category_2__c = ' + mapFilters.get('ProductCat2');
		if(mapFilters.containsKey('ProductCat3'))
			soqlWHERE += ' AND Product2.Category_3__c = ' + mapFilters.get('ProductCat3');
		if(mapFilters.containsKey('ProductPlasma'))
			soqlWHERE += ' AND Product2.Human_Plasma_Derived_or_Recombinant__c = ' + mapFilters.get('ProductPlasma');

		String 	soqlSELECT = 'SELECT Id, IsActive, Margin__c, PriceBook2.Name, PriceBook2.IsStandard, PriceBook2.Uniquefier__c,'
				soqlSELECT += 'Product2.Id, Product2.Name, Product2.Family,	Product2.ProductCode, UnitPrice, UseStandardPrice FROM PriceBookEntry';

		String 	soqlORDER = ' ORDER BY Product2.Name, Product2.ProductCode, PriceBook2.IsStandard DESC, Pricebook2.Uniquefier__c, Pricebook2.Name'

		String soql = soqlSELECT + soqlWHERE + soqlORDER;

		List<PriceBookEntry> listPBE = Database.query(soql);*/

		list<obj> listObj = new list<obj>();
		for(PriceBookEntry pbe :
			[SELECT Id, 
					IsActive,
					Margin__c,
					PriceBook2.Name,
					PriceBook2.IsStandard,
					PriceBook2.Uniquefier__c,
					Product2.Id,
					Product2.Name,
					Product2.Family,
					Product2.ProductCode,
					Product2.Category_1__c,
					Product2.Category_2__c,
					Product2.Category_3__c,
					Product2.Human_Plasma_Derived_or_Recombinant__c,
					UnitPrice,
					UseStandardPrice,
					Effective_Date__c
				 FROM PriceBookEntry
				 WHERE PriceBook2.IsStandard = false
				 ORDER BY Product2.Name, Product2.ProductCode, PriceBook2.IsStandard DESC, Pricebook2.Uniquefier__c, Pricebook2.Name, Effective_Date__c DESC])
		{
			obj obj = new obj();
			obj.mapProperty.put('idPBE',pbe.Id);
			if(pbe.isActive)
				 obj.mapProperty.put('isActive','true');
			else obj.mapProperty.put('isActive','false');
			if(pbe.PriceBook2.IsStandard)
				 obj.mapProperty.put('isStandardPriceBook','true');
			else obj.mapProperty.put('isStandardPriceBook','false');	
			if(pbe.PriceBook2.Uniquefier__c == 'PurchaseOrder')
				 obj.mapProperty.put('isDefaultPurchasing','true');
			else obj.mapProperty.put('isDefaultPurchasing','false');	
			if(pbe.PriceBook2.Uniquefier__c == 'MarginBasis')
				 obj.mapProperty.put('isMarginBasis','true');
			else obj.mapProperty.put('isMarginBasis','false');
			if(pbe.UseStandardPrice)
				 obj.mapProperty.put('useStandardPrice','true');
			else obj.mapProperty.put('useStandardPrice','false');

			obj.mapProperty.put('margin',String.valueOf(pbe.Margin__c));
			obj.mapProperty.put('unitPrice',String.valueOf(pbe.UnitPrice));
			obj.mapProperty.put('priceBookName',pbe.PriceBook2.Name);

			obj.mapProperty.put('productName', pbe.Product2.Name);
			obj.mapProperty.put('productCode', pbe.Product2.ProductCode);

			obj.mapProperty.put('productCategory1', pbe.Product2.Category_1__c);
			obj.mapProperty.put('productCategory2', pbe.Product2.Category_2__c);
			obj.mapProperty.put('productCategory3', pbe.Product2.Category_3__c);
			obj.mapProperty.put('productPlasma', pbe.Product2.Human_Plasma_Derived_or_Recombinant__c);

			obj.mapProperty.put('idProduct', pbe.Product2.Id);

			if(pbe.Product2.Family != null)
				obj.mapProperty.put('productFamily', pbe.Product2.Family);
			else
				obj.mapProperty.put('productFamily', '---blank---');

			if(pbe.Effective_Date__c != null)
				obj.mapProperty.put('effectiveDate',pbe.Effective_Date__c.format());

			listObj.add(obj);
		}
		return listObj;
	}

	@RemoteAction
	global static String updateUnitPrice(Id idPBE, Decimal unitPrice)
	{
		for(PriceBookEntry pbe : 
			[SELECT Id, UnitPrice
			 FROM PriceBookEntry
			 WHERE Id = :idPBE])
		{
			pbe.UnitPrice = unitPrice;
			update pbe;
		}
		return 'Ok';
	}
	@RemoteAction
	global static String updateMargin(Id idPBE, Decimal margin)
	{
		String returns;
		for(PriceBookEntry pbe : 
			[SELECT Id, Margin__c, UnitPrice
			 FROM PriceBookEntry
			 WHERE Id = :idPBE])
		{
			pbe.Margin__c = margin;
			update pbe;
			cGMBL_PriceBookEntry.recalcMarkup();
		}
		for(PriceBookEntry pbe : 
			[SELECT Id, Margin__c, UnitPrice
			 FROM PriceBookEntry
			 WHERE Id = :idPBE])
		{
			returns = String.valueOf(pbe.Margin__c) + '__' + String.valueOf(pbe.UnitPrice);
		}
		return returns;
	}	

	global class obj{

		global map<String,String> mapProperty{get;set;}

		global obj()
		{
			mapProperty = new map<String,String>();
		}
	}
}