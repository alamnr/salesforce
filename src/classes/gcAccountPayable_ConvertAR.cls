global without sharing class gcAccountPayable_ConvertAR {
	public gcAccountPayable_ConvertAR() {}
	public gcAccountPayable_ConvertAR(ApexPages.StandardController c){idAP = c.getId();}

	Id idAP{get;set;}
	public AcctSeed__Account_Payable__c reRenderHelper
	{
		get{
			return [SELECT AcctSeed__Total__c, AcctSeed__Balance__c FROM AcctSeed__Account_Payable__c WHERE Id = :idAP][0];
		}
		set;
	}

	@RemoteAction
	public static string undoCreditMemoAll(String idAccountPayable)
	{
		list<string> listIdBilling = new list<string>();
		for(AcctSeed__Billing__c b :
			[SELECT Id FROM AcctSeed__Billing__c
			 WHERE Account_Payable__c = :idAccountPayable
			   AND Account_Payable__c != null])
		{
			listIdBilling.add(b.Id);
		}
		if(listIdBilling.size() > 0)
			undoCreditMemoRA(listIdBilling);
		return '';
	}

	webservice static string undoCreditMemoWS(list<string> listIdBilling)
	{
		return undoCreditMemoRA(listIdBilling);
	}

	@RemoteAction
	public static string undoCreditMemoRA(list<string> listIdBilling)
	{
		/*if a billing meets all of the following criteria, it can be undone:
			- the billing is posted
			- the period of the billing is open
			- any Billing Credit Memos under the Billing are in a period that is open.
		*/

		list<AcctSeed__Billing_Credit_Memo__c> listBCMdelete = new list<AcctSeed__Billing_Credit_Memo__c>();
		list<AcctSeed__Billing__c> listBillDelete = new list<AcctSeed__Billing__c>();

		for(AcctSeed__Billing__c b :
			[SELECT Id,
					(SELECT Id, AcctSeed__Accounting_Period__r.AcctSeed__Status__c
					 FROM AcctSeed__Billing_Credit_Memos__r),
					(SELECT Id, AcctSeed__Accounting_Period__r.AcctSeed__Status__c
					 FROM AcctSeed__Billing_Credit_Memos1__r)
			 FROM AcctSeed__Billing__c
			 WHERE Id IN :listIdBilling
			   AND AcctSeed__Status__c = 'Posted'
			   AND AcctSeed__Accounting_Period__r.AcctSeed__Status__c = 'Open'])
		{
			Boolean boolContinue = false;
			for(AcctSeed__Billing_Credit_Memo__c bcm : b.AcctSeed__Billing_Credit_Memos__r)
			{
				if(bcm.AcctSeed__Accounting_Period__r.AcctSeed__Status__c != 'Open')
					boolContinue = true;
			}
			for(AcctSeed__Billing_Credit_Memo__c bcm : b.AcctSeed__Billing_Credit_Memos1__r)
			{
				if(bcm.AcctSeed__Accounting_Period__r.AcctSeed__Status__c != 'Open')
					boolContinue = true;
			}

			if(boolContinue) continue;

			listBCMdelete.addAll(b.AcctSeed__Billing_Credit_Memos__r);
			listBCMdelete.addAll(b.AcctSeed__Billing_Credit_Memos1__r);

			listBillDelete.add(b);
		}

		if(listBCMdelete.size() > 0)
			delete listBCMdelete;
		if(listBillDelete.size() > 0)
		{
			AcctSeed.BillingPostService.unpostBillings(listBillDelete);
			delete listBillDelete;
		}
		return '';
	}

	@RemoteAction @ReadOnly
	public static list<gcObj> retrieveCreditLines(String idAccountPayable)
	{
		Id idCustomer = [SELECT AcctSeed__Vendor__c FROM AcctSeed__Account_Payable__c WHERE Id =:idAccountPayable][0].AcctSeed__Vendor__c;
		Id idGlAR2AP = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Uniquefier__c = 'AR2AP'][0].Id;
		list<gcObj> listObj = new list<gcObj>();

		list<AcctSeed__Billing_Line__c> listBL = new list<AcctSeed__Billing_Line__c>();
		map<Id,AcctSeedERP__Sales_Order_Line__c> mapSOL = new map<Id,AcctSeedERP__Sales_Order_Line__c>();

		for(AcctSeed__Billing_Line__c bl :
			[SELECT Id, Name,
					AcctSeed__Billing__c,
					AcctSeed__Billing__r.Name,
					AcctSeed__Billing__r.AcctSeed__Balance__c,
					AcctSeed__Hours_Units__c,
					AcctSeed__Product__r.Name,
					AcctSeed__Product__r.ProductCode,
					AcctSeed__Product__r.Variable_Price__c,
					AcctSeed__Rate__c,
					AcctSeed__Revenue_GL_Account__c,
					AcctSeed__Revenue_GL_Account__r.Name,
					AcctSeed__Total__c,
					AcctSeedERP__Sales_Order_Line__c,
					(SELECT Id, 
							AcctSeed__Billing_Invoice__c, 
							AcctSeed__Billing_Invoice__r.Name,
							Billing_Invoice_Line__c,
							Billing_Invoice_Line__r.Name
					 FROM Billing_Credit_Memo_Credit_Lines__r
					 WHERE AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0
					 ORDER BY CreatedDate, Id)					
			 FROM AcctSeed__Billing_Line__c
			 WHERE AcctSeed__Billing__r.Account_Payable__c = :idAccountPayable
			   AND AcctSeed__Billing__r.AcctSeed__Status__c = 'Posted'])
		{
			listBL.add(bl);
			mapSOL.put(bl.AcctSeedERP__Sales_Order_Line__c, null);
		}

		for(AcctSeedERP__Sales_Order_Line__c sol : 
			[SELECT Id, Name,
					AcctSeedERP__Quantity_Ordered__c,
					AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Name,
					AcctSeedERP__Total__c,
					AcctSeedERP__Unit_Price__c,	
					Lot__c,
					Lot__r.Name,
					Lot__r.Expiration_Date__c,
					Lot__r.Variant_Qty__c,
					Variant_Unit_Price__c,
					(SELECT Id, Name,
							AcctSeed__Billing__c,
							AcctSeed__Billing__r.Name
					 FROM AcctSeedERP__Billing_Lines__r
					 WHERE AcctSeed__Billing__r.AcctSeed__Customer__c != :idCustomer
					 ORDER BY CreatedDate, Id
					 LIMIT 1)
			 FROM AcctSeedERP__Sales_Order_Line__c
			 WHERE Id IN :mapSOL.keySet()])
		{
			mapSOL.put(sol.Id,sol);
		}
		mapSOL.remove(null);

		//cycle over the billing lines
		for(AcctSeed__Billing_Line__c bl : listBL)
		{
			gcObj obj = new gcObj();
			map<string,string> m = obj.mapProperty;

			m.put('idBilling',bl.AcctSeed__Billing__c);
			m.put('billingName',bl.AcctSeed__Billing__r.Name);

			m.put('idBillingLine',bl.Id);
			m.put('billingLineName',bl.Name);

			if(bl.AcctSeed__Total__c != null)
				m.put('billingLineTotal',String.valueOf((-1.000000)*bl.AcctSeed__Total__c.setScale(6)));
			else
				m.put('billingLineTotal','0');

			m.put('productName',bl.AcctSeed__Product__r.Name);
			m.put('productCode',bl.AcctSeed__Product__r.ProductCode);

			m.put('glName',bl.AcctSeed__Revenue_GL_Account__r.Name);
			if(bl.AcctSeed__Revenue_GL_Account__c == idGlAR2AP)
				m.put('amountAP2AR',String.valueOf((-1.000000)*bl.AcctSeed__Total__c.setScale(6)));
			else
				m.put('amountOther',String.valueOf((-1.000000)*bl.AcctSeed__Total__c.setScale(6)));

			if(bl.Billing_Credit_Memo_Credit_Lines__r.size() > 0)
			{
				m.put('idBillingVendor',bl.Billing_Credit_Memo_Credit_Lines__r[0].AcctSeed__Billing_Invoice__c);
				m.put('billingNameVendor',bl.Billing_Credit_Memo_Credit_Lines__r[0].AcctSeed__Billing_Invoice__r.Name);
				m.put('idBillingLineVendor',bl.Billing_Credit_Memo_Credit_Lines__r[0].Billing_Invoice_Line__c);
				m.put('billingLineNameVendor',bl.Billing_Credit_Memo_Credit_Lines__r[0].Billing_Invoice_Line__r.Name);
			}



			if(bl.AcctSeedERP__Sales_Order_Line__c != null && mapSOL.containsKey(bl.AcctSeedERP__Sales_Order_Line__c))
			{
				AcctSeedERP__Sales_Order_Line__c sol = mapSOL.get(bl.AcctSeedERP__Sales_Order_Line__c);

				m.put('idSalesOrderLine', sol.Id);
				m.put('salesOrderLineName', sol.Name);

				if(sol.AcctSeedERP__Quantity_Ordered__c != null)
					m.put('salesOrderLineQty',String.valueOf(sol.AcctSeedERP__Quantity_Ordered__c.setScale(6)));
				else
					m.put('salesOrderLineQty','0');

				if(sol.AcctSeedERP__Total__c != null)
					m.put('salesOrderLineTotal',String.valueOf(sol.AcctSeedERP__Total__c.setScale(6)));
				else
					m.put('salesOrderLineTotal','0');

				if(sol.AcctSeedERP__Unit_Price__c != null)
					m.put('salesOrderLineUnitPrice',String.valueOf(sol.AcctSeedERP__Unit_Price__c.setScale(6)));
				else
					m.put('salesOrderLineUnitPrice','0');

				if(sol.Variant_Unit_Price__c != null)
					m.put('salesOrderLineVariantUnitPrice',String.valueOf(sol.Variant_Unit_Price__c.setScale(6)));

				m.put('customerName',sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Name);
				
				m.put('idLot',sol.Lot__c);
				m.put('lotName',sol.Lot__r.Name);
				if(sol.Lot__r.Expiration_Date__c != null)
					m.put('lotExpirationDate',sol.Lot__r.Expiration_Date__c.format());
				if(sol.Lot__r.Variant_Qty__c != null)
				m.put('lotVariantQty',String.valueOf(sol.Lot__r.Variant_Qty__c));

				if(sol.AcctSeedERP__Billing_Lines__r.size() > 0)
				{
					m.put('idBillingCustomer', sol.AcctSeedERP__Billing_Lines__r[0].AcctSeed__Billing__c);
					m.put('billingNameCustomer', sol.AcctSeedERP__Billing_Lines__r[0].AcctSeed__Billing__r.Name);
				}
			}

			listObj.add(obj);
		}
		return listObj;
	}


	@RemoteAction @ReadOnly
	public static list<gcObj> retrieveBillingLines(String idAccountPayable)
	{
		Id idCustomer = [SELECT AcctSeed__Vendor__c FROM AcctSeed__Account_Payable__c WHERE Id =:idAccountPayable][0].AcctSeed__Vendor__c;
		list<gcObj> listObj = new list<gcObj>();

		//get the list of billings
		list<AcctSeed__Billing_Line__c> listBL = new list<AcctSeed__Billing_Line__c>();
		map<Id,AcctSeedERP__Sales_Order_Line__c> mapSOL = new map<Id,AcctSeedERP__Sales_Order_Line__c>();

		for(AcctSeed__Billing_Line__c bl :
			[SELECT Id, Name,
					AcctSeed__Billing__c,
					AcctSeed__Billing__r.Name,
					AcctSeed__Billing__r.AcctSeed__Balance__c,
					AcctSeed__Hours_Units__c,
					AcctSeed__Product__r.Name,
					AcctSeed__Product__r.ProductCode,
					AcctSeed__Product__r.Variable_Price__c,
					AcctSeed__Rate__c,
					AcctSeed__Total__c,
					AcctSeedERP__Sales_Order_Line__c,
					(SELECT Id, AcctSeed__Amount__c
					 FROM Billing_Credit_Memo_Invoice_Lines__r
					 WHERE AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0),
					(SELECT Id, AcctSeed__Amount__c
					 FROM Billing_Credit_Memo_Credit_Lines__r
					 WHERE AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0)		
			 FROM AcctSeed__Billing_Line__c
			 WHERE AcctSeed__Billing__r.AcctSeed__Customer__c = :idCustomer
			   AND AcctSeed__Billing__r.AcctSeed__Balance__c != 0
			   AND AcctSeed__Billing__r.AcctSeed__Status__c = 'Posted'])
		{
			//if the billing line no longer has a balance, do not include it
			Decimal balance = bl.AcctSeed__Total__c;
			for(AcctSeed__Billing_Credit_Memo__c bcm : bl.Billing_Credit_Memo_Invoice_Lines__r)
				balance += bcm.AcctSeed__Amount__c;
			for(AcctSeed__Billing_Credit_Memo__c bcm : bl.Billing_Credit_Memo_Credit_Lines__r)
				balance -= bcm.AcctSeed__Amount__c;
			if(balance.setScale(2) == 0) continue;

			listBL.add(bl);
			mapSOL.put(bl.AcctSeedERP__Sales_Order_Line__c, null);
		}

		//retrieve the sales order lines
		//note:  an attempt is made to correctly identify the CUSTOMER BILLING for the Sales Order
		for(AcctSeedERP__Sales_Order_Line__c sol : 
			[SELECT Id, Name,
					AcctSeedERP__Quantity_Ordered__c,
					AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Name,
					AcctSeedERP__Total__c,
					AcctSeedERP__Unit_Price__c,	
					Lot__c,
					Lot__r.Name,
					Lot__r.Expiration_Date__c,
					Lot__r.Variant_Qty__c,
					Variant_Unit_Price__c,
					(SELECT Id, Name,
							AcctSeed__Billing__c,
							AcctSeed__Billing__r.Name
					 FROM AcctSeedERP__Billing_Lines__r
					 WHERE AcctSeed__Billing__r.AcctSeed__Customer__c != :idCustomer
					 ORDER BY CreatedDate, Id
					 LIMIT 1)
			 FROM AcctSeedERP__Sales_Order_Line__c
			 WHERE Id IN :mapSOL.keySet()])
		{
			mapSOL.put(sol.Id,sol);
		}
		mapSOL.remove(null);

		//cycle over the billing lines
		for(AcctSeed__Billing_Line__c bl : listBL)
		{
			gcObj obj = new gcObj();
			map<string,string> m = obj.mapProperty;

			Decimal balance = bl.AcctSeed__Total__c;
			Decimal credits = 0;
			for(AcctSeed__Billing_Credit_Memo__c bcm : bl.Billing_Credit_Memo_Invoice_Lines__r)
				credits += bcm.AcctSeed__Amount__c;

			for(AcctSeed__Billing_Credit_Memo__c bcm : bl.Billing_Credit_Memo_Credit_Lines__r)
				credits -= bcm.AcctSeed__Amount__c;

			balance += credits;

			m.put('idBilling',bl.AcctSeed__Billing__c);
			m.put('billingName',bl.AcctSeed__Billing__r.Name);

			m.put('idBillingLine',bl.Id);
			m.put('billingLineName',bl.Name);

			if(bl.AcctSeed__Hours_Units__c != null)
				m.put('billingLineQty',String.valueOf(bl.AcctSeed__Hours_Units__c.setScale(6)));
			else
				m.put('billingLineQty','0');

			if(bl.AcctSeed__Rate__c != null)
				m.put('billingLineRate',String.valueOf(bl.AcctSeed__Rate__c.setScale(6)));
			else
				m.put('billingLineRate','0');

			if(bl.AcctSeed__Total__c != null)
				m.put('billingLineTotal',String.valueOf(bl.AcctSeed__Total__c.setScale(6)));
			else
				m.put('billingLineTotal','0');

			m.put('productName',bl.AcctSeed__Product__r.Name);
			m.put('productCode',bl.AcctSeed__Product__r.ProductCode);

			if(bl.AcctSeed__Product__r.Variable_Price__c == true)
				m.put('productIsVariablePrice','true');
			else
				m.put('productIsVariablePrice','false');


			if(bl.AcctSeedERP__Sales_Order_Line__c != null && mapSOL.containsKey(bl.AcctSeedERP__Sales_Order_Line__c))
			{
				AcctSeedERP__Sales_Order_Line__c sol = mapSOL.get(bl.AcctSeedERP__Sales_Order_Line__c);

				m.put('idSalesOrderLine', sol.Id);
				m.put('salesOrderLineName', sol.Name);

				if(sol.AcctSeedERP__Quantity_Ordered__c != null)
					m.put('salesOrderLineQty',String.valueOf(sol.AcctSeedERP__Quantity_Ordered__c.setScale(6)));
				else
					m.put('salesOrderLineQty','0');

				if(sol.AcctSeedERP__Total__c != null)
					m.put('salesOrderLineTotal',String.valueOf(sol.AcctSeedERP__Total__c.setScale(6)));
				else
					m.put('salesOrderLineTotal','0');

				if(sol.AcctSeedERP__Unit_Price__c != null)
					m.put('salesOrderLineUnitPrice',String.valueOf(sol.AcctSeedERP__Unit_Price__c.setScale(6)));
				else
					m.put('salesOrderLineUnitPrice','0');

				if(sol.Variant_Unit_Price__c != null)
					m.put('salesOrderLineVariantUnitPrice',String.valueOf(sol.Variant_Unit_Price__c.setScale(6)));

				m.put('customerName',sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Name);
				
				m.put('idLot',sol.Lot__c);
				m.put('lotName',sol.Lot__r.Name);
				if(sol.Lot__r.Expiration_Date__c != null)
					m.put('lotExpirationDate',sol.Lot__r.Expiration_Date__c.format());
				if(sol.Lot__r.Variant_Qty__c != null)
				m.put('lotVariantQty',String.valueOf(sol.Lot__r.Variant_Qty__c));

				if(sol.AcctSeedERP__Billing_Lines__r.size() > 0)
				{
					m.put('idBillingCustomer', sol.AcctSeedERP__Billing_Lines__r[0].AcctSeed__Billing__c);
					m.put('billingNameCustomer', sol.AcctSeedERP__Billing_Lines__r[0].AcctSeed__Billing__r.Name);
				}
			}

			m.put('billingLineCredit',String.valueOf(credits.setScale(6)));
			m.put('billingLineBalance',String.valueOf(balance.setScale(6)));

			listObj.add(obj);
		}
		return listObj;
	}

	@RemoteAction
	public static string createCreditMemo(Id idAccountPayable, list<map<string,string>> listRow)
	{
		/*
		Something in this method that may, at first glance, seem inexplicable is that sometimes TWO new billing records will be created:  one positive, and one negative.
		Here is an explanation of the need for that complexity.

		One outcome of this process will be the creation of new billing lines, and billing credit memo (bcm) records that join the new billing lines to pre-existing billing lines.
		A bcm record must look up to exactly one billing for which billing.total >= 0 (the billing invoice)
		and exactly one billing for which billing.total < 0 (the billing credit memo).

		There are four possible cases of an existing billing line that will be converted to A/P:
		1) BillingLine.Total > 0 and BillingLine.Billing.Total >= 0 (i.e. a positive line on a billing)
		2) BillingLine.Total < 0 and BillingLine.Billing.Total >= 0 (i.e. a negative line on an otherwise positive billing)
		3) BillingLine.Total < 0 and BillingLine.Billing.Total < 0 (i.e. a negative line on a negative billing - a.k.a. an A/R credit memo)
		4) BillingLine.Total > 0 and BillingLine.Billing.Total < 0 (i.e. a positive line on an otherwise negative billing)

		In case #2, the new billing line that is created will have a positive amount.  And the parent of the old billing is also positive.
		This means that it will be impossible to simply create a new billing for the new billing line, and relate the new billing line to the
		old billing line with a bcm record.  (The reason that this would be impossible is because the new billing and the old billing would both be 
		positive billings, and a bcm record CANNOT join two positive billings or two negative billings; there must be one positive billing and one negative billing.)

		So a solution is needed for circumstances in which the polarity of the originating bill is opposite to the net polarity of the billing lines on that bill that 
		are being converted.

		The solution is to create an additional billing, solely for the purpose of ensuring that the rules of polarity for bcm records is observed, and to create
		additional billing lines that will be joined to each other - and cancel each other out - by means of a bcm.

		Sound confusing?  It is.

		One of the outcomes, that is sure to cause confusion to the end-user, is that it will seem that "extra" billings and billing lines are being created.
		*/

		if(listRow == null || listRow.size() == 0) return '';

		list<wrapRow> listWrapRow = new list<wrapRow>();

		map<Id,AcctSeed__Billing_Line__c> mapBL = new map<Id,AcctSeed__Billing_Line__c>();
		list<AcctSeed__Billing_Line__c> listBLnew = new list<AcctSeed__Billing_Line__c>();
		list<AcctSeed__Billing_Credit_Memo__c> listBCM = new list<AcctSeed__Billing_Credit_Memo__c>();

		AcctSeed__Billing__c billNewPos;
		AcctSeed__Billing__c billNewNeg;

		AcctSeed__Account_Payable__c ap = [SELECT Id, AcctSeed__Accounting_Period__c, AcctSeed__Date__c, AcctSeed__Status__c, AcctSeed__Vendor__c FROM AcctSeed__Account_Payable__c WHERE Id =:idAccountPayable][0];

		Id idGlAR2AP = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Uniquefier__c = 'AR2AP'][0].Id;

		for(map<string,string> m : listRow)
		{
			if(!mapBL.containsKey(Id.valueOf(m.get('idBillingLine'))))
				mapBL.put(Id.valueOf(m.get('idBillingLine')),null);
		}
		for(AcctSeed__Billing_Line__c bl :
			[SELECT Id,
					AcctSeed__Billing__c,
					AcctSeed__Billing__r.AcctSeed__Total__c,
					AcctSeed__GL_Account_Variable_1__c,
					AcctSeed__GL_Account_Variable_2__c,
					AcctSeed__GL_Account_Variable_3__c,
					AcctSeed__GL_Account_Variable_4__c,
					AcctSeed__Product__c,
					AcctSeed__Revenue_GL_Account__c,
					AcctSeedERP__Sales_Order_Line__c
			 FROM AcctSeed__Billing_Line__c
			 WHERE Id IN :mapBL.keySet()])
		{
			mapBL.put(bl.Id,bl);
		}

		Decimal billNewPosBalance = 0;
		Decimal billNewNegBalance = 0;

		for(map<string,string> m : listRow)
		{
			Decimal amtConvert = (Decimal.valueOf(m.get('convertToAP'))).setScale(2);
			Decimal amtReverse = (Decimal.valueOf(m.get('writeDown'))).setScale(2);

			AcctSeed__Billing_Line__c lineOld = mapBL.get(Id.valueOf(m.get('idBillingLine')));
			AcctSeed__Billing_Line__c lineNewConvert;
			AcctSeed__Billing_Line__c lineNewReverse;

			if(amtConvert != 0 || amtReverse != 0)
			{
				Id idBillNew;

				if(lineOld.AcctSeed__Billing__r.AcctSeed__Total__c < 0)
				{
					if(billNewPos == null)
					{
						billNewPos = new AcctSeed__Billing__c(
							AcctSeed__Accounting_Period__c = ap.AcctSeed__Accounting_Period__c,
							AcctSeed__Customer__c = ap.AcctSeed__Vendor__c,
							AcctSeed__Date__c = ap.AcctSeed__Date__c,
							AcctSeed__Proprietary_Billing_Number__c = 'billNewPos',
							AcctSeed__Status__c = 'Approved',
							Account_Payable__c = ap.Id);

						insert billNewPos;
					}
					idBillNew = billNewPos.Id;
				}
				else
				{
					if(billNewNeg == null)
					{
						billNewNeg = new AcctSeed__Billing__c(
							AcctSeed__Accounting_Period__c = ap.AcctSeed__Accounting_Period__c,
							AcctSeed__Customer__c = ap.AcctSeed__Vendor__c,
							AcctSeed__Date__c = ap.AcctSeed__Date__c,
							AcctSeed__Proprietary_Billing_Number__c = 'billNewNeg',							
							AcctSeed__Status__c = 'Approved',
							Account_Payable__c = ap.Id);

						insert billNewNeg;
					}
					idBillNew = billNewNeg.Id;
				}

				if(amtConvert != 0)
				{
					lineNewConvert = lineOld.clone();

					lineNewConvert.AcctSeed__Billing__c = idBillNew;
					lineNewConvert.AcctSeed__Hours_Units__c = 1;
					lineNewConvert.AcctSeed__Rate__c = (-1) * amtConvert;
					lineNewConvert.Override__c = true;

					lineNewConvert.AcctSeed__Revenue_GL_Account__c = idGlAR2AP;

					listBLnew.add(lineNewConvert);

					listWrapRow.add(new wrapRow(lineOld, lineNewConvert));

					if(billNewPos != null && idBillNew == billNewPos.Id)
						billNewPosBalance -= amtConvert;
					else
						billNewNegBalance -= amtConvert;
				}

				if(amtReverse != 0)
				{
					lineNewReverse = lineOld.clone();

					lineNewReverse.AcctSeed__Billing__c = idBillNew;
					lineNewReverse.AcctSeed__Hours_Units__c = 1;
					lineNewReverse.AcctSeed__Rate__c = (-1) * amtReverse;
					lineNewReverse.Override__c = true;

					listBLnew.add(lineNewReverse);

					listWrapRow.add(new wrapRow(lineOld, lineNewReverse));

					if(billNewPos != null && idBillNew == billNewPos.Id)
						billNewPosBalance -= amtReverse;
					else
						billNewNegBalance -= amtReverse;					
				}
			}
		}

		if(listBLnew.size() > 0)
		{
			//ensure that the positive bill is indeed positive, and the negative bill is indeed negative
			//if not, then add a billing line to each bill, and then use a bcm to shift from one to the other
			Decimal amtShift = 0;
			if(billNewPosBalance < 0)
			{
				amtShift = 0 - billNewPosBalance;
				billNewPosBalance += amtShift;
				billNewNegBalance -= amtShift;

				if(billNewNeg == null)
				{
					billNewNeg = new AcctSeed__Billing__c(
						AcctSeed__Accounting_Period__c = ap.AcctSeed__Accounting_Period__c,
						AcctSeed__Customer__c = ap.AcctSeed__Vendor__c,
						AcctSeed__Date__c = ap.AcctSeed__Date__c,
						AcctSeed__Proprietary_Billing_Number__c = 'billNewNeg',						
						AcctSeed__Status__c = 'Approved',
						Account_Payable__c = ap.Id);

					insert billNewNeg;					
				}				
			}

			if(billNewNegBalance > 0)
			{
				amtShift += billNewNegBalance;
				billNewPosBalance += amtShift;
				billNewNegBalance -= amtShift;

				if(billNewPos == null)
				{
					billNewPos = new AcctSeed__Billing__c(
						AcctSeed__Accounting_Period__c = ap.AcctSeed__Accounting_Period__c,
						AcctSeed__Customer__c = ap.AcctSeed__Vendor__c,
						AcctSeed__Date__c = ap.AcctSeed__Date__c,
						AcctSeed__Proprietary_Billing_Number__c = 'billNewPos',
						AcctSeed__Status__c = 'Approved',
						Account_Payable__c = ap.Id);

					insert billNewPos;					
				}
			}

			//if the net effect of all actions will be that the invoice that is "supposed to be" negative
			//ends up having a zero balance, that will be a problem, because a bill with a zero balance is, from
			//the perspective of the rules of polarity for bcm records, a positive billing.
			//so we shift an additional .01 from the negative billing to the positive billing, to ensure that the negative billing will be negative.
			if(billNewNegBalance == 0 && billNewNeg != null)
			{
				amtShift += .01;
				billNewPosBalance += .01;
				billNewNegBalance -= .01;

				if(billNewPos == null)
				{
					billNewPos = new AcctSeed__Billing__c(
						AcctSeed__Accounting_Period__c = ap.AcctSeed__Accounting_Period__c,
						AcctSeed__Customer__c = ap.AcctSeed__Vendor__c,
						AcctSeed__Date__c = ap.AcctSeed__Date__c,
						AcctSeed__Proprietary_Billing_Number__c = 'billNewPos',
						AcctSeed__Status__c = 'Approved',
						Account_Payable__c = ap.Id);

					insert billNewPos;					
				}				
			}

			if(amtShift != 0)
			{
				for(AcctSeed__Billing__c b : [SELECT Id, Name FROM AcctSeed__Billing__c WHERE Id IN (:billNewNeg.Id, :billNewPos.Id)])
				{
					if(b.Id == billNewNeg.Id) 
						 billNewNeg = b;
					else billNewPos = b;
				}
				AcctSeed__Billing_Line__c shiftPos = new AcctSeed__Billing_Line__c(

					AcctSeed__Billing__c = billNewPos.Id,
					AcctSeed__Hours_Units__c = 1,
					AcctSeed__Rate__c = amtShift,
					AcctSeed__Revenue_GL_Account__c = idGlAR2AP,
					Override__c = true,
					AcctSeed__Comment__c = 'The sole purpose of this billing line is to ensure that this billing is positive and/or that billing '+billNewNeg.Name+' is negative.'
				);
				AcctSeed__Billing_Line__c shiftNeg = new AcctSeed__Billing_Line__c(

					AcctSeed__Billing__c = billNewNeg.Id,
					AcctSeed__Hours_Units__c = 1,
					AcctSeed__Rate__c = (-1) * amtShift,
					AcctSeed__Revenue_GL_Account__c = idGlAR2AP,
					Override__c = true,
					AcctSeed__Comment__c = 'The sole purpose of this billing line is to ensure that this billing is negative and/or that billing '+billNewPos.Name+' is positive.'			
				);
				
				gcBillingLine.disableTrigger = true;
				insert new list<AcctSeed__Billing_Line__c>{shiftPos,shiftNeg};

				listBCM.add(new AcctSeed__Billing_Credit_Memo__c(
					AcctSeed__Accounting_Period__c = ap.AcctSeed__Accounting_Period__c,
					AcctSeed__Amount__c = (-1)*amtShift,
					AcctSeed__Billing_Credit_Memo__c = billNewNeg.Id,
					Billing_Credit_Memo_Line__c = shiftNeg.Id,
					AcctSeed__Billing_Invoice__c = billNewPos.Id,
					Billing_Invoice_Line__c = shiftPos.Id));
			}

			gcBillingLine.disableTrigger = true;
			insert listBLnew;

			list<AcctSeed__Billing__c> listB = new list<AcctSeed__Billing__c>();
			if(billNewNeg != null)
				listB.add(billNewNeg);
			if(billNewPos != null)
				listB.add(billNewPos);

			list<AcctSeed.PostResult> postResults = AcctSeed.BillingPostService.postBillings(listB);

			for (AcctSeed.PostResult theResult : postResults) {
			    if (!theResult.isSuccess)
			    {
			        System.debug(loggingLevel.error,'Error posting billing ' + theResult.id);
			        for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
			            System.debug(loggingLevel.error,'Error status code ' + errorResult.statusCode);
			            System.debug(loggingLevel.error,'Error message ' + errorResult.message);
			        }
			    }
			}

			for(wrapRow wr : listWrapRow)
			{
				AcctSeed__Billing_Credit_Memo__c bcm = new AcctSeed__Billing_Credit_Memo__c(
					AcctSeed__Accounting_Period__c = ap.AcctSeed__Accounting_Period__c,
					AcctSeed__Amount__c = wr.lineNew.AcctSeed__Rate__c);

				if(billNewPos != null && wr.lineNew.AcctSeed__Billing__c == billNewPos.Id)
				{
					bcm.AcctSeed__Billing_Invoice__c = wr.lineNew.AcctSeed__Billing__c;
					bcm.Billing_Invoice_Line__c = wr.lineNew.Id;
					bcm.AcctSeed__Billing_Credit_Memo__c = wr.lineOld.AcctSeed__Billing__c;
					bcm.Billing_Credit_Memo_Line__c = wr.lineOld.Id;
					bcm.AcctSeed__Amount__c *= (-1);
				}
				else
				{
					bcm.AcctSeed__Billing_Invoice__c = wr.lineOld.AcctSeed__Billing__c;
					bcm.Billing_Invoice_Line__c = wr.lineOld.Id;
					bcm.AcctSeed__Billing_Credit_Memo__c = wr.lineNew.AcctSeed__Billing__c;
					bcm.Billing_Credit_Memo_Line__c = wr.lineNew.Id;
				}

				listBCM.add(bcm);
			}

			if(listBCM.size() > 0)
				insert listBCM;

			if(ap.AcctSeed__Status__c != 'Posted')
			{
				Decimal amt = 0;

				for(AggregateResult aggRes : 
					[SELECT sum(AcctSeed__Total__c) amt
					 FROM AcctSeed__Billing_Line__c
					 WHERE AcctSeed__Billing__r.Account_Payable__c = :ap.Id
					   AND AcctSeed__Revenue_GL_Account__c = :idGlAR2AP
					   AND AcctSeed__Billing__r.AcctSeed__Status__c = 'Posted'])
				{
					amt = (Decimal)aggRes.get('amt');
				}

				list<AcctSeed__Account_Payable_Line__c> listAPL = new list<AcctSeed__Account_Payable_Line__c>();
				listAPL.addAll(
					[SELECT Id, AcctSeed__Amount__c 
					 FROM AcctSeed__Account_Payable_Line__c 
					 WHERE AcctSeed__Account_Payable__c = :ap.Id
					   AND AcctSeed__Expense_GL_Account__c = :idGlAR2AP]);
				if(listAPL.size() == 1)
				{
					listAPL[0].AcctSeed__Amount__c = amt;
					update listAPL;
				}
				else if(listAPL.size() == 0)
				{
					insert new AcctSeed__Account_Payable_Line__c(
						AcctSeed__Account_Payable__c = ap.Id,
						AcctSeed__Expense_GL_Account__c = idGlAR2AP,
						AcctSeed__Amount__c = amt
					);
				}
			}
		}
		return '';
	}

	private class wrapRow
	{	
		AcctSeed__Billing_Line__c lineOld{get;set;}
		AcctSeed__Billing_Line__c lineNew{get;set;}

		private wrapRow(AcctSeed__Billing_Line__c pLineOld, AcctSeed__Billing_Line__c pLineNew)
		{
			lineOld = pLineOld;
			lineNew = pLineNew;
		}
	}
}