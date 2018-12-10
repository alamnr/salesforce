global without sharing class gcInventoryMovementCube_BatchRefresh implements Database.Batchable<sObject>{
	
	private String strMode;
	
	global gcInventoryMovementCube_BatchRefresh(String pStrMode)
	{
		strMode = pStrMode;
	}
		
	global Database.QueryLocator start(Database.BatchableContext BC)
	{	
		String soql = '';
		if(strMode == 'AcctSeedERP__Inbound_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Manufacturing_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Outbound_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Purchase_Order_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Sales_Order_Inventory_Movement__c')
		{
			soql = ' SELECT Id, AcctSeedERP__Inventory_Balance__c, AcctSeedERP__Movement_Date__c, Lot__c, Serial_Number__c ';
			soql = soql + ' FROM ' + strMode;
			soql = soql + ' ORDER BY AcctSeedERP__Movement_Date__c DESC, AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c, Lot__c, Serial_Number__c ';
		}
		else if(strMode == 'deleteAll')
		{
			soql = ' SELECT Id FROM Inventory_Movement_Cube__c ORDER BY Movement_Date__c DESC ';
		}
		else
		{
			soql = ' SELECT Id FROM Account LIMIT 1 ';
		}

		return Database.getQueryLocator(soql);
	}
	
	global void execute(Database.BatchableContext BC, list<sObject> scope)
	{
		gcInventoryMovementCube.allowDML = true;
		if(strMode == 'AcctSeedERP__Inbound_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Manufacturing_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Outbound_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Purchase_Order_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Sales_Order_Inventory_Movement__c')
		{
			gcInventoryMovementCube.recalc(scope);
		}
		else if(strMode == 'deleteAll')
		{
			gcInventoryMovementCube.disableTrigger = true;
			delete scope;
		}
		else
		{
			//invalid mode...do nothing
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		if(strMode == 'AcctSeedERP__Inbound_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Manufacturing_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Outbound_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Purchase_Order_Inventory_Movement__c' ||
		   strMode == 'AcctSeedERP__Sales_Order_Inventory_Movement__c')
		{
			//don't do anything
		}
		else if(strMode == 'deleteAll')
		{
	    	gcInventoryMovement_BatchUpdate_GlAmount c;
	    	c = new gcInventoryMovement_BatchUpdate_GlAmount('AcctSeedERP__Inbound_Inventory_Movement__c');
			Database.executeBatch(c,2000);

	    	c = new gcInventoryMovement_BatchUpdate_GlAmount('AcctSeedERP__Manufacturing_Inventory_Movement__c');
			Database.executeBatch(c,2000);	

	    	c = new gcInventoryMovement_BatchUpdate_GlAmount('AcctSeedERP__Outbound_Inventory_Movement__c');
			Database.executeBatch(c,2000);	

	    	c = new gcInventoryMovement_BatchUpdate_GlAmount('AcctSeedERP__Purchase_Order_Inventory_Movement__c');
			Database.executeBatch(c,2000);

	    	c = new gcInventoryMovement_BatchUpdate_GlAmount('AcctSeedERP__Sales_Order_Inventory_Movement__c');
			Database.executeBatch(c,2000);			
		}		
	}
}