global without sharing class gcInventoryTransfer {

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

	private static Id idWarehouseTransit{get;set;}
	private static Id idLocationTransit{get;set;}
	private static Id idWarehouseAdjustment{get;set;}

	private static date dateEarliestOpen{get;set;}

	private static map<Id,Id> mapDefaultLocation{get;set;}

	private static list<sObject> listSObjectUpdate{get;set;}
	private static list<sObject> listSObjectInsert{get;set;}
	private static list<sObject> listSObjectDelete{get;set;}

	private static map<Id,map<Id,map<Id,Id>>> mapPWLB{get;set;}

	private static integer intChildren{get;set;}

	private static Boolean sameDay{get;set;}
	private static Inventory_Transfer__c xfr{
		get;
		set{
			xfr = value;
			sameDay = false;
			if(xfr.Inbound_Date__c == xfr.Outbound_Date__c && xfr.CreatedDate > date.newInstance(2015,12,30))
				sameDay = true;
		}
	}

	private static void initStatics()
	{
		if(idWarehouseTransit == null || idLocationTransit == null || idWarehouseAdjustment == null)
		{
			for(AcctSeedERP__Warehouse__c whs : 
				[SELECT Id, Uniquefier__c, (SELECT Id FROM AcctSeedERP__Locations__r ORDER BY CreatedDate LIMIT 1)
				 FROM AcctSeedERP__Warehouse__c
				 WHERE Uniquefier__c = 'TRANSIT' OR Uniquefier__c = 'ValueAdjustment'])
			{
				if(whs.Uniquefier__c == 'TRANSIT')
				{
					idWarehouseTransit = whs.Id;
					if(whs.AcctSeedERP__Locations__r.size() > 0)
						idLocationTransit = whs.AcctSeedERP__Locations__r[0].Id;				
				}
				else
					idWarehouseAdjustment = whs.Id;
			}

			if(idWarehouseTransit == null)
				throw new gcException('The Transit Warehouse does not exist.');
			else if(idLocationTransit == null)
				throw new gcException('The Transit Location does not exist.');
			else if(idWarehouseAdjustment == null)
				throw new gcException('The Adjustment Warehouse does not exist.');
		}
		
		if(dateEarliestOpen == null)
			dateEarliestOpen = gcAccountingPeriod.dateEarliestOpen();

		if(mapDefaultLocation == null)
			mapDefaultLocation = new map<Id,Id>();

		listSObjectDelete = new list<sObject>();		
		listSObjectUpdate = new list<sObject>();
		listSObjectInsert = new list<sObject>();
		mapPWLB = new map<Id,map<Id,map<Id,Id>>>();
	}

	private static void retrieveDefaultLocations()
	{
		mapDefaultLocation.remove(null);

		set<Id> setIdWarehouse = new set<Id>();
		for(Id idWarehouse : mapDefaultLocation.keySet())
		{
			if(mapDefaultLocation.get(idWarehouse) == null)
				setIdWarehouse.add(idWarehouse);
		}

		if(setIdWarehouse.size() > 0)
		{
			for(AcctSeedERP__Warehouse__c whs : 
				[SELECT Id, (SELECT Id FROM AcctSeedERP__Locations__r ORDER BY CreatedDate LIMIT 1)
				 FROM AcctSeedERP__Warehouse__c
				 WHERE Id IN :setIdWarehouse])
			{
				if(whs.AcctSeedERP__Locations__r.size() > 0)
					mapDefaultLocation.put(whs.Id,whs.AcctSeedERP__Locations__r[0].Id);
				else
					throw new gcException('A location for warehouse '+whs.Id+' does not exist.');					
			}
		}
	}

	public static void triggerHandler
		(map<Id,Inventory_Transfer__c> oldMap,
		 map<Id,Inventory_Transfer__c> newMap,
		 list<Inventory_Transfer__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,Inventory_Transfer__c>();
		if(newMap == NULL) newMap = new map<Id,Inventory_Transfer__c>();
		if(listNew == NULL) listNew = new list<Inventory_Transfer__c>();

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
		(map<Id,Inventory_Transfer__c> oldMap,
		 map<Id,Inventory_Transfer__c> newMap,
		 list<Inventory_Transfer__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore)
		{
			initStatics();
			
			set<Id> setIdHasMoves = new set<Id>();
			for(AcctSeedERP__Outbound_Inventory_Movement__c move :
					[SELECT Inventory_Transfer__c
					 FROM AcctSeedERP__Outbound_Inventory_Movement__c
					 WHERE (Inventory_Transfer__c IN : oldMap.keySet() OR Inventory_Transfer__c IN : newMap.keySet())
					   AND Inventory_Transfer__c != NULL
					   AND AcctSeedERP__Inbound_Inventory_Movement__c = NULL])
			{
				setIdHasMoves.add(move.Inventory_Transfer__c);
			}

			for(Inventory_Transfer__c x : listNew)
			{
				if(boolIsInsert || boolIsUpdate)
				{
					if(x.Warehouse_From__c == NULL)
						x.addError('An originating warehouse must be specified.');
					else if(x.Warehouse_To__c == NULL)
						x.addError('A destination warehouse must be specified.');
					else if(x.Warehouse_From__c == idWarehouseTransit || x.Warehouse_To__c == idWarehouseTransit)
						x.addError('The Transit warehouse may not be used as the Warehouse From or the Warehouse To.');
					else if(x.Warehouse_From__c == idWarehouseAdjustment || x.Warehouse_To__c == idWarehouseAdjustment)
						x.addError('The Adjustment warehouse may not be used as the Warehouse From or the Warehouse To.');
					else if(x.Warehouse_From__c == x.Warehouse_To__c)
						x.addError('The Warehouse From must be different than the Warehouse To.');
					else if(x.Inbound_Date__c != null && x.Inbound_Date__c < x.Outbound_Date__c)
						x.addError('The Inbound Date may not precede the Outbound Date.');
				}
				if(boolIsInsert)
				{
					if(x.Outbound_Date__c == NULL || x.Outbound_Date__c < dateEarliestOpen)
						x.addError('The Outbound Date must be within an Accounting Period that is Open.  The earliest open date is '+ String.valueOf(dateEarliestOpen)+'.');
					else if(x.Inbound_Date__c != NULL && x.Inbound_Date__c < dateEarliestOpen)
						x.addError('The Inbound Date must be within an Accounting Period that is Open.  The earliest open date is '+ String.valueOf(dateEarliestOpen)+'.');					
				}
				if(boolIsUpdate)
				{
					if(x.Outbound_Date__c != oldMap.get(x.Id).Outbound_Date__c && oldMap.get(x.Id).Outbound_Date__c < dateEarliestOpen)
						x.addError('The Outbound Date cannot be changed, because it is within an Accounting Period that is Closed.');
					else if(x.Outbound_Date__c != oldMap.get(x.Id).Outbound_Date__c && x.Outbound_Date__c < dateEarliestOpen)
						x.addError('The new Outbound Date must be within an Accounting Period that is Open.');

					else if(x.Inbound_Date__c != oldMap.get(x.Id).Inbound_Date__c && oldMap.get(x.Id).Inbound_Date__c < dateEarliestOpen)
						x.addError('The Inbound Date cannot be changed, because it is within an Accounting Period that is Closed.');
					else if(x.Inbound_Date__c != oldMap.get(x.Id).Inbound_Date__c && x.Inbound_Date__c < dateEarliestOpen)
						x.addError('The new Inbound Date must be within an Accounting Period that is Open.');

					else if(x.Warehouse_From__c != oldMap.get(x.Id).Warehouse_From__c && oldMap.get(x.Id).Outbound_Date__c < dateEarliestOpen)
						x.addError('The Outbound Warehouse cannot be changed, because the Outbound Date is within an Accounting Period that is Closed.');
					else if(x.Warehouse_To__c != oldMap.get(x.Id).Warehouse_To__c && oldMap.get(x.Id).Inbound_Date__c < dateEarliestOpen)
						x.addError('The Inbound Warehouse cannot be changed, because the Inbound Date is within an Accounting Period that is Closed.');

					else if(x.Warehouse_From__c != oldMap.get(x.Id).Warehouse_From__c && setIdHasMoves.contains(x.Id))
						x.addError('The Outbound Warehouse cannot be changed, because the transfer has been started.  If necessary, delete all lines, or create a reversing transfer.');
				}
			}
			for(Inventory_Transfer__c x : oldMap.values())
			{
				if(boolIsDelete)
				{
					if(setIdHasMoves.contains(x.Id))
						x.addError('The transfer cannot be deleted, because it has already been started.  If necessary, delete all lines, or create a reversing transfer.');
				}
			}
		}		
		else //i.e. isAfter
		{
			set<Id> setIdCascadeUpdate = new set<Id>();
			if(boolIsUpdate)
			{
				for(Inventory_Transfer__c x : listNew)
				{
					if(x.Warehouse_From__c != oldMap.get(x.Id).Warehouse_From__c ||
					   x.Warehouse_To__c != oldMap.get(x.Id).Warehouse_To__c ||
					   x.Outbound_Date__c != oldMap.get(x.Id).Outbound_Date__c ||
					   x.Inbound_Date__c != oldMap.get(x.Id).Inbound_Date__c)
					{
						setIdCascadeUpdate.add(x.Id);
					}
				}
			}
			if(setIdCascadeUpdate.size() > 0)
				cascadeUpdate(setIdCascadeUpdate);
		}		
	}
	
	public static void cascadeUpdate(set<Id> setIdTransfer)
	{
		setIdTransfer.remove(null);
		if(setIdTransfer.size() == 0) return;

		//update children
		update [SELECT Id 
		        FROM AcctSeedERP__Outbound_Inventory_Movement__c
		        WHERE Inventory_Transfer__c IN :setIdTransfer
		          AND AcctSeedERP__Inbound_Inventory_Movement__c = null];
	}	

/*
A completed inventory transfer consists of TWO PAIRS of inventory movements, for a total of FOUR inventory movements:
1) Outbound from Origin - the "root" movement that starts it all, and that looks up directly to the Inventory Transfer record.
2) Inbound to Transit - the child of the Outbound from Origin, that completes the first pair of movements.
3) Outbound from Transit - the child of the Inbound to Transit, that starts the inbound movement to the destination.
4) Inbound to Destination - the child of the Outbound from Transit, that completes the transfer.

Movements #1 and #2 happen within the same execution context.
Movements #3 and #4 happen within the same execution context.

If the Outbound and Inbound date are the same, then movements #3 and #4 don't happen, and movement #2 is inbound to destination.
*/

	public static void cascadeDeleteChildrenOfInbound(set<Id> setIdInboundMove)
	{
		setIdInboundMove.remove(NULL);
		//the purpose of this method is to delete the outbound movements that underlie an inbound movement
		list<Id> listIdOutboundMoveDelete = new list<Id>();
		for(AcctSeedERP__Outbound_Inventory_Movement__c move : 
				[SELECT Id
				 FROM AcctSeedERP__Outbound_Inventory_Movement__c
				 WHERE AcctSeedERP__Inbound_Inventory_Movement__c IN : setIdInboundMove])
		{
			listIdOutboundMoveDelete.add(move.Id);
		}
		
		Database.delete(listIdOutboundMoveDelete);
	}

	public static void cascadeDeleteChildrenOfOutbound(set<Id> setIdOutboundMove)
	{
		setIdOutboundMove.remove(NULL);
		//the purpose of this method is to delete the inbound movements that underlie an outbound movement
		list<Id> listIdInboundMoveDelete = new list<Id>();
		for(AcctSeedERP__Inbound_Inventory_Movement__c move : 
				[SELECT Id
				 FROM AcctSeedERP__Inbound_Inventory_Movement__c
				 WHERE AcctSeedERP__Outbound_Inventory_Movement__c IN : setIdOutboundMove])
		{
			listIdInboundMoveDelete.add(move.Id);
		}
		
		Database.delete(listIdInboundMoveDelete);
	}

/*
VERIFY INBOUND TO TRANSIT, I.E. CHILDREN OF OUTBOUND FROM ORIGIN
CALL THIS METHOD AFTER INSERT, AFTER UPDATE OF OUTBOUND INVENTORY MOVEMENT
*/
	public static void verifyChildrenOfOutboundFromOrigin(set<Id> setIdMove)
	{
		/*
		The purpose of this method is to ensure that the "Outbound from Origin" movement has all and only the correct children, i.e. that the "Inbound to Transit" movements are correct.
		*/
		
		initStatics();

		list<AcctSeedERP__Outbound_Inventory_Movement__c> listMove = new list<AcctSeedERP__Outbound_Inventory_Movement__c>();
		map<Id,list<AcctSeedERP__Inbound_Inventory_Movement__c>> mapMoveToChildren = new map<Id, list<AcctSeedERP__Inbound_Inventory_Movement__c>>();
		list<AcctSeedERP__Inbound_Inventory_Movement__c> listChildren = new list<AcctSeedERP__Inbound_Inventory_Movement__c>();
		AcctSeedERP__Inbound_Inventory_Movement__c moveChild;

		for(AcctSeedERP__Outbound_Inventory_Movement__c move :
			   [SELECT Id,
				AcctSeedERP__Debit_GL_Account__c,
				AcctSeedERP__Inventory_Balance__c,
				AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,
				AcctSeedERP__Movement_Date__c,
				AcctSeedERP__Quantity__c,
				AcctSeedERP__Type__c,
				AcctSeedERP__Unit_Cost__c,
				Cost_Override__c,
				Inventory_Transfer__c,
				Inventory_Transfer__r.Id,				
				Inventory_Transfer__r.CreatedDate,
				Inventory_Transfer__r.Inbound_Date__c,
				Inventory_Transfer__r.Outbound_Date__c,
				Inventory_Transfer__r.Warehouse_To__c,
				Serial_Number__c,
				Lot__c,
				   (SELECT Id,
					AcctSeedERP__Credit_GL_Account__c,
					AcctSeedERP__Inventory_Balance__c,
					AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,
					AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__c,					
					AcctSeedERP__Movement_Date__c,
					AcctSeedERP__Quantity__c,
					AcctSeedERP__Type__c,
					AcctSeedERP__Unit_Cost__c,
					Cost_Override__c,
					Inventory_Transfer__c,
					Serial_Number__c,
					Lot__c
					FROM AcctSeedERP__Inbound_Inventory_Movements__r)
				FROM AcctSeedERP__Outbound_Inventory_Movement__c
				WHERE Id IN : setIdMove
				  AND Inventory_Transfer__c != NULL
				  AND Inventory_Transfer__r.Outbound_Date__c >= :dateEarliestOpen
				  AND AcctSeedERP__Inbound_Inventory_Movement__c = NULL]) //i.e. this is the "root" move
		{
			listMove.add(move);
			mapMoveToChildren.put(move.Id,move.AcctSeedERP__Inbound_Inventory_Movements__r.clone());

			if(!mapDefaultLocation.containsKey(move.Inventory_Transfer__r.Warehouse_To__c))
				mapDefaultLocation.put(move.Inventory_Transfer__r.Warehouse_To__c, null);
		}
		if(listMove.size() == 0) return;

		retrieveDefaultLocations();

		for(AcctSeedERP__Outbound_Inventory_Movement__c move : listMove)
		{	
			//must move children into their own list, because the subquery cannot be manipulated
			listChildren = mapMoveToChildren.get(move.Id);

			xfr = move.Inventory_Transfer__r;

			intChildren = listChildren.size();
			for(Integer i = intChildren -1; i >= 0 ; i--)
			{
				moveChild = listChildren[i];
				
				if(moveChild.AcctSeedERP__Movement_Date__c >= dateEarliestOpen)
				{
					//if there's a moveChild whose master inventory balance does not match the move parent, remove it
					if((!sameDay && moveChild.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__c != idWarehouseTransit) || 
					   ( sameDay && moveChild.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__c != xfr.Warehouse_To__c) ||
					   moveChild.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c != move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c)
					{
						listSObjectDelete.add(moveChild);
						listChildren.remove(i);						
					}	
					//update all children, for cascade effect, and to synchronize with parent
					else if(listChildren.size() == 1)
					{
						moveChild.AcctSeedERP__Credit_GL_Account__c = move.AcctSeedERP__Debit_GL_Account__c;
						moveChild.AcctSeedERP__Movement_Date__c = move.AcctSeedERP__Movement_Date__c;
						moveChild.AcctSeedERP__Quantity__c = move.AcctSeedERP__Quantity__c;
						moveChild.AcctSeedERP__Type__c = move.AcctSeedERP__Type__c;
						moveChild.AcctSeedERP__Unit_Cost__c = move.AcctSeedERP__Unit_Cost__c;
						moveChild.Cost_Override__c = true;							
						moveChild.Inventory_Transfer__c = xfr.Id;
						moveChild.Serial_Number__c = move.Serial_Number__c;	
						moveChild.Lot__c = move.Lot__c;

						listSObjectUpdate.add(moveChild);				
					}
				}
			}

			//if there exist more than one underlying move, then that's a mistake, so eliminate all of them.	
			intChildren = listChildren.size();				
			if(intChildren > 1)
			{
				for(Integer i = intChildren - 1; i >= 0 ; i--)
				{
					moveChild = listChildren[i];
					if(moveChild.AcctSeedERP__Movement_Date__c >= dateEarliestOpen)
					{
						listSObjectDelete.add(moveChild);
						listChildren.remove(i);
					}
				}	
			}

			//if there is no child, create one.  first, we'll need to get the inventorybalanceId
			intChildren = listChildren.size();					
			if(intChildren == 0)
			{
				Id idProduct = move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c;
				Id idWarehouse = idWarehouseTransit;
				Id idLocation  = idLocationTransit;
				if(sameDay)
				{
					idWarehouse = xfr.Warehouse_To__c;
					idLocation = mapDefaultLocation.get(xfr.Warehouse_To__c);
				}
				
				if(!mapPWLB.containsKey(idProduct))
					mapPWLB.put(idProduct, new map<Id,map<Id,Id>>());
				if(!mapPWLB.get(idProduct).containsKey(idWarehouse))
					mapPWLB.get(idProduct).put(idWarehouse, new map<Id,Id>());
				if(!mapPWLB.get(idProduct).get(idWarehouse).containsKey(idLocation))
					mapPWLB.get(idProduct).get(idWarehouse).put(idLocation,null);				
			}
		}
		
		if(mapPWLB.size() > 0)
			gcInventoryBalance.findOrCreateBalances(mapPWLB);

		for(AcctSeedERP__Outbound_Inventory_Movement__c move : listMove)
		{	
			listChildren = mapMoveToChildren.get(move.Id);

			xfr = move.Inventory_Transfer__r;

			intChildren = listChildren.size();
			if(intChildren == 0)
			{
				Id idProduct = move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c;
				Id idWarehouse = idWarehouseTransit;
				Id idLocation  = idLocationTransit;
				if(sameDay)
				{
					idWarehouse = xfr.Warehouse_To__c;
					idLocation = mapDefaultLocation.get(xfr.Warehouse_To__c);
				}
				Id idBalance = mapPWLB.get(idProduct).get(idWarehouse).get(idLocation);

				listSObjectInsert.add(new AcctSeedERP__Inbound_Inventory_Movement__c
					(
						AcctSeedERP__Credit_GL_Account__c = move.AcctSeedERP__Debit_GL_Account__c,
						AcctSeedERP__Inventory_Balance__c = idBalance,
						AcctSeedERP__Movement_Date__c = move.AcctSeedERP__Movement_Date__c,
						AcctSeedERP__Outbound_Inventory_Movement__c = move.Id,
						AcctSeedERP__Quantity__c = move.AcctSeedERP__Quantity__c,
						AcctSeedERP__Type__c = move.AcctSeedERP__Type__c,
						AcctSeedERP__Unit_Cost__c = move.AcctSeedERP__Unit_Cost__c,
						Cost_Override__c = true,
						Inventory_Transfer__c = xfr.Id,
						Serial_Number__c = move.Serial_Number__c,		
						Lot__c = move.Lot__c		
					));
			}
		}

		if(listSObjectDelete.size() > 0) delete listSObjectDelete;
		if(listSObjectUpdate.size() > 0) update listSObjectUpdate;		
		if(listSObjectInsert.size() > 0) insert listSObjectInsert;	
	}

/*
VERIFY OUTBOUND FROM TRANSIT, I.E. CHILDREN OF INBOUND TO TRANSIT
CALL THIS METHOD AFTER INSERT, AFTER UPDATE OF INBOUND INVENTORY MOVEMENT
*/
	
	global static void verifyChildrenOfInboundToTransit(set<Id> setIdMove)
	{
		/*
		The purpose of this method is to ensure that the "Inbound to Transit" movement has all and only the correct children, i.e. that the "Outbound from Transit" movements are correct.
		*/

		initStatics();

		list<AcctSeedERP__Inbound_Inventory_Movement__c> listMove = new list<AcctSeedERP__Inbound_Inventory_Movement__c>();
		map<Id,list<AcctSeedERP__Outbound_Inventory_Movement__c>> mapMoveToChildren = new map<Id, list<AcctSeedERP__Outbound_Inventory_Movement__c>>();
		list<AcctSeedERP__Outbound_Inventory_Movement__c> listChildren = new list<AcctSeedERP__Outbound_Inventory_Movement__c>();
		AcctSeedERP__Outbound_Inventory_Movement__c moveChild;
		
		for(AcctSeedERP__Inbound_Inventory_Movement__c move :
			   [SELECT Id,
				AcctSeedERP__Credit_GL_Account__c,
				AcctSeedERP__Inventory_Balance__c,
				AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,
				AcctSeedERP__Movement_Date__c,
				AcctSeedERP__Quantity__c,
				AcctSeedERP__Type__c,
				AcctSeedERP__Unit_Cost__c,
				AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__c,
				AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Id,
				AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.CreatedDate,
				AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Inbound_Date__c,
				AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Outbound_Date__c,				
				AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Warehouse_To__c,
				Cost_Override__c,
				Serial_Number__c,
				Lot__c,
				   (SELECT Id,
					AcctSeedERP__Debit_GL_Account__c,
					AcctSeedERP__Inventory_Balance__c,
					AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,
					AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__c,					
					AcctSeedERP__Movement_Date__c,
					AcctSeedERP__Quantity__c,
					AcctSeedERP__Type__c,
					AcctSeedERP__Unit_Cost__c,
					Cost_Override__c,
					Inventory_Transfer__c,
					Serial_Number__c,
					Lot__c
					FROM AcctSeedERP__Outbound_Inventory_Movements__r)
				FROM AcctSeedERP__Inbound_Inventory_Movement__c
				WHERE Id IN : setIdMove
				  AND AcctSeedERP__Outbound_Inventory_Movement__c != NULL				
				  AND AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__c != NULL
				  AND AcctSeedERP__Outbound_Inventory_Movement__r.AcctSeedERP__Inbound_Inventory_Movement__c = NULL]) //make sure that this inbound is under the "root" outbound
		{
			listMove.add(move);
			mapMoveToChildren.put(move.Id,move.AcctSeedERP__Outbound_Inventory_Movements__r.clone());
		}
		if(listMove.size() == 0) return;

		for(AcctSeedERP__Inbound_Inventory_Movement__c move : listMove)
		{	
			xfr = move.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r;
			
			listChildren = mapMoveToChildren.get(move.Id);

			//if there's a moveChild that does not match the move parent, remove it			
			intChildren = listChildren.size();
			for(Integer i = intChildren - 1; i >= 0 ; i--)
			{
				moveChild = listChildren[i];
				
				if(moveChild.AcctSeedERP__Movement_Date__c >= dateEarliestOpen)
				{
					if(moveChild.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__c != idWarehouseTransit ||
					   moveChild.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c != move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c ||
					   xfr.Inbound_Date__c == null ||
					   sameDay)
					{
						listSObjectDelete.add(moveChild);
						listChildren.remove(i);						
					}
					else if(listChildren.size() == 1)
					{									
						moveChild.AcctSeedERP__Debit_GL_Account__c = move.AcctSeedERP__Credit_GL_Account__c;
						moveChild.AcctSeedERP__Movement_Date__c = xfr.Inbound_Date__c;
						moveChild.AcctSeedERP__Quantity__c = move.AcctSeedERP__Quantity__c;
						moveChild.AcctSeedERP__Type__c = move.AcctSeedERP__Type__c;
						moveChild.AcctSeedERP__Unit_Cost__c = move.AcctSeedERP__Unit_Cost__c;
						moveChild.Cost_Override__c = true;						
						moveChild.Inventory_Transfer__c = xfr.Id;
						moveChild.Serial_Number__c = move.Serial_Number__c;
						moveChild.Lot__c = move.Lot__c;

						listSObjectUpdate.add(moveChild);					
					}
				}
			}

			//if there exist more than one underlying move, then that's a mistake, so eliminate all of them.	
			intChildren = listChildren.size();					
			if(intChildren > 1)
			{
				for(Integer i = intChildren - 1; i >= 0 ; i--)
				{
					moveChild = listChildren[i];
					if(moveChild.AcctSeedERP__Movement_Date__c >= dateEarliestOpen)
					{
						listSObjectDelete.add(moveChild);
						listChildren.remove(i);
					}
				}	
			}

			//if there is no child, create one.  first, we'll need to get the inventorybalanceId
			intChildren = listChildren.size();					
			if(intChildren == 0 && xfr.Inbound_Date__c != NULL && xfr.Inbound_Date__c >= dateEarliestOpen && !sameDay)
			{
				Id idProduct = move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c;
				Id idWarehouse = idWarehouseTransit;
				Id idLocation  = idLocationTransit;

				if(!mapPWLB.containsKey(idProduct))
					mapPWLB.put(idProduct, new map<Id,map<Id,Id>>());
				if(!mapPWLB.get(idProduct).containsKey(idWarehouse))
					mapPWLB.get(idProduct).put(idWarehouse, new map<Id,Id>());
				if(!mapPWLB.get(idProduct).get(idWarehouse).containsKey(idLocation))
					mapPWLB.get(idProduct).get(idWarehouse).put(idLocation,null);				
			}
		}
		
		if(mapPWLB.size() > 0)
			gcInventoryBalance.findOrCreateBalances(mapPWLB);

		for(AcctSeedERP__Inbound_Inventory_Movement__c move : listMove)
		{	
			xfr = move.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r;
			
			listChildren = mapMoveToChildren.get(move.Id);

			intChildren = listChildren.size();
			if(intChildren == 0 && xfr.Inbound_Date__c != null && xfr.Inbound_Date__c >= dateEarliestOpen && !sameDay)
			{
				Id idProduct = move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c;
				Id idBalance = mapPWLB.get(idProduct).get(idWarehouseTransit).get(idLocationTransit);

				listSObjectInsert.add(new AcctSeedERP__Outbound_Inventory_Movement__c
					(
						AcctSeedERP__Debit_GL_Account__c = move.AcctSeedERP__Credit_GL_Account__c,
						AcctSeedERP__Inventory_Balance__c = idBalance,
						AcctSeedERP__Movement_Date__c = xfr.Inbound_Date__c,
						AcctSeedERP__Inbound_Inventory_Movement__c = move.Id,
						AcctSeedERP__Quantity__c = move.AcctSeedERP__Quantity__c,
						AcctSeedERP__Type__c = move.AcctSeedERP__Type__c,
						AcctSeedERP__Unit_Cost__c = move.AcctSeedERP__Unit_Cost__c,
						Cost_Override__c = true,
						Inventory_Transfer__c = xfr.Id,
						Serial_Number__c = move.Serial_Number__c,
						Lot__c = move.Lot__c				
					));
			}
		}	
		if(listSObjectDelete.size() > 0) delete listSObjectDelete;
		if(listSObjectUpdate.size() > 0) update listSObjectUpdate;		
		if(listSObjectInsert.size() > 0) insert listSObjectInsert;
	}

/*
VERIFY INBOUND TO DESTINATION, I.E. CHILDREN OF OUTBOUND FROM TRANSIT
CALL THIS METHOD AFTER INSERT, AFTER UPDATE OF OUTBOUND INVENTORY MOVEMENT
*/
	global static void verifyChildrenOfOutboundFromTransit(set<Id> setIdMove)
	{	
		initStatics();

		list<AcctSeedERP__Outbound_Inventory_Movement__c> listMove = new list<AcctSeedERP__Outbound_Inventory_Movement__c>();
		map<Id,list<AcctSeedERP__Inbound_Inventory_Movement__c>> mapMoveToChildren = new map<Id, list<AcctSeedERP__Inbound_Inventory_Movement__c>>();
		list<AcctSeedERP__Inbound_Inventory_Movement__c> listChildren = new list<AcctSeedERP__Inbound_Inventory_Movement__c>();
		AcctSeedERP__Inbound_Inventory_Movement__c moveChild;
		
		for(AcctSeedERP__Outbound_Inventory_Movement__c move :
			   [SELECT Id,
				AcctSeedERP__Debit_GL_Account__c,
				AcctSeedERP__Inventory_Balance__c,
				AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,
				AcctSeedERP__Movement_Date__c,
				AcctSeedERP__Quantity__c,
				AcctSeedERP__Type__c,
				AcctSeedERP__Unit_Cost__c,
				AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__c,
				AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Id,
				AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.CreatedDate,				
				AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Inbound_Date__c,
				AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Outbound_Date__c,
				AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Warehouse_To__c,
				Cost_Override__c,
				Inventory_Transfer__c,
				Serial_Number__c,
				Lot__c,
				   (SELECT Id,
					AcctSeedERP__Credit_GL_Account__c,
					AcctSeedERP__Inventory_Balance__c,
					AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,
					AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__c,					
					AcctSeedERP__Movement_Date__c,
					AcctSeedERP__Quantity__c,
					AcctSeedERP__Type__c,
					AcctSeedERP__Unit_Cost__c,
					Cost_Override__c,
					Inventory_Transfer__c,
					Serial_Number__c,
					Lot__c
					FROM AcctSeedERP__Inbound_Inventory_Movements__r)
				FROM AcctSeedERP__Outbound_Inventory_Movement__c
				WHERE Id IN : setIdMove
				  AND AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.AcctSeedERP__Inbound_Inventory_Movement__c = NULL
				  AND AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__c != NULL
				  AND AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Inbound_Date__c >= :dateEarliestOpen]) //i.e. this is the grandchild of the "root" move
		{
			listMove.add(move);
			mapMoveToChildren.put(move.Id,move.AcctSeedERP__Inbound_Inventory_Movements__r.clone());

			if(!mapDefaultLocation.containsKey(move.AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Warehouse_To__c))
				mapDefaultLocation.put(move.AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r.Warehouse_To__c, null);
		}
		if(listMove.size() == 0) return;

		retrieveDefaultLocations();
		
		for(AcctSeedERP__Outbound_Inventory_Movement__c move : listMove)
		{	
			xfr = move.AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r;
			
			listChildren = mapMoveToChildren.get(move.Id);
			
			intChildren = listChildren.size();
			for(Integer i = intChildren - 1; i >= 0 ; i--)
			{
				moveChild = listChildren[i];
				
				if(moveChild.AcctSeedERP__Movement_Date__c >= dateEarliestOpen)
				{
					//if there's a moveChild whose master inventory balance does not match the move parent, remove it
					if(moveChild.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__c != xfr.Warehouse_To__c ||
					   moveChild.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c != move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c)
					{
						listSObjectDelete.add(moveChild);
						listChildren.remove(i);						
					}									
					//update all children, for cascade effect
					else if(listChildren.size() == 1)
					{
						moveChild.AcctSeedERP__Credit_GL_Account__c = move.AcctSeedERP__Debit_GL_Account__c;
						moveChild.AcctSeedERP__Movement_Date__c = move.AcctSeedERP__Movement_Date__c;
						moveChild.AcctSeedERP__Quantity__c = move.AcctSeedERP__Quantity__c;
						moveChild.AcctSeedERP__Type__c = move.AcctSeedERP__Type__c;
						moveChild.AcctSeedERP__Unit_Cost__c = move.AcctSeedERP__Unit_Cost__c;
						moveChild.Cost_Override__c = true;
						moveChild.Inventory_Transfer__c = xfr.Id;
						moveChild.Serial_Number__c = move.Serial_Number__c;	
						moveChild.Lot__c = move.Lot__c;				
						
						listSObjectUpdate.add(moveChild);				
					}
				}
			}

			//if there exist more than one underlying move, then that's a mistake, so eliminate all of them.	
			intChildren = listChildren.size();					
			if(intChildren > 1)
			{
				for(Integer i = intChildren - 1; i >= 0 ; i--)
				{
					moveChild = listChildren[i];
					if(moveChild.AcctSeedERP__Movement_Date__c >= dateEarliestOpen)
					{
						listSObjectDelete.add(moveChild);
						listChildren.remove(i);
					}
				}	
			}

			//if there is no child, create one.  first, we'll need to get the inventorybalanceId
			intChildren = listChildren.size();					
			if(intChildren == 0)
			{
				Id idProduct = move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c;
				Id idWarehouse = xfr.Warehouse_To__c;
				Id idLocation = mapDefaultLocation.get(xfr.Warehouse_To__c);

				if(!mapPWLB.containsKey(idProduct))
					mapPWLB.put(idProduct, new map<Id,map<Id,Id>>());
				if(!mapPWLB.get(idProduct).containsKey(idWarehouse))
					mapPWLB.get(idProduct).put(idWarehouse, new map<Id,Id>());
				if(!mapPWLB.get(idProduct).get(idWarehouse).containsKey(idLocation))
					mapPWLB.get(idProduct).get(idWarehouse).put(idLocation,null);			
			}
		}
		
		if(mapPWLB.size() > 0)
			gcInventoryBalance.findOrCreateBalances(mapPWLB);

		for(AcctSeedERP__Outbound_Inventory_Movement__c move : listMove)
		{	
			xfr = move.AcctSeedERP__Inbound_Inventory_Movement__r.AcctSeedERP__Outbound_Inventory_Movement__r.Inventory_Transfer__r;
			listChildren = mapMoveToChildren.get(move.Id);
			
			intChildren = listChildren.size();		
			if(intChildren == 0)
			{
				Id idProduct = move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c;
				Id idBalance = mapPWLB.get(idProduct).get(xfr.Warehouse_To__c).get(mapDefaultLocation.get(xfr.Warehouse_To__c));

				listSObjectInsert.add(new AcctSeedERP__Inbound_Inventory_Movement__c
					(
						AcctSeedERP__Credit_GL_Account__c = move.AcctSeedERP__Debit_GL_Account__c,
						AcctSeedERP__Inventory_Balance__c = idBalance,
						AcctSeedERP__Movement_Date__c = move.AcctSeedERP__Movement_Date__c,
						AcctSeedERP__Outbound_Inventory_Movement__c = move.Id,
						AcctSeedERP__Quantity__c = move.AcctSeedERP__Quantity__c,
						AcctSeedERP__Type__c = move.AcctSeedERP__Type__c,
						AcctSeedERP__Unit_Cost__c = move.AcctSeedERP__Unit_Cost__c,
						Cost_Override__c = true,
						Inventory_Transfer__c = xfr.Id,
						Serial_Number__c = move.Serial_Number__c,
						Lot__c = move.Lot__c		
					));
			}
		}	
		if(listSObjectDelete.size() > 0) delete listSObjectDelete;
		if(listSObjectUpdate.size() > 0) update listSObjectUpdate;		
		if(listSObjectInsert.size() > 0) insert listSObjectInsert;
	}
}