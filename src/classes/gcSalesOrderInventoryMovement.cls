global without sharing class gcSalesOrderInventoryMovement {

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
		(map<Id,AcctSeedERP__Sales_Order_Inventory_Movement__c> oldMap,
		 map<Id,AcctSeedERP__Sales_Order_Inventory_Movement__c> newMap,
		 list<AcctSeedERP__Sales_Order_Inventory_Movement__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeedERP__Sales_Order_Inventory_Movement__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeedERP__Sales_Order_Inventory_Movement__c>();
		if(listNew == NULL) listNew = new list<AcctSeedERP__Sales_Order_Inventory_Movement__c>();

		gcSalesOrder.disableTrigger = true;
		gcSalesOrderLine.disableTrigger = true;
		
		updateAndValidate(oldMap,newMap,listNew,boolIsBefore,boolIsInsert,boolIsUpdate,boolIsDelete);
		gcInventoryMovement.triggerHandler(oldMap, newMap, listNew, boolIsBefore, boolIsInsert, boolIsUpdate, boolIsDelete);

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

	private static void updateAndValidate
		(map<Id,AcctSeedERP__Sales_Order_Inventory_Movement__c> oldMap,
		 map<Id,AcctSeedERP__Sales_Order_Inventory_Movement__c> newMap,
		 list<AcctSeedERP__Sales_Order_Inventory_Movement__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			if(boolIsInsert || boolIsUpdate)
			{
				for(AcctSeedERP__Sales_Order_Inventory_Movement__c move :listNew)
				{
					move.addError('Sales Order Inventory Movements are not compatible with the current suite of inventory customizations.');
				}				
			}
			else
			{
				for(AcctSeedERP__Sales_Order_Inventory_Movement__c move :oldMap.values())
				{
					move.addError('Sales Order Inventory Movements are not compatible with the current suite of inventory customizations.');
				}				
			}
		}		
	}
}