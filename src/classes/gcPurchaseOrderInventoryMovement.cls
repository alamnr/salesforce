global without sharing class gcPurchaseOrderInventoryMovement {

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
		(map<Id,AcctSeedERP__Purchase_Order_Inventory_Movement__c> oldMap,
		 map<Id,AcctSeedERP__Purchase_Order_Inventory_Movement__c> newMap,
		 list<AcctSeedERP__Purchase_Order_Inventory_Movement__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeedERP__Purchase_Order_Inventory_Movement__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeedERP__Purchase_Order_Inventory_Movement__c>();
		if(listNew == NULL) listNew = new list<AcctSeedERP__Purchase_Order_Inventory_Movement__c>();

		Boolean boolDisableGrandParent = gcPurchaseOrder.disableTrigger;
		Boolean boolDisableParent = gcPurchaseOrderLine.disableTrigger;
		gcPurchaseOrder.disableTrigger = true;
		gcPurchaseOrderLine.disableTrigger = true;

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
		
		gcPurchaseOrder.disableTrigger = boolDisableGrandParent;
		gcPurchaseOrderLine.disableTrigger = boolDisableParent;
	}

	private static void updateAndValidate
		(map<Id,AcctSeedERP__Purchase_Order_Inventory_Movement__c> oldMap,
		 map<Id,AcctSeedERP__Purchase_Order_Inventory_Movement__c> newMap,
		 list<AcctSeedERP__Purchase_Order_Inventory_Movement__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			//collect and map the parent purchase order lines
			map<Id,AcctSeedERP__Purchase_Order_Line__c> mapPurchLine = new map<Id,AcctSeedERP__Purchase_Order_Line__c>();		
			for(AcctSeedERP__Purchase_Order_Inventory_Movement__c move : listNew)
			{
				mapPurchLine.put(move.AcctSeedERP__Purchase_Order_Line__c, NULL);
			}

			for(AcctSeedERP__Purchase_Order_Line__c pol: 
					[SELECT Id, 
					 AcctSeedERP__GL_Account_Variable_1__c,
					 AcctSeedERP__GL_Account_Variable_2__c,
					 AcctSeedERP__GL_Account_Variable_3__c,
					 AcctSeedERP__GL_Account_Variable_4__c,
					 AcctSeedERP__Project__c,
					 AcctSeedERP__Project_Task__c,
					 AcctSeedERP__Unit_Price__c,
					 Lot__c
					 FROM AcctSeedERP__Purchase_Order_Line__c
					 WHERE Id IN : mapPurchLine.keySet()])
			{
				mapPurchLine.put(pol.Id, pol);
			}

			for(AcctSeedERP__Purchase_Order_Inventory_Movement__c move : listNew)
			{
	//SET FIELD VALUES
				//set field values on the purchase movement to match field values on the parent purchase order line
				move.AcctSeedERP__GL_Account_Variable_1__c  = mapPurchLine.get(move.AcctSeedERP__Purchase_Order_Line__c).AcctSeedERP__GL_Account_Variable_1__c;
				move.AcctSeedERP__GL_Account_Variable_2__c  = mapPurchLine.get(move.AcctSeedERP__Purchase_Order_Line__c).AcctSeedERP__GL_Account_Variable_2__c;
				move.AcctSeedERP__GL_Account_Variable_3__c  = mapPurchLine.get(move.AcctSeedERP__Purchase_Order_Line__c).AcctSeedERP__GL_Account_Variable_3__c;
				move.AcctSeedERP__GL_Account_Variable_4__c  = mapPurchLine.get(move.AcctSeedERP__Purchase_Order_Line__c).AcctSeedERP__GL_Account_Variable_4__c;
				move.AcctSeedERP__Project__c 				= mapPurchLine.get(move.AcctSeedERP__Purchase_Order_Line__c).AcctSeedERP__Project__c;
				move.AcctSeedERP__Project_Task__c 			= mapPurchLine.get(move.AcctSeedERP__Purchase_Order_Line__c).AcctSeedERP__Project_Task__c;
				move.AcctSeedERP__Unit_Cost__c 				= mapPurchLine.get(move.AcctSeedERP__Purchase_Order_Line__c).AcctSeedERP__Unit_Price__c;
				move.Lot__c = mapPurchLine.get(move.AcctSeedERP__Purchase_Order_Line__c).Lot__c;

	//VALIDATE
				if(boolIsUpdate && move.Account_Payable_Line__c != null)
					move.addError('The Purchase Order Inventory Movement cannot be modified because it looks up to a Payable Line.  If necessary, delete the Payable Line. '+move.Name);	
			}
		}
		else if(boolIsBefore && boolIsDelete)
		{
			for(AcctSeedERP__Purchase_Order_Inventory_Movement__c move : oldMap.values())
			{
				if(move.Account_Payable_Line__c != null)
					move.addError('The Purchase Order Inventory Movement cannot be deleted because it looks up to a Payable Line.  If necessary, delete the Payable Line. '+move.Name);
			}
		}
	}
}