global without sharing class gcBillingLine {

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
		(map<Id,AcctSeed__Billing_Line__c> oldMap,
		 map<Id,AcctSeed__Billing_Line__c> newMap,
		 list<AcctSeed__Billing_Line__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeed__Billing_Line__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeed__Billing_Line__c>();
		if(listNew == NULL) listNew = new list<AcctSeed__Billing_Line__c>();

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
		(map<Id,AcctSeed__Billing_Line__c> oldMap,
		 map<Id,AcctSeed__Billing_Line__c> newMap,
		 list<AcctSeed__Billing_Line__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{

		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			//collect the products and sales order lines
			map<Id,Product2> mapProduct = new map<Id,Product2>();
			map<Id,AcctSeedERP__Sales_Order_Line__c> mapSOL = new map<Id,AcctSeedERP__Sales_Order_Line__c>();
			for(AcctSeed__Billing_Line__c bl : listNew)
			{
				mapProduct.put(bl.AcctSeed__Product__c,null);
				mapSOL.put(bl.AcctSeedERP__Sales_Order_Line__c,null);
			}
			mapProduct.remove(null);
			mapSOL.remove(null);

			if(mapSOL.size() > 0)
			for(AcctSeedERP__Sales_Order_Line__c sol :
					[SELECT Id,
							AcctSeedERP__GL_Account_Variable_1__c,
							AcctSeedERP__GL_Account_Variable_2__c,
							AcctSeedERP__GL_Account_Variable_3__c,
							AcctSeedERP__GL_Account_Variable_4__c,
							AcctSeedERP__Product__c,
							AcctSeedERP__Project__c,
							AcctSeedERP__Project_Task__c,
							AcctSeedERP__Project_Task__r.AcctSeed__Project__c,
							AcctSeedERP__Quantity_Ordered__c, 
							AcctSeedERP__Unit_Price__c,
							AcctSeedERP__Total__c,
							AcctSeedERP__Sales_Order__r.Warehouse__r.GL_Account_Variable_2__c,
							(SELECT Id, AcctSeed__Hours_Units__c FROM AcctSeedERP__Billing_Lines__r)
					 FROM AcctSeedERP__Sales_Order_Line__c
					 WHERE Id IN :mapSOL.keySet()])
			{
				mapSOL.put(sol.Id, sol);
				mapProduct.put(sol.AcctSeedERP__Product__c,null);
			}
			mapProduct.remove(null);

			if(mapProduct.size() > 0)
			for(Product2 p : 
					[SELECT Id, 
							AcctSeed__Revenue_GL_Account__c,
							AcctSeed__GL_Account_Variable_1__c,
							AcctSeed__GL_Account_Variable_2__c,
							AcctSeed__GL_Account_Variable_3__c,
							AcctSeed__GL_Account_Variable_4__c
					 FROM 	Product2 
					 WHERE 	Id IN :mapProduct.keySet()])
			{
				mapProduct.put(p.Id,p);
			}

			for(AcctSeed__Billing_Line__c bl : listNew)
			{
				AcctSeedERP__Sales_Order_Line__c sol;

				if(mapSOL.containsKey(bl.AcctSeedERP__Sales_Order_Line__c) && !bl.Override__c)
				{
					sol = mapSOL.get(bl.AcctSeedERP__Sales_Order_Line__c);

					//if the product of the billing line does not match the product of the sales order line, make them match
					if(sol.AcctSeedERP__Product__c != null && bl.AcctSeed__Product__c != sol.AcctSeedERP__Product__c)
					{
						bl.AcctSeed__Product__c = sol.AcctSeedERP__Product__c;
					}
					//if there is a sales order line, and the sales order line has a GLV1, use it
					if(sol.AcctSeedERP__GL_Account_Variable_1__c != null)
						bl.AcctSeed__GL_Account_Variable_1__c = sol.AcctSeedERP__GL_Account_Variable_1__c;
					//if there is a sales order line, and the sales order line has a GLV2, use it
					if(sol.AcctSeedERP__GL_Account_Variable_2__c != null)
						bl.AcctSeed__GL_Account_Variable_2__c = sol.AcctSeedERP__GL_Account_Variable_2__c;
					//if there is a sales order line, and the sales order line has a GLV3, use it
					if(sol.AcctSeedERP__GL_Account_Variable_3__c != null)
						bl.AcctSeed__GL_Account_Variable_3__c = sol.AcctSeedERP__GL_Account_Variable_3__c;
					//if there is a sales order line, and the sales order line has a GLV4, use it
					if(sol.AcctSeedERP__GL_Account_Variable_4__c != null)
						bl.AcctSeed__GL_Account_Variable_4__c = sol.AcctSeedERP__GL_Account_Variable_4__c;

					if(sol.AcctSeedERP__Sales_Order__r.Warehouse__r.GL_Account_Variable_2__c != null)
						bl.AcctSeed__GL_Account_Variable_2__c = sol.AcctSeedERP__Sales_Order__r.Warehouse__r.GL_Account_Variable_2__c;

					//if there is a sales order line, and the sales order line has a project, use it
					if(sol.AcctSeedERP__Project__c != null)
						bl.AcctSeed__Project__c = sol.AcctSeedERP__Project__c;

					//if there is a sales order line, and the sales order line has a project task, use it
					if(sol.AcctSeedERP__Project_Task__c != null)
					{
						bl.AcctSeed__Project_Task__c = sol.AcctSeedERP__Project_Task__c;
						bl.AcctSeed__Project__c = sol.AcctSeedERP__Project_Task__r.AcctSeed__Project__c;
					}


					//assume the unit price of the Sales Order Line
					if(sol.AcctSeedERP__Unit_Price__c != null && sol.AcctSeedERP__Unit_Price__c != 0)
						bl.AcctSeed__Rate__c = sol.AcctSeedERP__Unit_Price__c;
					

					//calculate the quantity that has already been billed
					Decimal qtyBilled = 0;
					for(AcctSeed__Billing_Line__c blx : sol.AcctSeedERP__Billing_Lines__r)
					{
						if(blx.AcctSeed__Hours_Units__c != null && blx.AcctSeed__Hours_Units__c != 0 && blx.Id != bl.Id)
							qtyBilled += blx.AcctSeed__Hours_Units__c;
					}

					//bill the quantity that has not yet been billed
					if(sol.AcctSeedERP__Quantity_Ordered__c != null && sol.AcctSeedERP__Quantity_Ordered__c != 0)
						bl.AcctSeed__Hours_Units__c = sol.AcctSeedERP__Quantity_Ordered__c - qtyBilled;

				}

				Product2 product;

				if(mapProduct.containsKey(bl.AcctSeed__Product__c) && !bl.Override__c)
				{
					product = mapProduct.get(bl.AcctSeed__Product__c);

					//use the revenue GL of the product
					if(bl.AcctSeed__Revenue_GL_Account__c == null && product.AcctSeed__Revenue_GL_Account__c != null)
						bl.AcctSeed__Revenue_GL_Account__c = product.AcctSeed__Revenue_GL_Account__c;

					if(product.AcctSeed__GL_Account_Variable_1__c != null && bl.AcctSeed__GL_Account_Variable_1__c == null)
						bl.AcctSeed__GL_Account_Variable_1__c = product.AcctSeed__GL_Account_Variable_1__c;		
					if(product.AcctSeed__GL_Account_Variable_2__c != null && bl.AcctSeed__GL_Account_Variable_2__c == null)
						bl.AcctSeed__GL_Account_Variable_2__c = product.AcctSeed__GL_Account_Variable_2__c;		
					if(product.AcctSeed__GL_Account_Variable_3__c != null && bl.AcctSeed__GL_Account_Variable_3__c == null)
						bl.AcctSeed__GL_Account_Variable_3__c = product.AcctSeed__GL_Account_Variable_3__c;		
					if(product.AcctSeed__GL_Account_Variable_4__c != null && bl.AcctSeed__GL_Account_Variable_4__c == null)
						bl.AcctSeed__GL_Account_Variable_4__c = product.AcctSeed__GL_Account_Variable_4__c;									
				}

				if(bl.AcctSeed__Hours_Units__c == null)
					bl.AcctSeed__Hours_Units__c = 1;
				if(bl.AcctSeed__Rate__c == null)
					bl.AcctSeed__Rate__c = 0;
			}
		}
		/* commented out by MR 10/13/15
		if(!boolIsBefore && boolIsUpdate)
		{
			set<Id> setIdSalesOrderLine = new set<Id>();
			//if the sales order line of a posted billing line is changed, update the revenue roll-up on the Sales Order Line
			for(AcctSeed__Billing_Line__c line : listNew)
			{
				if(line.AcctSeed__Parent_Status__c == 'Posted')
				{
					if(line.AcctSeedERP__Sales_Order_Line__c != oldMap.get(line.Id).AcctSeedERP__Sales_Order_Line__c)
					{
						setIdSalesOrderLine.add(line.AcctSeedERP__Sales_Order_Line__c);
						setIdSalesOrderLine.add(oldMap.get(line.Id).AcctSeedERP__Sales_Order_Line__c);
					}
				}
			}
			setIdSalesOrderLine.remove(NULL);
			if(setIdSalesOrderLine.size() > 0)
				gcSalesOrderLine.rollup(setIdSalesOrderLine);
		}
		*/
	}
}