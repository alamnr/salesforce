global without sharing class gcSalesOrder_Report
{

	global gcSalesOrder_Report(ApexPages.standardController c){}
	global gcSalesOrder_Report(gcAccountingPeriod c){}
	global gcSalesOrder_Report(){}

	@RemoteAction @ReadOnly
	global static list<obj> retrieveOrders(Id idPeriod)
	{
		set<Id> setIdGL = new set<Id>();
		set<Id> setIdGLrevenue = new set<Id>();
		for(AcctSeed__GL_Account__c gl : [SELECT Id, AcctSeed__Type__c FROM AcctSeed__GL_Account__c WHERE AcctSeed__Type__c IN ('Revenue', 'Expense')])
		{
			setIdGL.add(gl.Id);
			if(gl.AcctSeed__Type__c == 'Revenue')
				setIdGLrevenue.add(gl.Id);
		}

		//get the set of orders having revenue or expense in the current period
		map<Id,cube> mapCube = new map<Id,cube>();

		for(AcctSeed__Transaction__c txn : 
			[SELECT AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__r.AcctSeedERP__Sales_Order__c,
					AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c,
					AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c,
					AcctSeed__Amount__c,
					AcctSeed__GL_Account__c
			 FROM AcctSeed__Transaction__c
			 WHERE AcctSeed__GL_Account__c IN : setIdGL
			   AND AcctSeed__Accounting_Period__c = :idPeriod
			   AND (AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0)
			   AND (AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__r.AcctSeedERP__Sales_Order__c != null OR
			   		AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c != null OR
			   		AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c != null)])
		{
			Id idSalesOrder = txn.AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__r.AcctSeedERP__Sales_Order__c;
			if(idSalesOrder == null)
			   idSalesOrder = txn.AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c;
			if(idSalesOrder == null)
			   idSalesOrder = txn.AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c;

			if(!mapCube.containsKey(idSalesOrder))
				mapCube.put(idSalesOrder, new cube());

			cube cube = mapCube.get(idSalesOrder);

			if(setIdGLrevenue.contains(txn.AcctSeed__GL_Account__c))
				cube.revenueThisPeriod -= txn.AcctSeed__Amount__c;
			else
				cube.expenseThisPeriod += txn.AcctSeed__Amount__c;
		}

		mapCube.remove(null);

		list<AggregateResult> listAggRes = new list<AggregateResult>();
		listAggRes.addAll(
			[SELECT AcctSeed__GL_Account__c idGL,
					AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__r.AcctSeedERP__Sales_Order__c idOrder1,
					AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c idOrder2,
					AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c idOrder3,
					sum(AcctSeed__Amount__c) amt
			 FROM AcctSeed__Transaction__c
			 WHERE AcctSeed__GL_Account__c IN : setIdGL
			   AND (AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0)
			   AND (AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__r.AcctSeedERP__Sales_Order__c IN : mapCube.keySet() OR
			   		AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c IN : mapCube.keySet() OR
			   		AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c IN : mapCube.keySet())
			GROUP BY AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__r.AcctSeedERP__Sales_Order__c,
					 AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c,
					 AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c,
					 AcctSeed__GL_Account__c]);
		for(AggregateResult aggRes : listAggRes)
		{
			Id idSalesOrder = (Id)aggRes.get('idOrder1');
			if(idSalesOrder == null)
			   idSalesOrder = (Id)aggRes.get('idOrder2');
			if(idSalesOrder == null)
			   idSalesOrder = (Id)aggRes.get('idOrder3');

			Id idGL = (Id)aggRes.get('idGL');
			Decimal amt = (Decimal)aggRes.get('amt');

			cube cube = mapCube.get(idSalesOrder);
			if(setIdGLrevenue.contains(idGL))
				cube.revenue -= amt;
			else
				cube.expense += amt;
		}

		list<obj> listObj = new list<obj>();

		for(AcctSeedERP__Sales_Order__c so :
			[SELECT Id, Name, 
					AcctSeedERP__Customer__r.Name,
					AccPac_Transaction_Number__c,
					Fill_Date__c,
					Warehouse__r.Name,
					AcctSeedERP__Status__c,
					AcctSeedERP__Total__c,
					Total_Filled__c
			FROM AcctSeedERP__Sales_Order__c
			WHERE Id IN : mapCube.keySet()
			ORDER BY AcctSeedERP__Customer__r.Name, Name])
		{
			Decimal orderTotal = so.AcctSeedERP__Total__c;
			if(orderTotal == null) orderTotal = 0;
			Decimal totalFilled = so.Total_Filled__c;
			if(totalFilled == null) totalFilled = 0;

			obj obj = new obj();

			obj.mapProperty.put('idOrder', so.Id);
			obj.mapProperty.put('orderName', so.Name);
			obj.mapProperty.put('customerName', so.AcctSeedERP__Customer__r.Name);
			obj.mapProperty.put('accPacTxnNumber', so.AccPac_Transaction_Number__c);
			if(so.Fill_Date__c != null)
			obj.mapProperty.put('fillDate',so.Fill_Date__c.format());
			obj.mapProperty.put('warehouseName', so.Warehouse__r.Name);
			obj.mapProperty.put('orderStatus', so.AcctSeedERP__Status__c);
			obj.mapProperty.put('orderTotal', String.valueOf(so.AcctSeedERP__Total__c.setScale(6)));
			obj.mapProperty.put('filledTotal', String.valueOf(so.Total_Filled__c.setScale(6)));
			obj.mapProperty.put('unfilledTotal', String.valueOf((so.AcctSeedERP__Total__c - so.Total_Filled__c).setScale(6)));


			cube cube = mapCube.get(so.Id);

			obj.mapProperty.put('revenueThisPeriod', String.valueOf(cube.revenueThisPeriod.setScale(6)));
			obj.mapProperty.put('expenseThisPeriod', String.valueOf(cube.expenseThisPeriod.setScale(6)));
			obj.mapProperty.put('revenue', String.valueOf(cube.revenue.setScale(6)));
			obj.mapProperty.put('expense', String.valueOf(cube.expense.setScale(6)));

			obj.mapProperty.put('revenueOtherPeriods', String.valueOf((cube.revenue - cube.revenueThisPeriod).setScale(6)));
			obj.mapProperty.put('expenseOtherPeriods', String.valueOf((cube.expense - cube.expenseThisPeriod).setScale(6)));

			obj.mapProperty.put('profitThisPeriod', String.valueOf((cube.revenueThisPeriod - cube.expenseThisPeriod).setScale(6)));
			obj.mapProperty.put('profit', String.valueOf((cube.revenue - cube.expense).setScale(6)));

			listObj.add(obj);
		}

		return listObj;
	}

	global class cube{
		global Decimal revenueThisPeriod{get;set;}
		global Decimal expenseThisPeriod{get;set;}
		global Decimal revenue{get;set;}
		global Decimal expense{get;set;}

		global cube()
		{
			revenueThisPeriod = 0;
			expenseThisPeriod = 0;
			revenue = 0;
			expense = 0;
		}
	}


	global class obj{
		global map<String,String> mapProperty{get;set;}
		global map<String,obj> mapObj{get;set;}
		global list<obj> listObj{get;set;}

		private void init()
		{
			mapProperty = new map<String,String>();
			mapObj = new map<String,obj>();
			listObj = new list<obj>();		
		}
		global obj()
		{
			init();
		}
	}	
}