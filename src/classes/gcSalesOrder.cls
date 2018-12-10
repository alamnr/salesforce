global without sharing class gcSalesOrder {

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
		(map<Id,AcctSeedERP__Sales_Order__c> oldMap,
		 map<Id,AcctSeedERP__Sales_Order__c> newMap,
		 list<AcctSeedERP__Sales_Order__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeedERP__Sales_Order__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeedERP__Sales_Order__c>();
		if(listNew == NULL) listNew = new list<AcctSeedERP__Sales_Order__c>();
		
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
		(map<Id,AcctSeedERP__Sales_Order__c> oldMap,
		 map<Id,AcctSeedERP__Sales_Order__c> newMap,
		 list<AcctSeedERP__Sales_Order__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{

		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			Date dateEarliestOpen = gcAccountingPeriod.dateEarliestOpen();

			//map the customer accounts, to get the default price book for the vendor
			map<Id,Account> mapAccount = new map<Id,Account>();
			for(AcctSeedERP__Sales_Order__c so : listNew)
			{
				mapAccount.put(so.AcctSeedERP__Customer__c,NULL);
			}
			mapAccount.remove(NULL);
			if(mapAccount.size() > 0)
			for(Account a : 
				[SELECT Id, OwnerId, Owner.IsActive,
						Pricebook__c,
						ShippingCity,
						ShippingCountry,
						ShippingPostalCode,
						ShippingState,
						ShippingStreet
				 FROM Account WHERE Id IN : mapAccount.keySet()])
			{
				mapAccount.put(a.Id,a);
			}

			//identify default price book
			Pricebook2 priceBookDefault = new Pricebook2();
			for(Pricebook2 pb :
					[SELECT Id, Uniquefier__c
					 FROM Pricebook2
					 WHERE IsStandard = true OR (IsActive = true AND Uniquefier__c = 'SalesOrder')
					 ORDER BY CreatedDate DESC])
			{
				if(priceBookDefault.Id == NULL)
					priceBookDefault = pb;

				if(priceBookDefault.Uniquefier__c != 'SalesOrder' && pb.Uniquefier__c == 'SalesOrder')
					priceBookDefault = pb;
			}

			for(AcctSeedERP__Sales_Order__c so : listNew)
			{
				//the default owner of a Sales Order is the owner of the Customer
				if(boolIsInsert && so.AcctSeedERP__Customer__c != null && mapAccount.containsKey(so.AcctSeedERP__Customer__c) && mapAccount.get(so.AcctSeedERP__Customer__c).Owner.IsActive)
				{
					so.OwnerId = mapAccount.get(so.AcctSeedERP__Customer__c).OwnerId;
				}

				if(so.Pricebook__c == NULL)
				{
					if(mapAccount.containsKey(so.AcctSeedERP__Customer__c) && mapAccount.get(so.AcctSeedERP__Customer__c).Pricebook__c != NULL)
						so.Pricebook__c = mapAccount.get(so.AcctSeedERP__Customer__c).Pricebook__c;
					else
						so.Pricebook__c = priceBookDefault.Id;
				}

				if(so.Fill_Date__c == null) so.Fill_Date__c = date.today();
				if(dateEarliestOpen.daysBetween(so.Fill_Date__c)<0)
					so.addError('The Fill Date must be within an open period.  The earliest open date is '+dateEarliestOpen.format());

				if(mapAccount.containsKey(so.AcctSeedERP__Customer__c) && 
				   mapAccount.get(so.AcctSeedERP__Customer__c).ShippingStreet != null &&
				   (boolIsInsert || (boolIsUpdate && (so.AcctSeedERP__Shipping_Street__c == null || so.AcctSeedERP__Customer__c != oldMap.get(so.Id).AcctSeedERP__Customer__c))))
				{
					Account a = mapAccount.get(so.AcctSeedERP__Customer__c);
					so.AcctSeedERP__Shipping_City__c = a.ShippingCity;
					so.AcctSeedERP__Shipping_Country__c = a.ShippingCountry;
					so.AcctSeedERP__Shipping_PostalCode__c = a.ShippingPostalCode;
					so.AcctSeedERP__Shipping_State__c = a.ShippingState;
					so.AcctSeedERP__Shipping_Street__c = a.ShippingStreet; 
				}
			}

			if(boolIsUpdate)
			{
				set<Id> setIdSOhasMoves = new set<Id>();
				for(AcctSeedERP__Outbound_Inventory_Movement__c move :
						[SELECT Sales_Order_Line__r.AcctSeedERP__Sales_Order__c
						 FROM AcctSeedERP__Outbound_Inventory_Movement__c
						 WHERE Sales_Order_Line__r.AcctSeedERP__Sales_Order__c IN : oldMap.keySet()])
				{
					setIdSOhasMoves.add(move.Sales_Order_Line__r.AcctSeedERP__Sales_Order__c);
				}
				set<Id> setIdSOhasBilling = new set<Id>();
				for(AcctSeed__Billing_Line__c bl :
						[SELECT AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c,
								AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c
						 FROM AcctSeed__Billing_Line__c
						 WHERE AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c IN : oldMap.keySet()
						    OR AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c IN : oldMap.keySet()])
				{
					setIdSOhasBilling.add(bl.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c);
					setIdSOhasBilling.add(bl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c);
				}
				setIdSOhasBilling.remove(NULL);

				for(AcctSeedERP__Sales_Order__c so : listNew)
				{
					if(so.Pricebook__c != oldMap.get(so.Id).Pricebook__c && setIdSOhasMoves.contains(so.Id))
						so.addError('The price book for the sales order cannot be changed, because inventory has already been allocated.');
					if(so.Pricebook__c != oldMap.get(so.Id).Pricebook__c && setIdSOhasBilling.contains(so.Id))
						so.addError('The price book for the sales order cannot be changed, because a billing has already been created.');

					if(so.Warehouse__c != oldMap.get(so.Id).Warehouse__c && setIdSOhasMoves.contains(so.Id))
						so.addError('The warehouse for the sales order cannot be changed, because inventory has already been allocated.');

					if(so.Fill_Date__c != oldMap.get(so.Id).Fill_Date__c)
					{
						if(oldMap.get(so.Id).Fill_Date__c != null && dateEarliestOpen.daysBetween(oldMap.get(so.Id).Fill_Date__c) < 0)
						{
							so.addError('The Fill Date cannot be changed, because the current Fill Date is within a closed period.');
						}

						if(so.Fill_Date__c != null && dateEarliestOpen.daysBetween(so.Fill_Date__c) < 0)
							so.addError('The Fill Date cannot be changed to a date that is within a closed period.');

						if(so.Fill_Date__c != null && setIdSOhasMoves.contains(so.Id))
							so.addError('The Fill Date cannot be changed because inventory has already been allocated.');
					}


				}
			}
		}

		if(!boolIsBefore && boolIsUpdate)
		{
			//if the pricebook has changed, update child lines, to update prices.
			set<Id> setIdSalesOrderUpdateChildLines = new set<Id>();

			//if the fill date has changed, update child moves, to update move dates.
			set<Id> setIdSalesOrderUpdateChildMoves = new set<Id>();

			for(AcctSeedERP__Sales_Order__c so : listNew)
			{
				if(so.Pricebook__c != oldMap.get(so.Id).Pricebook__c)
				{
					setIdSalesOrderUpdateChildLines.add(so.Id);
				}
				if(so.Fill_Date__c != oldMap.get(so.Id).Fill_Date__c)
				{
					setIdSalesOrderUpdateChildMoves.add(so.Id);
				}
			}
			setIdSalesOrderUpdateChildLines.remove(NULL);
			setIdSalesOrderUpdateChildMoves.remove(NULL);
			if(setIdSalesOrderUpdateChildMoves.size() > 0)
			{
				update [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c WHERE AcctSeedERP__Sales_Order__c IN : setIdSalesOrderUpdateChildLines];
			}
			if(setIdSalesOrderUpdateChildMoves.size() > 0)
			{
				update [SELECT Id FROM AcctSeedERP__Outbound_Inventory_Movement__c WHERE Sales_Order_Line__r.AcctSeedERP__Sales_Order__c IN : setIdSalesOrderUpdateChildMoves];
			}
		}
	}
}