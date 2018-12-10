global without sharing class cGMBL_PriceBookEntry {

	global cGMBL_PriceBookEntry(ApexPages.StandardController c){}

	@RemoteAction
	global static string recalcMarkup()
	{
		/*
		Salesforce does not allow triggers on the Price Book Entry Object.
		There is automation that we wish to implement on Price Book Entries.
		This method is called by UI actions.
		The functionality that we wish to implement is:
		- Ensure that the PriceBookEntry.UnitPrice is correct, for products whose price is determined by Mark-up.
		- Ensure that there are no Price Book Entries for which PriceBookEntry.UseStandardPrice is TRUE.
		- Ensure that there are no Price Book Entries for which PriceBookEntry.isActive is FALSE.
		*/
		//collect the basis prices
		map<Id,PriceBookEntry> mapBasisPrice = new map<Id,PriceBookEntry>();
		for(PriceBookEntry pbe :
				[SELECT Id, Product2Id, UnitPrice
				 FROM PriceBookEntry
				 WHERE PriceBook2.Uniquefier__c = 'MarginBasis'
				   AND UnitPrice != NULL])
		{
			mapBasisPrice.put(pbe.Product2Id,pbe);
		}
		mapBasisPrice.remove(NULL);

		list<PriceBookEntry> listPBEupdate = new list<PriceBookEntry>();
		for(PriceBookEntry pbe :
			[SELECT Id, Margin__c, Product2Id, UnitPrice, UseStandardPrice, IsActive, PriceBook2.Uniquefier__c, Effective_Date__c
			 FROM PriceBookEntry
			 WHERE (Product2Id IN : mapBasisPrice.keySet()
			   AND Margin__c != NULL
			   AND Margin__c != 100
			   AND PriceBook2.Uniquefier__c != 'MarginBasis'
			   AND Product2Id != NULL)
			    OR UseStandardPrice = true
			    OR IsActive = false
			    OR Effective_Date__c = null
			   ])
		{
			Boolean boolUpdate = false;

			//ensure that UseStandardPrice = true
			if(pbe.UseStandardPrice)
			{
				pbe.UseStandardPrice = false;
				boolUpdate = true;
			}

			//ensure that IsActive = true
			if(!pbe.IsActive)
			{
				pbe.IsActive = true;
				boolUpdate = true;
			}

			//ensure that the effective date is not null
			if(pbe.Effective_Date__c == null)
			{
				pbe.Effective_Date__c = date.newInstance(2012,1,1);
				boolUpdate = true;
			}

			//ensure correct margin+ pricing
			if(mapBasisPrice.containsKey(pbe.Product2Id) &&
				pbe.Margin__c != null &&
				pbe.Margin__c != 100 &&
				pbe.PriceBook2.Uniquefier__c != 'MarginBasis' &&
				pbe.Product2Id != null)
			{
				Decimal decPriceShouldBe = mapBasisPrice.get(pbe.Product2Id).UnitPrice / (1 - pbe.Margin__c/100);
				if(pbe.UnitPrice.setScale(6) != decPriceShouldBe.setScale(6))
				{
					pbe.UnitPrice = decPriceShouldBe.setScale(6);
					boolUpdate = true;
				}				
			}

			if(boolUpdate)
				listPBEupdate.add(pbe);

		}
		if(listPBEupdate.size() > 0)
			update listPBEupdate;

		return 'OK';
	}


}