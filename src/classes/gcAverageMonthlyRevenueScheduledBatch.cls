global with sharing class gcAverageMonthlyRevenueScheduledBatch implements Schedulable, Database.Batchable<sObject>{

	global gcAverageMonthlyRevenueScheduledBatch() {}
	
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
		gcAccount.updateAverageRevenue(setIdAccount);
	}
	
	global void execute(SchedulableContext sc) {
		gcAverageMonthlyRevenueScheduledBatch b = new gcAverageMonthlyRevenueScheduledBatch();
		database.executeBatch(b, 20);
	}
	
	global void finish(Database.BatchableContext BC) 
	{

	}
}