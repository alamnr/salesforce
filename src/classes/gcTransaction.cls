public with sharing class gcTransaction {

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
		(map<Id,AcctSeed__Transaction__c> oldMap,
		 map<Id,AcctSeed__Transaction__c> newMap,
		 list<AcctSeed__Transaction__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeed__Transaction__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeed__Transaction__c>();
		if(listNew == NULL) listNew = new list<AcctSeed__Transaction__c>();

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

	public static void updateAndValidate
		(map<Id,AcctSeed__Transaction__c> oldMap,
		 map<Id,AcctSeed__Transaction__c> newMap,
		 list<AcctSeed__Transaction__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore)
		{
			List<AcctSeed__Transaction__c> listTxn = new List<AcctSeed__Transaction__c>();
			Set<Id> setIdAccount = new Set<Id>();
			listTxn.addAll(listNew);
			listTxn.addAll(oldMap.values());
			for(AcctSeed__Transaction__c txn : listTxn)
			{
				if(txn.AcctSeed__Account__c != null && txn.AcctSeed__Billing_Line__c != null)
					setIdAccount.add(txn.AcctSeed__Account__c);
			}
			if(!setIdAccount.isEmpty())
				gcAccount.recalcEarliestBillingActivityFuture(setIdAccount);
		}

		if(!boolIsBefore)
		{
			set<Id> setIdSalesOrderLine = new set<Id>();
			for(AcctSeed__Transaction__c txn :
				[SELECT AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__c, 
						AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__c 
				 FROM AcctSeed__Transaction__c
				 WHERE (Id IN :oldMap.values() OR Id IN :newMap.values())
				   AND (AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__c != null OR
				   		AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__c != null)
				   AND (AcctSeed__GL_Account__r.AcctSeed__Type__c IN ('Revenue','Expense'))
				 ALL ROWS])
			{
				if(txn.AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__c != null)
				setIdSalesOrderLine.add(txn.AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__c);
				if(txn.AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__c != null)
				setIdSalesOrderLine.add(txn.AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__c);
			}

			setIdSalesOrderLine.remove(null);
			if(setIdSalesOrderLine.size() > 0)
			gcSalesOrderLine.rollup(setIdSalesOrderLine);

			////////////////////// Update average monthly revenue
			List<AcctSeed__Transaction__c> listTxn = new List<AcctSeed__Transaction__c>();
			listTxn.addAll(listNew);
			listTxn.addAll(oldMap.values());
		
			rollupAccountRevenue(listTxn);
		}
	}

	private static void rollupAccountRevenue(list<AcctSeed__Transaction__c> listTxn)
	{
		Set<Id> setIdAccount = new Set<Id>();
		for(AcctSeed__Transaction__c txn : listTxn)
		{
			if(txn.AcctSeed__Account__c != null)
				setIdAccount.add(txn.AcctSeed__Account__c);
		}
		if(!setIdAccount.isEmpty())
			gcAccount.updateAverageRevenueFuture(setIdAccount);
	}
}