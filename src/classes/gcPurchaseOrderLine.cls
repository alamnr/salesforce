global without sharing class gcPurchaseOrderLine {

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
		(map<Id,AcctSeedERP__Purchase_Order_Line__c> oldMap,
		 map<Id,AcctSeedERP__Purchase_Order_Line__c> newMap,
		 list<AcctSeedERP__Purchase_Order_Line__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeedERP__Purchase_Order_Line__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeedERP__Purchase_Order_Line__c>();
		if(listNew == NULL) listNew = new list<AcctSeedERP__Purchase_Order_Line__c>();

		gcPurchaseOrder.disableTrigger = true;
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
		gcPurchaseOrder.disableTrigger = true;			
	}

	global static void updateAndValidate
		(map<Id,AcctSeedERP__Purchase_Order_Line__c> oldMap,
		 map<Id,AcctSeedERP__Purchase_Order_Line__c> newMap,
		 list<AcctSeedERP__Purchase_Order_Line__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore)
		{
			if(boolIsUpdate || boolIsInsert)
			{
				price(listNew);
				for(AcctSeedERP__Purchase_Order_Line__c pol : listNew)
				{
					//pol.Lot__c = null;	//this company does not use variant pricing, so they do not use PurchaseOrderLine.Lot
				}
			}
			
			if(boolIsUpdate || boolIsDelete)
			{
				set<Id> setIdHasAPlines = new set<Id>();
				set<Id> setIdHasMoves	= new set<Id>();

				for(AcctSeedERP__Purchase_Order_Line__c pol :
					[SELECT Id,
					 	(SELECT Id FROM AcctSeedERP__Account_Payable_Lines__r LIMIT 1),
					 	(SELECT Id FROM AcctSeedERP__Purchase_Order_Inventory_Movements__r LIMIT 1)
					 FROM AcctSeedERP__Purchase_Order_Line__c
					 WHERE Id IN : oldMap.keySet()])
				{
					if(pol.AcctSeedERP__Account_Payable_Lines__r.size() > 0)
						setIdHasAPlines.add(pol.Id);
					if(pol.AcctSeedERP__Purchase_Order_Inventory_Movements__r.size() > 0)
						setIdHasMoves.add(pol.Id);					
				}
				if(boolIsUpdate)
				{				
					for(AcctSeedERP__Purchase_Order_Line__c pol : oldMap.values())
					{
						if(pol.AcctSeedERP__Product__c != newMap.get(pol.Id).AcctSeedERP__Product__c && setIdHasAPlines.contains(pol.Id))
						{
							newMap.get(pol.Id).addError('The Product of the Purchase Order Line cannot be changed, because the Purchase Order Line has underlying Account Payable Lines.');
						}
						else if(pol.AcctSeedERP__Unit_Price__c != newMap.get(pol.Id).AcctSeedERP__Unit_Price__c && setIdHasAPlines.contains(pol.Id))
						{
							newMap.get(pol.Id).addError('The Unit Price of the Purchase Order Line cannot be changed, because the Purchase Order Line has underlying Account Payable Lines.');
						}
						else if(pol.AcctSeedERP__Product__c != newMap.get(pol.Id).AcctSeedERP__Product__c && setIdHasMoves.contains(pol.Id))
						{
							newMap.get(pol.Id).addError('The Product of the Purchase Order Line cannot be changed, because the Purchase Order Line has underlying Inventory Movements.');
						}
						else if(pol.Lot__c != newMap.get(pol.Id).Lot__c && setIdHasMoves.contains(pol.Id))
						{
							newMap.get(pol.Id).addError('The Lot of the Purchase Order Line cannot be changed, because the Purchase Order Line has underlying Inventory Movements.');
						}
					}
				}
				if(boolIsDelete)
				{
					for(AcctSeedERP__Purchase_Order_Line__c pol : oldMap.values())
					{
						if(setIdHasAPlines.contains(pol.Id))
							pol.addError('The Purchase Order Line cannot be deleted because it has an underlying Account Payable Line: '+pol.Name);
						if(setIdHasMoves.contains(pol.Id))
							pol.addError('The Purchase Order Line cannot be deleted because it has an underlying Inventory Movement: '+pol.Name);					
					}													
				}
			}
		}

		if(!boolIsBefore && boolIsUpdate)
		{
			//if the price is updated on a Purchase Order Line
			//and there are underlying movements that have not been paid, and that are in an open period
			//then update the unit cost on the purchase order inventory movements to match the parent purchase order line

			//get the start date of the earliest open period
			Date dateBoundary = [SELECT AcctSeed__Start_Date__c 
								 FROM AcctSeed__Accounting_Period__c
								 WHERE AcctSeed__Status__c = 'Open'
								 ORDER BY AcctSeed__Start_Date__c
								 LIMIT 1][0].AcctSeed__Start_Date__c;	
			
			list<AcctSeedERP__Purchase_Order_Inventory_Movement__c> listPOIMupdate = new list<AcctSeedERP__Purchase_Order_Inventory_Movement__c>();

			for(AcctSeedERP__Purchase_Order_Inventory_Movement__c move :
					[SELECT Id, AcctSeedERP__Purchase_Order_Line__c, AcctSeedERP__Unit_Cost__C
					 FROM AcctSeedERP__Purchase_Order_Inventory_Movement__c
					 WHERE AcctSeedERP__Purchase_Order_Line__c IN : newMap.keySet()
					   AND AcctSeedERP__Movement_Date__c >= : dateBoundary
					   AND Account_Payable_Line__c = null])
			{
				if(move.AcctSeedERP__Unit_Cost__c != newMap.get(move.AcctSeedERP__Purchase_Order_Line__c).AcctSeedERP__Unit_Price__c)
				{
					move.AcctSeedERP__Unit_Cost__c = newMap.get(move.AcctSeedERP__Purchase_Order_Line__c).AcctSeedERP__Unit_Price__c;
					listPOIMupdate.add(move);
				}			
			}

			if(listPOIMupdate.size()>0) update listPOIMupdate;
		}//end of after update
	}

	global static void price(list<AcctSeedERP__Purchase_Order_Line__c> listNew)
	{
		map<Id,AcctSeedERP__Purchase_Order__c> mapPurchaseOrder = new map<Id,AcctSeedERP__Purchase_Order__c>();
		map<Id,Product2> mapProduct = new map<Id,Product2>();
		map<Id,Lot__c> mapLot = new map<Id,Lot__c>();
		set<Id> setIdLineHasPayable = new set<Id>();
		set<Id> setIdLineHasMove = new set<Id>();
		map<Id,map<Id,Decimal>> mapProductPricebookPrice = new map<Id,map<Id,Decimal>>();


		for(AcctSeedERP__Purchase_Order_Line__c pol : listNew)
		{
			mapProduct.put(pol.AcctSeedERP__Product__c,NULL);
			mapPurchaseOrder.put(pol.AcctSeedERP__Purchase_Order__c,NULL);
			mapLot.put(pol.Lot__c,NULL);
			mapProductPricebookPrice.put(pol.AcctSeedERP__Product__c,new map<Id,Decimal>());
		}
		mapProduct.remove(NULL);
		mapPurchaseOrder.remove(NULL);
		mapLot.remove(NULL);
		mapProductPricebookPrice.remove(NULL);


		//collect the purchase orders, to get the price book
		for(AcctSeedERP__Purchase_Order__c po :
				[SELECT Id, Pricebook__c
				 FROM AcctSeedERP__Purchase_Order__c
				 WHERE Id IN : mapPurchaseOrder.keySet()])
		{
			mapPurchaseOrder.put(po.Id,po);
		}

		//collect the products, with prices
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

		for(AcctSeedERP__Purchase_Order_Line__c pol : listNew)
		{
			Decimal decUnitPrice = 0;
			if(!pol.Price_Override__c)
			{
				Id idPricebook = mapPurchaseOrder.get(pol.AcctSeedERP__Purchase_Order__c).Pricebook__c;
				map<Id,Decimal> mapPricebookPrice = mapProductPricebookPrice.get(pol.AcctSeedERP__Product__c);

				//if there is a price book entry for the PurchaseOrder.Pricebook, use that price
				if(idPricebook != NULL && mapPricebookPrice.containsKey(idPricebook) && mapPricebookPrice.get(idPricebook) != 0 && mapPricebookPrice.get(idPricebook) != NULL)
					decUnitPrice = mapPricebookPrice.get(idPricebook);					
			}
			else if(mapProduct.containsKey(pol.AcctSeedERP__Product__c) && mapProduct.get(pol.AcctSeedERP__Product__c).Variable_Price__c)
			{
				decUnitPrice = pol.Variant_Unit_Price__c;
			}
			else
			{
				decUnitPrice = pol.AcctSeedERP__Unit_Price__c;
			}

			if(decUnitPrice == null) decUnitPrice = 0;

			if(mapProduct.containsKey(pol.AcctSeedERP__Product__c) && mapProduct.get(pol.AcctSeedERP__Product__c).Variable_Price__c)
			{
				pol.Variant_Unit_Price__c = decUnitPrice;

				Lot__c lot = new Lot__c();
				if(mapLot.containsKey(pol.Lot__c))
				{
					lot = mapLot.get(pol.Lot__c);
				}

				if(lot.Variant_Qty__c != NULL)
				{
					pol.AcctSeedERP__Unit_Price__c = lot.Variant_Qty__c * decUnitPrice;
				}
				else
				{
					pol.AcctSeedERP__Unit_Price__c = decUnitPrice;
				}
			}
			else
			{
				pol.Variant_Unit_Price__c = 0;
				pol.AcctSeedERP__Unit_Price__c = decUnitPrice;					
			}

			if(pol.AcctSeedERP__Unit_Price__c == null)
			   pol.AcctSeedERP__Unit_Price__c = 0;

			pol.AcctSeedERP__Unit_Price__c = pol.AcctSeedERP__Unit_Price__c.setScale(2);
		}		
	}
}