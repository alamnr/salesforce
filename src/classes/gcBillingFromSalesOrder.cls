global without sharing class gcBillingFromSalesOrder {
	
	global gcBillingFromSalesOrder() {}

	webservice static String createBilling(String idSalesOrder)
	{
		String idBilling = null;
		
		for(AcctSeedERP__Sales_Order__c so :
			[SELECT Id,
					AcctSeedERP__Customer__c,
					Fill_Date__c,
					AcctSeedERP__Opportunity__c,
					PO_Number__c,
					(SELECT Id,
						    AcctSeedERP__GL_Account_Variable_1__c,
						    AcctSeedERP__GL_Account_Variable_2__c,
						    AcctSeedERP__GL_Account_Variable_3__c,
						    AcctSeedERP__GL_Account_Variable_4__c,
						    AcctSeedERP__Product__c,
						    AcctSeedERP__Project__c,
						    AcctSeedERP__Project_Task__c,
						    Quantity_Filled__c,
						    AcctSeedERP__Quantity_Ordered__c,
						    AcctSeedERP__Unit_Price__c
					 FROM AcctSeedERP__Sales_Order_Line__r
					 ORDER BY Id)
			 FROM AcctSeedERP__Sales_Order__c
			 WHERE Id = :idSalesOrder])
		{
			AcctSeed__Billing__c b = new AcctSeed__Billing__c(
				AcctSeed__Date__c = so.Fill_Date__c,
				AcctSeed__Customer__c = so.AcctSeedERP__Customer__c,
				AcctSeed__Opportunity__c = so.AcctSeedERP__Opportunity__c,
				AcctSeed__PO_Number__c = so.PO_Number__c,
				AcctSeedERP__Sales_Order__c = so.Id
			);
			for(AcctSeed__Accounting_Period__c p :
				[SELECT Id 
				 FROM AcctSeed__Accounting_Period__c
				 WHERE AcctSeed__End_Date__c >= :so.Fill_Date__c
				   AND AcctSeed__Status__c = 'Open'
				 ORDER BY AcctSeed__End_Date__c
				 LIMIT 1])
			{
				b.AcctSeed__Accounting_Period__c = p.Id;
			}

			insert b;

			list<AcctSeed__Billing_Line__c> listBL = new list<AcctSeed__Billing_Line__c>();

			for(AcctSeedERP__Sales_Order_Line__c sol : so.AcctSeedERP__Sales_Order_Line__r)
			{
				AcctSeed__Billing_Line__c bl = new AcctSeed__Billing_Line__c(
					AcctSeed__Billing__c = b.Id,
					AcctSeed__GL_Account_Variable_1__c = sol.AcctSeedERP__GL_Account_Variable_1__c,
					AcctSeed__GL_Account_Variable_2__c = sol.AcctSeedERP__GL_Account_Variable_2__c,
					AcctSeed__GL_Account_Variable_3__c = sol.AcctSeedERP__GL_Account_Variable_3__c,
					AcctSeed__GL_Account_Variable_4__c = sol.AcctSeedERP__GL_Account_Variable_4__c,
					AcctSeed__Product__c = sol.AcctSeedERP__Product__c,
					AcctSeed__Project__c = sol.AcctSeedERP__Project__c,
					AcctSeed__Project_Task__c = sol.AcctSeedERP__Project_Task__c,
					AcctSeed__Hours_Units__c = sol.AcctSeedERP__Quantity_Ordered__c,
					AcctSeed__Rate__c = sol.AcctSeedERP__Unit_Price__c,
					AcctSeedERP__Sales_Order_Line__c = sol.Id);

				listBL.add(bl);
			}

			insert listBL;

			idBilling = b.Id;
		}
		return idBilling;
	}
}