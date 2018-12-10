global without sharing class gcAccountPayableLine {

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
		(map<Id,AcctSeed__Account_Payable_Line__c> oldMap,
		 map<Id,AcctSeed__Account_Payable_Line__c> newMap,
		 list<AcctSeed__Account_Payable_Line__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeed__Account_Payable_Line__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeed__Account_Payable_Line__c>();
		if(listNew == NULL) listNew = new list<AcctSeed__Account_Payable_Line__c>();

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
		(map<Id,AcctSeed__Account_Payable_Line__c> oldMap,
		 map<Id,AcctSeed__Account_Payable_Line__c> newMap,
		 list<AcctSeed__Account_Payable_Line__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			//collect the products and purchase order lines
			map<Id,Product2> mapProduct = new map<Id,Product2>();
			map<Id,wrapPOL> mapWrapPOL = new map<Id,wrapPOL>();
			for(AcctSeed__Account_Payable_Line__c apl : listNew)
			{
				mapProduct.put(apl.AcctSeed__Product__c,null);
				mapWrapPOL.put(apl.AcctSeedERP__Purchase_Order_Line__c,null);
			}
			mapProduct.remove(null);
			mapWrapPOL.remove(null);
			if(mapProduct.size() > 0)
			for(Product2 p : 
					[SELECT Id, 
							AcctSeed__Expense_GL_Account__c, 
							AcctSeed__GL_Account_Variable_3__c,
							AcctSeed__Inventory_Product__c
					 FROM 	Product2 
					 WHERE 	Id IN :mapProduct.keySet()])
			{
				mapProduct.put(p.Id,p);
			}
			if(mapWrapPOL.size() > 0)
			for(AcctSeedERP__Purchase_Order_Line__c pol :
					[SELECT Id,
							AcctSeedERP__Product__c,
							AcctSeedERP__Product__r.AcctSeed__Inventory_Product__c,
							AcctSeedERP__Quantity__c, 
							AcctSeedERP__Quantity_Received__c,
							AcctSeedERP__Total__c
					 FROM AcctSeedERP__Purchase_Order_Line__c
					 WHERE Id IN :mapWrapPOL.keySet()])
			{
				mapWrapPOL.put(pol.Id, new wrapPOL(pol));
			}
			//get the Vouchers Payable account
			Id idGLVP = [SELECT AcctSeed__Vouchers_Payable_GL_Account__c FROM AcctSeed__Accounting_Settings__c][0].AcctSeed__Vouchers_Payable_GL_Account__c;

			for(AcctSeed__Transaction__c txn :
					[SELECT AcctSeed__Account_Payable_Line__c,
							AcctSeed__Account_Payable_Line__r.AcctSeedERP__Purchase_Order_Line__c,
							AcctSeed__Account_Payable_Line__r.AcctSeed__Quantity__c,
							AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Purchase_Order_Line__c,
							AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Quantity__c,
							AcctSeed__Amount__c
					 FROM AcctSeed__Transaction__c
					 WHERE (AcctSeed__Account_Payable_Line__r.AcctSeedERP__Purchase_Order_Line__c IN :mapWrapPOL.keySet() OR 
					 		AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Purchase_Order_Line__c IN :mapWrapPOL.keySet())
					   AND AcctSeed__GL_Account__c = :idGLVP])
			{
				wrapPOL wpl;
				if(mapWrapPOL.containsKey(txn.AcctSeed__Account_Payable_Line__r.AcctSeedERP__Purchase_Order_Line__c))
				{
					wpl = mapWrapPOL.get(txn.AcctSeed__Account_Payable_Line__r.AcctSeedERP__Purchase_Order_Line__c);
					wpl.decAmtVP -= txn.AcctSeed__Amount__c;
					if(txn.AcctSeed__Account_Payable_Line__r.AcctSeed__Quantity__c != null)
					wpl.decQtyVP -= txn.AcctSeed__Account_Payable_Line__r.AcctSeed__Quantity__c;
				}
				else if(mapWrapPOL.containsKey(txn.AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Purchase_Order_Line__c))
				{
					wpl = mapWrapPOL.get(txn.AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Purchase_Order_Line__c);
					wpl.decAmtVP -= txn.AcctSeed__Amount__c;

					if(txn.AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Quantity__c != null)
					wpl.decQtyVP += txn.AcctSeedERP__Purchase_Order_Inventory_Movement__r.AcctSeedERP__Quantity__c;
				}
			}	

			for(AcctSeed__Account_Payable_Line__c apl : listNew)
			{
				wrapPOL wpl = new wrapPOL(new AcctSeedERP__Purchase_Order_Line__c(Id = null));
				if(mapWrapPOL.containsKey(apl.AcctSeedERP__Purchase_Order_Line__c))
					wpl = mapWrapPOL.get(apl.AcctSeedERP__Purchase_Order_Line__c);

				Product2 product = new Product2(Id = null);
				if(mapProduct.containsKey(apl.AcctSeed__Product__c))
					product = mapProduct.get(apl.AcctSeed__Product__c);

				//if the product of the APL does not match the product of the POL, make them match
				if(apl.AcctSeedERP__Purchase_Order_Line__c != null && 
				   wpl.line.Id != null &&
				   wpl.line.AcctSeedERP__Product__c != null && 
				   apl.AcctSeed__Product__c != wpl.line.AcctSeedERP__Product__c)
				{
					apl.AcctSeed__Product__c = wpl.line.AcctSeedERP__Product__c;
				}

				//if it's an inventory product, and there's a purchase order line, then unwind the VP balance
				if(product.AcctSeed__Inventory_Product__c && wpl.line.Id != null)
				{
					apl.AcctSeed__Expense_GL_Account__c = idGLVP;
					apl.AcctSeed__Quantity__c = wpl.decQtyVP;
					apl.AcctSeed__Amount__c = wpl.decAmtVP;
				}
				//otherwise, if there's a product, use the expense GL of the product
				else if(product.AcctSeed__Expense_GL_Account__c != null)
				{
					apl.AcctSeed__Expense_GL_Account__c = product.AcctSeed__Expense_GL_Account__c;
				}

				apl.AcctSeed__GL_Account_Variable_3__c = product.AcctSeed__GL_Account_Variable_3__c;
			}
		}

		if(!boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			//if the ap line references a purchase order line, and if the purchase order line has movements that do NOT already reference an AP line, set the AP line on the POIM
			map<Id,Id> mapPOLtoAPL = new map<Id,Id>();
			for(AcctSeed__Account_Payable_Line__c apl : listNew)
			{
				if(apl.AcctSeedERP__Purchase_Order_Line__c != NULL)
					mapPOLtoAPL.put(apl.AcctSeedERP__Purchase_Order_Line__c,apl.Id);
			}
			list<AcctSeedERP__Purchase_Order_Inventory_Movement__c> listMoveUpdate = new list<AcctSeedERP__Purchase_Order_Inventory_Movement__c>();
			if(mapPOLtoAPL.size() > 0)
			for(AcctSeedERP__Purchase_Order_Inventory_Movement__c move :
					[SELECT Id, 
					 		AcctSeedERP__Purchase_Order_Line__c,
					 		Account_Payable_Line__c
					 FROM 	AcctSeedERP__Purchase_Order_Inventory_Movement__c
					 WHERE 	AcctSeedERP__Purchase_Order_Line__c IN :mapPOLtoAPL.keySet()
					   AND  Account_Payable_Line__c = null])
			{
				move.Account_Payable_Line__c = mapPOLtoAPL.get(move.AcctSeedERP__Purchase_Order_Line__c);
				listMoveUpdate.add(move);
			}

			if(listMoveUpdate.size() > 0)
			{
				gcPurchaseOrderInventoryMovement.disableTrigger = true;
				update listMoveUpdate;
				gcPurchaseOrderInventoryMovement.disableTrigger = false;
			}
		}
	}

	global class wrapPOL
	{
		AcctSeedERP__Purchase_Order_Line__c line{get;set;}
		Decimal decAmtVP{get;set;}
		Decimal decQtyVP{get;set;}

		global wrapPOL(AcctSeedERP__Purchase_Order_Line__c pLine)
		{
			line = pLine;
			decAmtVP = 0;
			decQtyVP = 0;
		}
	}
}