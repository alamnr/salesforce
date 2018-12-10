global without sharing class gcAccount_Ext
{
	
	global gcAccount_Ext(ApexPages.StandardController ctrl){}

	@RemoteAction @ReadOnly
	global static list<obj> salesOrderHistory(Id idAccount)
	{

		//map<Id,cube> mapCube = new map<Id,Cube>();
		//map<Id,map<Id,cube>> mapRPC = new map<Id,map<Id,cube>>(); //map record-product-cube, where record is either a billing or a sales order

		map<String,cube> mapCube = new map<String,cube>();

		map<Id,AcctSeedERP__Sales_Order__c> mapOrder = new map<Id,AcctSeedERP__Sales_Order__c>();
		map<Id,AcctSeed__Billing__c> mapBilling = new map<Id,AcctSeed__Billing__c>();
		map<Id,AcctSeed__Accounting_Period__c> mapPeriod = new map<Id,AcctSeed__Accounting_Period__c>();
		map<Id,Product2> mapProduct = new map<Id,Product2>();

		list<AggregateResult> listAggRes = new list<AggregateResult>();
		listAggRes.addAll(
			[SELECT AcctSeed__Accounting_Period__c idPeriod,
					AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__r.AcctSeedERP__Sales_Order__c idSalesOrder,
					AcctSeed__Billing_Line__r.AcctSeed__Billing__c idBilling,
					AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c idBillingSalesOrder,
					AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c idBillingLineSalesOrder,
					AcctSeed__Product__c idProduct,
					AcctSeed__GL_Account__r.AcctSeed__Type__c type,
					sum(AcctSeed__Amount__c) amt,
					sum(AcctSeedERP__Outbound_Inventory_Movement__r.AcctSeedERP__Quantity__c) qty
			 FROM AcctSeed__Transaction__c
			 WHERE (AcctSeed__Account__c = :idAccount 
			    OR AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c = :idAccount
			    OR AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c = :idAccount
			    OR AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c = :idAccount
			    OR AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeed__Customer__c = :idAccount)
			   AND AcctSeed__GL_Account__r.AcctSeed__Type__c IN ('Revenue','Expense')
			 GROUP BY AcctSeed__Accounting_Period__c,
			 		  AcctSeedERP__Outbound_Inventory_Movement__r.Sales_Order_Line__r.AcctSeedERP__Sales_Order__c,
			 		  AcctSeed__Billing_Line__r.AcctSeed__Billing__c,
			 		  AcctSeed__Billing_Line__r.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c,
			 		  AcctSeed__Billing_Line__r.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c,
			 		  AcctSeed__Product__c,
			 		  AcctSeed__GL_Account__r.AcctSeed__Type__c]);

		for(AggregateResult aggRes : listAggRes)
		{
			Decimal amt = (Decimal)aggRes.get('amt');
			
			if(amt == null) continue;

			Decimal qty = (Decimal)aggRes.get('qty');
			if(qty == null) qty = 0;

			Id idProduct = (Id)aggRes.get('idProduct');
			Id idPeriod = (Id)aggRes.get('idPeriod');

			Id idOrder = (Id)aggRes.get('idSalesOrder');
			if(idOrder == null) idOrder = (Id)aggRes.get('idBillingSalesOrder');
			if(idOrder == null) idOrder = (Id)aggRes.get('idBillingLineSalesOrder');
			
			Id idBilling = (Id)aggRes.get('idBilling');

			Id idRecord = idOrder;
			if(idRecord == null) idRecord = idBilling;

			String key = '';
			if(idPeriod != null) key += idPeriod;
			if(idRecord != null) key += idRecord;
			if(idProduct != null) key += idProduct;

			if(!mapCube.containsKey(key))
				mapCube.put(key, new cube(idPeriod, idOrder, idBilling, idProduct));

			cube cube = mapCube.get(key);

			if(aggRes.get('type') == 'Revenue')
				cube.rev -= amt;
			else
				cube.exp += amt;

			cube.qty += qty;

			mapPeriod.put(idPeriod,null);
			mapOrder.put(idOrder,null);
			mapBilling.put(idBilling,null);
			mapProduct.put(idProduct,null);
		}

		mapPeriod.remove(null);
		mapOrder.remove(null);
		mapBilling.remove(null);
		mapProduct.remove(null);

		for(AcctSeed__Accounting_Period__c period : [SELECT Id, Name FROM AcctSeed__Accounting_Period__c WHERE Id IN : mapPeriod.keySet()])
			mapPeriod.put(period.Id,period);

		for(Product2 product : [SELECT Id, Name, ProductCode FROM Product2 WHERE Id IN : mapProduct.keySet()])
			mapProduct.put(product.Id,product);

		for(AcctSeedERP__Sales_Order__c so : 
				[SELECT Id, Name,
						AcctSeedERP__Status__c,
						Fill_Date__c,
						Warehouse__r.Name
				 FROM AcctSeedERP__Sales_Order__c
				 WHERE Id IN : mapOrder.keySet()])
		{
			mapOrder.put(so.Id,so);
		}

		for(AcctSeed__Billing__c b :
				[SELECT Id, Name, AcctSeed__Date__c
				 FROM AcctSeed__Billing__c
				 WHERE Id IN :mapBilling.keySet()])
		{
			mapBilling.put(b.Id,b);
		}

		list<obj> listObj = new list<obj>();
		for(cube cube : mapCube.values())
		{
			obj obj = new obj();

			obj.mapProperty.put('idPeriod', cube.idPeriod);
			if(mapPeriod.containsKey(cube.idPeriod))
			{
				obj.mapProperty.put('periodName', mapPeriod.get(cube.idPeriod).Name);
			}
			
			obj.mapProperty.put('idProduct', cube.idProduct);
			if(mapProduct.containsKey(cube.idProduct))
			{
				Product2 product = mapProduct.get(cube.idProduct);
				obj.mapProperty.put('productName',product.Name);
				obj.mapProperty.put('productCode',product.ProductCode);
			}

			obj.mapProperty.put('idOrder', cube.idOrder);
			if(mapOrder.containsKey(cube.idOrder))
			{
				AcctSeedERP__Sales_Order__c order = mapOrder.get(cube.idOrder);
				obj.mapProperty.put('orderName',String.valueOf(Integer.valueOf(order.Name.replaceAll('[^0-9]',''))));
				obj.mapProperty.put('orderStatus',order.AcctSeedERP__Status__c);
				if(order.Fill_Date__c != null)
				obj.mapProperty.put('fillDate',order.Fill_Date__c.format());
				obj.mapProperty.put('warehouseName',order.Warehouse__r.Name);
			}

			obj.mapProperty.put('idBilling', cube.idBilling);
			if(mapBilling.containsKey(cube.idBilling))
			{
				AcctSeed__Billing__c billing = mapBilling.get(cube.idBilling);
				obj.mapProperty.put('billingName',String.valueOf(Integer.valueOf(billing.Name.replaceAll('[^0-9]',''))));
				if(billing.AcctSeed__Date__c != null)
				obj.mapProperty.put('billingDate',billing.AcctSeed__Date__c.format());
			}

			obj.mapProperty.put('revenue',String.valueOf(cube.rev.setScale(6)));
			obj.mapProperty.put('expense',String.valueOf(cube.exp.setScale(6)));
			obj.mapProperty.put('profit',String.valueOf((cube.rev - cube.exp).setScale(6)));
			obj.mapProperty.put('quantity',String.valueOf(cube.qty.setScale(6)));

			listObj.add(obj);
		}

		return listObj;
	}

	global class cube{
		global Decimal rev{get;set;}
		global Decimal exp{get;set;}
		global Decimal qty{get;set;}

		global Id idBilling{get;set;}
		global Id idOrder{get;set;}
		global Id idProduct{get;set;}
		global Id idPeriod{get;set;}

		global void init()
		{
			rev = 0;
			exp = 0;
			qty = 0;

			idBilling = null;
			idOrder = null;
			idProduct = null;
			idPeriod = null;
		}

		global cube()
		{
			init();
		}

		global cube(Id pIdPeriod, Id pIdOrder, Id pIdBilling, Id pIdProduct)
		{
			init();

			idPeriod = pIdPeriod;
			idOrder = pIdOrder;
			idBilling = pIdBilling;
			idProduct = pIdProduct;
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