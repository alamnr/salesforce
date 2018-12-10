global without sharing class gcSalesOrder_ConsignmentReview {
	global gcSalesOrder_ConsignmentReview(){}

	@RemoteAction @ReadOnly
	global static obj retrieveOrder(Id idSalesOrder)
	{
		obj obj = new obj();

		Date dateEarliestOpen = [SELECT AcctSeed__Start_Date__c 
								 FROM AcctSeed__Accounting_Period__c 
								 WHERE AcctSeed__Status__c = 'Open' 
								 ORDER BY AcctSeed__Start_Date__c LIMIT 1][0].AcctSeed__Start_Date__c;

		for(AcctSeedERP__Sales_Order__c so :
				[SELECT Id, Name, Notes__c,
				 AcctSeedERP__Customer__r.Name,
				 Fill_Date__c, AcctSeedERP__Customer__r.Owner.Name
				 FROM AcctSeedERP__Sales_Order__c
				 WHERE Id =: idSalesOrder
				 LIMIT 1])
		{
			obj.mapProperty.put('idSalesOrder',so.Id);
			obj.mapProperty.put('orderNumber',so.Name.replaceAll('[^0-9]',''));
			obj.mapProperty.put('customerName',so.AcctSeedERP__Customer__r.Name);
			obj.mapProperty.put('repName',so.AcctSeedERP__Customer__r.Owner.Name);
			if(so.Fill_Date__c != null)
			obj.mapProperty.put('fillDate',so.Fill_Date__c.format());
			if(so.Fill_Date__c != null && dateEarliestOpen.daysBetween(so.Fill_Date__c) > = 0)
				obj.mapProperty.put('periodIsClosed','false');
			else
				obj.mapProperty.put('periodIsClosed','true');
		}
		obj.mapProperty.put('orderHasBilling','false');
		for(AcctSeed__Billing_Line__c line : [SELECT Id FROM AcctSeed__Billing_Line__c WHERE AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c = :idSalesOrder LIMIT 1])
		{
			obj.mapProperty.put('orderHasBilling','true');
		}
		for(AcctSeed__Billing__c bill : [SELECT Id FROM AcctSeed__Billing__c WHERE AcctSeedERP__Sales_Order__c = :idSalesOrder LIMIT 1])
		{
			obj.mapProperty.put('orderHasBilling','true');
		}
		return obj;
	}

	@RemoteAction @ReadOnly
	global static list<obj> retrieveLots(Id idSalesOrder)
	{
		Id idWarehouse = [SELECT Warehouse__c FROM AcctSeedERP__Sales_Order__c WHERE Id =:idSalesOrder][0].Warehouse__c;
		Date fillDate = [SELECT Fill_Date__c FROM AcctSeedERP__Sales_Order__c WHERE Id =:idSalesOrder][0].Fill_Date__c;

		map<Id,Decimal> mapLotInventoryFillDate = new map<Id,Decimal>();
		map<Id,Decimal> mapLotInventory = new map<Id,Decimal>();
		map<Id,Decimal> mapLotFilled = new map<Id,Decimal>();

		map<Id,obj> mapObj = new map<Id,obj>();
		list<obj> listObj = new list<obj>();


		for(map<string,string> x : gcInventoryReport.inventoryDetail(new map<String,list<String>>{'idWarehouse'=> new list<String>{idWarehouse} }))
		{
			Id idLot = x.get('idLot');
			Id idBalance = x.get('idBalance');

			if(!mapLotInventory.containsKey(idLot))
			{
				mapLotInventory.put(idLot,0);

				obj obj = new obj();
				obj.mapProperty.put('idBalance', idBalance); //NOTE:  in the case of multiple LOCATIONS, only the idBalance of the first balance will be used for all new movements
				mapObj.put(idLot, obj);
			}
			
			mapLotInventory.put(idLot, mapLotInventory.get(idLot) + Decimal.valueOf(x.get('qty')));
		}
		mapLotInventory.remove(null);

		map<string,list<string>> mapFilters = new map<string,list<string>>();
        mapFilters.put('dateThru', new list<string>{String.valueOf(fillDate.format())});
        mapFilters.put('idWarehouse', new list<string>{idWarehouse});

		for(map<string,string> x : gcInventoryReport.inventoryDetail(mapFilters))
		{
			Id idLot = x.get('idLot');
			Id idBalance = x.get('idBalance');

			if(!mapLotInventoryFillDate.containsKey(idLot))
			{
				mapLotInventoryFillDate.put(idLot,0);

				obj obj = new obj();
				obj.mapProperty.put('idBalanceFillDate', idBalance); //NOTE:  in the case of multiple LOCATIONS, only the idBalance of the first balance will be used for all new movements
				mapObj.put(idLot, obj);
			}
			
			mapLotInventoryFillDate.put(idLot, mapLotInventoryFillDate.get(idLot) + Decimal.valueOf(x.get('qty')));
		}
		mapLotInventoryFillDate.remove(null);

		for(AggregateResult aggRes :
			[SELECT AcctSeedERP__Inventory_Balance__c idBalance, Lot__c idLot, sum(AcctSeedERP__Quantity__c) sumQty
			 FROM AcctSeedERP__Outbound_Inventory_Movement__c
			 WHERE Sales_Order_Line__r.AcctSeedERP__Sales_Order__c = :idSalesOrder
			   AND AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__c = :idWarehouse //if there happen to be movements from a different warehouse on this order, they will be intentionally ignored
			   AND Lot__c != null
			   AND AcctSeedERP__Quantity__c != null
			 GROUP BY AcctSeedERP__Inventory_Balance__c, Lot__c])
		{
			Id idLot = (Id)aggRes.get('idLot');
			Id idBalance = (Id)aggRes.get('idBalance');
			Decimal qty = (Decimal)aggRes.get('sumQty');

			if(!mapLotFilled.containsKey(idLot))
				mapLotFilled.put(idLot,0);

			mapLotFilled.put(idLot, mapLotFilled.get(idLot) + qty);

			if(!mapObj.containsKey(idLot))
			{
				obj obj = new obj();
				mapObj.put(idLot,obj);
			}
			mapObj.get(idLot).mapProperty.put('idBalance', idBalance); //because we want to use the same balance, when looking for a move to insert/update
		}

		for(AcctSeedERP__Sales_Order_Line__c sol :
			[SELECT Id, Lot__c, Notes__c
			 FROM AcctSeedERP__Sales_Order_Line__c
			 WHERE AcctSeedERP__Sales_Order__c = :idSalesOrder])
		{
			obj obj = mapObj.get(sol.Lot__c);
			obj.mapProperty.put('Notes',sol.Notes__c);
		}

		//fill in the Product and Lot attributes
		for(Lot__c lot : 
				[SELECT Id, Name, Expiration_Date__c, Variant_Qty__c,
				 Product__r.Name, Product__r.ProductCode
				 FROM Lot__c 
				 WHERE Id IN :mapObj.keySet()
				 ORDER BY Product__r.Name, Product__r.ProductCode, Name, Id])
		{
			obj obj = mapObj.get(lot.Id);
			obj.mapProperty.put('idProduct',lot.Product__c);
			obj.mapProperty.put('productName',lot.Product__r.Name);
			obj.mapProperty.put('productCode',lot.Product__r.ProductCode);
			obj.mapProperty.put('idLot',lot.Id);
			obj.mapProperty.put('lotName',lot.Name);


			if(lot != null && lot.Expiration_Date__c != null)
				obj.mapProperty.put('lotExpirationDate', lot.Expiration_Date__c.format());

			if(lot != null && lot.Variant_Qty__c != null)
				obj.mapProperty.put('lotVariantQty', String.valueOf(lot.Variant_Qty__c.setScale(6)));

			if(mapLotInventory.containsKey(lot.Id))
				obj.mapProperty.put('qtyInventoryNonFillDate',String.valueOf(mapLotInventory.get(lot.Id).setScale(6)));

			if(mapLotInventoryFillDate.containsKey(lot.Id))
				obj.mapProperty.put('qtyInventory',String.valueOf(mapLotInventoryFillDate.get(lot.Id).setScale(6)));

			if(mapLotFilled.containsKey(lot.Id))
				obj.mapProperty.put('qtyFilled',String.valueOf(mapLotFilled.get(lot.Id).setScale(6)));

			if(!obj.mapProperty.containsKey('qtyInventory') || obj.mapProperty.get('qtyInventory') == null)
				obj.mapProperty.put('qtyInventory','0');

			if(!obj.mapProperty.containsKey('qtyFilled'))
				obj.mapProperty.put('qtyFilled',null);

			listObj.add(obj);

		}

		return listObj;
	}

	@RemoteAction
	global static obj fill(map<String,String> mapParameters)
	{
		Id idSalesOrder = (Id)mapParameters.get('idSalesOrder');
		Id idProduct = (Id)mapParameters.get('idProduct');
		Id idBalance = (Id)mapParameters.get('idBalance');
		Id idLot = (Id)mapParameters.get('idLot');
		Decimal qtyInvNew = Decimal.valueOf(mapParameters.get('Quantity'));

		Id idWarehouse = [SELECT Warehouse__c FROM AcctSeedERP__Sales_Order__c WHERE Id =:idSalesOrder][0].Warehouse__c;

		obj order = retrieveOrder(idSalesOrder);

		if(idSalesOrder == null || idLot == null || qtyInvNew == null || idWarehouse == null || order.mapProperty.get('periodIsClosed') == 'true' || order.mapProperty.get('orderHasBilling') == 'true') return order;

		Decimal qtyInvOld = 0;

		for(map<string,string> obj : gcInventoryReport.inventoryDetail(new map<String,list<String>>{'idWarehouse'=>new list<String>{idWarehouse},'idLot'=>new list<String>{idLot}}))
		{
			qtyInvOld += Decimal.valueOf(obj.get('qty'));
		}

		if(qtyInvOld == qtyInvNew) return order;

		//find an existing move
		Decimal qtyFilledOld = 0;
		AcctSeedERP__Outbound_Inventory_Movement__c move = new AcctSeedERP__Outbound_Inventory_Movement__c();
		for(AcctSeedERP__Outbound_Inventory_Movement__c m : 
				[SELECT Id, AcctSeedERP__Inventory_Balance__c, AcctSeedERP__Quantity__c, Sales_Order_Line__c
				 FROM AcctSeedERP__Outbound_Inventory_Movement__c
				 WHERE Sales_Order_Line__r.AcctSeedERP__Sales_Order__c = :idSalesOrder
				   AND Lot__c = :idLot
				   AND AcctSeedERP__Inventory_Balance__c = :idBalance
				 ORDER BY AcctSeedERP__Movement_Date__c DESC, LastModifiedDate DESC, Name DESC])
		{
				if(move.Id == null)
					move = m;
				if(move.AcctSeedERP__Quantity__c != null)
					qtyFilledOld += move.AcctSeedERP__Quantity__c;
		}

		Decimal qtyFilledNew = qtyFilledOld + qtyInvOld - qtyInvNew;

		//find an existing line
		AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c();
		Id idGL = null;
		if(move.Id == null)
		for(AcctSeedERP__Sales_Order_Line__c l :
				[SELECT Id, AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c
				 FROM AcctSeedERP__Sales_Order_Line__c
				 WHERE AcctSeedERP__Sales_Order__c = :idSalesOrder
				   AND Lot__c = :idLot
				 ORDER BY LastModifiedDate DESC, Name DESC
				 LIMIT 1])
		{
			sol = l;
			idGL = l.AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c;
		}

		//case 1:  There is an Outbound Movement
		if(move.Id != null)
		{
			if(qtyFilledNew == 0)
			{
				DELETE [SELECT Id FROM AcctSeedERP__Outbound_Inventory_Movement__c 
						WHERE Sales_Order_Line__r.AcctSeedERP__Sales_Order__c = :idSalesOrder
						  AND Lot__c = :idLot];
				DELETE [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c WHERE Id = :sol.Id];			
			}
			else
			{
				DELETE [SELECT Id FROM AcctSeedERP__Outbound_Inventory_Movement__c 
						WHERE Sales_Order_Line__r.AcctSeedERP__Sales_Order__c = :idSalesOrder
						  AND Lot__c = :idLot
						  AND Id != :move.Id];
				move.AcctSeedERP__Quantity__c += (qtyFilledNew - qtyFilledOld);
				update move;
			}
		}
		//case 2:  There is no movement
		else if(move.Id == null)
		{
			//create a line, if a line does not exist
			if(sol.Id == null)
			{
				sol.AcctSeedERP__Sales_Order__c = idSalesOrder;
				sol.AcctSeedERP__Product__c = idProduct;
				sol.AcctSeedERP__Quantity_Ordered__c = qtyFilledNew;
				sol.AcctSeedERP__Unit_Price__c = 0;
				sol.Lot__c = idLot;
				insert sol;

				idGL = [SELECT AcctSeed__Expense_GL_Account__c FROM Product2 WHERE Id = :idProduct][0].AcctSeed__Expense_GL_Account__c;
			}

			move = new AcctSeedERP__Outbound_Inventory_Movement__c
			(			
				AcctSeedERP__Debit_GL_Account__c = idGL,
				AcctSeedERP__Inventory_Balance__c = idBalance,
				AcctSeedERP__Movement_Date__c = date.Today(),
				Sales_Order_Line__c = sol.Id,
				AcctSeedERP__Quantity__c = qtyFilledNew.setScale(6),
				AcctSeedERP__Type__c = 'Accounting',
				AcctSeedERP__Unit_Cost__c = null,
				Lot__c = idLot
			);
			insert move;
		}

		return order;
	}

	//@RemoteAction
	//global static obj updateNotes(map<String,String> mapParameters)
	//{
	//	//Id idSalesOrder = (Id)mapParameters.get('idSalesOrder');
	//	//Id idProduct = (Id)mapParameters.get('idProduct');
	//	//Id idLot = (Id)mapParameters.get('idLot');
	//	//String = mapParameters.get('Notes');

	//	//obj order = retrieveOrder(idSalesOrder);

	//	//if(idSalesOrder == null || idLot == null || order.mapProperty.get('periodIsClosed') == 'true' || order.mapProperty.get('orderHasBilling') == 'true') return order;

	//	////find an existing line
	//	//Sales_Order_Line__r sol = new AcctSeedERP__Outbound_Inventory_Movement__c();
	//	//for(AcctSeedERP__Outbound_Inventory_Movement__c m : 
	//	//		[SELECT Id, AcctSeedERP__Inventory_Balance__c, AcctSeedERP__Quantity__c, Sales_Order_Line__c
	//	//		 FROM AcctSeedERP__Outbound_Inventory_Movement__c
	//	//		 WHERE Sales_Order_Line__r.AcctSeedERP__Sales_Order__c = :idSalesOrder
	//	//		   AND Lot__c = :idLot
	//	//		   AND AcctSeedERP__Inventory_Balance__c = :idBalance
	//	//		 ORDER BY AcctSeedERP__Movement_Date__c DESC, LastModifiedDate DESC, Name DESC])
	//	//{
	//	//		if(move.Id == null)
	//	//			move = m;
	//	//		if(move.AcctSeedERP__Quantity__c != null)
	//	//			qtyFilledOld += move.AcctSeedERP__Quantity__c;
	//	//}

	//	//Decimal qtyFilledNew = qtyFilledOld + qtyInvOld - qtyInvNew;

	//	////find an existing line
	//	//AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c();
	//	//Id idGL = null;
	//	//if(move.Id == null)
	//	//for(AcctSeedERP__Sales_Order_Line__c l :
	//	//		[SELECT Id, AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c
	//	//		 FROM AcctSeedERP__Sales_Order_Line__c
	//	//		 WHERE AcctSeedERP__Sales_Order__c = :idSalesOrder
	//	//		   AND Lot__c = :idLot
	//	//		 ORDER BY LastModifiedDate DESC, Name DESC
	//	//		 LIMIT 1])
	//	//{
	//	//	sol = l;
	//	//	idGL = l.AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c;
	//	//}

	//	////case 1:  There is an Outbound Movement
	//	//if(move.Id != null)
	//	//{
	//	//	if(qtyFilledNew == 0)
	//	//	{
	//	//		DELETE [SELECT Id FROM AcctSeedERP__Outbound_Inventory_Movement__c 
	//	//				WHERE Sales_Order_Line__r.AcctSeedERP__Sales_Order__c = :idSalesOrder
	//	//				  AND Lot__c = :idLot];
	//	//		DELETE [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c WHERE Id = :sol.Id];			
	//	//	}
	//	//	else
	//	//	{
	//	//		DELETE [SELECT Id FROM AcctSeedERP__Outbound_Inventory_Movement__c 
	//	//				WHERE Sales_Order_Line__r.AcctSeedERP__Sales_Order__c = :idSalesOrder
	//	//				  AND Lot__c = :idLot
	//	//				  AND Id != :move.Id];
	//	//		move.AcctSeedERP__Quantity__c += (qtyFilledNew - qtyFilledOld);
	//	//		update move;
	//	//	}
	//	//}
	//	////case 2:  There is no movement
	//	//else if(move.Id == null)
	//	//{
	//	//	//create a line, if a line does not exist
	//	//	if(sol.Id == null)
	//	//	{
	//	//		sol.AcctSeedERP__Sales_Order__c = idSalesOrder;
	//	//		sol.AcctSeedERP__Product__c = idProduct;
	//	//		sol.AcctSeedERP__Quantity_Ordered__c = qtyFilledNew;
	//	//		sol.AcctSeedERP__Unit_Price__c = 0;
	//	//		sol.Lot__c = idLot;
	//	//		insert sol;

	//	//		idGL = [SELECT AcctSeed__Expense_GL_Account__c FROM Product2 WHERE Id = :idProduct][0].AcctSeed__Expense_GL_Account__c;
	//	//	}

	//	//	move = new AcctSeedERP__Outbound_Inventory_Movement__c
	//	//	(			
	//	//		AcctSeedERP__Debit_GL_Account__c = idGL,
	//	//		AcctSeedERP__Inventory_Balance__c = idBalance,
	//	//		AcctSeedERP__Movement_Date__c = date.Today(),
	//	//		Sales_Order_Line__c = sol.Id,
	//	//		AcctSeedERP__Quantity__c = qtyFilledNew.setScale(6),
	//	//		AcctSeedERP__Type__c = 'Accounting',
	//	//		AcctSeedERP__Unit_Cost__c = null,
	//	//		Lot__c = idLot
	//	//	);
	//	//	insert move;
	//	//}

	//	//return order;
	//}

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