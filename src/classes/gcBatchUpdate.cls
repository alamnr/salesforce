global class gcBatchUpdate implements Database.Batchable<sObject> {
	
	String query;
	
	global gcBatchUpdate(String pQuery) {
		query = pQuery;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}