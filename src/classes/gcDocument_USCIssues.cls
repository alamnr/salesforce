global without sharing class gcDocument_USCIssues {

	global transient List<USC_Invoice_Data__c> issues{get;set;}

 	global String USCIDString{
		get;
		set{
			USCIDString = value;
			init();			
		}
	}

	private List<String> lstUSCID {
       	get {
			if (USCIDString == null)
	            return new List<String>();
	        else
	            return USCIDString.split(',');
	    }
	}

	global gcDocument_USCIssues() {}

	global void init() {

		system.debug(lstUSCID[0]);

		issues = [SELECT Id, Name, SOP_Number__c, Invoice_Date__c, Customer_Number__c, Customer_Name__c, Item_Description__c,
				 Item_Number__c, QTY__c, Import_Unit_Cost__c, Import_Unit_Price__c, Contract_Unit_Cost__c, Contract_Unit_Price__c
				 FROM USC_Invoice_Data__c
				 WHERE Name In :lstUSCID];

	}

}