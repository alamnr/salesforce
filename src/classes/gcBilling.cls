global without sharing class gcBilling {

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
		(map<Id,AcctSeed__Billing__c> oldMap,
		 map<Id,AcctSeed__Billing__c> newMap,
		 list<AcctSeed__Billing__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeed__Billing__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeed__Billing__c>();
		if(listNew == NULL) listNew = new list<AcctSeed__Billing__c>();

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
		(map<Id,AcctSeed__Billing__c> oldMap,
		 map<Id,AcctSeed__Billing__c> newMap,
		 list<AcctSeed__Billing__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			//map the customer accounts, to get the default addresses
			//map the sales orders, to get the sales order shipping address
			map<Id,Account> mapAccount = new map<Id,Account>();
			map<Id,AcctSeedERP__Sales_Order__c> mapSalesOrder = new map<Id,AcctSeedERP__Sales_Order__c>();

			for(AcctSeed__Billing__c b : listNew)
			{
				mapAccount.put(b.AcctSeed__Customer__c,null);
				mapAccount.put(b.Ship_To__c,null);
				mapSalesOrder.put(b.AcctSeedERP__Sales_Order__c,null);
			}
			mapSalesOrder.remove(null);

			if(mapSalesOrder.size() > 0)
			for(AcctSeedERP__Sales_Order__c so :
				[SELECT Id,
						AcctSeedERP__Customer__c,
						AcctSeedERP__Customer__r.AcctSeed__Shipping_Contact__c,
						AcctSeedERP__Shipping_City__c,
						AcctSeedERP__Shipping_Country__c,
						AcctSeedERP__Shipping_PostalCode__c,
						AcctSeedERP__Shipping_State__c,
						AcctSeedERP__Shipping_Street__c,
						PO_Number__c
				 FROM AcctSeedERP__Sales_Order__c
				 WHERE Id IN : mapSalesOrder.keySet()])
			{
				mapSalesOrder.put(so.Id,so);
				mapAccount.put(so.AcctSeedERP__Customer__c, null);
			}
			mapAccount.remove(null);

			if(mapAccount.size() > 0)
			for(Account a : 
				[SELECT Id,
						AcctSeed__Billing_Contact__c,
						AcctSeed__Billing_Terms_Name__c,
						AcctSeed__Shipping_Contact__c,
						BillingCity,
						BillingCountry,
						BillingPostalCode,
						BillingState,
						BillingStreet,
						ShippingCity,
						ShippingCountry,
						ShippingPostalCode,
						ShippingState,
						ShippingStreet
				 FROM Account WHERE Id IN : mapAccount.keySet()])
			{
				mapAccount.put(a.Id,a);
			}

			for(AcctSeed__Billing__c b : listNew)
			{
				Account accountShipTo = new Account();

				//set the ship to account, on insert
				if(boolIsInsert)
				{
					if(b.AcctSeedERP__Sales_Order__c != null)
					{
						AcctSeedERP__Sales_Order__c so = mapSalesOrder.get(b.AcctSeedERP__Sales_Order__c);

						accountShipTo.Id 							= so.AcctSeedERP__Customer__c;
						accountShipTo.ShippingCity 					= so.AcctSeedERP__Shipping_City__c;
						accountShipTo.ShippingCountry 				= so.AcctSeedERP__Shipping_Country__c;
						accountShipTo.ShippingPostalCode 			= so.AcctSeedERP__Shipping_PostalCode__c;
						accountShipTo.ShippingStreet 				= so.AcctSeedERP__Shipping_Street__c;
						accountShipTo.AcctSeed__Shipping_Contact__c = so.AcctSeedERP__Customer__r.AcctSeed__Shipping_Contact__c;		
					}
					else if(b.Ship_To__c != null)
					{
						accountShipTo = mapAccount.get(b.Ship_To__c);
					}
					else
					{
						accountShipTo = mapAccount.get(b.AcctSeed__Customer__c);
					}
				}
				//update the ship to account, on update
				else if(boolIsUpdate)
				{
					if(b.AcctSeedERP__Sales_Order__c != null && (b.Ship_To__c == null || (b.AcctSeedERP__Sales_Order__c != oldMap.get(b.Id).AcctSeedERP__Sales_Order__c)))
					{
						AcctSeedERP__Sales_Order__c so = mapSalesOrder.get(b.AcctSeedERP__Sales_Order__c);

						accountShipTo.Id 							= so.AcctSeedERP__Customer__c;
						accountShipTo.ShippingCity 					= so.AcctSeedERP__Shipping_City__c;
						accountShipTo.ShippingCountry 				= so.AcctSeedERP__Shipping_Country__c;
						accountShipTo.ShippingPostalCode 			= so.AcctSeedERP__Shipping_PostalCode__c;
						accountShipTo.ShippingStreet 				= so.AcctSeedERP__Shipping_Street__c;
						accountShipTo.AcctSeed__Shipping_Contact__c = so.AcctSeedERP__Customer__r.AcctSeed__Shipping_Contact__c;
					}
					else if(b.Ship_To__c != null && (b.Ship_To__c != oldMap.get(b.Id).Ship_To__c))
					{
						accountShipTo = mapAccount.get(b.Ship_To__c);
					}
					else if(b.Ship_To__c == null)
					{
						accountShipTo = mapAccount.get(b.AcctSeed__Customer__c);
					}
				}

				if(accountShipTo.Id != null)
				{
					b.Ship_To__c 						= accountShipTo.Id;
					b.AcctSeed__Shipping_City__c 		= accountShipTo.ShippingCity;
					b.AcctSeed__Shipping_Country__c 	= accountShipTo.ShippingCountry;
					b.AcctSeed__Shipping_PostalCode__c 	= accountShipTo.ShippingPostalCode;
					b.AcctSeed__Shipping_State__c 		= accountShipTo.ShippingState;
					b.AcctSeed__Shipping_Street__c 		= accountShipTo.ShippingStreet;
					b.AcctSeed__Shipping_Contact__c		= accountShipTo.AcctSeed__Shipping_Contact__c;
				}

				if(boolIsInsert || (boolIsUpdate && (b.AcctSeed__Customer__c != oldMap.get(b.Id).AcctSeed__Customer__c)))
				{
					Account a = mapAccount.get(b.AcctSeed__Customer__c);

					b.AcctSeed__Billing_City__c 		= a.BillingCity;
					b.AcctSeed__Billing_Country__c 		= a.BillingCountry;
					b.AcctSeed__Billing_PostalCode__c 	= a.BillingPostalCode;
					b.AcctSeed__Billing_State__c 		= a.BillingState;
					b.AcctSeed__Billing_Street__c 		= a.BillingStreet;
					b.AcctSeed__Billing_Contact__c 		= a.AcctSeed__Billing_Contact__c;
					b.AcctSeed__Billing_Terms_Name__c   = a.AcctSeed__Billing_Terms_Name__c;
				}

				if(mapSalesOrder.containsKey(b.AcctSeedERP__Sales_Order__c) && mapSalesOrder.get(b.AcctSeedERP__Sales_Order__c).PO_Number__c != null &&
				   (boolIsInsert || (boolIsUpdate && (b.AcctSeed__PO_Number__c == null || b.AcctSeedERP__Sales_Order__c != oldMap.get(b.Id).AcctSeedERP__Sales_Order__c))))
				{
					b.AcctSeed__PO_Number__c = mapSalesOrder.get(b.AcctSeedERP__Sales_Order__c).PO_Number__c;
				}
			}
		}
		/* commented out by MR 10/13/15...using gtTransaction instead, to call gcSalesOrderLine.rollup
		if(!boolIsBefore && boolIsUpdate)
		{
			//If a Billing's posting status is changed, then the revenue roll-up on any Sales Order Lines must be refreshed.
			
			set<Id> setIdBillChangePostStatus = new set<Id>();
			set<Id> setIdSalesOrderLine = new set<Id>();
			//identify the billings whose posting status has changed
			for(AcctSeed__Billing__c b : listNew)
			{
				if(b.Posted__c != oldMap.get(b.Id).Posted__c)
				{
					setIdBillChangePostStatus.add(b.Id);
				}
			}
			//collect the sales order lines for billings whose posting status has changed
			for(AcctSeed__Billing_Line__c bl :
				[SELECT AcctSeedERP__Sales_Order_Line__c
				 FROM AcctSeed__Billing_Line__c
				 WHERE AcctSeed__Billing__c IN :setIdBillChangePostStatus
				   AND AcctSeedERP__Sales_Order_Line__c != null])
			{
				setIdSalesOrderLine.add(bl.AcctSeedERP__Sales_Order_Line__c);
			}
			setIdSalesOrderLine.remove(NULL);
			if(setIdSalesOrderLine.size() > 0)
				gcSalesOrderLine.rollup(setIdSalesOrderLine);
		}
		*/
	}
}