global with sharing class gcUpdateLotQuantityCost implements Database.Batchable<sObject>{

	global gcUpdateLotQuantityCost() {}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id FROM Lot__c';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Set<Id> setIdLot = new Set<Id>();
		for(SObject sObj : scope) {
			Lot__c lot = (Lot__c) sObj;
			setIdLot.add(lot.Id);
		}
		gcInventoryMovementCube.recalcLotQtyCost(setIdLot);
	}
	
	global void finish(Database.BatchableContext BC) 
	{

	}
}