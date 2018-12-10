global without sharing class gcOutboundInventoryMovement {

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

	public static void triggerHandler
		(map<Id,AcctSeedERP__Outbound_Inventory_Movement__c> oldMap,
		 map<Id,AcctSeedERP__Outbound_Inventory_Movement__c> newMap,
		 list<AcctSeedERP__Outbound_Inventory_Movement__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,AcctSeedERP__Outbound_Inventory_Movement__c>();
		if(newMap == NULL) newMap = new map<Id,AcctSeedERP__Outbound_Inventory_Movement__c>();
		if(listNew == NULL) listNew = new list<AcctSeedERP__Outbound_Inventory_Movement__c>();

		updateAndValidate(oldMap,newMap,listNew,boolIsBefore,boolIsInsert,boolIsUpdate,boolIsDelete);
		gcInventoryMovement.triggerHandler(oldMap, newMap, listNew, boolIsBefore, boolIsInsert, boolIsUpdate, boolIsDelete);	

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
				gcInventoryTransfer.cascadeDeleteChildrenOfOutbound(oldMap.keySet());
			}
		}
		else //i.e. trigger.isAfter
		{
			if(boolIsInsert)
			{
				gcInventoryTransfer.verifyChildrenOfOutboundFromOrigin(newMap.keySet());
				gcInventoryTransfer.verifyChildrenOfOutboundFromTransit(newMap.keySet());				
			}
			if(boolIsUpdate)
			{
				gcInventoryTransfer.verifyChildrenOfOutboundFromOrigin(newMap.keySet());				
				gcInventoryTransfer.verifyChildrenOfOutboundFromTransit(newMap.keySet());
			}
			if(boolIsDelete)
			{

			}
		}			
	}

	private static void updateAndValidate
		(map<Id,AcctSeedERP__Outbound_Inventory_Movement__c> oldMap,
		 map<Id,AcctSeedERP__Outbound_Inventory_Movement__c> newMap,
		 list<AcctSeedERP__Outbound_Inventory_Movement__c> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(boolIsBefore && (boolIsInsert || boolIsUpdate))
		{
			//collect the parent sales order line, for the purpose of setting the lot
			//collect the parent sales order, for the purpose of setting the movement date
			map<Id,AcctSeedERP__Sales_Order_Line__c> mapSalesOrderLine = new map<Id,AcctSeedERP__Sales_Order_Line__c>();
			map<Id,AcctSeedERP__Sales_Order__c> mapSalesOrder = new map<Id,AcctSeedERP__Sales_Order__c>();

			map<Id,AcctSeedERP__Inventory_Balance__c> mapBalance = new map<Id,AcctSeedERP__Inventory_Balance__c>();
			
			map<Id,Inventory_Transfer__c> mapTransfer = new map<Id,Inventory_Transfer__c>();

			for(AcctSeedERP__Outbound_Inventory_Movement__c move : listNew)
			{
				if(move.Sales_Order_Line__c != NULL)
					mapSalesOrderLine.put(move.Sales_Order_Line__c,NULL);
				if(move.Inventory_Transfer__c != null)
					mapTransfer.put(move.Inventory_Transfer__c,null);	
				mapBalance.put(move.AcctSeedERP__Inventory_Balance__c,null);			
			}
			mapSalesOrderLine.remove(NULL);	
			if(mapSalesOrderLine.size() > 0)
			for(AcctSeedERP__Sales_Order_Line__c sol :
					[SELECT Id, AcctSeedERP__Sales_Order__c, Lot__c
					 FROM AcctSeedERP__Sales_Order_Line__c
					 WHERE Id IN : mapSalesOrderLine.keySet()])
			{
				mapSalesOrderLine.put(sol.Id,sol);
				mapSalesOrder.put(sol.AcctSeedERP__Sales_Order__c, null);
			}
			mapSalesOrder.remove(NULL);
			if(mapSalesOrder.size() > 0)
			for(AcctSeedERP__Sales_Order__c so : [SELECT Id, Fill_Date__c FROM AcctSeedERP__Sales_Order__c WHERE Id IN : mapSalesOrder.keySet()])
			{
				mapSalesOrder.put(so.Id, so);
			}

			mapTransfer.remove(null);
			if(mapTransfer.size() > 0)
			for(Inventory_Transfer__c xfr :
					[SELECT Id, Inbound_Date__c, Outbound_Date__c, Warehouse_From__c, Warehouse_To__c
					 FROM Inventory_Transfer__c
					 WHERE Id IN :mapTransfer.keySet()])
			{
				mapTransfer.put(xfr.Id,xfr);
			}

			mapBalance.remove(null);
			for(AcctSeedERP__Inventory_Balance__c bal :
				[SELECT Id, AcctSeedERP__Product__r.AcctSeed__Inventory_GL_Account__c
				 FROM AcctSeedERP__Inventory_Balance__c
				 WHERE Id In :mapBalance.keySet()])
			{
				mapBalance.put(bal.Id,bal);
			}

			for(AcctSeedERP__Outbound_Inventory_Movement__c move : listNew)
			{
				move.AcctSeedERP__Credit_GL_Account__c = mapBalance.get(move.AcctSeedERP__Inventory_Balance__c).AcctSeedERP__Product__r.AcctSeed__Inventory_GL_Account__c;

				if(boolIsInsert && move.Sales_Order_Line__c != NULL)
					move.Lot__c = mapSalesOrderLine.get(move.Sales_Order_Line__c).Lot__c;

				if(boolIsUpdate && move.Sales_Order_Line__c != oldMap.get(move.Id).Sales_Order_Line__c)
					move.addError('The Sales Order Line of an Inventory Movement cannot be changed.');

				/*
				The outbound move that is the direct child of an Inventory Transfer should have movementDate = Transfer.OutboundDate
				The outbound move that is the grandchild of an Inventory Transfer should have movementDate = Transfer.InboundDate
				*/
				if(move.Inventory_Transfer__c != null && mapTransfer.containsKey(move.Inventory_Transfer__c))
				{
					Inventory_Transfer__c xfr = mapTransfer.get(move.Inventory_Transfer__c);
					if(move.AcctSeedERP__Inbound_Inventory_Movement__c == null)
						move.AcctSeedERP__Movement_Date__c = xfr.Outbound_Date__c;
					else if(xfr.Inbound_Date__c != null)
						move.AcctSeedERP__Movement_Date__c = xfr.Inbound_Date__c;
				}

				//set the move date to the Sales Order Fill Date
				if(move.Sales_Order_Line__c != NULL && mapSalesOrder.get(mapSalesOrderLine.get(move.Sales_Order_Line__c).AcctSeedERP__Sales_Order__c).Fill_Date__c != null)
				{
					move.AcctSeedERP__Movement_Date__c = mapSalesOrder.get(mapSalesOrderLine.get(move.Sales_Order_Line__c).AcctSeedERP__Sales_Order__c).Fill_Date__c;
				}


			}							
		}
		else if(!boolIsBefore)
		{
			set<Id> setIdSalesOrderLine = new set<Id>();
			for(AcctSeedERP__Outbound_Inventory_Movement__c move :oldMap.values())
			{
				setIdSalesOrderLine.add(move.Sales_Order_Line__c);
			}
			for(AcctSeedERP__Outbound_Inventory_Movement__c move :listNew)
			{
				setIdSalesOrderLine.add(move.Sales_Order_Line__c);
			}	
			setIdSalesOrderLine.remove(NULL);
			if(setIdSalesOrderLine.size() > 0)
				gcSalesOrderLine.rollup(setIdSalesOrderLine);
		}
	}
}