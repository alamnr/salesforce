global class gcInventoryMovement_BatchUpdate implements Database.Batchable<sObject> {
	
	set<Id> setIdMove;
	string objectName;
	
	global gcInventoryMovement_BatchUpdate(set<Id> pSetIdMove, string pObjectName) {
		setIdMove = pSetIdMove;
		objectName = pObjectName;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String soql = '';
		soql += ' SELECT Id, AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.AcctSeed__Inventory_GL_Account__c ';

		if(objectName == 'AcctSeedERP__Inbound_Inventory_Movement__c')
		soql += ', AcctSeedERP__Debit_GL_Account__c';
		
		else if(objectName == 'AcctSeedERP__Outbound_Inventory_Movement__c')
		soql += ', AcctSeedERP__Credit_GL_Account__c';

		soql += ' FROM ' + objectName + ' ';

		if(setIdMove.size() > 0)
		soql += ' WHERE Id IN :setIdMove ';

		soql += ' ORDER BY AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,  AcctSeedERP__Inventory_Balance__c, Lot__c, Serial_Number__c ';

		return Database.getQueryLocator(soql);

	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		list<sObject> listMoveUpdate = new list<sObject>();
   		set<Id> setIdMoveUpdateValue = new set<Id>();
   		for(sObject move :scope)
   		{
   			if(objectName == 'AcctSeedERP__Inbound_Inventory_Movement__c' || objectName == 'AcctSeedERP__Outbound_Inventory_Movement__c')
   			{
   				Id idGLinv = (Id)(move.getSObject('AcctSeedERP__Inventory_Balance__r').getSObject('AcctSeedERP__Product__r').get('AcctSeed__Inventory_GL_Account__c'));
   				String fieldName = '';
   				if(objectName == 'AcctSeedERP__Inbound_Inventory_Movement__c')
   					fieldName = 'AcctSeedERP__Debit_GL_Account__c';
   				else
   					fieldName = 'AcctSeedERP__Credit_GL_Account__c';

   				if((Id)move.get(fieldName) == null)
   				{
   					move.put(fieldName,idGLinv);
   					listMoveUpdate.add(move);
   				}
   			}

   			setIdMoveUpdateValue.add(move.Id);
   		}

   		if(listMoveUpdate.size() > 0)
   		{
   			gcInboundInventoryMovement.disableTrigger = true;
   			gcManufacturingInventoryMovement.disableTrigger = true;
   			gcOutboundInventoryMovement.disableTrigger = true;
   			gcPurchaseOrderInventoryMovement.disableTrigger = true;
   			gcSalesOrderInventoryMovement.disableTrigger = true;
   			update listMoveUpdate;
   		}

		gcInventoryMovement.updateInventoryGlAmount(setIdMoveUpdateValue);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
}