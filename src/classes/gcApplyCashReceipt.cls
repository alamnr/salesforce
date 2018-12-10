public without sharing class gcApplyCashReceipt {
	
	public Id srchIdAccount{get;set;}
	public Id srchIdCashReceipt{get;set;}

	public static List<PickListValues> lstAdjustmentGL  = new List<PickListValues>();
	public static List<PickListValues> lstPeriods = new List<PickListValues>();

	public gcApplyCashReceipt()	{}
	

    @RemoteAction
	public static list<CashReceiptWrapper> LoadCashReceipts(String idAccount, String idCashReceipt, Boolean includeAll)
	{

		list<CashReceiptWrapper> lstCR = new list<CashReceiptWrapper>();

		String s = 'SELECT id, Name, AcctSeed__Account__c, AcctSeed__Account__r.Name, AcctSeed__Purpose__c, AcctSeed__Payment_Reference__c,';
		s += 'AcctSeed__Balance__c, AcctSeed__Receipt_Date__c, AcctSeed__Amount__c, AcctSeed__Applied_Amount__c ';
		s += 'FROM AcctSeed__Cash_Receipt__c ';
		if (includeAll)
			s += 'WHERE AcctSeed__Account__c = :idAccount ';
		else
			s += 'WHERE id = :idCashReceipt ';

		s += ' ORDER BY AcctSeed__Receipt_Date__c desc';

		system.debug (s);
		for (AcctSeed__Cash_Receipt__c cr : Database.query(s))
		{

			Decimal AmountReceived = (cr.AcctSeed__Amount__c != null ? cr.AcctSeed__Amount__c : 0);
   			Decimal AmountApplied = (cr.AcctSeed__Applied_Amount__c != null ? cr.AcctSeed__Applied_Amount__c : 0);
   			Decimal AmountUnapplied = AmountReceived - AmountApplied;

			CashReceiptWrapper crRec = new CashReceiptWrapper();
			crRec.idCashReceipt = cr.Id;
			crRec.CashReceiptName = cr.Name;
			crRec.AccountName = cr.AcctSeed__Account__r.Name;
			crRec.Reference = cr.AcctSeed__Payment_Reference__c;
			crRec.ReceiptDate = cr.AcctSeed__Receipt_Date__c;
			crRec.decReceived = AmountReceived;
			crRec.decAppliedNew = AmountApplied;
			crRec.decAppliedOld = AmountApplied;
			crRec.decUnapplied = AmountUnapplied;
			lstCR.add(crRec);
		}
		return lstCR;
	}

	@RemoteAction
	public static list<BillWrapper> RetrieveBills(Id idCashReceipt, Id idAccount)
	{

		List<BillWrapper> listBills = new List<BillWrapper>();
		set<Id> setAssignedBill = new set<Id>();
		set<Id> setAssignedLine = new set<Id>();
		set<Id> setBills = new set<Id>();
		map<Id,BillWrapper> mapBills = new map<Id,BillWrapper>();

		//Collect all bills that have a billing cash receipt that does not have a bill line assigned
		for(AcctSeed__Billing_Cash_Receipt__c bcr : 
         		[SELECT AcctSeed__Billing__c, Billing_Line__c
         		 FROM AcctSeed__Billing_Cash_Receipt__c
         		 WHERE AcctSeed__Cash_Receipt__c = :idCashReceipt AND Billing_Line__c = null])
		{
			setAssignedBill.add(bcr.AcctSeed__Billing__c);
		}

		//Collect all bills that have a billing cash receipt that does have a bill line assigned
		for(AcctSeed__Billing_Cash_Receipt__c bcr : 
         		[SELECT AcctSeed__Billing__c, Billing_Line__c
         		 FROM AcctSeed__Billing_Cash_Receipt__c
         		 WHERE AcctSeed__Cash_Receipt__c = :idCashReceipt AND Billing_Line__c != null])
		{
			setAssignedLine.add(bcr.AcctSeed__Billing__c);
		}

		//Collect the billings that have a matching billing cash receipt
		for(AcctSeed__Billing_Cash_Receipt__c bcr : 
         		[SELECT AcctSeed__Billing__c 
         		 FROM AcctSeed__Billing_Cash_Receipt__c
         		 WHERE AcctSeed__Cash_Receipt__c = :idCashReceipt])
		{
			setBills.add(bcr.AcctSeed__Billing__c);
		}

		for (AcctSeed__Billing__c b : 
				[SELECT Id, Name, AcctSeed__Customer__r.Name,
				AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Name,
				AcctSeedERP__Sales_Order__r.PO_Number__c,
				AcctSeedERP__Sales_Order__r.Fill_Date__c,
				AcctSeed__Date__c, AcctSeed__Total__c,
				AcctSeed__Credit_Memo_Applied_Amount__c
				FROM AcctSeed__Billing__c
				WHERE AcctSeed__Customer__c =: idAccount AND AcctSeed__Status__c = 'Posted'
	        	AND (AcctSeed__Balance__c > 0 OR Id IN :setBills)
				ORDER BY AcctSeed__Date__c desc])
		{

			BillWrapper i = new BillWrapper();
			i.idBill = b.Id;
	        i.BillingName = b.Name;
	        i.BillDate = b.AcctSeed__Date__c.format();
	        //i.FillDate = b.AcctSeedERP__Sales_Order__r.Fill_Date__c.format();
	        i.BillingCustomer = b.AcctSeed__Customer__r.Name;
	        i.OrderCustomer = b.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Name;
	        i.PONumber = b.AcctSeedERP__Sales_Order__r.PO_Number__c;
	        i.decCreditMemo = b.AcctSeed__Credit_Memo_Applied_Amount__c;
			i.decTotalCost = b.AcctSeed__Total__c;
			mapBills.put(b.Id, i);
		}


		//Get all AppliedOther
		for (AcctSeed__Billing_Cash_Receipt__c bcr : [SELECT Id, AcctSeed__Adjustment_Amount__c,
			AcctSeed__Billing__c, AcctSeed__Applied_Amount__c 
			FROM AcctSeed__Billing_Cash_Receipt__c
			WHERE AcctSeed__Billing__c IN :mapBills.keySet() AND AcctSeed__Cash_Receipt__c <> :idCashReceipt])
		{
			if(mapBills.containsKey(bcr.AcctSeed__Billing__c)){
				system.debug(bcr.AcctSeed__Applied_Amount__c);
				system.debug(bcr.AcctSeed__Adjustment_Amount__c);

				mapBills.get(bcr.AcctSeed__Billing__c).decAppliedOther += bcr.AcctSeed__Applied_Amount__c;
				if (bcr.AcctSeed__Adjustment_Amount__c != Null)
					mapBills.get(bcr.AcctSeed__Billing__c).decAdjustedOther += bcr.AcctSeed__Adjustment_Amount__c;
			}
		}

		//Get all decAdjustedOld and decAppliedOld, 
		for (AcctSeed__Billing_Cash_Receipt__c bcr : [SELECT Id, AcctSeed__Adjustment_Amount__c,
			AcctSeed__Billing__c, AcctSeed__Applied_Amount__c, AcctSeed__Accounting_Period__r.AcctSeed__Status__c,
			AcctSeed__Accounting_Period__r.Id, AcctSeed__Accounting_Period__r.Name,
			AcctSeed__Adjustment_GL_Account__r.Id, AcctSeed__Adjustment_GL_Account__r.Name
			FROM AcctSeed__Billing_Cash_Receipt__c
			WHERE AcctSeed__Billing__c IN :mapBills.keySet() AND AcctSeed__Cash_Receipt__c = :idCashReceipt])
		{
			if(mapBills.containsKey(bcr.AcctSeed__Billing__c))
			{
				mapBills.get(bcr.AcctSeed__Billing__c).decAppliedOld += bcr.AcctSeed__Applied_Amount__c;
				mapBills.get(bcr.AcctSeed__Billing__c).decAppliedNew += bcr.AcctSeed__Applied_Amount__c;
				if (bcr.AcctSeed__Adjustment_Amount__c != Null){
					mapBills.get(bcr.AcctSeed__Billing__c).decAdjustedOld += bcr.AcctSeed__Adjustment_Amount__c;
					mapBills.get(bcr.AcctSeed__Billing__c).decAdjustedNew += bcr.AcctSeed__Adjustment_Amount__c;
				}
				mapBills.get(bcr.AcctSeed__Billing__c).idPeriodOld = bcr.AcctSeed__Accounting_Period__r.Id;
				mapBills.get(bcr.AcctSeed__Billing__c).idPeriodNew = bcr.AcctSeed__Accounting_Period__r.Id;
				mapBills.get(bcr.AcctSeed__Billing__c).PeriodName = bcr.AcctSeed__Accounting_Period__r.Name;
				mapBills.get(bcr.AcctSeed__Billing__c).PeriodClosed = bcr.AcctSeed__Accounting_Period__r.AcctSeed__Status__c == 'Closed';
				mapBills.get(bcr.AcctSeed__Billing__c).idAdjustmentGLOld = bcr.AcctSeed__Adjustment_GL_Account__r.Id;
				mapBills.get(bcr.AcctSeed__Billing__c).idAdjustmentGLNew = bcr.AcctSeed__Adjustment_GL_Account__r.Id;
				mapBills.get(bcr.AcctSeed__Billing__c).AdjustmentGLName = bcr.AcctSeed__Adjustment_GL_Account__r.Name;
			
			}
		}

		for(BillWrapper i : mapBills.values())
		{

			i.decBalance = (i.decTotalCost - i.decAppliedOther - i.decAppliedOld - i.decAdjustedOther - i.decAdjustedOld - i.decCreditMemo).setScale(2);

			i.assignLevelOld = 0;

			if (setAssignedBill.contains(i.idBill))
				i.assignLevelOld = 1;
			else if (setAssignedLine.contains(i.idBill))
				i.assignLevelOld = 2;

			i.assignLevelNew = i.assignLevelOld;

			listBills.add(i);
		}  

	 	return listBills;    
	}

	@RemoteAction
	public static list<BillLineWrapper> RetrieveBillLines(Id idCashReceipt, Id idBill)
	{

		list<BillLineWrapper> lstBillLines = new list<BillLineWrapper>();
    	map<Id, BillLineWrapper> mapBillLines = new map<Id, BillLineWrapper>();
	

		for (AcctSeed__Billing_Line__c bl : 
				[SELECT Id, Name, AcctSeedERP__Sales_Order_Line__r.Lot__r.Name, 
				AcctSeed__Total__c,	AcctSeed__Product__r.Name, AcctSeed__Hours_Units__c, AcctSeed__Rate__c,
				AcctSeed__Billing__c
				FROM AcctSeed__Billing_Line__c
				WHERE AcctSeed__Billing__c = :idBill
				ORDER BY Name desc])
		{
			BillLineWrapper li = new BillLineWrapper();
			li.idBill = idBill;
			li.idBillLine = bl.Id;
			li.BillLineName = bl.Name;
			li.Product = bl.AcctSeed__Product__r.Name;
			li.Lot = bl.AcctSeedERP__Sales_Order_Line__r.Lot__r.Name;
			li.UnitCost = bl.AcctSeed__Rate__c;
			li.Quantity = bl.AcctSeed__Hours_Units__c;
			li.decTotalCost = bl.AcctSeed__Total__c;
			mapBillLines.put(bl.Id, li);
		}

		//Get all AppliedOther
		for (AcctSeed__Billing_Cash_Receipt__c bcr : [SELECT Id, AcctSeed__Adjustment_Amount__c,
			AcctSeed__Billing__c, Billing_Line__c, AcctSeed__Applied_Amount__c 
			FROM AcctSeed__Billing_Cash_Receipt__c
			WHERE Billing_Line__c IN :mapBillLines.keySet() AND AcctSeed__Cash_Receipt__c <> :idCashReceipt])
		{
			if(mapBillLines.containsKey(bcr.Billing_Line__c)){
				mapBillLines.get(bcr.Billing_Line__c).decAppliedOther += bcr.AcctSeed__Applied_Amount__c;
				if (bcr.AcctSeed__Adjustment_Amount__c != Null)
					mapBillLines.get(bcr.Billing_Line__c).decAdjustedOther += bcr.AcctSeed__Adjustment_Amount__c;
			}
		}

		//Get all decAppliedOld and decAdjustedOld
		for (AcctSeed__Billing_Cash_Receipt__c bcr : [SELECT Id, AcctSeed__Adjustment_Amount__c,
			AcctSeed__Billing__c, AcctSeed__Applied_Amount__c, AcctSeed__Accounting_Period__r.AcctSeed__Status__c,
			AcctSeed__Accounting_Period__r.Id, AcctSeed__Accounting_Period__r.Name,
			AcctSeed__Adjustment_GL_Account__r.Id, AcctSeed__Adjustment_GL_Account__r.Name, Billing_Line__c
			FROM AcctSeed__Billing_Cash_Receipt__c
			WHERE Billing_Line__c IN :mapBillLines.keySet() AND AcctSeed__Cash_Receipt__c = :idCashReceipt])
		{
			if(mapBillLines.containsKey(bcr.Billing_Line__c))
			{
				mapBillLines.get(bcr.Billing_Line__c).decAppliedOld += bcr.AcctSeed__Applied_Amount__c;
				mapBillLines.get(bcr.Billing_Line__c).decAppliedNew += bcr.AcctSeed__Applied_Amount__c;
				if (bcr.AcctSeed__Adjustment_Amount__c != Null){
					mapBillLines.get(bcr.Billing_Line__c).decAdjustedOld += bcr.AcctSeed__Adjustment_Amount__c;
					mapBillLines.get(bcr.Billing_Line__c).decAdjustedNew += bcr.AcctSeed__Adjustment_Amount__c;
				}
				mapBillLines.get(bcr.Billing_Line__c).idPeriodOld = bcr.AcctSeed__Accounting_Period__r.Id;
				mapBillLines.get(bcr.Billing_Line__c).idPeriodNew = bcr.AcctSeed__Accounting_Period__r.Id;
				mapBillLines.get(bcr.Billing_Line__c).PeriodName = bcr.AcctSeed__Accounting_Period__r.Name;
				mapBillLines.get(bcr.Billing_Line__c).PeriodClosed = bcr.AcctSeed__Accounting_Period__r.AcctSeed__Status__c == 'Closed';
				mapBillLines.get(bcr.Billing_Line__c).idAdjustmentGLOld = bcr.AcctSeed__Adjustment_GL_Account__r.Id;
				mapBillLines.get(bcr.Billing_Line__c).idAdjustmentGLNew = bcr.AcctSeed__Adjustment_GL_Account__r.Id;
				mapBillLines.get(bcr.Billing_Line__c).AdjustmentGLName = bcr.AcctSeed__Adjustment_GL_Account__r.Name;			
			}
		}

		for(BillLineWrapper il : mapBillLines.values())
		{

			il.decBalance = (il.decTotalCost - il.decAppliedOther - il.decAppliedOld - il.decAdjustedOther - il.decAdjustedOld).setScale(2);
			lstBillLines.add(il);
		}  

	 	return lstBillLines;    
	}

	//@RemoteAction
	//public static string SaveBillLines(Id idCashReceipt, list<map<string,string>> listRow)
	//{

	//	//All rows that get here have a difference between amount previously applied and amount
	//	//currently applied.  So, each line needs to have any bcr from an open period deleted and 
	//	//a new one created with the new amount

	//	set<Id> setIdLineDeleteBCRs = new set<Id>();
	//	list<AcctSeed__Billing_Cash_Receipt__c> listBCRinsert = new list<AcctSeed__Billing_Cash_Receipt__c>();
		
	//	//cycle over the wrapped lines, and collect the ones that have a change in cash application
	//	for(map<string,string> m : listRow)
	//	{
	//		system.debug('found one');
	//		Decimal decAppliedOld = (Decimal.valueOf(m.get('AppliedOld'))).setScale(2);
	//		Decimal decAppliedNew = (Decimal.valueOf(m.get('AppliedNew'))).setScale(2);
	//		if(decAppliedNew != decAppliedOld)
	//		{

	//			Decimal decAppliedClosed = (Decimal.valueOf(m.get('AppliedClosed'))).setScale(2);
				
	//			String idBill = m.get('idBill');
	//			String idBillLine = m.get('idBillingLine');

	//			if(decAppliedNew > decAppliedClosed)
	//			{
	//				listBCRinsert.add(new AcctSeed__Billing_Cash_Receipt__c
	//				(	AcctSeed__Applied_Amount__c = decAppliedNew - decAppliedClosed,
	//					AcctSeed__Billing__c = idBill,
	//					AcctSeed__Cash_Receipt__c = idCashReceipt,
	//					Billing_Line__c = idBillLine
	//				));
	//			}
					
	//			setIdLineDeleteBCRs.add(idBillLine);
	//		}
	//	}
		
	//	//Find which BCR's should be deleted
	//	list<AcctSeed__Billing_Cash_Receipt__c> listBCRdelete = new list<AcctSeed__Billing_Cash_Receipt__c>();
	//	if(setIdLineDeleteBCRs.size() >0)
	//	{		
	//		for(AcctSeed__Billing_Cash_Receipt__c bcr :
	//			[SELECT Id FROM AcctSeed__Billing_Cash_Receipt__c
	//			 WHERE Billing_Line__c IN : setIdLineDeleteBCRs
	//			   AND AcctSeed__Cash_Receipt__c = :idCashReceipt
	//			   AND AcctSeed__Accounting_Period__r.AcctSeed__Status__c ='Open'])
	//		{
	//			listBCRdelete.add(bcr);
	//		}
	//	}
		
	//	if(listBCRdelete.size() >0) delete listBCRdelete;
	//	if(listBCRinsert.size() >0) insert listBCRinsert;

	//	return '';
	//}

	@RemoteAction
	public static string SaveBillLines(Id idCashReceipt, list<BillLineWrapper> lstInvoiceLines)
	{


		set<Id> setIdLineDeleteBCRs = new set<Id>();
		list<AcctSeed__Billing_Cash_Receipt__c> listBCRinsert = new list<AcctSeed__Billing_Cash_Receipt__c>();
		
		//cycle over the wrapped lines, and collect the ones that have a change in cash application
		for(BillLineWrapper bl : lstInvoiceLines)
		{
			
			if(bl.decAppliedNew != bl.decAppliedOld || bl.idPeriodOld != bl.idPeriodNew || bl.idAdjustmentGLOld != bl.idAdjustmentGLNew || bl.decAdjustedOld != bl.decAdjustedNew)
			{
				if(bl.decAppliedNew != 0 || bl.decAdjustedNew != 0)
				{
					AcctSeed__Billing_Cash_Receipt__c NewBCR = new AcctSeed__Billing_Cash_Receipt__c();

					NewBCR.AcctSeed__Applied_Amount__c = bl.decAppliedNew;
					NewBCR.AcctSeed__Billing__c = bl.idBill;
					NewBCR.AcctSeed__Cash_Receipt__c = idCashReceipt;
					NewBCR.Billing_Line__c = bl.idBillLine;
					if (bl.idPeriodNew != '0') NewBCR.AcctSeed__Accounting_Period__c = bl.idPeriodNew;

					if (bl.decAdjustedNew != 0)
					{
						NewBCR.AcctSeed__Adjustment_Amount__c = bl.decAdjustedNew;
						NewBCR.AcctSeed__Adjustment_GL_Account__c = bl.idAdjustmentGLNew;
					}

					listBCRinsert.add(NewBCR);
					setIdLineDeleteBCRs.add(bl.idBillLine);	
				}
			}
		}
		
		//Find which BCR's should be deleted
		list<AcctSeed__Billing_Cash_Receipt__c> listBCRdelete = new list<AcctSeed__Billing_Cash_Receipt__c>();
		if(setIdLineDeleteBCRs.size() >0)
		{		
			for(AcctSeed__Billing_Cash_Receipt__c bcr :
				[SELECT Id FROM AcctSeed__Billing_Cash_Receipt__c
				 WHERE Billing_Line__c IN : setIdLineDeleteBCRs
				   AND AcctSeed__Cash_Receipt__c = :idCashReceipt
				   AND AcctSeed__Accounting_Period__r.AcctSeed__Status__c ='Open'])
			{
				listBCRdelete.add(bcr);
			}
		}
		
		if(listBCRdelete.size() >0) delete listBCRdelete;
		if(listBCRinsert.size() >0) insert listBCRinsert;

		return '';
	}

	@RemoteAction
	public static string SaveBills(Id idCashReceipt, list<BillWrapper> lstInvoices)
	{

		set<Id> setIdDeleteBCRs = new set<Id>();
		list<AcctSeed__Billing_Cash_Receipt__c> listBCRinsert = new list<AcctSeed__Billing_Cash_Receipt__c>();
		
		//cycle over the wrapped lines, and collect the ones that have a change in cash application
		for(BillWrapper b : lstInvoices)
		{
			if(b.decAppliedNew != b.decAppliedOld || b.idPeriodOld != b.idPeriodNew || b.idAdjustmentGLOld != b.idAdjustmentGLNew || b.decAdjustedOld != b.decAdjustedNew)
			{
				if(b.decAppliedNew != 0 || b.decAdjustedNew != 0)
				{
					
					AcctSeed__Billing_Cash_Receipt__c NewBCR = new AcctSeed__Billing_Cash_Receipt__c();

					NewBCR.AcctSeed__Applied_Amount__c = b.decAppliedNew;
					NewBCR.AcctSeed__Billing__c = b.idBill;
					NewBCR.AcctSeed__Cash_Receipt__c = idCashReceipt;
					if (b.idPeriodNew != '0') NewBCR.AcctSeed__Accounting_Period__c = b.idPeriodNew;

					if (b.decAdjustedNew != 0)
					{
						NewBCR.AcctSeed__Adjustment_Amount__c = b.decAdjustedNew;
						if (b.idAdjustmentGLNew != '0') NewBCR.AcctSeed__Adjustment_GL_Account__c = b.idAdjustmentGLNew;
					}

					listBCRinsert.add(NewBCR);
					setIdDeleteBCRs.add(b.idBill);	
				}
			}
		}
		
		//Find which BCR's should be deleted
		list<AcctSeed__Billing_Cash_Receipt__c> listBCRdelete = new list<AcctSeed__Billing_Cash_Receipt__c>();
		if(setIdDeleteBCRs.size() >0)
		{		
			for(AcctSeed__Billing_Cash_Receipt__c bcr :
				[SELECT Id FROM AcctSeed__Billing_Cash_Receipt__c
				 WHERE AcctSeed__Billing__c IN : setIdDeleteBCRs
				   AND AcctSeed__Cash_Receipt__c = :idCashReceipt
				   AND AcctSeed__Accounting_Period__r.AcctSeed__Status__c ='Open'])
			{
				listBCRdelete.add(bcr);
			}
		}
		
		if(listBCRdelete.size() >0) delete listBCRdelete;
		if(listBCRinsert.size() >0) insert listBCRinsert;

		return '';
	}

	@RemoteAction
	public static String crToRevenue(Id idCashReceipt, Id idGL, Decimal decAmount, String strComment)
	{	

		List<AcctSeed__Billing__c> lstBillings = new List<AcctSeed__Billing__c>();
		
		AcctSeed__Cash_Receipt__c cr = [SELECT Id, AcctSeed__Balance__c, AcctSeed__Account__c 
										FROM AcctSeed__Cash_Receipt__c WHERE Id = : idCashReceipt LIMIT 1];

		//Create billing record
		AcctSeed__Billing__c b = new AcctSeed__Billing__c(
			AcctSeed__Date__c = date.Today(),
			AcctSeed__Customer__c = cr.AcctSeed__Account__c);
		insert b;

		//Create billing line item record
		AcctSeed__Billing_Line__c bl = new AcctSeed__Billing_Line__c(
			AcctSeed__Billing__c = b.Id,
			Override__c = true,
			AcctSeed__Revenue_GL_Account__c = idGL,
			AcctSeed__Hours_Units__c = 1,
			AcctSeed__Rate__c = decAmount);
		insert bl;
	
		//Post billing
		lstBillings.add(b);
		AcctSeed.BillingPostService.postBillings(lstBillings);
		
		//Create billing cash receipt record
		AcctSeed__Billing_Cash_Receipt__c bcr = new AcctSeed__Billing_Cash_Receipt__c(
			AcctSeed__Billing__c = b.Id,
			Billing_Line__c = bl.Id,
			AcctSeed__Cash_Receipt__c = cr.Id,
			AcctSeed__Applied_Amount__c = decAmount);
		insert bcr;

		return  '';
	}


	@RemoteAction
	public static String crToRefund(Id idCashReceipt, Id idGL, Decimal decAmount, String strComment)
	{

		//These lists are only for posting
		List<AcctSeed__Billing__c> lstBillings = new List<AcctSeed__Billing__c>();
		List<AcctSeed__Account_Payable__c> lstAP = new List<AcctSeed__Account_Payable__c>();
		

		AcctSeed__Cash_Receipt__c cr = [SELECT Id, Name, AcctSeed__Balance__c, AcctSeed__Account__c 
										FROM AcctSeed__Cash_Receipt__c WHERE Id = : idCashReceipt LIMIT 1];

		//Create billing record
		AcctSeed__Billing__c b = new AcctSeed__Billing__c(
			AcctSeed__Date__c = date.Today(),
			AcctSeed__Billing_Comment__c = strComment,
			AcctSeed__Customer__c = cr.AcctSeed__Account__c);
		insert b;

		//Create billing line item record
		AcctSeed__Billing_Line__c bl = new AcctSeed__Billing_Line__c(
			AcctSeed__Billing__c = b.Id,
			Override__c = true,
			AcctSeed__Revenue_GL_Account__c = idGL,
			AcctSeed__Hours_Units__c = 1,
			AcctSeed__Rate__c = decAmount);
		insert bl;
	
		//Post billing
		lstBillings.add(b);
		AcctSeed.BillingPostService.postBillings(lstBillings);
		
		//Create billing cash receipt record
		AcctSeed__Billing_Cash_Receipt__c bcr = new AcctSeed__Billing_Cash_Receipt__c(
			AcctSeed__Billing__c = b.Id,
			Billing_Line__c = bl.Id,
			AcctSeed__Cash_Receipt__c = cr.Id,
			AcctSeed__Applied_Amount__c = decAmount);
		insert bcr;

		AcctSeed__Account_Payable__c ap = new AcctSeed__Account_Payable__c(
		 	AcctSeed__Vendor__c = cr.AcctSeed__Account__c,
		 	AcctSeed__Payee_Reference__c = cr.Name,
		 	Decription__c = strComment,
			AcctSeed__Date__c = date.Today());
		insert ap;
				
		AcctSeed__Account_Payable_Line__c apl = new AcctSeed__Account_Payable_Line__c(
			AcctSeed__Account_Payable__c = ap.id,
		 	AcctSeed__Expense_GL_Account__c = idGL,
			AcctSeed__Date__c = date.Today(),
			AcctSeed__Amount__c = decAmount);
		insert apl;

		//Post AP
		lstAP.add(ap);
	 	AcctSeed.AccountPayablePostService.postAccountPayables(lstAP);

		return '';

	}


	@RemoteAction
	public static String createCreditMemo(Id idCashReceipt, Id idGL, Decimal decAmount, String strComment)
	{	

		List<AcctSeed__Billing__c> lstBillings = new List<AcctSeed__Billing__c>();
		
		AcctSeed__Cash_Receipt__c cr = [SELECT Id, AcctSeed__Balance__c, AcctSeed__Account__c 
										FROM AcctSeed__Cash_Receipt__c WHERE Id = : idCashReceipt LIMIT 1];

		//Create billing record
		AcctSeed__Billing__c b = new AcctSeed__Billing__c(
			AcctSeed__Date__c = date.Today(),
			AcctSeed__Billing_Comment__c = strComment,
			AcctSeed__Customer__c = cr.AcctSeed__Account__c);
		insert b;

		//Create billing line item record
		AcctSeed__Billing_Line__c bl = new AcctSeed__Billing_Line__c(
			AcctSeed__Billing__c = b.Id,
			Override__c = true,
			AcctSeed__Revenue_GL_Account__c = idGL,
			AcctSeed__Hours_Units__c = 1,
			AcctSeed__Rate__c = decAmount * -1);
		insert bl;
	
		//Post billing
		lstBillings.add(b);
		AcctSeed.BillingPostService.postBillings(lstBillings);
		
		//Create billing cash receipt record
		AcctSeed__Billing_Cash_Receipt__c bcr = new AcctSeed__Billing_Cash_Receipt__c(
			AcctSeed__Billing__c = b.Id,
			Billing_Line__c = bl.Id,
			AcctSeed__Cash_Receipt__c = cr.Id,
			AcctSeed__Applied_Amount__c = decAmount * -1);
		insert bcr;

		return '';
	}

	@RemoteAction @ReadOnly
	public static list<PickListValues> retrieveAdjustmentGL()
	{

		PickListValues Glrec;

		if (lstAdjustmentGL.size() > 0)
			return lstAdjustmentGL;

		Glrec = new PickListValues();
		Glrec.id = '0';
		Glrec.name = '';
		lstAdjustmentGL.add(Glrec);	

		for(AcctSeed__GL_Account__c gl : 
         		[SELECT Id, Name, Uniquefier__c 
         		 FROM AcctSeed__GL_Account__c
         		 WHERE AcctSeed__Active__c = true
         		 ORDER BY Name])
         		 //WHERE AcctSeed__Type__c = 'Revenue' ORDER BY Name])
		{

			Glrec = new PickListValues();
			Glrec.id = (String)gl.Id;
			Glrec.name = gl.Name;
			lstAdjustmentGL.add(Glrec);	
		}
		
		return lstAdjustmentGL;
	}


	@RemoteAction @ReadOnly
	public static list<PickListValues> retrievePeriods()
	{

		PickListValues Prec;

		if (lstPeriods.size() > 0)
			return lstPeriods;

		Prec = new PickListValues();
		Prec.id = '0';
		Prec.name = '';
		lstPeriods.add(Prec);

		for(AcctSeed__Accounting_Period__c p : 
         		[SELECT Id, Name 
         		 FROM AcctSeed__Accounting_Period__c
         		 WHERE AcctSeed__Start_Date__c <= TODAY AND AcctSeed__Status__c = 'Open' ORDER BY AcctSeed__Start_Date__c desc])
		{


			Prec = new PickListValues();
			Prec.id = (String)p.Id;
			Prec.name = p.Name;
			lstPeriods.add(Prec);	
		}
		return lstPeriods;
	}

	public class PickListValues
	{
		public String id;
		public String name;
	}

	public class BillLineWrapper
	{
		public Id idBillLine;
		public Id idBill;
		public String idPeriodOld;
		public String idPeriodNew;
		public Boolean PeriodClosed;
		public String BillLineName;
		public String Product;
		public String Lot;
		public Decimal UnitCost;
		public Decimal Quantity;
		public String PeriodName;
		public String idAdjustmentGLOld;
		public String idAdjustmentGLNew;
		public String AdjustmentGLName;
		public Decimal decAppliedOld;		//applied from this cash receipt, before any changes
		public Decimal decAppliedNew;	 	//applied from this cash receipt, after changes
		public Decimal decAppliedOther;
		public Decimal decAdjustedOld;		//applied from this cash receipt, before any changes
		public Decimal decAdjustedNew;	 	//applied from this cash receipt, after changes
		public Decimal decAdjustedOther; 	//applied from other cash receipts
		public Decimal decBalance;
		public Decimal decTotalCost;

		
		public BillLineWrapper()
		{
			decAppliedOld = 0;
			decAppliedNew = 0;
			decAppliedOther = 0;
			decAdjustedOld = 0;
			decAdjustedNew = 0;
			decAdjustedOther = 0;
			decTotalCost = 0;
			decBalance = 0;
			idAdjustmentGLOld = '0';
			idAdjustmentGLNew = '0';
			idPeriodOld = '0';
			idPeriodNew = '0';
			PeriodClosed = False;
		}
	}

	public class BillWrapper
	{
		public String idBill;
		public String idPeriodOld;
		public String idPeriodNew;
		public Integer assignLevelOld;
		public Integer assignLevelNew;
		public Boolean PeriodClosed;
        public String BillingName;
        public String BillDate;
        public String FillDate;
        public String BillingCustomer;
        public String OrderCustomer;
        public String PONumber;
        public String PeriodName;
		public String idAdjustmentGLOld;
		public String idAdjustmentGLNew;
		public String AdjustmentGLName;
		public Decimal decAppliedOld;		//applied from this cash receipt, before any changes
		public Decimal decAppliedNew;	 	//applied from this cash receipt, after changes
		public Decimal decAppliedOther;
		public Decimal decAdjustedOld;		//applied from this cash receipt, before any changes
		public Decimal decAdjustedNew;	 	//applied from this cash receipt, after changes
		public Decimal decAdjustedOther; 	//applied from other cash receipts
		public Decimal decBalance;
		public Decimal decTotalCost;
		public Decimal decCreditMemo;

		public BillWrapper()
		{
			decAppliedOld = 0;
			decAppliedNew = 0;
			decAppliedOther = 0;
			decAdjustedOld = 0;
			decAdjustedNew = 0;
			decAdjustedOther = 0;
			decTotalCost = 0;
			decBalance = 0;
			PeriodClosed = False;
			idPeriodOld = '0';
			idPeriodNew = '0';
			idAdjustmentGLOld = '0';
			idAdjustmentGLNew = '0';
			assignLevelOld = 0;
			assignLevelNew = 0;
		}
	}

	public class CashReceiptWrapper
	{
		public String idCashReceipt;
		public String CashReceiptName;
		public String AccountName;
		public String Reference;
		public Date ReceiptDate;
		public Decimal decReceived;
		public Decimal decAppliedNew;
		public Decimal decAppliedOld;
		public Decimal decUnapplied;

		public CashReceiptWrapper()
		{
			decReceived = 0;
			decAppliedNew = 0;
			decAppliedOld = 0;
			decUnapplied = 0;

		}
	}

}