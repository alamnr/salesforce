global without sharing class gcDocument_InventoryTransfer {
	global transient Inventory_Transfer__c rec{get;set;}

	global Id idTransfer
	{
		get;
		set{
			idTransfer = value;
			init();			
		}
	}
	
	global gcDocument_InventoryTransfer() {}

	global void init() {
		rec = [SELECT Id, Name, Shipping_Method__c, Outbound_Date__c,
					  Warehouse_From__r.Account__r.Name,
					  Warehouse_From__r.Account__r.AccountNumber,
					  Warehouse_From__r.Account__r.ShippingCity,
					  Warehouse_From__r.Account__r.ShippingPostalCode,
					  Warehouse_From__r.Account__r.ShippingState,
					  Warehouse_From__r.Account__r.ShippingStreet,
					  Warehouse_From__r.Account__r.Shipping_Attention__c,
					  Warehouse_From__r.Account__r.Phone,
					  Warehouse_From__r.Account__r.DEA_Number__c,
					  Warehouse_From__r.Account__r.License_Number__c,
					  Warehouse_From__r.Distributor__c,
					  Warehouse_From__r.Distributor__r.Name,
					  Warehouse_From__r.Distributor__r.ShippingCity,
					  Warehouse_From__r.Distributor__r.ShippingPostalCode,
					  Warehouse_From__r.Distributor__r.ShippingState,
					  Warehouse_From__r.Distributor__r.ShippingStreet,
					  Warehouse_From__r.Distributor__r.License_Number__c,
					  Warehouse_From__r.Distributor__r.Phone,
					  Warehouse_To__r.Account__r.Name,
					  Warehouse_To__r.Account__r.AccountNumber,
					  Warehouse_To__r.Account__r.ShippingCity,
					  Warehouse_To__r.Account__r.ShippingPostalCode,
					  Warehouse_To__r.Account__r.ShippingState,
					  Warehouse_To__r.Account__r.ShippingStreet,
					  Warehouse_To__r.Account__r.Shipping_Attention__c,
					  Warehouse_To__r.Account__r.Phone,
					  Warehouse_To__r.Account__r.DEA_Number__c,
					  Warehouse_To__r.Account__r.License_Number__c,
					  Warehouse_To__r.Account__r.Drop_Ship_Account_Number__c,
					  Warehouse_To__r.Account__r.AcctSeed__Shipping_Contact__r.Name,
					  (SELECT Id, Name,
					  		  AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Name,
					  		  AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.ProductCode,
					  		  AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Storage_Requirement__c,
					  		  AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Pricing_Units__c,
					  		  AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Variable_Price__c,
					  		  AcctSeedERP__Quantity__c,
					  		  Lot__r.Name,
					  		  Lot__r.Expiration_Date__c,
					  		  Lot__r.Variant_Qty__c
					  	FROM Outbound_Inventory_Movements__r
					  	WHERE AcctSeedERP__Inbound_Inventory_Movement__c = null
					  	ORDER BY Name)
				FROM Inventory_Transfer__c WHERE Id = :idTransfer][0];		  

		if(rec.Warehouse_From__r.Distributor__c == null)
		{
			Account AUS = new Account();
			Account FLA = new Account();

			for(Account a :
					[SELECT Id,
							AccountNumber,
							Name,
							ShippingCity,
							ShippingPostalCode,
							ShippingState,
							ShippingStreet,
							License_Number__c,
							Phone
					 FROM Account
					 WHERE AccountNumber IN ('PHSC01','PHSC02')])
			{
				if(a.AccountNumber == 'PHSC01') AUS = a;
				else FLA = a;
			}

			if(rec.Warehouse_To__r.Account__r.ShippingState != null && rec.Warehouse_To__r.Account__r.ShippingState.startsWithIgnoreCase('FL'))
			   rec.Warehouse_From__r.Distributor__r = FLA;
			else 
			   rec.Warehouse_From__r.Distributor__r = AUS;
		}
	}	
}