global without sharing class cGMBL_PurchaseOrder_Ext {

	global Id idPurchaseOrder{get;set;}
	
	global cGMBL_PurchaseOrder_Ext(ApexPages.StandardController ctrl)
	{
		idPurchaseOrder = ctrl.getId();
	}
	
	global cGMBL_PurchaseOrder_Ext()
	{
		if(ApexPages.CurrentPage().getParameters().get('id') != NULL)
			idPurchaseOrder = ApexPages.CurrentPage().getParameters().get('id');
	}
	

	@RemoteAction @ReadOnly
	global static list<Product2> searchProduct(String strSearch, Integer intMaxResultCount)
	{
		if(intMaxResultCount == null) intMaxResultCount = 10;

		list<Product2> listResult = new list<Product2>();
		
		set<Id> setIdFound = new set<Id>();

		for(Product2 p : 
				[SELECT Id, Name, ProductCode, Description
				 FROM Product2
				 WHERE IsActive = true
				   AND AcctSeed__Inventory_Product__c = true
				   AND (Name = :strSearch OR ProductCode = :strSearch)
				 ORDER BY ProductCode, Name, Id])
		{
			listResult.add(p);
			setIdFound.add(p.Id);
		}

		strSearch = '%'+strSearch.replaceAll('[*]','%') +'%';
		Integer intSize = intMaxResultCount - listResult.size();
		if(intSize < 0) intSize = 0;			
		for(Product2 p :
				[SELECT Id, Name, ProductCode, Description
				 FROM Product2
				 WHERE IsActive = true
				   AND AcctSeed__Inventory_Product__c = true
				   AND (Name LIKE :strSearch OR ProductCode LIKE :strSearch)
				   AND Id NOT IN :setIdFound
				 ORDER BY ProductCode, Name, Id
				 LIMIT :intSize])
		{
			listResult.add(p);
		}
		return listResult;
	}


	@RemoteAction @ReadOnly
	global static list<Lot__c> searchLot(String strSearch, String idProduct, Integer intMaxResultCount)
	{
		if(intMaxResultCount == NULL) intMaxResultCount = 5;
		
		list<Lot__c> listResult = new list<Lot__c>();
		
		set<Id> setIdFound = new set<Id>();

		for(Lot__c lot : 
				[SELECT Id, Name, Expiration_Date__c, Variant_Qty__c
			 	 FROM Lot__c
				 WHERE Product__c =: idProduct
				   AND Name = :strSearch
				 ORDER BY Id])
		{
			listResult.add(lot);
			setIdFound.add(lot.Id);
		}
		
		strSearch = '%'+strSearch.replaceAll('[*]','%') +'%';
		Integer intSize = intMaxResultCount - listResult.size();	
		if(intSize < 0) intSize = 0;	
		
		for(Lot__c lot : 
				[SELECT Id, Name, Expiration_Date__c, Variant_Qty__c
			 	 FROM Lot__c
				 WHERE Product__c =: idProduct
				   AND Name LIKE :strSearch
				   AND Id NOT IN :setIdFound
				 ORDER BY Name, Id
				 LIMIT :intSize])
		{
			listResult.add(lot);
		}		
		return listResult;
	}

	@RemoteAction
	global static AcctSeedERP__Purchase_Order_Line__c selectLot(Id idLine, Id idLot)
	{
		AcctSeedERP__Purchase_Order_Line__c line = new AcctSeedERP__Purchase_Order_Line__c();
		line = [SELECT Id, Lot__c FROM AcctSeedERP__Purchase_Order_Line__c WHERE Id = :idLine][0];
		if(line.Lot__c != idLot)
		{
			line.Lot__c = idLot;
			update line;
		}
		return refreshDetailRow(line.Id);
	}
	
	@RemoteAction
	global static Lot__c createLot(String lotName, String idProduct, String dateExpiration, Decimal decVariantQty)
	{
		Lot__c lot = new Lot__c
		(
			Name = lotName,
			Product__c = idProduct,
			Expiration_Date__c = date.parse(dateExpiration),
			Variant_Qty__c = decVariantQty
		
		);
		
		insert lot;
		return lot;
	}

	@RemoteAction
	global static AcctSeedERP__Purchase_Order_Line__c createPurchaseOrderLine(String idPurchaseOrder, String idProduct)
	{
		AcctSeedERP__Purchase_Order_Line__c pol = new AcctSeedERP__Purchase_Order_Line__c();
		pol.AcctSeedERP__Purchase_Order__c = idPurchaseOrder;
		pol.AcctSeedERP__Product__c = idProduct;
		pol.AcctSeedERP__Quantity__c = 1;
		pol.AcctSeedERP__Unit_Price__c = 0;
		
		insert pol;
		return pol;
	}
	
	@RemoteAction
	global static AcctSeedERP__Purchase_Order_Line__c updatePriceAndQuantity(Id idPurchaseOrderLine, Decimal decPrice, Decimal decQty, Boolean boolPriceOverride)
	{
		AcctSeedERP__Purchase_Order_Line__c line = [SELECT Id FROM AcctSeedERP__Purchase_Order_Line__c WHERE Id = :idPurchaseOrderLine];
		
		line.AcctSeedERP__Unit_Price__c = decPrice;
		line.Variant_Unit_Price__c = decPrice;
		line.Price_Override__c = boolPriceOverride;
		line.AcctSeedERP__Quantity__c = decQty;
		
		update line;
		
		return refreshDetailRow(line.Id);
	}

	@RemoteAction @ReadOnly
	global static list<AcctSeedERP__Purchase_Order_Line__c> refreshDetailRows(Id idPurchaseOrder)
	{
		list<AcctSeedERP__Purchase_Order_Line__c> listPOL = new list<AcctSeedERP__Purchase_Order_Line__c>();
		listPOL.addAll(
			[SELECT Id, Name,
			 AcctSeedERP__Product__c,
			 AcctSeedERP__Product__r.Name,
			 AcctSeedERP__Product__r.Pricing_Units__c,
			 AcctSeedERP__Product__r.ProductCode,
			 AcctSeedERP__Product__r.Variable_Price__c,
			 AcctSeedERP__Quantity__c,
			 AcctSeedERP__Quantity_Received__c,
			 AcctSeedERP__Unit_Price__c,
			 AcctSeedERP__Total__c,
			 Lot__c,
			 Lot__r.Name,
			 Lot__r.Expiration_Date__c,
			 Lot__r.Variant_Qty__c,
			 Price_Override__c,
			 Variant_Unit_Price__c,
			 Total_Received__c,
			 (SELECT Id FROM AcctSeedERP__Purchase_Order_Inventory_Movements__r LIMIT 1),
			 (SELECT Id FROM AcctSeedERP__Account_Payable_Lines__r LIMIT 1)
			 FROM AcctSeedERP__Purchase_Order_Line__c
			 WHERE AcctSeedERP__Purchase_Order__c = :idPurchaseOrder
			 ORDER BY AcctSeedERP__Product__r.Name, AcctSeedERP__Product__r.ProductCode, Lot__r.Name, Name]);
		return listPOL;
	}

	@RemoteAction @ReadOnly
	global static AcctSeedERP__Purchase_Order_Line__c refreshDetailRow(Id idPurchaseOrderLine)
	{
		return
			[SELECT Id, Name,
			 AcctSeedERP__Product__c,
			 AcctSeedERP__Product__r.Name,
			 AcctSeedERP__Product__r.Pricing_Units__c,
			 AcctSeedERP__Product__r.ProductCode,
			 AcctSeedERP__Product__r.Variable_Price__c,
			 AcctSeedERP__Quantity__c,
			 AcctSeedERP__Quantity_Received__c,
			 AcctSeedERP__Unit_Price__c,
			 AcctSeedERP__Total__c,
			 Lot__c,
			 Lot__r.Name,
			 Lot__r.Expiration_Date__c,
			 Lot__r.Variant_Qty__c,
			 Price_Override__c,
			 Variant_Unit_Price__c,
			 Total_Received__c,
			 (SELECT Id FROM AcctSeedERP__Purchase_Order_Inventory_Movements__r LIMIT 1),
			 (SELECT Id FROM AcctSeedERP__Account_Payable_Lines__r LIMIT 1)
			 FROM AcctSeedERP__Purchase_Order_Line__c
			 WHERE Id = :idPurchaseOrderLine
			 ORDER BY Name][0];
	}



	

}