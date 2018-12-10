public without sharing class gcWarehouse {

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
		(map<Id,AcctSeedERP__Warehouse__c> oldMap,
		 map<Id,AcctSeedERP__Warehouse__c> newMap,
		 list<AcctSeedERP__Warehouse__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeedERP__Warehouse__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeedERP__Warehouse__c>();
		if(listNew == NULL) listNew = new list<AcctSeedERP__Warehouse__c>();
		
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
				createDefaultLocation(newMap.keySet());
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
	}

	public static void updateAndValidate
		(map<Id,AcctSeedERP__Warehouse__c> oldMap,
		 map<Id,AcctSeedERP__Warehouse__c> newMap,
		 list<AcctSeedERP__Warehouse__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(!boolIsBefore)
		{
			set<Id> setIdAccount = new set<Id>();
			for(AcctSeedERP__Warehouse__c w : oldMap.values())
			{
				setIdAccount.add(w.Account__c);
			}
			for(AcctSeedERP__Warehouse__c w : listNew)
			{
				setIdAccount.add(w.Account__c);
			}
			setIdAccount.remove(null);

			Boolean boolOld = gcAccount.disableTrigger;
			gcAccount.disableTrigger = true;
			gcAccount.rollup(setIdAccount);
			gcAccount.disableTrigger = boolOld;
		}
	}

	public static void createDefaultLocation(set<Id> setIdWarehouse)
	{
		setIdWarehouse.remove(null);
		list<AcctSeedERP__Location__c> listLoc = new list<AcctSeedERP__Location__c>();
		for(Id idWhs : setIdWarehouse)
		{
			listLoc.add(new AcctSeedERP__Location__c(Name = 'Default', AcctSeedERP__Warehouse__c = idWhs));
		}
		insert listLoc;
	}	
}