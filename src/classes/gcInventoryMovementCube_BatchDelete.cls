public without sharing class gcInventoryMovementCube_BatchDelete implements Database.Batchable<sObject>{

	/*
	This batch deletes all of the Inventory Movement Cubes for a set of periods, possibly filtered by movement type.
	*/
	private String strType;
	private Date dateFrom;
	private Date dateThru;
	
	public gcInventoryMovementCube_BatchDelete(Date pDateFrom, Date pDateThru, String pStrType)
	{
		dateFrom = pDateFrom;
		dateThru = pDateThru;
		strType = pStrType;
	}
		
	public Database.QueryLocator start(Database.BatchableContext BC)
	{	
		String soql = '';
		if(dateFrom != null)
		{
			if(soql != '')
				soql += ' AND ';
			soql += ' Movement_Date__c >= :dateFrom ';
		}
		if(dateThru != null)
		{
			if(soql != '')
				soql += ' AND ';
			soql += ' Movement_Date__c <= :dateThru ';
		}
		if(strType != null)
		{
			if(soql != '')
				soql += ' AND ';
			soql += ' Movement_Type__c = :strType ';
		}

		if(soql != '')
			soql = ' WHERE '+soql;

		soql = ' SELECT Id FROM Inventory_Movement_Cube__c ' + soql;

		soql = soql + ' ORDER BY Product__r.Name, Warehouse__r.Name, Location__r.Name, Lot__r.Name, Serial_Number__r.Name, Movement_Date__c ';

		return Database.getQueryLocator(soql);
	}
	
	public void execute(Database.BatchableContext BC, list<Inventory_Movement_Cube__c> scope)
	{  	
		gcInventoryMovementCube.disableTrigger = true;		
		delete scope;
	}
	
	public void finish(Database.BatchableContext BC)
	{

	}
}