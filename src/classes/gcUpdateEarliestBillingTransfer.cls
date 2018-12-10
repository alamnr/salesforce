global with sharing class gcUpdateEarliestBillingTransfer implements Database.Batchable<sObject>{

	global gcUpdateEarliestBillingTransfer() {}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id FROM Account';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Set<Id> setIdAccount = new Set<Id>();
		for(SObject sObj : scope) {
			Account a = (Account) sObj;
			setIdAccount.add(a.Id);
		}
		gcAccount.recalcEarliestBillingActivity(setIdAccount);
		gcAccount.recalcEarliestInventoryActivity(setIdAccount);
	}
	
	global void finish(Database.BatchableContext BC) 
	{

	}
}