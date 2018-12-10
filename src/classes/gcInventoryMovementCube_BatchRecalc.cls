public without sharing class gcInventoryMovementCube_BatchRecalc implements Database.Batchable<sObject>{
	
	/*
	This batch recalculates and updates the Inventory Movement Cubes for a set of periods.
	It is typically called AFTER deleting all of the Inventory Movement Cubes for the periods, to ensure that it's starting from a "blank slate".
	*/
	private String strType;
	private Date dateFrom;
	private Date dateThru;
	
	public gcInventoryMovementCube_BatchRecalc(Date pDateFrom, Date pDateThru, String pStrType)
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
			soql += ' AcctSeedERP__Movement_Date__c >= :dateFrom ';
		}
		if(dateThru != null)
		{
			if(soql != '')
				soql += ' AND ';
			soql += ' AcctSeedERP__Movement_Date__c <= :dateThru ';
		}

		if(soql != '')
			soql = ' WHERE '+soql;

		soql = ' SELECT Id, AcctSeedERP__Inventory_Balance__c, AcctSeedERP__Movement_Date__c, Lot__c, Serial_Number__c FROM ' + strType + soql;
		soql = soql + ' ORDER BY AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c, AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__c, AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Location__c, Lot__c, Serial_Number__c, AcctSeedERP__Movement_Date__c ';

		return Database.getQueryLocator(soql);
	}
	
	public void execute(Database.BatchableContext BC, list<sObject> scope)
	{
		gcInventoryMovementCube.allowDML = true;		
		gcInventoryMovementCube.recalc(scope);
	}
	
	public void finish(Database.BatchableContext BC){}
}