global with sharing class gcUpdateGeocodeBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts{

	set<Id> setIdAccountThisBatchExecute{get;set;}
	
	global gcUpdateGeocodeBatchable(set<Id> pSetIdAccount)
	{
		setIdAccountThisBatchExecute = pSetIdAccount;
	}
		
	global Database.QueryLocator start(Database.BatchableContext BC)
	{	
		String queryString  = ' SELECT Id FROM Account WHERE Id IN :setIdAccountThisBatchExecute ';

		return Database.getQueryLocator(queryString);
	}
	
	global void execute(Database.BatchableContext BC, list<sObject> scope)
	{
		set<Id> setIdAccountThisTxn = new set<Id>();
		for(sObject obj : scope)
		{
			setIdAccountThisTxn.add(obj.Id);
		}
		gcAccount.updateGeocode(setIdAccountThisTxn);
	}
	
	global void finish(Database.BatchableContext BC){}
}