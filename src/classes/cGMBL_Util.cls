global without sharing class cGMBL_Util {

	global cGMBL_Util(ApexPages.standardController ctrl){}

	@RemoteAction @ReadOnly
	global static list<wrapLocationLot> retrieveWrapLocationLots(Id idProduct, String idWarehouse)
	{
		list<wrapLocationLot> listWrapLocationLot = new list<wrapLocationLot>();
		for(AcctSeedERP__Inventory_Balance__c bal :
				[SELECT Id, AcctSeedERP__Location__c, AcctSeedERP__Location__r.Id, AcctSeedERP__Location__r.Name,
					(SELECT AcctSeedERP__Quantity__c, Lot__c, Lot__r.Id, Lot__r.Name, Lot__r.Expiration_Date__c, Lot__r.Variant_Qty__c FROM AcctSeedERP__Inbound_Inventory_Movements__r 			WHERE AcctSeedERP__Quantity__c != NULL),
					(SELECT AcctSeedERP__Quantity__c, Lot__c, Lot__r.Id, Lot__r.Name, Lot__r.Expiration_Date__c, Lot__r.Variant_Qty__c FROM AcctSeedERP__Manufacturing_Inventory_Movements__r 	WHERE AcctSeedERP__Quantity__c != NULL),
					(SELECT AcctSeedERP__Quantity__c, Lot__c, Lot__r.Id, Lot__r.Name, Lot__r.Expiration_Date__c, Lot__r.Variant_Qty__c FROM AcctSeedERP__Outbound_Inventory_Movements__r 		WHERE AcctSeedERP__Quantity__c != NULL),
					(SELECT AcctSeedERP__Quantity__c, Lot__c, Lot__r.Id, Lot__r.Name, Lot__r.Expiration_Date__c, Lot__r.Variant_Qty__c FROM AcctSeedERP__Purchase_Order_Inventory_Movements__r 	WHERE AcctSeedERP__Quantity__c != NULL),
					(SELECT AcctSeedERP__Quantity__c, Lot__c, Lot__r.Id, Lot__r.Name, Lot__r.Expiration_Date__c, Lot__r.Variant_Qty__c FROM AcctSeedERP__Inventory_Movements__r 		WHERE AcctSeedERP__Quantity__c != NULL)
				 FROM AcctSeedERP__Inventory_Balance__c
				 WHERE AcctSeedERP__Product__c = :idProduct
				   AND AcctSeedERP__Warehouse__c = :idWarehouse
				 ORDER BY AcctSeedERP__Location__r.Name])
		{
			map<Id,wrapLocationLot> mapWrapLocationLot = new map<Id,wrapLocationLot>(); //a map of LotId => wrapLocationLot, for the Location of this inventory balance

			AcctSeedERP__Location__c location = bal.AcctSeedERP__Location__r;
						
			for(AcctSeedERP__Inbound_Inventory_Movement__c move : bal.AcctSeedERP__Inbound_Inventory_Movements__r)
			{
				if(!mapWrapLocationLot.containsKey(move.Lot__c))
					mapWrapLocationLot.put(move.Lot__c, new wrapLocationLot(location, move.Lot__r, bal.Id));
				
				mapWrapLocationLot.get(move.Lot__c).qty += move.AcctSeedERP__Quantity__c;
			}			

			for(AcctSeedERP__Manufacturing_Inventory_Movement__c move : bal.AcctSeedERP__Manufacturing_Inventory_Movements__r)
			{
				if(!mapWrapLocationLot.containsKey(move.Lot__c))
					mapWrapLocationLot.put(move.Lot__c, new wrapLocationLot(location, move.Lot__r, bal.Id));
				
				mapWrapLocationLot.get(move.Lot__c).qty -= move.AcctSeedERP__Quantity__c;
			}	

			for(AcctSeedERP__Outbound_Inventory_Movement__c move : bal.AcctSeedERP__Outbound_Inventory_Movements__r)
			{
				if(!mapWrapLocationLot.containsKey(move.Lot__c))
					mapWrapLocationLot.put(move.Lot__c, new wrapLocationLot(location, move.Lot__r, bal.Id));
				
				mapWrapLocationLot.get(move.Lot__c).qty -= move.AcctSeedERP__Quantity__c;
			}	

			for(AcctSeedERP__Purchase_Order_Inventory_Movement__c move : bal.AcctSeedERP__Purchase_Order_Inventory_Movements__r)
			{
				if(!mapWrapLocationLot.containsKey(move.Lot__c))
					mapWrapLocationLot.put(move.Lot__c, new wrapLocationLot(location, move.Lot__r, bal.Id));
				
				mapWrapLocationLot.get(move.Lot__c).qty += move.AcctSeedERP__Quantity__c;
			}				

			for(AcctSeedERP__Sales_Order_Inventory_Movement__c move : bal.AcctSeedERP__Inventory_Movements__r)
			{
				if(!mapWrapLocationLot.containsKey(move.Lot__c))
					mapWrapLocationLot.put(move.Lot__c, new wrapLocationLot(location, move.Lot__r, bal.Id));
				
				mapWrapLocationLot.get(move.Lot__c).qty -= move.AcctSeedERP__Quantity__c;
			}
			
			for(wrapLocationLot wll : mapWrapLocationLot.values())
			{
				if(wll.qty > 0)
				listWrapLocationLot.add(wll);
			}
		}
		
		listWrapLocationLot.sort();
		return listWrapLocationLot;
	}
	
	
	global class wrapLocationLot implements Comparable
	{
		global Lot__c lot {get;set;}
		global AcctSeedERP__Location__c location{get;set;}
		global Decimal qty{get;set;}
		global Id idBalance{get;set;}
		
		global wrapLocationLot(AcctSeedERP__Location__c pLocation, Lot__c pLot, Id pIdBalance)
		{
			lot = pLot;
			location = pLocation;
			qty = 0;
			idBalance = pIdBalance;
		}
		global Integer compareTo(Object compareTo){
            wrapLocationLot cmp = (wrapLocationLot)compareTo;
            if(lot.Expiration_Date__c < cmp.lot.Expiration_Date__c)return -1;
            if(lot.Expiration_Date__c > cmp.lot.Expiration_Date__c)return 1;
            if(lot.Name < cmp.lot.Name)return -1;
            if(lot.Name > cmp.lot.Name)return 1;
            if(location.Name < cmp.location.Name)return -1;          
            return 1;
        }		
	}	
}