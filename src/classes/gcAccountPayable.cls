global without sharing class gcAccountPayable {

	global static Boolean disableTrigger{
		get{
			if(disableTrigger == null) return false;
			else return disableTrigger;
		}
		set{
			if(value == null) disableTrigger = false;
			else disableTrigger = value;
		}
	}

	global static void triggerHandler
		(map<Id,AcctSeed__Account_Payable__c> oldMap,
		 map<Id,AcctSeed__Account_Payable__c> newMap,
		 list<AcctSeed__Account_Payable__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeed__Account_Payable__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeed__Account_Payable__c>();
		if(listNew == NULL) listNew = new list<AcctSeed__Account_Payable__c>();

		updateAndValidate(oldMap,newMap,listNew,boolIsBefore,boolIsInsert,boolIsUpdate,boolIsDelete);

		if(boolIsBefore)
		{
			if(boolIsInsert)
			{

			}
			if(boolIsUpdate)
			{

			}
			if(boolIsDelete)
			{

			}
		}
		else //i.e. trigger.isAfter
		{
			if(boolIsInsert)
			{

			}
			if(boolIsUpdate)
			{

			}
			if(boolIsDelete)
			{

			}
		}			
	}

	global static void updateAndValidate
		(map<Id,AcctSeed__Account_Payable__c> oldMap,
		 map<Id,AcctSeed__Account_Payable__c> newMap,
		 list<AcctSeed__Account_Payable__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{

	}
}