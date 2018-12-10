global without sharing class gcBilling_Buttons {

	webservice static boolean checkForCustomCreditMemoWS(String idBilling)
	{
		return checkForCustomCreditMemoRA(idBilling);
	}

	@RemoteAction @ReadOnly
	public static boolean checkForCustomCreditMemoRA(String idBilling)
	{
		for(AcctSeed__Billing_Credit_Memo__c bcm :
			[SELECT Id
			 FROM AcctSeed__Billing_Credit_Memo__c
			 WHERE AcctSeed__Billing_Credit_Memo__c = :idBilling
			   AND (Billing_Credit_Memo_Line__c != null OR Billing_Invoice_Line__c != null)])
		{
			return true;
		}
		return false;
	}
}