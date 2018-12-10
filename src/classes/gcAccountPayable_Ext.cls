global without sharing class gcAccountPayable_Ext {
	global gcAccountPayable_Ext(ApexPages.StandardController stdController){}
	global gcAccountPayable_Ext() {}

	webservice static String accountPayableToBCM(String idAccountPayable, Decimal creditAmount){
		String returnStatus = null;
	
		for(AcctSeed__Account_Payable__c ap : 
				[SELECT 
					Id, 
					AcctSeed__Status__c, 
					AcctSeed__Vendor__c, 
					AcctSeed__Balance__c, 
					AcctSeed__Accounting_Period__c,
					AcctSeed__Payee_Reference__c 
				FROM AcctSeed__Account_Payable__c 
				WHERE Id = :idAccountPayable])
		{
			// Current Total balance of the AP
			Decimal totalAPBalance = (Decimal) ap.AcctSeed__Balance__c;
			// Checking total balance. If <= 0 no need to work on this AP
			if(totalAPBalance > 0 && creditAmount <= totalAPBalance){

				String idAccPeriod;
				// Checking the current period is open or not
				AcctSeed__Accounting_Period__c period = gcAccountingPeriod.periodThis(ap.AcctSeed__Accounting_Period__c);
				if(period.AcctSeed__Status__c == 'Open')
					idAccPeriod = period.Id;
				else{
					// Checking the current period is open or not
					period = gcAccountingPeriod.periodCurr();
					idAccPeriod = period.Id;
				}
				// Creating Credit of the AP
				AcctSeed__Account_Payable__c apCredit = new AcctSeed__Account_Payable__c(
					AcctSeed__Vendor__c = ap.AcctSeed__Vendor__c,
					AcctSeed__Accounting_Period__c  = idAccPeriod,
					AcctSeed__Payee_Reference__c = ap.AcctSeed__Payee_Reference__c + '-CM-' + String.valueOf(DateTime.now().getTime()),
					AcctSeed__Date__c = date.Today()
				);
				//apCredit = ap.clone();
				// Inserting AP Credit
				insert apCredit;
				
				// The GL account newly created for AP2AR purpose only.
				// We can create it on the fly if does not exist.
				Id idGLAp2Ar = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Uniquefier__c = 'AP2AR'][0].Id;

				// Creadit Account Payable line. only one line even if there are more lines in original AP
				AcctSeed__Account_Payable_Line__c apCreditLine = new AcctSeed__Account_Payable_Line__c(
					AcctSeed__Account_Payable__c = apCredit.Id,
					AcctSeed__Amount__c = (creditAmount * -1),
					AcctSeed__Expense_GL_Account__c = idGLAp2Ar
				);
				// Inserting Credit AP line
				insert apCreditLine;

				// Posting Credit AP.
				List<AcctSeed.PostResult> listPostResult = new list<AcctSeed.PostResult>();
				List<AcctSeed__Account_Payable__c> apList = new List<AcctSeed__Account_Payable__c>();
				apList.add(apCredit);

				// Not doing anything based on the results for now.
				listPostResult = AcctSeed.AccountPayablePostService.postAccountPayables(apList);

				/*// Applying AP credit memo to the original AP
				AcctSeed__AP_Credit_Memo__c apCreditMemo = new AcctSeed__AP_Credit_Memo__c(
					AcctSeed__Account_Payable_Credit_Memo__c = ap.Id,
					AcctSeed__Account_Payable_Invoice__c = apCredit.Id,
					AcctSeed__Accounting_Period__c = idAccPeriod,
					AcctSeed__Amount__c = (creditAmount * -1)
				);
				insert apCreditMemo;*/

				// Creating Credit billing
				AcctSeed__Billing__c b = new AcctSeed__Billing__c(
					AcctSeed__Date__c = date.Today(),
					Account_Payable__c = apCredit.Id,
					AcctSeed__Customer__c = ap.AcctSeed__Vendor__c
				);
				insert b;

				// Creating Credit billing line
				AcctSeed__Billing_Line__c bl = new AcctSeed__Billing_Line__c(
					AcctSeed__Billing__c = b.Id,
					AcctSeed__Revenue_GL_Account__c = idGLAp2Ar,
					AcctSeed__Hours_Units__c = 1,
					AcctSeed__Rate__c = (creditAmount * -1)
				);
				insert bl;

				// Posting New Credit Bill
				list<AcctSeed__Billing__c> listBill = new list<AcctSeed__Billing__c>();
				listBill.add(b);
				listPostResult = AcctSeed.BillingPostService.postBillings(listBill);

				returnStatus = apCredit.Id;
			}
		}
		return returnStatus;
	}
}