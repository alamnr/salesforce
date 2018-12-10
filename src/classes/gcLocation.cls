public without sharing class gcLocation {

	public static Boolean disableTrigger{
		get{
			if(disableTrigger == null) return false;
			else return disableTrigger;
		}
		set{
			if(value == null) disableTrigger = false;
			else disableTrigger = value;
		}
	}

	public static void triggerHandler
		(map<Id,AcctSeedERP__Location__c> oldMap,
		 map<Id,AcctSeedERP__Location__c> newMap,
		 list<AcctSeedERP__Location__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeedERP__Location__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeedERP__Location__c>();
		if(listNew == NULL) listNew = new list<AcctSeedERP__Location__c>();
		
		updateAndValidate(oldMap,newMap,listNew,boolIsBefore,boolIsInsert,boolIsUpdate,boolIsDelete);

		if(boolIsBefore)
		{
			if(boolIsInsert)
			{
				return;
			}
			if(boolIsUpdate)
			{
				return;
			}
			if(boolIsDelete)
			{
				return;
			}
		}
		else //i.e. trigger.isAfter
		{
			if(boolIsInsert)
			{
				maximumOneLocation(listNew);
				return;
			}
			if(boolIsUpdate)
			{
				return;
			}
			if(boolIsDelete)
			{
				noDeleteDefaultLocation(oldMap.values());
				return;
			}
		}			
	}

	public static void updateAndValidate
		(map<Id,AcctSeedERP__Location__c> oldMap,
		 map<Id,AcctSeedERP__Location__c> newMap,
		 list<AcctSeedERP__Location__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{

	}

	public static void maximumOneLocation(list<AcctSeedERP__Location__c> listNew)
	{
		map<Id,AcctSeedERP__Warehouse__c> mapWhs = new map<Id,AcctSeedERP__Warehouse__c>();
		for(AcctSeedERP__Location__c loc : listNew)
		{
			mapWhs.put(loc.AcctSeedERP__Warehouse__c, null);
		}
		for(AcctSeedERP__Warehouse__c whs :
			[SELECT Id, (SELECT Id FROM AcctSeedERP__Locations__r)
			 FROM AcctSeedERP__Warehouse__c
			 WHERE Id IN :mapWhs.keySet()])
		{
			mapWhs.put(whs.Id,whs);
		}
		for(AcctSeedERP__Location__c loc : listNew)
		{
			if(mapWhs.get(loc.AcctSeedERP__Warehouse__c).AcctSeedERP__Locations__r.size() > 1)
				loc.addError('The Location cannot be inserted, because every Warehouse must have only one Location.');
		}
	}

	public static void noDeleteDefaultLocation(list<AcctSeedERP__Location__c> listOld)
	{
		map<Id,AcctSeedERP__Warehouse__c> mapWhs = new map<Id,AcctSeedERP__Warehouse__c>();
		for(AcctSeedERP__Location__c loc : listOld)
		{
			mapWhs.put(loc.AcctSeedERP__Warehouse__c, null);
		}
		for(AcctSeedERP__Warehouse__c whs :
			[SELECT Id, (SELECT Id FROM AcctSeedERP__Locations__r)
			 FROM AcctSeedERP__Warehouse__c
			 WHERE Id IN :mapWhs.keySet()])
		{
			mapWhs.put(whs.Id,whs);
		}
		for(AcctSeedERP__Location__c loc : listOld)
		{
			if(mapWhs.get(loc.AcctSeedERP__Warehouse__c).AcctSeedERP__Locations__r.size() == 0)
				loc.addError('The Location cannot be deleted, because every Warehouse must have at least one Location.');
		}
	}	
}