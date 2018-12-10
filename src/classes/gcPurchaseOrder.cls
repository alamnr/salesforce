global without sharing class gcPurchaseOrder {

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
		(map<Id,AcctSeedERP__Purchase_Order__c> oldMap,
		 map<Id,AcctSeedERP__Purchase_Order__c> newMap,
		 list<AcctSeedERP__Purchase_Order__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeedERP__Purchase_Order__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeedERP__Purchase_Order__c>();
		if(listNew == NULL) listNew = new list<AcctSeedERP__Purchase_Order__c>();

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
		(map<Id,AcctSeedERP__Purchase_Order__c> oldMap,
		 map<Id,AcctSeedERP__Purchase_Order__c> newMap,
		 list<AcctSeedERP__Purchase_Order__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			//map the accounts, to get the addresses, contacts, and pricebooks
			map<Id,Account> mapAccount = new map<Id,Account>();

			for(AcctSeedERP__Purchase_Order__c po : listNew)
			{
				mapAccount.put(po.AcctSeedERP__Vendor__c,null);
				mapAccount.put(po.AcctSeedERP__Shipping_Company__c, null);
			}

			mapAccount.remove(NULL);

			Id idAccountProdigy = null;

			for(Account a : 
					[SELECT Id, Name, AccountNumber,
					 AcctSeed__Billing_Contact__c,
					 AcctSeed__Shipping_Contact__c,
					 BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,
					 Pricebook__c,
					 ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry
					 FROM Account
					 WHERE Id IN :mapAccount.keySet() OR Name LIKE 'Prodigy%' OR AccountNumber = 'PHSC01'])
			{
				mapAccount.put(a.Id,a);
				if(a.AccountNumber == 'PHSC01')
					idAccountProdigy = a.Id;
				else if(idAccountProdigy == null && a.Name.startsWithIgnoreCase('Prodigy'))
					idAccountProdigy = a.Id;
			}

			//identify default price book
			Pricebook2 priceBookDefault = new Pricebook2();
			for(Pricebook2 pb :
					[SELECT Id, Uniquefier__c
					 FROM Pricebook2
					 WHERE IsStandard = true OR (IsActive = true AND Uniquefier__c = 'PurchaseOrder')
					 ORDER BY CreatedDate DESC])
			{
				if(priceBookDefault.Id == NULL)
					priceBookDefault = pb;

				if(priceBookDefault.Uniquefier__c != 'PurchaseOrder' && pb.Uniquefier__c == 'PurchaseOrder')
					priceBookDefault = pb;
			}

			for(AcctSeedERP__Purchase_Order__c po : listNew)
			{
				//auto-populate the vendor address information
				if(boolIsInsert || (boolIsUpdate && oldMap.get(po.Id).AcctSeedERP__Vendor__c != po.AcctSeedERP__Vendor__c))
				{
					if(mapAccount.containsKey(po.AcctSeedERP__Vendor__c))
					{
						Account a = mapAccount.get(po.AcctSeedERP__Vendor__c);
						
						po.AcctSeedERP__Vendor_Street__c = a.BillingStreet;
						po.AcctSeedERP__Vendor_City__c = a.BillingCity;
						if(a.BillingState != null)
							 po.AcctSeedERP__Vendor_State__c = a.BillingState.LEFT(20);
						else po.AcctSeedERP__Vendor_State__c = null;
						po.AcctSeedERP__Vendor_Postal_Code__c = a.BillingPostalCode;
						po.AcctSeedERP__Vendor_Country__c = a.BillingCountry;
						po.AcctSeedERP__Vendor_Contact__c = a.AcctSeed__Billing_Contact__c;
					}
				}

				//default the Shipping company to Prodigy
				if(boolIsInsert && po.AcctSeedERP__Shipping_Company__c == null)
				   po.AcctSeedERP__Shipping_Company__c = idAccountProdigy;

				//auto-populate the shipping address
				if(boolIsInsert || (boolIsUpdate && oldMap.get(po.Id).AcctSeedERP__Shipping_Company__c != po.AcctSeedERP__Shipping_Company__c))
				{
					if(mapAccount.containsKey(po.AcctSeedERP__Shipping_Company__c))
					{
						Account a = mapAccount.get(po.AcctSeedERP__Shipping_Company__c);

						po.AcctSeedERP__Shipping_Street__c = a.ShippingStreet;
						po.AcctSeedERP__Shipping_City__c = a.ShippingCity;
						if(a.ShippingState != null)
							 po.AcctSeedERP__Shipping_State__c = a.ShippingState.LEFT(20);
						else po.AcctSeedERP__Shipping_State__c = null;
						po.AcctSeedERP__Shipping_Postal_Code__c = a.ShippingPostalCode;
						po.AcctSeedERP__Shipping_Country__c = a.ShippingCountry;
						po.AcctSeedERP__Shipping_Contact__c = a.AcctSeed__Shipping_Contact__c;
					}
				}

				//auto-populate the price book
				if(po.Pricebook__c == NULL)
				{
					if(mapAccount.containsKey(po.AcctSeedERP__Vendor__c) && mapAccount.get(po.AcctSeedERP__Vendor__c).Pricebook__c != NULL)
						po.Pricebook__c = mapAccount.get(po.AcctSeedERP__Vendor__c).Pricebook__c;
					else
						po.Pricebook__c = priceBookDefault.Id;
				}
			}

			if(boolIsUpdate)
			{
				//do not allow the priceboook to be changed, if the PO has movements, or payments
				set<Id> setIdPOhasMoves = new set<Id>();
				for(AcctSeedERP__Purchase_Order_Inventory_Movement__c move :
						[SELECT AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c
						 FROM AcctSeedERP__Purchase_Order_Inventory_Movement__c
						 WHERE AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c IN : oldMap.keySet()])
				{
					setIdPOhasMoves.add(move.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c);
				}
				set<Id> setIdPOhasPayment = new set<Id>();
				for(AcctSeed__Account_Payable_Line__c apl :
						[SELECT AcctSeed__Account_Payable__r.AcctSeedERP__Purchase_Order__c,
								AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c
						 FROM AcctSeed__Account_Payable_Line__c
						 WHERE AcctSeed__Account_Payable__r.AcctSeedERP__Purchase_Order__c IN : oldMap.keySet()
						    OR AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c IN : oldMap.keySet()])
				{
					setIdPOhasPayment.add(apl.AcctSeed__Account_Payable__r.AcctSeedERP__Purchase_Order__c);
					setIdPOhasPayment.add(apl.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c);
				}
				setIdPOhasPayment.remove(NULL);

				for(AcctSeedERP__Purchase_Order__c po : listNew)
				{
					if(po.Pricebook__c != oldMap.get(po.Id).Pricebook__c && setIdPOhasMoves.contains(po.Id))
						po.addError('The price book for the purchase order cannot be changed, because some receiving has already occurred.');
					if(po.Pricebook__c != oldMap.get(po.Id).Pricebook__c && setIdPOhasPayment.contains(po.Id))
						po.addError('The price book for the purchase order cannot be changed, because payment has already been made.');						
				}
			}
		}

		if(!boolIsBefore && boolIsUpdate)
		{
			//if the pricebook has changed, update children to update prices.
			set<Id> setIdPOupdateChildren = new set<Id>();
			for(AcctSeedERP__Purchase_Order__c po : listNew)
			{
				if(po.Pricebook__c != oldMap.get(po.Id).Pricebook__c)
					setIdPOupdateChildren.add(po.Id);
			}
			setIdPOupdateChildren.remove(NULL);
			if(setIdPOupdateChildren.size() > 0)
			{
				update [SELECT Id FROM AcctSeedERP__Purchase_Order_Line__c WHERE AcctSeedERP__Purchase_Order__c IN : setIdPOupdateChildren];
			}
		}
	}
}