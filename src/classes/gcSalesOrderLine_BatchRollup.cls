public without sharing class gcSalesOrderLine_BatchRollup implements Database.Batchable<sObject>{
	
	private Date dateFrom;
	private Date dateThru;
	
	public gcSalesOrderLine_BatchRollup(Date pDateFrom, Date pDateThru)
	{
		dateFrom = pDateFrom;
		dateThru = pDateThru;
	}
		
	public Database.QueryLocator start(Database.BatchableContext BC)
	{	
		String soql = '';
		if(dateFrom != null)
		{
			if(soql != '')
				soql += ' AND ';
			soql += ' AcctSeedERP__Sales_Order__r.Fill_Date__c >= :dateFrom ';
		}
		if(dateThru != null)
		{
			if(soql != '')
				soql += ' AND ';
			soql += ' AcctSeedERP__Sales_Order__r.Fill_Date__c <= :dateThru ';
		}

		if(soql != '')
			soql = ' WHERE '+soql;

		soql = 'SELECT Id FROM AcctSeedERP__Sales_Order_Line__c ' + soql;
		soql = soql + ' ORDER BY AcctSeedERP__Sales_Order__r.Fill_Date__c, AcctSeedERP__Sales_Order__c ';

		return Database.getQueryLocator(soql);
	}
	
	public void execute(Database.BatchableContext BC, list<sObject> scope)
	{
		set<Id> setIdSalesOrderLine = new set<Id>();
		for(sObject sol : scope)
		{
			setIdSalesOrderLine.add(sol.Id);
		}
		setIdSalesOrderLine.remove(null);
		if(setIdSalesOrderLine.size() > 0)
			gcSalesOrderLine.rollup(setIdSalesOrderLine);
	}
	
	public void finish(Database.BatchableContext BC){}
}