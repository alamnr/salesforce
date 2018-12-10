global without sharing class gcDocument_SalesOrder {
	
	global transient AcctSeedERP__Sales_Order__c order{get;set;}

	global Id idSalesOrder
	{
		get;
		set{
			idSalesOrder = value;
			init();			
		}
	}

	global gcDocument_SalesOrder() {}

	global void init() {
		order =	[SELECT Id, 
						Name,
						Owner.Name,
						Fill_Date__c,
						PO_Number__c,
						Tracking_Number__c,
						Total_Ordered__c,
						Shipping_Method__c,

						AcctSeedERP__Shipment_Count__c,
						AcctSeedERP__Shipping_City__c,
						AcctSeedERP__Shipping_Country__c,
						AcctSeedERP__Shipping_PostalCode__c,
						AcctSeedERP__Shipping_State__c,
						AcctSeedERP__Shipping_Street__c,

						AcctSeedERP__Customer__r.Name,
						AcctSeedERP__Customer__r.AccountNumber,
						AcctSeedERP__Customer__r.Billing_Attention__c,
						AcctSeedERP__Customer__r.Drop_Ship_Account_Number__c,						
						AcctSeedERP__Customer__r.License_Number__c,
						AcctSeedERP__Customer__r.Shipping_Attention__c,
						AcctSeedERP__Customer__r.Phone,
						AcctSeedERP__Customer__r.BillingStreet,
						AcctSeedERP__Customer__r.BillingCity,
						AcctSeedERP__Customer__r.BillingState,
						AcctSeedERP__Customer__r.BillingPostalCode,
						AcctSeedERP__Customer__r.BillingCountry,

						Warehouse__r.Account__c,
						Warehouse__r.Account__r.Name,
						Warehouse__r.Account__r.ShippingCity,
						Warehouse__r.Account__r.ShippingPostalCode,
						Warehouse__r.Account__r.ShippingState,
						Warehouse__r.Account__r.ShippingStreet,
						Warehouse__r.Account__r.License_Number__c,
						Warehouse__r.Account__r.Phone,

						Warehouse__r.Distributor__c,
						Warehouse__r.Distributor__r.Name,
						Warehouse__r.Distributor__r.ShippingCity,
						Warehouse__r.Distributor__r.ShippingPostalCode,
						Warehouse__r.Distributor__r.ShippingState,
						Warehouse__r.Distributor__r.ShippingStreet,
						Warehouse__r.Distributor__r.License_Number__c,
						Warehouse__r.Distributor__r.Phone,

						AcctSeedERP__Customer__r.AcctSeed__Billing_Contact__c,
						AcctSeedERP__Customer__r.AcctSeed__Billing_Contact__r.Name,
						AcctSeedERP__Customer__r.AcctSeed__Billing_Contact__r.Phone,
						AcctSeedERP__Customer__r.AcctSeed__Shipping_Contact__c,
						AcctSeedERP__Customer__r.AcctSeed__Shipping_Contact__r.Name,
						AcctSeedERP__Customer__r.AcctSeed__Shipping_Contact__r.Phone,
						(SELECT Id,
								AcctSeedERP__Product__c,
								AcctSeedERP__Product__r.Name,
								AcctSeedERP__Product__r.ProductCode,
								AcctSeedERP__Product__r.Storage_Requirement__c,
								AcctSeedERP__Product__r.Variable_Price__c,
								AcctSeedERP__Product__r.Pricing_Units__c,
								
								Quantity_Filled__c,
								AcctSeedERP__Quantity_Needed__c,
								AcctSeedERP__Quantity_Ordered__c,
								AcctSeedERP__Unit_Price__c,
								Variant_Unit_Price__c,

								Lot__c,
								Lot__r.Name,
								Lot__r.Expiration_Date__c,
								Lot__r.Variant_Qty__c								
						 FROM AcctSeedERP__Sales_Order_Line__r
						 ORDER BY Name)
				 FROM AcctSeedERP__Sales_Order__c
				 WHERE Id = :idSalesOrder][0];

		if(order.Warehouse__r.Distributor__c == null)
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

			if(order.AcctSeedERP__Shipping_State__c != null && order.AcctSeedERP__Shipping_State__c.startsWithIgnoreCase('FL'))
			   order.Warehouse__r.Distributor__r = FLA;
			else 
			   order.Warehouse__r.Distributor__r = AUS;
		}
	}	
}