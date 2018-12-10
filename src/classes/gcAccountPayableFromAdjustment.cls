global without sharing class gcAccountPayableFromAdjustment {
	
	global gcAccountPayableFromAdjustment() {}
		
	webservice static String createAccountPayable(String idAdjustment, String vendorInvoiceNumber)
	{
		Inventory_Adjustment__c adjust = [SELECT Vendor__c, Adjustment_Date__c FROM Inventory_Adjustment__c WHERE Id = :idAdjustment][0];

		AcctSeed__Account_Payable__c ap = new AcctSeed__Account_Payable__c(
												AcctSeed__Vendor__c = adjust.Vendor__c,
												AcctSeed__Date__c = adjust.Adjustment_Date__c, //date.Today(),
												AcctSeed__Payee_Reference__c = vendorInvoiceNumber);
		insert ap;

		Id idGL = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Uniquefier__c = 'VendorAdjustment'][0].Id;

		List<AcctSeed__Account_Payable_Line__c> listAPL = new List<AcctSeed__Account_Payable_Line__c>();
		// Retrieve inbound moves for the Adjustment
		for(AcctSeedERP__Inbound_Inventory_Movement__c move :
               [SELECT Id,
               		   AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,
                	   Inventory_GL_Amount__c,
                	   (SELECT Inventory_GL_Amount__c FROM AcctSeedERP__Outbound_Inventory_Movements__r)
                FROM AcctSeedERP__Inbound_Inventory_Movement__c
                WHERE Inventory_Adjustment__c = :idAdjustment AND Inventory_Adjustment__c != null])
        {	        	
	        	Decimal inMoveValue = move.Inventory_GL_Amount__c;
	        	
	        	if(inMoveValue == null) inMoveValue = 0;
	        	
	        	Decimal outMoveValue = 0;
	        	
	        	if(move.AcctSeedERP__Outbound_Inventory_Movements__r.size() > 0)
	        		outMoveValue = move.AcctSeedERP__Outbound_Inventory_Movements__r[0].Inventory_GL_Amount__c;
	        	
	        	if(outMoveValue == null) outMoveValue = 0;
	        	
	        	Decimal apValue = inMoveValue - outMoveValue;

				listAPL.add(new AcctSeed__Account_Payable_Line__c(
					AcctSeed__Account_Payable__c = ap.Id,
					AcctSeed__Amount__c = apValue,
					AcctSeed__Expense_GL_Account__c = idGL,
					AcctSeed__Product__c = move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c
				));
        }
        Boolean disableTrigger = gcAccountPayableLine.disableTrigger;
        gcAccountPayableLine.disableTrigger = true;
		insert listAPL;
		gcAccountPayableLine.disableTrigger = disableTrigger;

		return String.valueOf(ap.Id);
	}
}