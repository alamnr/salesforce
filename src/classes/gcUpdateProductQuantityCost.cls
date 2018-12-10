global with sharing class gcUpdateProductQuantityCost implements Database.Batchable<sObject>{

	global gcUpdateProductQuantityCost() {}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id FROM Product2';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Set<Id> setIdProduct = new Set<Id>();
		for(SObject sObj : scope) {
			Product2 product = (Product2) sObj;
			setIdProduct.add(product.Id);
		}
		gcInventoryMovementCube.recalcProductQtyCost(setIdProduct);
	}
	
	global void finish(Database.BatchableContext BC) 
	{

	}
}