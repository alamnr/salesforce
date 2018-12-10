global without sharing class gcInventoryMovementCube {
	
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

	global static Boolean allowDML{
		get{
			if(allowDML == null) return false;
			else return allowDML;
		}
		set{
			if(value == null) allowDML = false;
			else allowDML = value;
		}
	}

	public static void triggerHandler
		(map<Id,Inventory_Movement_Cube__c> oldMap,
		 map<Id,Inventory_Movement_Cube__c> newMap,
		 list<Inventory_Movement_Cube__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,Inventory_Movement_Cube__c>();
		if(newMap == NULL) newMap = new map<Id,Inventory_Movement_Cube__c>();
		if(listNew == NULL) listNew = new list<Inventory_Movement_Cube__c>();

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

	private static void updateAndValidate
		(map<Id,Inventory_Movement_Cube__c> oldMap,
		 map<Id,Inventory_Movement_Cube__c> newMap,
		 list<Inventory_Movement_Cube__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			for(Inventory_Movement_Cube__c imc : listNew)
			{
				if(!gcInventoryMovementCube.allowDML)
					imc.addError('Direct manipulation of the Inventory Movement Cube object is not allowed.');
			}
		}
		if(boolIsBefore && boolIsDelete)
		{
			for(Inventory_Movement_Cube__c imc : oldMap.values())
			{
				if(!gcInventoryMovementCube.allowDML)
					imc.addError('Direct manipulation of the Inventory Movement Cube object is not allowed.');
			}
		}

		if(boolIsBefore && boolIsInsert)
		{
			map<Id,AcctSeedERP__Inventory_Balance__c> mapBalance = new map<Id,AcctSeedERP__Inventory_Balance__c>();
			for(Inventory_Movement_Cube__c cube : listNew)
			{
				mapBalance.put(cube.Inventory_Balance__c,null);
			}
			for(AcctSeedERP__Inventory_Balance__c bal : 
				[SELECT Id, AcctSeedERP__Warehouse__c, AcctSeedERP__Location__c, AcctSeedERP__Product__c 
				 FROM AcctSeedERP__Inventory_Balance__c
				 WHERE Id IN :mapBalance.keySet()])
			{
				mapBalance.put(bal.Id,bal);
			}
			for(Inventory_Movement_Cube__c cube : listNew)
			{
				AcctSeedERP__Inventory_Balance__c bal = mapBalance.get(cube.Inventory_Balance__c);
				cube.Warehouse__c = bal.AcctSeedERP__Warehouse__c;
				cube.Location__c = bal.AcctSeedERP__Location__c;
				cube.Product__c = bal.AcctSeedERP__Product__c;
			}
		}

		if(!boolIsBefore)
		{
			Set<Id> setIdProducts = new Set<Id>();
			Set<Id> setIdLots = new Set<Id>();
			for(Inventory_Movement_Cube__c cube : listNew)
			{
				setIdLots.add(cube.Lot__c);
				setIdProducts.add(cube.Product__c);
			}
			for(Inventory_Movement_Cube__c cube : oldMap.values())
			{
				setIdLots.add(cube.Lot__c);
				setIdProducts.add(cube.Product__c);
			}
			recalcLotQtyCost(setIdLots);
			recalcProductQtyCost(setIdProducts);
		}
	}

	global static void recalcLotQtyCost(Set<Id> setIdLots)
	{
		if(System.isBatch())
			recalcLotQtyCostSynch(setIdLots);
		else
			recalcLotQtyCostFuture(setIdLots);
	}

	@future
	global static void recalcLotQtyCostFuture(Set<Id> setIdLots)
	{
		recalcLotQtyCostSynch(setIdLots);
	}	

	/// Update Lot Quantity and Cost
	global static void recalcLotQtyCostSynch(Set<Id> setIdLots)
	{
		setIdLots.remove(null);
		List<AggregateResult> listAggRes = new List<AggregateResult>();
		Map<Id,Decimal> mapQty = new Map<Id,Decimal>();
		Map<Id,Decimal> mapCost = new Map<Id,Decimal>();
        listAggRes.addAll([SELECT Lot__c idLot, sum(Inventory_GL_Amount__c) amt, sum(Quantity__c) qty 
        	FROM Inventory_Movement_Cube__c 
        	WHERE Lot__c IN :setIdLots 
        		AND (Quantity__c < 0 OR Quantity__c > 0 OR Inventory_GL_Amount__c < 0 OR Inventory_GL_Amount__c > 0)
        	GROUP BY Lot__c 
        	HAVING sum(Quantity__c) < 0 OR sum(Quantity__c) > 0 OR sum(Inventory_GL_Amount__c) < 0 OR sum(Inventory_GL_Amount__c) > 0]);
        for(sObject aggRes : listAggRes)
        {
            Id idLot = (Id)aggRes.get('idLot');
            mapQty.put(idLot, (Decimal)aggRes.get('qty'));
            mapCost.put(idLot, (Decimal)aggRes.get('amt'));
        }
        List<Lot__c> listLot = new List<Lot__c>();
        for(Lot__c lot : [SELECT Id, Quantity__c, Cost__c FROM Lot__c WHERE Id IN:setIdLots])
        {
        	Decimal qty = mapQty.get(lot.Id);
        	qty = (qty == null)?0:qty;

        	Decimal cost = mapCost.get(lot.Id);
        	cost = (cost == null)?0:cost;

        	if((lot.Quantity__c == null || lot.Quantity__c.setScale(6) != qty.setScale(6))
        	 || (lot.Cost__c == null || lot.Cost__c.setScale(6) != cost.setScale(6)))
        	{
        		lot.Quantity__c = qty;
        		lot.Cost__c = cost;
        		listLot.add(lot);
        	}
        }
        if(!listLot.isEmpty())
        {
         	Boolean triggerStatus = gcLot.disableTrigger;
         	gcLot.disableTrigger = true;
        	update listLot;
        	gcLot.disableTrigger = triggerStatus;
        }
	}

	/// Update Product Quantity and Cost
	global static void recalcProductQtyCost(Set<Id> setIdProducts)
	{
		if(System.isBatch())
			recalcProductQtyCostSynch(setIdProducts);
		else
			recalcLotQtyCostFuture(setIdProducts);
	}

	@future
	global static void recalcProductQtyCostFuture(Set<Id> setIdProducts)
	{
		recalcProductQtyCostSynch(setIdProducts);
	}	

	/// Update Product Quantity and Cost
	global static void recalcProductQtyCostSynch(Set<Id> setIdProducts)
	{
		setIdProducts.remove(null);
		List<AggregateResult> listAggRes = new List<AggregateResult>();
		Map<Id,Decimal> mapQty = new Map<Id,Decimal>();
		Map<Id,Decimal> mapCost = new Map<Id,Decimal>();
        listAggRes.addAll([SELECT Product__c idProduct, sum(Inventory_GL_Amount__c) amt, sum(Quantity__c) qty 
        		FROM Inventory_Movement_Cube__c WHERE Product__c IN :setIdProducts 
        			AND (Quantity__c < 0 OR Quantity__c > 0 OR Inventory_GL_Amount__c < 0 OR Inventory_GL_Amount__c > 0)
        		GROUP BY Product__c 
        		HAVING sum(Quantity__c) < 0 OR sum(Quantity__c) > 0 OR sum(Inventory_GL_Amount__c) < 0 OR sum(Inventory_GL_Amount__c) > 0]);
        for(sObject aggRes : listAggRes)
        {
            Id idProduct = (Id)aggRes.get('idProduct');
            mapQty.put(idProduct, (Decimal)aggRes.get('qty'));
            mapCost.put(idProduct, (Decimal)aggRes.get('amt'));
        }
        List<Product2> listProduct = new List<Product2>();
        for(Product2 product : [SELECT Id, Quantity__c, Cost__c FROM Product2 WHERE Id IN:setIdProducts])
        {
        	Decimal qty = mapQty.get(product.Id);
        	qty = (qty == null)?0:qty;

        	Decimal cost = mapCost.get(product.Id);
        	cost = (cost == null)?0:cost;

        	if((product.Quantity__c == null || product.Quantity__c.setScale(6) != qty.setScale(6))
        	 || (product.Cost__c == null || product.Cost__c.setScale(6) != cost.setScale(6)))
        	{
        		product.Quantity__c = qty;
        		product.Cost__c = cost;
        		listProduct.add(product);
        	}
        }
        if(!listProduct.isEmpty())
        {
         	Boolean triggerStatus = gcProduct.disableTrigger;
         	gcProduct.disableTrigger = true;
        	update listProduct;
         	gcProduct.disableTrigger = triggerStatus;
        }
	}

	global static void recalc(list<sObject> listMove)
	{
		//collect the earliest and latest move date, of the moves that have been passed in.
		//then convert this to the start date of the earliest month, and the end date of the latest month.
		//then create a map of days to periods.

		if(listMove.size() == 0) return;

		String moveType = listMove[0].getSObjectType().getDescribe().getName();
		map<Id,map<Id,map<Id,map<Date,wrapCube>>>> mapBLSDC = new map<Id,map<Id,map<Id,map<Date,wrapCube>>>>(); // map Balance-Lot-Serial-Date to Cube

		list<wrapCube> listWrapCube = new list<wrapCube>();

		set<Id> setIdBalance = new set<Id>();
		set<Id> setIdLot = new set<Id>();
		set<Id> setIdSerial = new set<Id>();
		set<Date> setDate = new set<Date>();

		//cycle over the moves to identify all of the Inventory Movement Cubes that are relevant to this update
		for(sObject obj : listMove)
		{
			Id idBalance = (Id)obj.get('AcctSeedERP__Inventory_Balance__c');
			Id idLot = (Id)obj.get('Lot__c');
			Id idSerial = (Id)obj.get('Serial_Number__c');
			Date moveDate = (Date)obj.get('AcctSeedERP__Movement_Date__c');

			if(!mapBLSDC.containsKey(idBalance))
			{
				mapBLSDC.put(idBalance, new map<Id,map<Id,map<Date,wrapCube>>>());
				setIdBalance.add(idBalance);
			}

			map<Id,map<Id,map<Date,wrapCube>>> mapLSDC = mapBLSDC.get(idBalance);

			if(!mapLSDC.containsKey(idLot))
			{
				mapLSDC.put(idLot, new map<Id,map<Date,wrapCube>>());
				setIdLot.add(idLot);				
			}

			map<Id,map<Date,wrapCube>> mapSDC = mapLSDC.get(idLot);

			if(!mapSDC.containsKey(idSerial))
			{
				mapSDC.put(idSerial, new map<Date,wrapCube>());
				setIdSerial.add(idSerial);				
			}

			map<Date,wrapCube> mapDC = mapSDC.get(idSerial);

			if(!mapDC.containsKey(moveDate))
			{
				mapDC.put(moveDate, new wrapCube(idBalance,idLot,idSerial,moveDate,moveType));
				setDate.add(moveDate);
				listWrapCube.add(mapDC.get(moveDate));
			}
		}

		//collect the move cubes that already exist
		for(Inventory_Movement_Cube__c cube :
				[SELECT Id, Inventory_Balance__c, Lot__c, Serial_Number__c, Movement_Date__c, Inventory_GL_Amount__c, Quantity__c
				 FROM Inventory_Movement_Cube__c
				 WHERE Inventory_Balance__c IN :setIdBalance
				   AND Lot__c IN :setIdLot
				   AND Serial_Number__c IN :setIdSerial
				   AND Movement_Date__c IN :setDate
				   AND Movement_Type__c = :moveType])
		{
			if(cube.Quantity__c == null) cube.Quantity__c = 0;
			if(cube.Inventory_GL_Amount__c == null) cube.Inventory_GL_Amount__c = 0;

			if(mapBLSDC.get(cube.Inventory_Balance__c).containsKey(cube.Lot__c))
			{
				if(mapBLSDC.get(cube.Inventory_Balance__c).get(cube.Lot__c).containsKey(cube.Serial_Number__c))
				{
					if(mapBLSDC.get(cube.Inventory_Balance__c).get(cube.Lot__c).get(cube.Serial_Number__c).containsKey(cube.Movement_Date__c))
					   mapBLSDC.get(cube.Inventory_Balance__c).get(cube.Lot__c).get(cube.Serial_Number__c).get(cube.Movement_Date__c).cube = cube;
				}
			}
		}

		//at this point, every cube that is in the map is either a new cube (i.e. wc.cube.Id == NULL) that will be created
		//or it is a cube that exists (i.e. wc.cube.Id != null)

		String soql = '';
		soql = ' SELECT AcctSeedERP__Inventory_Balance__c idBalance, Lot__c idLot, Serial_Number__c idSerial, AcctSeedERP__Movement_Date__c moveDate, sum(AcctSeedERP__Quantity__c) qty, sum(Inventory_GL_Amount__c) amt ';
		soql += ' FROM '+moveType;
		soql += ' WHERE AcctSeedERP__Inventory_Balance__c IN :setIdBalance ';
		soql +=   ' AND Lot__c IN :setIdLot ';
		soql +=   ' AND Serial_Number__c IN :setIdSerial ';
		soql +=   ' AND AcctSeedERP__Movement_Date__c IN :setDate ';
		soql += ' GROUP BY AcctSeedERP__Inventory_Balance__c, Lot__c, Serial_Number__c, AcctSeedERP__Movement_Date__c ';

		list<SObject> listAggRes = new list<SObject>();
		listAggRes.addAll(Database.query(soql));

		Decimal negativeForOutbound = 1;
		if(moveType == 'AcctSeedERP__Outbound_Inventory_Movement__c' ||
		   moveType == 'AcctSeedERP__Manufacturing_Inventory_Movement__c' ||
		   moveType == 'AcctSeedERP__Sales_Order_Inventory_Movement__c')
		negativeForOutbound = -1;

		for(SObject aggRes : listAggRes)
		{
			Id idBalance = (Id)aggRes.get('idBalance');
			Id idLot = (Id)aggRes.get('idLot');
			Id idSerial = (Id)aggRes.get('idSerial');
			Date moveDate = (Date)aggRes.get('moveDate');

			wrapCube wc;

			if(mapBLSDC.get(idBalance).containsKey(idLot))
			{
				if(mapBLSDC.get(idBalance).get(idLot).containsKey(idSerial))
				{
					if(mapBLSDC.get(idBalance).get(idLot).get(idSerial).containsKey(moveDate))
					    wc = mapBLSDC.get(idBalance).get(idLot).get(idSerial).get(moveDate);
				}
			}

			if(wc == null) continue;

			Decimal qty = (Decimal)aggRes.get('qty');
			if(qty == null) qty = 0;
			Decimal amt = (Decimal)aggRes.get('amt');
			if(amt == null) amt = 0;

			wc.qtyNew += qty * negativeForOutbound;
			wc.amtNew += amt * negativeForOutbound;
		}

		list<Inventory_Movement_Cube__c> listCubeUpsert = new list<Inventory_Movement_Cube__c>();
		list<Inventory_Movement_Cube__c> listCubeDelete = new list<Inventory_Movement_Cube__c>();
		for(wrapCube wc : listWrapCube)
		{
			if(//it's a new cube, and either the new quantity or the new amount is non-zero
			   (wc.cube.Id == NULL && (wc.qtyNew.setScale(6) != 0 || wc.amtNew.setScale(6) != 0)) ||
			   //OR it's an existing cube, and either the quantity or the amount is non-zero, and either the quantity or amount are changing
			   (wc.cube.Id != NULL && (wc.qtyNew.setScale(6) != 0 || wc.amtNew.setScale(6) != 0) && (wc.cube.Quantity__c.setScale(6) != wc.qtyNew.setScale(6) || wc.cube.Inventory_GL_Amount__c.setScale(6) != wc.amtNew.setScale(6))))
			{
				wc.cube.Quantity__c = wc.qtyNew.setScale(6);
				wc.cube.Inventory_GL_Amount__c = wc.amtNew.setScale(6);
				listCubeUpsert.add(wc.cube);				
			}
			else if(//it's an existing cube, and the new quantity is zero, and the new amount is zero
					wc.cube.Id != NULL && wc.qtyNew.setScale(6) == 0 && wc.amtNew.setScale(6) == 0)
			{
				listCubeDelete.add(wc.cube);	
			}
		}

		Boolean boolOld;
		if(listCubeUpsert.size() > 0)
		{
			boolOld = gcInventoryMovementCube.allowDML;
			gcInventoryMovementCube.allowDML = true;
			upsert listCubeUpsert;
			gcInventoryMovementCube.allowDML = boolOld;
		}
		if(listCubeDelete.size() > 0)
		{
			boolOld = gcInventoryMovementCube.allowDML;
			gcInventoryMovementCube.allowDML = true;
			delete listCubeDelete;
			gcInventoryMovementCube.allowDML = boolOld;
		}
	}

	private class wrapCube
	{
		public Inventory_Movement_Cube__c cube{get;set;}
		public Decimal qtyNew{get;set;}
		public Decimal amtNew{get;set;}

		public wrapCube(Id idBalance, Id idLot, Id idSerial, Date moveDate, String moveType)
		{
			cube = new Inventory_Movement_Cube__c(Inventory_Balance__c = idBalance, Lot__c = idLot, Serial_Number__c = idSerial, Movement_Date__c = moveDate, Movement_Type__c = moveType, Inventory_GL_Amount__c = 0, Quantity__c = 0);
			qtyNew = 0;
			amtNew = 0;
		}
	}
}