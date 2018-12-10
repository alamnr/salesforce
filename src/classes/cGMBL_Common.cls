global without sharing class cGMBL_Common {

	global cGMBL_Common(ApexPages.standardController ctrl){}

	@RemoteAction @ReadOnly
	global static list<wrapProduct> searchProduct(String strSearch, String idWarehouse, Integer intMaxResultCount)
	{
		if(intMaxResultCount == 0) intMaxResultCount = 10;
		
		map<Id,wrapProduct> mapWrapProduct = new map<Id,wrapProduct>();
		list<wrapProduct> listWrapProduct = new list<wrapProduct>();

		for(Product2 p : 
				[SELECT Id, Name, ProductCode
				 FROM Product2
				 WHERE IsActive = true
				   AND AcctSeed__Inventory_Product__c = true
				   AND (Name = :strSearch OR ProductCode = :strSearch)
				 ORDER BY ProductCode, Name, Id])
		{
			wrapProduct wp = new wrapProduct(p);
			mapWrapProduct.put(p.Id, wp);
			listWrapProduct.add(wp);
		}

		strSearch = '%'+strSearch.replaceAll('[*]','%') +'%';
		Integer intSize = intMaxResultCount - listWrapProduct.size();
		if(intSize < 0) intSize = 0;			
		for(Product2 p :
				[SELECT Id, Name, ProductCode
				 FROM Product2
				 WHERE IsActive = true
				   AND AcctSeed__Inventory_Product__c = true
				   AND (Name LIKE :strSearch OR ProductCode LIKE :strSearch)
				   AND Id NOT IN :mapWrapProduct.keySet()
				 ORDER BY ProductCode, Name, Id
				 LIMIT :intSize])
		{
			wrapProduct wp = new wrapProduct(p);
			mapWrapProduct.put(p.Id, wp);
			listWrapProduct.add(wp);
		}
		
		Boolean boolIncludeAllWarehouses = true;
		for(AcctSeedERP__Warehouse__c whs : [SELECT Id FROM AcctSeedERP__Warehouse__c WHERE Id =:idWarehouse])
		{
			boolIncludeAllWarehouses = false;
		}
		
		for(AggregateResult aggRes :
				[SELECT AcctSeedERP__Product__c idProduct, SUM(AcctSeedERP__Available_Quantity__c) qty
				 FROM AcctSeedERP__Inventory_Balance__c
				 WHERE AcctSeedERP__Product__c IN :mapWrapProduct.keySet()
				   AND (AcctSeedERP__Warehouse__c = :idWarehouse OR IsDeleted != :boolIncludeAllWarehouses)
				   AND AcctSeedERP__Available_Quantity__c != NULL
				 GROUP BY AcctSeedERP__Product__c])
		{
			Decimal decQty = (Decimal)aggRes.get('qty');
			Id idProduct = (Id)aggRes.get('idProduct');
			
			mapWrapProduct.get(idProduct).Qty = decQty;
		}
		
		return listWrapProduct;
	}

	global class wrapProduct
	{
		global Id Id{get;set;}
		global String Name{get;set;}
		global String ProductCode{get;set;}
		global Decimal Qty{get;set;}
		
		global wrapProduct(Product2 product)
		{
			Id = product.Id;
			Name = product.Name;
			ProductCode = product.ProductCode;
			Qty = 0;
		}		
	}

	@RemoteAction @ReadOnly
	global static list<wrapWarehouse> retrieveWrapWarehouses(Id idProduct)
	{
		//list<AcctSeedERP__Warehouse__c> listWarehouse = new list<AcctSeedERP__Warehouse__c>();
		list<wrapWarehouse> listWrapWarehouse = new list<wrapWarehouse>();
		
		for(AcctSeedERP__Warehouse__c whs :
				[SELECT Id, Name,
				 	(SELECT AcctSeedERP__Available_Quantity__c 
				  	 FROM AcctSeedERP__Inventory_Balance__r
				  	 WHERE AcctSeedERP__Product__c = :idProduct
				  	   AND AcctSeedERP__Available_Quantity__c > 0
				  	 LIMIT 1)
				 FROM AcctSeedERP__Warehouse__c
				 ORDER BY Name])
		{			
			listWrapWarehouse.add(new wrapWarehouse(whs));
		}	
		return listWrapWarehouse;
	}
	
	@RemoteAction @ReadOnly
	global static list<wrapWarehouse> retrieveWrapWarehousesByType(Id idPurchaseOrder, Id idProduct)
	{
		//list<AcctSeedERP__Warehouse__c> listWarehouse = new list<AcctSeedERP__Warehouse__c>();
		list<wrapWarehouse> listWrapWarehouse = new list<wrapWarehouse>();
		
		AcctSeedERP__Purchase_Order__c po =  [SELECT Id, AcctSeedERP__Type__c 
											  FROM AcctSeedERP__Purchase_Order__c
    										  WHERE Id = :idPurchaseOrder][0];

    	if (po.AcctSeedERP__Type__c == 'Standard')
    	{
			for(AcctSeedERP__Warehouse__c whs :
					[SELECT Id, Name,
					 	(SELECT AcctSeedERP__Available_Quantity__c 
					  	 FROM AcctSeedERP__Inventory_Balance__r
					  	 WHERE AcctSeedERP__Product__c = :idProduct AND AcctSeedERP__Available_Quantity__c > 0 LIMIT 1)
					 FROM AcctSeedERP__Warehouse__c 
					 WHERE Allow_Receiving__c = True
					 ORDER BY Name])
			{			
				listWrapWarehouse.add(new wrapWarehouse(whs));
			}
		}
		else if (po.AcctSeedERP__Type__c == 'Drop Shipment')
		{
			for(AcctSeedERP__Warehouse__c whs :
				[SELECT Id, Name,
				 	(SELECT AcctSeedERP__Available_Quantity__c 
				  	 FROM AcctSeedERP__Inventory_Balance__r
				  	 WHERE AcctSeedERP__Product__c = :idProduct AND AcctSeedERP__Available_Quantity__c > 0 LIMIT 1)
				 FROM AcctSeedERP__Warehouse__c 
				 WHERE Allow_Receiving__c = False
				 ORDER BY Name])
			{			
				listWrapWarehouse.add(new wrapWarehouse(whs));
			}
		}
		else
		{
			for(AcctSeedERP__Warehouse__c whs :
				[SELECT Id, Name,
				 	(SELECT AcctSeedERP__Available_Quantity__c 
				  	 FROM AcctSeedERP__Inventory_Balance__r
				  	 WHERE AcctSeedERP__Product__c = :idProduct AND AcctSeedERP__Available_Quantity__c > 0 LIMIT 1)
				 FROM AcctSeedERP__Warehouse__c ORDER BY Name])
			{			
				listWrapWarehouse.add(new wrapWarehouse(whs));
			}
		}

		return listWrapWarehouse;
	}

	global class wrapWarehouse
	{
		global Id Id{get;set;}
		global String Name{get;set;}
		
		global wrapWarehouse(AcctSeedERP__Warehouse__c whs)
		{
			Id = whs.Id;
			Name = whs.Name;
			if(whs.AcctSeedERP__Inventory_Balance__r.size() > 0)
			Name = '* '+Name;
		}
	}	
		
	@RemoteAction @ReadOnly
	global static list<wrapLocation> retrieveWrapLocations(Id idProduct, Id idWarehouse)
	{
		list<wrapLocation> listWrapLocation = new list<wrapLocation>();
		
		for(AcctSeedERP__Location__c loc :
				[SELECT Id, Name,
				 	(SELECT AcctSeedERP__Available_Quantity__c 
				  	 FROM AcctSeedERP__Inventory_Balances__r
				  	 WHERE AcctSeedERP__Product__c = :idProduct
				  	   AND AcctSeedERP__Available_Quantity__c != 0
				  	   AND AcctSeedERP__Available_Quantity__c != NULL)
				 FROM AcctSeedERP__Location__c
				 WHERE AcctSeedERP__Warehouse__c = :idWarehouse
				 ORDER BY Name])
		{			
			listWrapLocation.add(new wrapLocation(loc));
		}
		return listWrapLocation;
	}
	
	global class wrapLocation
	{
		global Id Id{get;set;}
		global String Name{get;set;}
		
		global wrapLocation(AcctSeedERP__Location__c loc)
		{
			Id = loc.Id;
			Name = loc.Name;
			
			Decimal decQty = 0;
			for(AcctSeedERP__Inventory_Balance__c bal : loc.AcctSeedERP__Inventory_Balances__r)
			{
				decQty += bal.AcctSeedERP__Available_Quantity__c;
			}
						
			if(decQty != 0)
			{
				Name = Name +' ('+String.valueOf(decQty.setScale(0))+')';
			}
		}
	}

	@RemoteAction
	global static Id findOrCreateBalance(Id idProduct, Id idWarehouse, Id idLocation)
	{
		AcctSeedERP__Inventory_Balance__c bal = new AcctSeedERP__Inventory_Balance__c();
		for(AcctSeedERP__Inventory_Balance__c b : 
				[SELECT Id
				 FROM AcctSeedERP__Inventory_Balance__c
				 WHERE AcctSeedERP__Product__c = :idProduct
				   AND AcctSeedERP__Warehouse__c = :idWarehouse
				   AND AcctSeedERP__Location__c = :idLocation
				 ORDER BY Id
				 LIMIT 1])
		{
			bal = b;
		}
		
		if(bal.Id == NULL)
		{
			bal = new AcctSeedERP__Inventory_Balance__c
			(
				AcctSeedERP__Product__c = idProduct,
				AcctSeedERP__Warehouse__c = idWarehouse,
				AcctSeedERP__Location__c = idLocation
			);
			
			insert bal;
		}
		
		return bal.Id;
	}
	
	
	@RemoteAction
	global static String findOrCreateBalances(map<Id,map<Id,map<Id,Id>>> mapPWLB)
	{
		for(AcctSeedERP__Inventory_Balance__c bal :
				[SELECT Id, AcctSeedERP__Product__c, AcctSeedERP__Warehouse__c, AcctSeedERP__Location__c
				 FROM AcctSeedERP__Inventory_Balance__c
				 WHERE AcctSeedERP__Product__c IN : mapPWLB.keySet()])
		{
			set<Id> setIdWarehouse = mapPWLB.get(bal.AcctSeedERP__Product__c).keySet();
			if(setIdWarehouse.contains(bal.AcctSeedERP__Warehouse__c))
			{
				set<Id> setIdLocation = mapPWLB.get(bal.AcctSeedERP__Product__c).get(bal.AcctSeedERP__Warehouse__c).keySet();
				if(setIdLocation.contains(bal.AcctSeedERP__Location__c))
				{
					 mapPWLB.get(bal.AcctSeedERP__Product__c).get(bal.AcctSeedERP__Warehouse__c).put(bal.AcctSeedERP__Location__c,bal.Id);
				}
			}
		}
		
		list<AcctSeedERP__Inventory_Balance__c> listBalInsert = new list<AcctSeedERP__Inventory_Balance__c>();
		for(Id idProduct : mapPWLB.keySet())
		{
			for(Id idWarehouse : mapPWLB.get(idProduct).keySet())
			{
				for(Id idLocation : mapPWLB.get(idProduct).get(idWarehouse).keySet())
				{
					if(mapPWLB.get(idProduct).get(idWarehouse).get(idLocation) == NULL)
					{
						listBalInsert.add(new AcctSeedERP__Inventory_Balance__c(AcctSeedERP__Product__c = idProduct, AcctSeedERP__Warehouse__c = idWarehouse, AcctSeedERP__Location__c = idLocation));
					}
				}
			}
		}
		if(listBalInsert.size() > 0)
		{
			insert listBalInsert;
			for(AcctSeedERP__Inventory_Balance__c bal : listBalInsert)
			{
				mapPWLB.get(bal.AcctSeedERP__Product__c).get(bal.AcctSeedERP__Warehouse__c).put(bal.AcctSeedERP__Location__c, bal.Id);
			}
		}
		
		return '';	
	}	
	
	@RemoteAction
	global static AcctSeedERP__Purchase_Order_Inventory_Movement__c createMovePurchase(Id idLine, Id idWarehouse, Id idLocation, Decimal decQty)
	{
		
		AcctSeedERP__Purchase_Order_Line__c line = [SELECT Id, AcctSeedERP__Product__c, AcctSeedERP__Unit_Price__c 
													FROM AcctSeedERP__Purchase_Order_Line__c
													WHERE Id = :idLine][0];
		
		Id idBalance = cGMBL_common.findOrCreateBalance(line.AcctSeedERP__Product__c, idWarehouse, idLocation);
		
		AcctSeedERP__Purchase_Order_Inventory_Movement__c move = new AcctSeedERP__Purchase_Order_Inventory_Movement__c
		(			
			AcctSeedERP__Inventory_Balance__c = idBalance,
			AcctSeedERP__Movement_Date__c = date.Today(),
			AcctSeedERP__Purchase_Order_Line__c = idLine,
			AcctSeedERP__Quantity__c = decQty.setScale(6),
			AcctSeedERP__Unit_Cost__c = 0
		);
		
		insert move;
		
		return [SELECT Id, Name, 
				AcctSeedERP__Location__c,
				AcctSeedERP__Movement_Date__c,
				AcctSeedERP__Purchase_Order_Line__c,
				AcctSeedERP__Quantity__c,
				AcctSeedERP__Unit_Cost__c,
				AcctSeedERP__Warehouse__c,
				Total__c
				FROM AcctSeedERP__Purchase_Order_Inventory_Movement__c
				WHERE Id = :move.Id][0];	
	}
	@RemoteAction @ReadOnly
	global static list<wrapMove> retrieveWrapMoves(Id idPurchaseOrderLine)
	{
		list<wrapMove> listWrapMove = new list<wrapMove>();
		Boolean boolLineHasPayment = false;
		
		for(AcctSeedERP__Purchase_Order_Inventory_Movement__c move :
			 [SELECT Id, Name,
			  AcctSeedERP__Location__c,
			  AcctSeedERP__Movement_Date__c,
			  AcctSeedERP__Purchase_Order_Line__c,
			  AcctSeedERP__Quantity__c,
			  AcctSeedERP__Unit_Cost__c,
			  AcctSeedERP__Warehouse__c,
			  Account_Payable_Line__c,
			  Total__c,
			  (SELECT Id FROM AcctSeedERP__Transactions__r WHERE AcctSeed__Accounting_Period__r.AcctSeed__Status__c != 'Open')
			  FROM AcctSeedERP__Purchase_Order_Inventory_Movement__c
			  WHERE AcctSeedERP__Purchase_Order_Line__c = :idPurchaseOrderLine
			  ORDER BY AcctSeedERP__Movement_Date__c,Name])
		{
			wrapMove wm = new wrapMove(move);
			if(move.AcctSeedERP__Transactions__r.size() > 0)
			{
				wm.boolDeleteRender = false;
				wm.strLockReason = 'Closed Period';
			}
			else if(move.Account_Payable_Line__c != null)
			{
				wm.boolDeleteRender = false;
				wm.strLockReason = 'Locked by AP';
			}

			listWrapMove.add(wm);
		}
		
		return listWrapMove;
	}

/*
	@RemoteAction
	global static AcctSeedERP__Outbound_Inventory_Movement__c createMoveOutbound(Id idLine, Id idWarehouse, Id idLocation, Decimal decQty)
	{	
		AcctSeedERP__Sales_Order_Line__c line = [SELECT Id, AcctSeedERP__Product__c, AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c, AcctSeedERP__Unit_Price__c, Lot__c 
												 FROM AcctSeedERP__Sales_Order_Line__c
												 WHERE Id = :idLine][0];

		Id idBalance = cGMBL_common.findOrCreateBalance(line.AcctSeedERP__Product__c, idWarehouse, idLocation);
		
		AcctSeedERP__Outbound_Inventory_Movement__c move = new AcctSeedERP__Outbound_Inventory_Movement__c
		(			
			AcctSeedERP__Debit_GL_Account__c = line.AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c,
			AcctSeedERP__Inventory_Balance__c = idBalance,
			AcctSeedERP__Movement_Date__c = date.Today(),
			Sales_Order_Line__c = idLine,
			AcctSeedERP__Quantity__c = decQty.setScale(6),
			AcctSeedERP__Type__c = 'Issue to Customer',
			AcctSeedERP__Unit_Cost__c = null,
			Lot__c = line.Lot__c
		);
		
		insert move;
		
		return [SELECT Id, Name, 
				AcctSeedERP__Location__c,
				AcctSeedERP__Movement_Date__c,
				Sales_Order_Line__c,
				AcctSeedERP__Quantity__c,
				AcctSeedERP__Unit_Cost__c,
				AcctSeedERP__Warehouse__c,
				Total__c
				FROM AcctSeedERP__Outbound_Inventory_Movement__c
				WHERE Id = :move.Id][0];	
	}
*/
	@RemoteAction @ReadOnly
	global static list<wrapMove> retrieveWrapMovesOutbound(Id idSalesOrderLine)
	{
		list<wrapMove> listWrapMove = new list<wrapMove>();
		Boolean boolLineHasBilling = false;
		
		for(AcctSeedERP__Outbound_Inventory_Movement__c move :
			 [SELECT Id, Name,
			  AcctSeedERP__Location__c,
			  AcctSeedERP__Movement_Date__c,
			  Sales_Order_Line__c,
			  AcctSeedERP__Quantity__c,
			  AcctSeedERP__Unit_Cost__c,
			  AcctSeedERP__Warehouse__c,
			  Total__c,
			  (SELECT Id FROM AcctSeedERP__Transactions__r WHERE AcctSeed__Accounting_Period__r.AcctSeed__Status__c != 'Open')
			  FROM AcctSeedERP__Outbound_Inventory_Movement__c
			  WHERE Sales_Order_Line__c = :idSalesOrderLine
			    AND Sales_Order_Line__c != NULL
			  ORDER BY AcctSeedERP__Movement_Date__c,Name])
		{

			wrapMove wm = new wrapMove(move);
			if(move.AcctSeedERP__Transactions__r.size() > 0)
			{
				wm.boolDeleteRender = false;
				wm.strLockReason = 'Closed Period';
			}

			listWrapMove.add(wm);
		}		

		for(AcctSeed__Billing_Line__c bl :
				[SELECT Id FROM AcctSeed__Billing_Line__c WHERE AcctSeedERP__Sales_Order_Line__c = :idSalesOrderLine])
		{
			boolLineHasBilling = true;
		}

		
		for(wrapMove wm : listWrapMove)
		{
			if(boolLineHasBilling && wm.boolDeleteRender)
			{
				wm.boolDeleteRender = false;
				wm.strLockReason = 'Locked by AR';
			}
		}
		return listWrapMove;
	}
	
	global class wrapMove
	{
		//global AcctSeedERP__Purchase_Order_Inventory_Movement__c move{get;set;}
		global sObject move{get;set;}
		global Boolean boolDeleteRender{get;set;}
		global String strLockReason{get;set;}
		
		global wrapMove(AcctSeedERP__Purchase_Order_Inventory_Movement__c pMove)
		{
			move = pMove;
			strLockReason = '';
			boolDeleteRender = true;
		}
		global wrapMove(AcctSeedERP__Outbound_Inventory_Movement__c pMove)
		{
			move = pMove;
			strLockReason = '';
			boolDeleteRender = true;
		}

	}
	
	@RemoteAction
	global static String deleteRecord(Id idRecord)
	{
		Database.delete(idRecord);
		return '';
	}
}