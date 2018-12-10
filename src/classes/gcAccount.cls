global without sharing class gcAccount {

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
		(map<Id,Account> oldMap,
		 map<Id,Account> newMap,
		 list<Account> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,Account>();
		if(newMap == NULL) newMap = new map<Id,Account>();
		if(listNew == NULL) listNew = new list<Account>();

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
		(map<Id,Account> oldMap,
		 map<Id,Account> newMap,
		 list<Account> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			//ensure that every account has a chargeback pricebook assigned
			Id idPricebookChargeback;
			for(Pricebook2 pb : [SELECT Id FROM Pricebook2 WHERE Uniquefier__c = 'ChargebackDefault'])
				idPricebookChargeback = pb.Id;

			for(Account a : listNew)
			{
				if(a.Chargeback_Pricebook__c == null)
				   a.Chargeback_Pricebook__c = idPricebookChargeback;

				if(boolIsInsert)
					a.Warehouse_Count__c = 0;
				else
				{
					Account oldRec = oldMap.get(a.Id);
					a.Warehouse_Count__c = oldRec.Warehouse_Count__c;
					
					a.Earliest_Billing_Activity__c = oldRec.Earliest_Billing_Activity__c;
					a.Earliest_Inventory_Activity__c = oldRec.Earliest_Inventory_Activity__c;

					a.Average_Monthly_Revenue__c = oldRec.Average_Monthly_Revenue__c;
					if(a.Average_Monthly_Revenue__c == null) 
						a.Average_Monthly_Revenue__c = 0;
				}
			}
		}

		if(!boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			set<Id> setIdAccountGeocode = new set<Id>();
			for(Account a : listNew)
			{
				//there's no need to call the Google API (and consume free calls) if the account does not have a shipping address
				Boolean boolHasAddress = false;
				if(a.ShippingStreet != null && a.ShippingCity != null && a.ShippingState != null) boolHasAddress = true;

				//there's no need to call the Google API, if the address has not been changed
				Boolean boolAddressChange = false;
				if(boolIsUpdate)
				{
					Account oldRec = oldMap.get(a.Id);

					if(a.ShippingStreet 	!= oldRec.ShippingStreet 		||
					   a.ShippingCity 		!= oldRec.ShippingCity		||
					   a.ShippingState		!= oldRec.ShippingState 		||
					   a.ShippingStateCode	!= oldRec.ShippingStateCode 	||
					   a.ShippingPostalCode != oldRec.ShippingPostalCode 	||
					   a.ShippingCountry	!= oldRec.ShippingCountry)
					boolAddressChange = true;
				}


				if(boolHasAddress && (boolIsInsert || (boolIsUpdate && boolAddressChange)))
				{
					setIdAccountGeocode.add(a.Id);
				}
			}

			if(setIdAccountGeocode.size() > 0)
			{
				if(setIdAccountGeocode.size() < 10)
					updateGeocodeFuture(setIdAccountGeocode);
				else
					Database.executeBatch(new gcUpdateGeocodeBatchable(setIdAccountGeocode),10);
			}
		}
	}

	@future (callout=true)
	global static void updateGeocodeFuture(set<Id> setIdAccount)
	{
		updateGeocode(setIdAccount);
	}

	global static void updateGeocode(set<Id> setIdAccount)
	{
		List<Account> listAccount = new list<Account>();
		List<Account> listAccountsToUpdateLatLng = new List<Account>();

		Integer intTimeout = 120000;
		//the maximum combined timeout of all callouts is 120s
		if(setIdAccount.size() > 0) intTimeout = 120000/(setIdAccount.size()+1);

		// gather account info
		for(Account a : [SELECT Id,
							ShippingCity,
							ShippingCountry,
							ShippingPostalCode,
							ShippingState,
							ShippingStreet,
							ShippingLatitude,
							ShippingLongitude 
						FROM Account 
						WHERE id IN : setIdAccount
						  AND ShippingCity != null
						  AND ShippingState != null])
		{
			listAccount.add(a);
		}

		//cycle over the accounts, and callout for each account
		for(Account a : listAccount)
		{
		    // create an address string
		    String address = '';
		    if (a.ShippingStreet != null)
		        address += a.ShippingStreet +',';
		    if (a.ShippingCity != null)
		        address += a.ShippingCity +',';
		    if (a.ShippingState != null)
		        address += a.ShippingState +',';
		    if (a.ShippingPostalCode != null)
		        address += a.ShippingPostalCode +',';
		    if (a.ShippingCountry != null)
		        address += a.ShippingCountry;

		    address = EncodingUtil.urlEncode(address, 'UTF-8');

		    // build callout
		    Http h = new Http();
		    HttpRequest req = new HttpRequest();
		    req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false');
		    req.setMethod('GET');
		    req.setTimeout(intTimeout);

		    try{
		        // callout
		        HttpResponse res = h.send(req);

		        // parse coordinates from response
		        JSONParser parser = JSON.createParser(res.getBody());
		        double lat = null;
		        double lon = null;

		        while (parser.nextToken() != null) {
		            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
		                (parser.getText() == 'location')){
		                   parser.nextToken(); // object start
		                   while (parser.nextToken() != JSONToken.END_OBJECT){
		                       String txt = parser.getText();
		                       parser.nextToken();
		                       if (txt == 'lat')
		                           lat = parser.getDoubleValue();
		                       else if (txt == 'lng')
		                           lon = parser.getDoubleValue();
		                   }
		            }
		        }


		        // update coordinates if we get back
		        if (lat != null){
		            a.ShippingLatitude = lat;
		            a.ShippingLongitude = lon;
		            listAccountsToUpdateLatLng.add(a);
		        }

		        //fabricate a 200 ms delay because
		        //the google maps API (free version) will fail if called more than 5 times per second
				Long start = datetime.now().getTime();
				while(datetime.now().getTime() < (start+200)){ 
				}	        

		    } catch (Exception e) {
		    	System.debug(e.getMessage());
		    }

		}
		Boolean triggerStatus = disableTrigger;
		disableTrigger = true;
		update listAccountsToUpdateLatLng;
		disableTrigger = triggerStatus;
	}

	@future
	public static void updateAverageRevenueFuture(set<Id> setIdAccount)
	{
		updateAverageRevenue(setIdAccount);
	}

	public static void updateAverageRevenue(set<Id> setIdAccount)
	{
		setIdAccount.remove(null);
		if(setIdAccount.isEmpty()) return;

		map<Id,Decimal> mapAccountRevenue = new map<Id,Decimal>();

		set<Id> setIdPeriod = new set<Id>();
		for(AcctSeed__Accounting_Period__c p :
			[SELECT Id
			 FROM AcctSeed__Accounting_Period__c
			 WHERE AcctSeed__End_Date__c < Today
			 ORDER BY AcctSeed__End_Date__c DESC
			 LIMIT 3])
		{
			setIdPeriod.add(p.Id);
		}

		List<AggregateResult> listAggRes = new List<AggregateResult>();
		listAggRes.addAll([SELECT AcctSeed__Account__c idAccount, sum(AcctSeed__Amount__c) amt
							FROM AcctSeed__Transaction__c
							WHERE AcctSeed__Accounting_Period__c IN :setIdPeriod
								AND AcctSeed__GL_Account__c IN 
									(SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Type__c = 'Revenue')
								AND (AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0)
								AND AcctSeed__Account__c IN :setIdAccount
							GROUP BY AcctSeed__Account__c
							HAVING sum(AcctSeed__Amount__c) < 0 OR sum(AcctSeed__Amount__c) > 0]);

		for(AggregateResult aggRes : listAggRes)
		{
			mapAccountRevenue.put((Id)aggRes.get('idAccount'), (Decimal)(aggRes.get('amt') == null ? 0 : (Decimal)aggRes.get('amt')/(-3)));
		}

		list<Account> listAccountUpdate = new list<Account>();

		for(Account a : 
			[SELECT Id, Average_Monthly_Revenue__c
			 FROM Account 
			 WHERE Id IN :setIdAccount])
		{
			Decimal amtNew = (mapAccountRevenue.get(a.Id) == null ? 0 : mapAccountRevenue.get(a.Id));

			if(a.Average_Monthly_Revenue__c == null || a.Average_Monthly_Revenue__c.setScale(2) != amtNew.setScale(2))
			{
				a.Average_Monthly_Revenue__c = amtNew.setScale(2);
				listAccountUpdate.add(a);
			}
		}

		if(!listAccountUpdate.isEmpty())
		{
			Boolean boolOld = gcAccount.disableTrigger;
			gcAccount.disableTrigger = true;
			update listAccountUpdate;
			gcAccount.disableTrigger = boolOld;
		}
	}

	public static void rollup(set<Id> setIdAccount)
	{
		list<Account> listUpdate = new list<Account>();
		for(Account a : 
			[SELECT Id, Warehouse_Count__c, (SELECT Id FROM Warehouses__r)
			 FROM Account
			 WHERE Id IN :setIdAccount])
		{
			Integer w = a.Warehouses__r.size();
			if(a.Warehouse_Count__c == null || a.Warehouse_Count__c != Decimal.valueOf(w))
			{
				a.Warehouse_Count__c = Decimal.valueof(w);
				listUpdate.add(a);
			}
		}
		if(listUpdate.size() > 0)
		{
			update listUpdate;
		}
	}

	@future
	public static void recalcEarliestBillingActivityFuture(Set<Id> setIdAccount)
	{
		recalcEarliestBillingActivity(setIdAccount);
	}

	/// Modified Earliest billing Activity
	public static void recalcEarliestBillingActivity(Set<Id> setIdAccount)
	{
		List<Account> listAccountUpdate = new List<Account>();

		for(Account a :	[SELECT Id, Earliest_Billing_Activity__c, 
				(SELECT AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeed__Date__c
				FROM AcctSeed__Transactions__r
				WHERE AcctSeed__Billing_Line__c != null
				ORDER BY AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeed__Date__c
				LIMIT 1)
			FROM Account
			WHERE Id IN :setIdAccount])
		{
			Date earliestDate = null;
			if(!a.AcctSeed__Transactions__r.isEmpty())
				earliestDate = a.AcctSeed__Transactions__r[0].AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeed__Date__c;

			if(a.Earliest_Billing_Activity__c != earliestDate)
			{
				a.Earliest_Billing_Activity__c = earliestDate;
				listAccountUpdate.add(a);
			}
		}

		if(!listAccountUpdate.isempty())
		{
			Boolean boolOld = gcAccount.disableTrigger;
			gcAccount.disableTrigger = true;
			update listAccountUpdate;
			gcAccount.disableTrigger = boolOld;
		}
	}

	@future
	public static void recalcEarliestInventoryActivityFuture(Set<Id> setIdAccount)
	{
		recalcEarliestInventoryActivity(setIdAccount);
	}

	//for earliest inventory activity
	public static void recalcEarliestInventoryActivity(Set<Id> setIdAccount)
	{
		setIdAccount.remove(null);
		Map<Id,Date> mapAccountDate = new Map<Id,Date>();
		for(AcctSeedERP__Warehouse__c w :
			[SELECT Id,	Account__c,
				(SELECT Movement_Date__c
				FROM Inventory_Movement_Cubes__r
				WHERE Movement_Date__c != null
				ORDER BY Movement_Date__c LIMIT 1)
			FROM AcctSeedERP__Warehouse__c
			WHERE Account__c IN :setIdAccount])
		{
			Date earlyDate = null;
			if(!w.Inventory_Movement_Cubes__r.isEmpty())
				earlyDate = w.Inventory_Movement_Cubes__r[0].Movement_Date__c;

			if(earlyDate == null)
			continue;

			Date mapDate = mapAccountDate.get(w.Account__c);

			if(mapDate == null || mapDate > earlyDate)
				mapAccountDate.put(w.Account__c, earlyDate);
		}

		List<Account> listAccountUpdate = new List<Account>();
		for(Account a :	[SELECT Id, Earliest_Inventory_Activity__c FROM Account WHERE Id IN :setIdAccount])
		{
			Date mapDate = mapAccountDate.get(a.Id);
			if(mapDate != a.Earliest_Inventory_Activity__c)
			{
				a.Earliest_Inventory_Activity__c = mapDate;
				listAccountUpdate.add(a);
			}
		}

		if(!listAccountUpdate.isEmpty())
		{
			Boolean boolOld = gcAccount.disableTrigger;
			gcAccount.disableTrigger = true;
			update listAccountUpdate;
			gcAccount.disableTrigger = boolOld;
		}
	}
}