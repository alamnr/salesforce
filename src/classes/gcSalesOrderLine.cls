global without sharing class gcSalesOrderLine {

	global static Boolean disableTrigger{
		get{
			if(disableTrigger == null) return false;
			else return disableTrigger;
		}
		set{
			if(value == null) disableTrigger = false;
			else disableTrigger = value;
		}
	}

	global static void triggerHandler
		(map<Id,AcctSeedERP__Sales_Order_Line__c> oldMap,
		 map<Id,AcctSeedERP__Sales_Order_Line__c> newMap,
		 list<AcctSeedERP__Sales_Order_Line__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeedERP__Sales_Order_Line__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeedERP__Sales_Order_Line__c>();
		if(listNew == NULL) listNew = new list<AcctSeedERP__Sales_Order_Line__c>();

		gcSalesOrder.disableTrigger = true;
		updateAndValidate(oldMap,newMap,listNew,boolIsBefore,boolIsInsert,boolIsUpdate,boolIsDelete);
		
		if(boolIsBefore)
		{
			if(boolIsInsert)
			{

			}
			if(boolIsUpdate)
			{

			}
			if(boolIsDelete)
			{

			}
		}
		else //i.e. trigger.isAfter
		{
			if(boolIsInsert)
			{

			}
			if(boolIsUpdate)
			{

			}
			if(boolIsDelete)
			{

			}
		}			
	}

	global static void updateAndValidate
		(map<Id,AcctSeedERP__Sales_Order_Line__c> oldMap,
		 map<Id,AcctSeedERP__Sales_Order_Line__c> newMap,
		 list<AcctSeedERP__Sales_Order_Line__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore)
		{
			if(boolIsInsert)
			{
				for(AcctSeedERP__Sales_Order_Line__c sol : listNew)
				{
					sol.Chargeback__c = 0;
					sol.Expense__c = 0;
					sol.Quantity_Filled__c = 0;
					sol.Revenue__c = 0;
				}
			}
			if(boolIsUpdate || boolIsInsert)
			{
				price(listNew);
			}

			if(boolIsUpdate || boolIsDelete)
			{		
				set<Id> setIdLineHasBilling = new set<Id>();
				set<Id> setIdLineHasMove = new set<Id>();

				for(AcctSeedERP__Sales_Order_Line__c sol :
					[SELECT Id,
					 	(SELECT Id FROM AcctSeedERP__Billing_Lines__r LIMIT 1),
					 	(SELECT Id FROM Outbound_Inventory_Movements__r LIMIT 1)
					 FROM AcctSeedERP__Sales_Order_Line__c
					 WHERE Id IN : oldMap.keySet()])
				{
					if(sol.AcctSeedERP__Billing_Lines__r.size() > 0)
						setIdLineHasBilling.add(sol.Id);
					if(sol.Outbound_Inventory_Movements__r.size() > 0)
						setIdLineHasMove.add(sol.Id);					
				}
				
				if(boolIsUpdate)
				{
					for(AcctSeedERP__Sales_Order_Line__c sol : oldMap.values())
					{
						if(sol.AcctSeedERP__Product__c != newMap.get(sol.Id).AcctSeedERP__Product__c && setIdLineHasBilling.contains(sol.Id))
						{
							newMap.get(sol.Id).addError('The Product of the Sales Order Line cannot be changed, because the Sales Order Line has underlying Billing Lines.');
						}
						else if(sol.AcctSeedERP__Unit_Price__c != newMap.get(sol.Id).AcctSeedERP__Unit_Price__c && setIdLineHasBilling.contains(sol.Id))
						{
							newMap.get(sol.Id).addError('The Unit Price of the Sales Order Line cannot be changed, because the Sales Order Line has underlying Billing Lines.');
						}
						else if(sol.AcctSeedERP__Product__c != newMap.get(sol.Id).AcctSeedERP__Product__c && setIdLineHasMove.contains(sol.Id))
						{
							newMap.get(sol.Id).addError('The Product of the Sales Order Line cannot be changed, because the Sales Order Line has underlying Outbound Inventory Movements.');
						}
						else if(sol.Lot__c != newMap.get(sol.Id).Lot__c && setIdLineHasMove.contains(sol.Id))
						{
							newMap.get(sol.Id).addError('The Lot of the Sales Order Line cannot be changed, because the Sales Order Line has underlying Outbound Inventory Movements.');
						}
						else if(sol.Quantity_Filled__c != newMap.get(sol.Id).Quantity_Filled__c)
						{
							newMap.get(sol.Id).addError('The Quantity Filled cannot be directly manipulated.');
						}	
						else if(sol.Expense__c != newMap.get(sol.Id).Expense__c)
						{
							newMap.get(sol.Id).addError('The Expense of a Sales Order Line cannot be directly manipulated.');
						}	
						else if(sol.Revenue__c != newMap.get(sol.Id).Revenue__c)
						{
							newMap.get(sol.Id).addError('The Revenue of a Sales Order Line cannot be directly manipulated.');
						}	
						else if(sol.Chargeback__c != newMap.get(sol.Id).Chargeback__c)
						{
							newMap.get(sol.Id).addError('The Chargeback of a Sales Order Line cannot be directly manipulated.');
						}													
					}
				}
				if(boolIsDelete)
				{
					for(AcctSeedERP__Sales_Order_Line__c sol : oldMap.values())
					{
						if(setIdLineHasBilling.contains(sol.Id))
							sol.addError('The Sales Order Line cannot be deleted because it has an underlying Billing Line: '+sol.Name);
						if(setIdLineHasMove.contains(sol.Id))
							sol.addError('The Sales Order Line cannot be deleted because it has an underlying Inventory Movement: '+sol.Name);				
					}													
				}
			}
		}	
	}

	global static void price(list<AcctSeedERP__Sales_Order_Line__c> listNew)
	{
		map<Id,AcctSeedERP__Sales_Order__c> mapSalesOrder = new map<Id,AcctSeedERP__Sales_Order__c>();
		map<Id,Product2> mapProduct = new map<Id,Product2>();
		map<Id,Lot__c> mapLot = new map<Id,Lot__c>();
		set<Id> setIdLineHasBilling = new set<Id>();
		set<Id> setIdLineHasMove = new set<Id>();
		map<Id,map<Id,Decimal>> mapProductPricebookPrice = new map<Id,map<Id,Decimal>>();


		for(AcctSeedERP__Sales_Order_Line__c sol : listNew)
		{
			mapProduct.put(sol.AcctSeedERP__Product__c,NULL);
			mapSalesOrder.put(sol.AcctSeedERP__Sales_Order__c,NULL);
			mapLot.put(sol.Lot__c,NULL);
			mapProductPricebookPrice.put(sol.AcctSeedERP__Product__c,new map<Id,Decimal>());
		}
		mapProduct.remove(NULL);
		mapSalesOrder.remove(NULL);
		mapLot.remove(NULL);
		mapProductPricebookPrice.remove(NULL);


		//collect the Sales orders, to get the price book
		if(mapSalesOrder.size() > 0)
		for(AcctSeedERP__Sales_Order__c so :
				[SELECT Id, Pricebook__c
				 FROM AcctSeedERP__Sales_Order__c
				 WHERE Id IN : mapSalesOrder.keySet()])
		{
			mapSalesOrder.put(so.Id,so);
		}

		//collect the products, with prices
		if(mapProduct.size() > 0)
		for(Product2 p :
			[SELECT Id, Name, ProductCode, Variable_Price__c,
				(SELECT Id, IsActive, UnitPrice, 
						PriceBook2Id, PriceBook2.Name, PriceBook2.IsActive, PriceBook2.IsStandard
				 FROM PriceBookEntries
				 WHERE IsActive = true
				   AND PriceBook2.IsActive = true
				 ORDER BY CreatedDate desc)
			 FROM Product2
			 WHERE Id IN : mapProduct.keySet()])
		{
			mapProduct.put(p.Id,p);

			map<Id,Decimal> mapPricebookPrice = mapProductPricebookPrice.get(p.Id);
			for(PriceBookEntry pbe : p.PriceBookEntries)
			{
				mapPricebookPrice.put(pbe.Pricebook2Id,pbe.UnitPrice);
			}
		}
		
		//collect the lots
		if(mapLot.size() > 0)
		for(Lot__c lot :
				[SELECT Id, Expiration_Date__c, Variant_Qty__c
				 FROM Lot__c
				 WHERE Id IN : mapLot.keySet()])
		{
			mapLot.put(lot.Id,lot);
		}

		for(AcctSeedERP__Sales_Order_Line__c sol : listNew)
		{
			Decimal decUnitPrice = 0;
			if(!sol.Price_Override__c)
			{
				Id idPricebook = mapSalesOrder.get(sol.AcctSeedERP__Sales_Order__c).Pricebook__c;
				map<Id,Decimal> mapPricebookPrice = mapProductPricebookPrice.get(sol.AcctSeedERP__Product__c);

				//if there is a price book entry for the PurchaseOrder.Pricebook, use that price
				if(idPricebook != NULL && mapPricebookPrice.containsKey(idPricebook) && mapPricebookPrice.get(idPricebook) != 0 && mapPricebookPrice.get(idPricebook) != NULL)
					decUnitPrice = mapPricebookPrice.get(idPricebook);					
			}
			else if(mapProduct.containsKey(sol.AcctSeedERP__Product__c) && mapProduct.get(sol.AcctSeedERP__Product__c).Variable_Price__c)
			{
				decUnitPrice = sol.Variant_Unit_Price__c;
			}
			else
			{
				decUnitPrice = sol.AcctSeedERP__Unit_Price__c;
			}

			if(decUnitPrice == null) decUnitPrice = 0;

			if(mapProduct.containsKey(sol.AcctSeedERP__Product__c) && mapProduct.get(sol.AcctSeedERP__Product__c).Variable_Price__c)
			{
				sol.Variant_Unit_Price__c = decUnitPrice;

				Lot__c lot = new Lot__c();
				if(mapLot.containsKey(sol.Lot__c))
				{
					lot = mapLot.get(sol.Lot__c);
				}

				if(lot.Variant_Qty__c != NULL)
				{
					sol.AcctSeedERP__Unit_Price__c = lot.Variant_Qty__c * decUnitPrice;
				}
				else
				{
					sol.AcctSeedERP__Unit_Price__c = decUnitPrice;
				}
			}
			else
			{
				sol.Variant_Unit_Price__c = 0;
				sol.AcctSeedERP__Unit_Price__c = decUnitPrice;					
			}

			if(sol.AcctSeedERP__Unit_Price__c == null)
			   sol.AcctSeedERP__Unit_Price__c = 0;

			sol.AcctSeedERP__Unit_Price__c = sol.AcctSeedERP__Unit_Price__c.setScale(2);
		}		
	}

	/*
	The purpose of this method is recalculate the Quantity Filled for a Sales Order Line.
	This method should be called whenever an Outbound Inventory Movement that is a child of a Sales Order Line is inserted or updated.
	*/
	global static void rollup(set<Id> pSetIdSalesOrderLine)
	{
		pSetIdSalesOrderLine.remove(NULL);
		if(pSetIdSalesOrderLine.size() == 0) return;

		list<AcctSeedERP__Sales_Order_Line__c> listSOLupdate = new list<AcctSeedERP__Sales_Order_Line__c>();

		Id idGLChargeback = null;
		for(AcctSeed__GL_Account__c gl : [SELECT Id FROM AcctSeed__GL_Account__c WHERE Uniquefier__c = 'ChargeBack'])
		{
			idGLChargeback = gl.Id;
		}

		map<Id,cube> mapCube = new map<Id,cube>();
		for(AcctSeed__Transaction__c txn :
			[SELECT Id, 
					AcctSeed__GL_Account__c, 
					AcctSeed__GL_Account__r.AcctSeed__Type__c,
					AcctSeed__Amount__c,
					AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__c, 
					AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__c
			 FROM AcctSeed__Transaction__c
			 WHERE AcctSeed__GL_Account__r.AcctSeed__Type__c IN ('Revenue','Expense')
			   AND (AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__c IN :pSetIdSalesOrderLine OR
			   	    AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__c IN :pSetIdSalesOrderLine)
			   AND (AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0)])
		{
			Id idSOL = txn.AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__c;
			if(idSOL == null)
			   idSOL = txn.AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__c;

			cube cube = mapCube.get(idSOL);
			if(cube == null)
			{
				cube = new cube();
				mapCube.put(idSOL, cube);
			}

			if(txn.AcctSeed__GL_Account__r.AcctSeed__Type__c == 'Revenue')
				cube.revenue -= txn.AcctSeed__Amount__c;
			else
				cube.expense += txn.AcctSeed__Amount__c;

			if(txn.AcctSeed__GL_Account__c == idGLChargeback)
				cube.chargeback -= txn.AcctSeed__Amount__c;
		}

		for(AcctSeedERP__Sales_Order_Line__c sol : 
				[SELECT Id, Chargeback__c, Expense__c, Quantity_Filled__c, Revenue__c,
				 (SELECT AcctSeedERP__Quantity__c, Total__c FROM Outbound_Inventory_Movements__r WHERE AcctSeedERP__Quantity__c <= 0 OR AcctSeedERP__Quantity__c > 0)
				 FROM AcctSeedERP__Sales_Order_Line__c
				 WHERE Id IN :pSetIdSalesOrderLine])
		{
			Decimal decQtyNew = 0;
			Decimal decExpNew = 0;
			Decimal decRevNew = 0;
			Decimal decChargeBackNew = 0;

			for(AcctSeedERP__Outbound_Inventory_Movement__c move : sol.Outbound_Inventory_Movements__r)
				decQtyNew += move.AcctSeedERP__Quantity__c;

			if(mapCube.containsKey(sol.Id))
			{
				cube cube = mapCube.get(sol.Id);
				decExpNew = cube.expense;
				decRevNew = cube.revenue;
				decChargeBackNew = cube.chargeback;
			}

			if(sol.Quantity_Filled__c == NULL || sol.Quantity_Filled__c.setScale(6) != decQtyNew.setScale(6) ||
			   sol.Expense__c == null || sol.Expense__c.setScale(6) != decExpNew.setScale(6) ||
			   sol.Revenue__c == null || sol.Revenue__c.setScale(6) != decRevNew.setScale(6) ||
			   sol.Chargeback__c == null || sol.Chargeback__c.setScale(6) != decChargeBackNew.setScale(6))
			{
				sol.Chargeback__c = decChargeBackNew;
				sol.Expense__c = decExpNew;
				sol.Quantity_Filled__c = decQtyNew;				
				sol.Revenue__c = decRevNew;
				listSOLupdate.add(sol);
			}
		}

		if(listSOLupdate.size() > 0)
		{
			Boolean boolOldSO = gcSalesOrder.disableTrigger;
			gcSalesOrder.disableTrigger = true;
			Boolean boolOldSOL = gcSalesOrderLine.disableTrigger;
			gcSalesOrderLine.disableTrigger = true;

			update listSOLupdate;
			gcSalesOrder.disableTrigger = boolOldSO;
			gcSalesOrderLine.disableTrigger = boolOldSOL;
		}
	}

	private class cube
	{
		Decimal expense{get;set;}
		Decimal revenue{get;set;}
		Decimal chargeback{get;set;}

		cube(){
			expense = 0;
			revenue = 0;
			chargeback = 0;
		}
	}
}