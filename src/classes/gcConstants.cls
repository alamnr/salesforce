public with sharing class gcConstants {

	private static Id idUSCAccount;
	private static Id idUSCWarehouse;
	private static Id idNetCostPricebook;
	private static Id idStandardPriceBook;

	public static id fetchIdUSCAccount(){
		if(idUSCAccount == null) 
			idUSCAccount = [SELECT Id FROM Account WHERE USC_Account_Number__c = 'USCOM01' ORDER BY CreatedDate LIMIT 1][0].Id;
		return idUSCAccount; 
	}

	public static id fetchIdUSCWarehouse(){
		if(idUSCWarehouse == null) 
			idUSCWarehouse = [SELECT Id FROM AcctSeedERP__Warehouse__c WHERE Uniquefier__c = 'USC_ProfitShare' ORDER BY CreatedDate LIMIT 1][0].Id;		
		return idUSCWarehouse;
	}

	public static id fetchIdNetCostPricebook(){
		if(idNetCostPricebook == null) 
			idNetCostPricebook = [SELECT Id, Uniquefier__c FROM Pricebook2 WHERE Uniquefier__c = 'MarginBasis' ORDER BY CreatedDate DESC][0].Id;
		return idNetCostPricebook;
	}

	public static id fetchIdStandardPriceBook(){
		if(idStandardPriceBook == null) 
			idStandardPriceBook = [SELECT Id FROM Pricebook2 WHERE isStandard=true LIMIT 1][0].Id;
		return idStandardPriceBook;
	}
	
}