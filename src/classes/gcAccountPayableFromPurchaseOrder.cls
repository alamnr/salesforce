global without sharing class gcAccountPayableFromPurchaseOrder {
	
	global gcAccountPayableFromPurchaseOrder() {}

	webservice static String createAccountPayable(String idPurchaseOrder, String vendorInvoiceNumber)
	{
		AcctSeedERP__Purchase_Order__c po = [SELECT Id, AcctSeedERP__Vendor__c FROM AcctSeedERP__Purchase_Order__c WHERE Id = :idPurchaseOrder][0];
		AcctSeed__Account_Payable__c ap = new AcctSeed__Account_Payable__c(
												AcctSeed__Vendor__c = po.AcctSeedERP__Vendor__c,
												AcctSeed__Date__c = date.Today(),
												AcctSeed__Payee_Reference__c = vendorInvoiceNumber,
												AcctSeedERP__Purchase_Order__c = po.Id);
		insert ap;

		//get the Vouchers Payable account
		Id idGLVP = [SELECT AcctSeed__Vouchers_Payable_GL_Account__c FROM AcctSeed__Accounting_Settings__c][0].AcctSeed__Vouchers_Payable_GL_Account__c;

		//get the VP balance for each Purchase Order Line
		list<AggregateResult> listAggRes = new list<AggregateResult>();

		listAggRes.addAll(
			[SELECT AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Purchase_Order_Line__c idPOL,
					sum(AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Quantity__c) qty,
					sum(AcctSeed__Amount__c) amt
			 FROM AcctSeed__Transaction__c
			 WHERE AcctSeed__GL_Account__c = :idGLVP
			   AND AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c = :po.Id
			   AND AcctSeedERP__Purchase_Order_Inventory_Movement__r.Account_Payable_Line__c = null
			   AND (AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0)
			 GROUP BY AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Purchase_Order_Line__c]);

		list<AcctSeed__Account_Payable_Line__c> listAPL = new list<AcctSeed__Account_Payable_Line__c>();
		map<Id,AcctSeedERP__Purchase_Order_Line__c> mapPOL = new map<Id,AcctSeedERP__Purchase_Order_Line__c>();

		//create the new AP Lines
		for(AggregateResult aggRes : listAggRes)
		{
			Decimal amt = (Decimal)aggRes.get('amt');

			if(amt != null && amt != 0)
			{
				mapPOL.put((Id)aggRes.get('idPOL'), null);
				listAPL.add(new AcctSeed__Account_Payable_Line__c(
					AcctSeed__Account_Payable__c = ap.Id,
					AcctSeed__Amount__c = amt,
					AcctSeed__Expense_GL_Account__c = idGLVP,
					AcctSeed__Quantity__c = (Decimal)aggRes.get('qty'),
					AcctSeedERP__Purchase_Order_Line__c = (Id)aggRes.get('idPOL')
				));
			}
		}

		//retrieve additional PO line details, to be used to populate the AP lines
		for(AcctSeedERP__Purchase_Order_Line__c pol : 
			[SELECT Id, AcctSeedERP__Product__c
			 FROM AcctSeedERP__Purchase_Order_Line__c
			 WHERE Id IN : mapPOL.keySet()])
		{
			mapPOL.put(pol.Id,pol);
		}

		//transfer the details of the PO lines to the new AP lines
		for(AcctSeed__Account_Payable_Line__c apl : listAPL)
		{
			AcctSeedERP__Purchase_Order_Line__c pol = mapPOL.get(apl.AcctSeedERP__Purchase_Order_Line__c);
			apl.AcctSeed__Product__c = pol.AcctSeedERP__Product__c;
		}

		//retrieve PO lines for non-inventory products, and create AP lines for them
		for(AcctSeedERP__Purchase_Order_Line__c pol : 
			[SELECT Id, 
				    AcctSeedERP__Product__c,
				    AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c,
				    AcctSeedERP__Quantity__c,
				    AcctSeedERP__Total__c,
				    (SELECT AcctSeed__Amount__c, AcctSeed__Quantity__c FROM AcctSeedERP__Account_Payable_Lines__r)
			 FROM AcctSeedERP__Purchase_Order_Line__c
			 WHERE AcctSeedERP__Purchase_Order__c = : po.Id
			   AND AcctSeedERP__Product__r.AcctSeed__Inventory_Product__c = false
			   AND AcctSeedERP__Total__c != 0])
		{
			Decimal qtyPaid = 0;
			Decimal amtPaid = 0;
			for(AcctSeed__Account_Payable_Line__c apl : pol.AcctSeedERP__Account_Payable_Lines__r)
			{
				if(apl.AcctSeed__Amount__c != null) amtPaid += apl.AcctSeed__Amount__c;
				if(apl.AcctSeed__Quantity__c != null) qtyPaid += apl.AcctSeed__Quantity__c;
			}

			Decimal qtyPurchased = pol.AcctSeedERP__Quantity__c;
			if(qtyPurchased == null) qtyPurchased = 0;
			Decimal amtPurchased = pol.AcctSeedERP__Total__c;
			if(amtPurchased == null) amtPurchased = 0;

			if(amtPaid.setScale(6) < amtPurchased.setScale(6))
			listAPL.add(new AcctSeed__Account_Payable_Line__c(
				AcctSeed__Account_Payable__c = ap.Id,
				AcctSeed__Amount__c = (amtPurchased - amtPaid).setScale(6),
				AcctSeed__Quantity__c = (qtyPurchased - qtyPaid).setScale(6),
				AcctSeed__Expense_GL_Account__c = pol.AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c,
				AcctSeedERP__Purchase_Order_Line__c = pol.Id
			));
		}

		insert listAPL;

		//prepare to update the Purchase Order Inventory Movements with the new AP Lines
		map<Id,Id> mapPOLtoAPL = new map<Id,Id>();
		for(AcctSeed__Account_Payable_Line__c apl : listAPL)
		{
			mapPOLtoAPL.put(apl.AcctSeedERP__Purchase_Order_Line__c, apl.Id);
		}

		//update the Purchase Order Inventory Movements
		list<AcctSeedERP__Purchase_Order_Inventory_Movement__c> listMove = new list<AcctSeedERP__Purchase_Order_Inventory_Movement__c>();
		for(AcctSeedERP__Purchase_Order_Inventory_Movement__c move :
			[SELECT Id, AcctSeedERP__Purchase_Order_Line__c, Account_Payable_Line__c
			 FROM AcctSeedERP__Purchase_Order_Inventory_Movement__c
			 WHERE AcctSeedERP__Purchase_Order_Line__c IN : mapPOLtoAPL.keySet()
			   AND Account_Payable_Line__c = null])
		{
			move.Account_Payable_Line__c = mapPOLtoAPL.get(move.AcctSeedERP__Purchase_Order_Line__c);
			listMove.add(move);
		}

		gcPurchaseOrderInventoryMovement.disableTrigger = true;
		update listMove;
		gcPurchaseOrderInventoryMovement.disableTrigger = false;

		return String.valueOf(ap.Id);
	}
}