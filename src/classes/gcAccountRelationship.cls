global without sharing class gcAccountRelationship {

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
		(map<Id,Account_Relationship__c> oldMap,
		 map<Id,Account_Relationship__c> newMap,
		 list<Account_Relationship__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,Account_Relationship__c>();
		if(newMap == NULL) newMap = new map<Id,Account_Relationship__c>();
		if(listNew == NULL) listNew = new list<Account_Relationship__c>();

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
		(map<Id,Account_Relationship__c> oldMap,
		 map<Id,Account_Relationship__c> newMap,
		 list<Account_Relationship__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			for(Account_Relationship__c ar : listNew)
			{
				if(ar.Customer__c == null)
					ar.addError('The Customer cannot be blank.');
				if(ar.Vendor__c == null)
					ar.addError('The Vendor cannot be blank.');
				ar.Uniquefier__c = ar.Customer__c + '-' +ar.Vendor__c;		
			}
		}
	}
}