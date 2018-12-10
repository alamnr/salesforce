global without sharing class gcInventoryAdjustment {

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
	
	public static void triggerHandler
		(map<Id,Inventory_Adjustment__c> oldMap,
		 map<Id,Inventory_Adjustment__c> newMap,
		 list<Inventory_Adjustment__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,Inventory_Adjustment__c>();
		if(newMap == NULL) newMap = new map<Id,Inventory_Adjustment__c>();
		if(listNew == NULL) listNew = new list<Inventory_Adjustment__c>();

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
				cascadeUpdate(newMap.keySet());
			}
			if(boolIsDelete)
			{

			}
		}
	}

	private static void updateAndValidate
		(map<Id,Inventory_Adjustment__c> oldMap,
		 map<Id,Inventory_Adjustment__c> newMap,
		 list<Inventory_Adjustment__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if (boolIsBefore) {
			Date dateEarliestOpen = gcAccountingPeriod.dateEarliestOpen();

			set<Id> setIdHasInboundMoves = new set<Id>();
			for(AcctSeedERP__Inbound_Inventory_Movement__c move :
					[SELECT Inventory_Adjustment__c
					 FROM AcctSeedERP__Inbound_Inventory_Movement__c
					 WHERE (Inventory_Adjustment__c IN : oldMap.keySet() OR  Inventory_Adjustment__c IN : newMap.keySet())
					   AND Inventory_Adjustment__c != NULL])
			{
				setIdHasInboundMoves.add(move.Inventory_Adjustment__c);
			}

			Map<Id,Id> mapProductVendor = new Map<Id,Id> ();
			if(boolIsInsert || boolIsUpdate)
			{
				for (Inventory_Adjustment__c adjust : listNew) 
				{
					if(adjust.Vendor__c != null && adjust.Product__c != null)
					{
						mapProductVendor.put(adjust.Product__c, null);
					}
				}	
				if(mapProductVendor.size() > 0){
					for(Product2 p : [SELECT Id, AcctSeedERP__Default_Vendor__c FROM Product2 WHERE Id IN :mapProductVendor.keySet()])
					{
						mapProductVendor.put(p.Id, p.AcctSeedERP__Default_Vendor__c);
					}
				}
			}

			for (Inventory_Adjustment__c adjust : listNew) 
			{
				if(boolIsInsert || boolIsUpdate)
				{
					if(adjust.Adjustment_Date__c == NULL)
						adjust.Adjustment_Date__c.addError('An adjustment date must be specified.');
					else if(adjust.Adjustment_Type__c == null)
						adjust.Adjustment_Type__c.addError('An adjustment type must be specified.');
					else if(adjust.Adjustment_Type__c == 'Supplier Invoice')
					{
						if(adjust.Vendor__c == null)
							adjust.Vendor__c.addError('For adjustments of type Supplier Invoice, a Vendor must be specified.');
						else if(adjust.Warehouse__c != null)
							adjust.Warehouse__c.addError('For adjustments of type Supplier Invoice, a Warehouse must NOT be specified.');
					}
					else if(adjust.Adjustment_Type__c == 'Value')
					{
						if(adjust.Warehouse__c != null)
							adjust.Warehouse__c.addError('For adjustments of type Value, a Warehouse must NOT be specified.');
					}
					else if(adjust.Adjustment_Type__c == 'Quantity')
					{
						if(adjust.Warehouse__c == null)
							adjust.Warehouse__c.addError('For adjustments of type Quantity, a Warehouse must be specified.');
					}
					else
					{
						adjust.Adjustment_Type__c.addError('The selected adjustment type is invalid.');
					}

					if(adjust.Vendor__c != null && adjust.Product__c != null && adjust.Vendor__c != mapProductVendor.get(adjust.Product__c))
					{
						adjust.Product__c.addError('This product does not belong to the selected Vendor.');
					}
				}				
				if (boolIsInsert) 
				{
					if(adjust.Adjustment_Date__c == NULL || adjust.Adjustment_Date__c < dateEarliestOpen) 
						adjust.addError('The Adjustment Date must be within an Accounting Period that is Open.  The earliest open date is '+ String.valueOf(dateEarliestOpen)+'.');
				}
				if (boolIsUpdate) 
				{
					if (adjust.Adjustment_Date__c != oldMap.get(adjust.Id).Adjustment_Date__c && adjust.Adjustment_Date__c < dateEarliestOpen)
						adjust.addError('The new Adjustment Date must be within an Accounting Period that is Open.');
					else if (adjust.Adjustment_Date__c != oldMap.get(adjust.id).Adjustment_Date__c && oldMap.get(adjust.Id).Adjustment_Date__c < dateEarliestOpen)
						adjust.addError('The Adjustment Date cannot be changed, because it is within an Accounting Period that is Closed.');
					else if (adjust.Warehouse__c != oldMap.get(adjust.Id).Warehouse__c && setIdHasInboundMoves.contains(adjust.Id)) 
						adjust.addError('The Warehouse cannot be changed, because the adjustment has been started. If necessary, delete all lines.');
					else if (adjust.Product__c != oldMap.get(adjust.Id).Product__c && setIdHasInboundMoves.contains(adjust.Id)) 
						adjust.addError('The Product cannot be changed, because the adjustment has been started. If necessary, delete all lines.');
					else if (adjust.Vendor__c != oldMap.get(adjust.Id).Vendor__c && setIdHasInboundMoves.contains(adjust.Id)) 
						adjust.addError('The Vendor cannot be changed, because the adjustment has been started. If necessary, delete all lines.');						
					else if (adjust.Adjustment_Type__c != oldMap.get(adjust.Id).Adjustment_Type__c && setIdHasInboundMoves.contains(adjust.Id)) 
						adjust.addError('Adjustment Type cannot be changed, because the adjustment has been started. If necessary, delete all lines.');
				}
			}

			for(Inventory_Adjustment__c adjust : oldMap.values())
			{
				if(boolIsDelete)
				{
					if(setIdHasInboundMoves.contains(adjust.Id))
						adjust.addError('The adjustment cannot be deleted, because it has already been started.  If necessary, delete all lines.');
				}
			}			
		}
	}

	private static void cascadeUpdate(set<Id> setIdAdjustment)
	{
		setIdAdjustment.remove(NULL);
		list<sObject> listChildren = new list<sObject>();
		for(AcctSeedERP__Inbound_Inventory_Movement__c move :
				[SELECT Id, 
						AcctSeedERP__Movement_Date__c, 
						Inventory_Adjustment__c,
						Inventory_Adjustment__r.Adjustment_Date__c
				 FROM AcctSeedERP__Inbound_Inventory_Movement__c				 
				 WHERE Inventory_Adjustment__c IN :setIdAdjustment])
		{	
			if(move.AcctSeedERP__Movement_Date__c != move.Inventory_Adjustment__r.Adjustment_Date__c) 
			{
				move.AcctSeedERP__Movement_Date__c = move.Inventory_Adjustment__r.Adjustment_Date__c;
				listChildren.add(move);
			}
		}

		if (listChildren.size() > 0) {
			gcInboundInventoryMovement.disableTrigger = true;
			update listChildren;
			gcInboundInventoryMovement.disableTrigger = false;
		}
	}

	public static void cascadeDeleteChildrenOfInbound(set<Id> setIdMoveIn)
	{
		list<AcctSeedERP__Inbound_Inventory_Movement__c> listMoveInUpdate = new list<AcctSeedERP__Inbound_Inventory_Movement__c>();
		list<AcctSeedERP__Outbound_Inventory_Movement__c> listMoveOutDelete = new list<AcctSeedERP__Outbound_Inventory_Movement__c>();

		for(AcctSeedERP__Inbound_Inventory_Movement__c moveIn :
			[SELECT Id, AcctSeedERP__Quantity__c, Serial_Number__c,
					(SELECT Id FROM AcctSeedERP__Outbound_Inventory_Movements__r)
			 FROM AcctSeedERP__Inbound_Inventory_Movement__c
			 WHERE Id IN :setIdMoveIn
			   AND Inventory_Adjustment__c != null])
		{
			//if the inbound move is for a serialized item, and if it has children, first update the quantity to zero.
			if(moveIn.AcctSeedERP__Outbound_Inventory_Movements__r.size() > 0)
			{
				if(moveIn.Serial_Number__c != null)
				{
					moveIn.AcctSeedERP__Quantity__c = 0;
					listMoveInUpdate.add(moveIn);
				}
				listMoveOutDelete.addAll(moveIn.AcctSeedERP__Outbound_Inventory_Movements__r);
			}
		}
		if(listMoveInUpdate.size() > 0)
			update listMoveInUpdate;
		if(listMoveOutDelete.size() > 0)
			delete listMoveOutDelete;
	}
}