global without sharing class gcProduct {

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

	global static Boolean disableCostUpdate{
		get{
			if(disableCostUpdate == null) return false;
			else return disableCostUpdate;
		}
		set{
			if(value == null) disableCostUpdate = false;
			else disableCostUpdate = value;
		}
	}

	global static void triggerHandler
		(map<Id,Product2> oldMap,
		 map<Id,Product2> newMap,
		 list<Product2> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,Product2>();
		if(newMap == NULL) newMap = new map<Id,Product2>();
		if(listNew == NULL) listNew = new list<Product2>();

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
		(map<Id,Product2> oldMap,
		 map<Id,Product2> newMap,
		 list<Product2> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			settings(listNew);
			for(Product2 p : listNew)
			{
				if(p.AcctSeed__Inventory_Product__c) p.AcctSeed__Unit_Cost__c = null; //the managed field must be nullified, in order for the average costing logic to reliably take precedence.
				if(boolIsInsert)
				{
					p.IsActive = true;
					/// Cost Quantity and unit Cost cannot be inserted
					p.Cost__c = null;
					p.Quantity__c = null;
				}
				else
				{
					/// Cost Quantity and unit Cost cannot be updated. These are auto populated
					p.Cost__c = oldMap.get(p.Id).Cost__c;
					p.Quantity__c = oldMap.get(p.Id).Quantity__c;
				}
			}
		}
	}

	global static void settings(list<Product2> listNew)
	{
		Id idGLrev;
		Id idGLexp;
		Id idGLinv;
		for(AcctSeed__GL_Account__c gl : [SELECT Id, Uniquefier__c FROM AcctSeed__GL_Account__c WHERE Uniquefier__c != null])
		{
			if(gl.Uniquefier__c == 'Inventory')
				idGLinv = gl.Id;
			else if (gl.Uniquefier__c == 'COGS')
				idGLexp = gl.Id;
			else if (gl.Uniquefier__c == 'ProductRevenue')
				idGLrev = gl.Id;
		}

		map<String,Id> mapGLV3 = new map<String,Id>();
		for(AcctSeed__Accounting_Variable__c glv : [SELECT Id, Uniquefier__c FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 3'])
			mapGLV3.put(glv.Uniquefier__c,glv.Id);

		for(Product2 p : listNew)
		{
			if(p.AcctSeed__Inventory_Product__c)
			{
				p.Lot_Tracked__c = true;
				p.AcctSeed__Inventory_Type__c = 'Purchased';
				p.AcctSeed__Expense_GL_Account__c = idGLexp;
				p.AcctSeed__Inventory_GL_Account__c = idGLinv;
				p.AcctSeed__Revenue_GL_Account__c = idGLrev;
			}
			else
			{
				p.Lot_Tracked__c = false;
				p.AcctSeed__Inventory_Type__c = null;
				if(p.AcctSeed__Expense_GL_Account__c == null) p.AcctSeed__Expense_GL_Account__c = idGLexp;
				if(p.AcctSeed__Revenue_GL_Account__c == null) p.AcctSeed__Revenue_GL_Account__c = idGLrev;
				p.AcctSeed__Inventory_GL_Account__c = null;
			}

			if(p.Family == 'Distribution' && mapGLV3.containsKey('DISTRIBUTION'))
			   p.AcctSeed__GL_Account_Variable_3__c = mapGLV3.get('DISTRIBUTION');
			else if(p.Family != null && p.Family.containsIgnoreCase('compound') && mapGLV3.containsKey('COMPOUNDING'))
			   p.AcctSeed__GL_Account_Variable_3__c = mapGLV3.get('COMPOUNDING');
		}	
	}
}