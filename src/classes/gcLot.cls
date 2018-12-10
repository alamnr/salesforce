global without sharing class gcLot {

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
		(map<Id,Lot__c> oldMap,
		 map<Id,Lot__c> newMap,
		 list<Lot__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,Lot__c>();
		if(newMap == NULL) newMap = new map<Id,Lot__c>();
		if(listNew == NULL) listNew = new list<Lot__c>();

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
		(map<Id,Lot__c> oldMap,
		 map<Id,Lot__c> newMap,
		 list<Lot__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			map<Id,Product2> mapProduct = new map<Id,Product2>();
			for(Lot__c lot : listNew)
			{
				mapProduct.put(lot.Product__c, null);
			}
			mapProduct.remove(null);
			for(Product2 product : [SELECT Id, Lot_Tracked__c, Variable_Price__c FROM Product2 WHERE Id IN :mapProduct.keySet()])
			{
				mapProduct.put(product.Id,product);
			}
			for(Lot__c lot : listNew)
			{
				if(!mapProduct.containsKey(lot.Product__c))
				{
					lot.addError('The Product is not valid.');
				}
				else if(!mapProduct.get(lot.Product__c).Lot_Tracked__c)
				{
					lot.addError('The specified product is not lot-tracked.');
				}
				else if(mapProduct.get(lot.Product__c).Variable_Price__c && (lot.Variant_Qty__c == NULL || lot.Variant_Qty__c <= 0))
				{
					lot.addError('The Lot must have a variant quantity because the product has a variable price.');
				}
				else if(lot.Expiration_Date__c == NULL)
				{
					lot.addError('A Lot must have an Expiration Date.');
				}				
				//enforce uniqueness of Lot Name + product Id
				//require alphanumeric, with option of special character suffix
				String  specialChar = lot.Name.right(1).toUpperCase().replaceAll('[0-9A-Z]','').replaceAll('[^*]','');

				lot.Name = lot.Name.toUpperCase().replaceAll('[^0-9A-Z]','') + specialChar;
				lot.Uniquefier__c = lot.Product__c + '-' +lot.Name;

				if(mapProduct.get(lot.Product__c).Variable_Price__c == false)
				{
					lot.Variant_Qty__c = NULL;
				}

				if(boolIsInsert)
				{
					/// Cost and Quantity are calculated fields. Cannot be inserted directly.
					lot.Cost__c = null;
					lot.Quantity__c = null;
				}
				else
				{
					/// Cost and Quantity cannot be modified, old values are auto populated
					lot.Cost__c = oldMap.get(lot.Id).Cost__c;
					lot.Quantity__c = oldMap.get(lot.Id).Quantity__c;
				}
			}

			if(boolIsUpdate)
			{
				
				//collect the lots that have underlying payable lines; the Variant Qty of these lots must not be changed
				set<Id> setIdLotHasPayable = new set<Id>();		
				for(AcctSeed__Account_Payable_Line__c apl :
					[SELECT AcctSeedERP__Purchase_Order_Line__r.Lot__c
					 FROM AcctSeed__Account_Payable_Line__c
					 WHERE AcctSeedERP__Purchase_Order_Line__r.Lot__c IN :oldMap.keySet()
					   AND AcctSeedERP__Purchase_Order_Line__r.Lot__c != NULL])
				{
					setIdLotHasPayable.add(apl.AcctSeedERP__Purchase_Order_Line__r.Lot__c);
				}
				
				//collect the lots that have underlying moves; the Variant Qty of these lots must not be changed
				set<Id> setIdLotHasMove = new set<Id>();	
				for(Lot__c lot : 
					[SELECT Id, 
						(SELECT Id FROM Inbound_Inventory_Movements__r LIMIT 1),
						(SELECT Id FROM Manufacturing_Inventory_Movements__r LIMIT 1),
						(SELECT Id FROM Outbound_Inventory_Movements__r LIMIT 1),
						(SELECT Id FROM Purchase_Order_Inventory_Movements__r LIMIT 1)
					 FROM Lot__c 
					 WHERE Id IN :oldMap.keySet()])
				{
					if(lot.Inbound_Inventory_Movements__r.size() > 0 ||
					   lot.Manufacturing_Inventory_Movements__r.size() > 0 ||
					   lot.Outbound_Inventory_Movements__r.size() > 0 ||
					   lot.Purchase_Order_Inventory_Movements__r.size() > 0)
					{
						setIdLotHasMove.add(lot.Id);
					}
				}
				
				for(Lot__c lot : oldMap.values())
				{
					if(lot.Product__c != newMap.get(lot.Id).Product__c)
						newMap.get(lot.Id).addError('The Product of a Lot cannot be changed.  If necessary, delete and re-create the lot.');
					
					if(lot.Variant_Qty__c != newMap.get(lot.Id).Variant_Qty__c)
					{
						if(setIdLotHasPayable.contains(lot.Id))
							newMap.get(lot.Id).addError('The variant quantity of the Lot cannot be changed, because the Lot has Purchase Order Lines with underlying Account Payable Lines.');
						else if(setIdLotHasMove.contains(lot.Id))
							newMap.get(lot.Id).addError('The variant quantity of the Lot cannot be changed, because the Lot has underlying Inventory Movements.');
					}
				}			
			}
		}
		else if(!boolIsBefore && boolIsUpdate)
		{
			list<AcctSeedERP__Purchase_Order_Line__c> listPurchaseOrderLineUpdate = new list<AcctSeedERP__Purchase_Order_Line__c>();
			for(Lot__c lot : 
				[SELECT Id,
					(SELECT Id FROM Purchase_Order_Lines__r)
				 FROM Lot__c
				 WHERE Id IN : oldMap.keySet()])
			{
				listPurchaseOrderLineUpdate.addAll(lot.Purchase_Order_Lines__r);
			}
			
			if(listPurchaseOrderLineUpdate.size() > 0)
			update listPurchaseOrderLineUpdate;		
		}
	}
}