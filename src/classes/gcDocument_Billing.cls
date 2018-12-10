global without sharing class gcDocument_Billing{

	global transient AcctSeed__Billing__c bill{get;set;}
	global transient Account accountDistributor{get;set;}

	global Id idBilling
	{
		get;
		set{
			idBilling = value;
			init();			
		}
	}
	
	global gcDocument_Billing() {}

	global void init() {
		bill =	[SELECT Id, 
						Name,
						AcctSeed__Balance__c,
						AcctSeed__Billing_City__c,
						AcctSeed__Billing_Contact__c,
						AcctSeed__Billing_Contact__r.Name,
						AcctSeed__Billing_Contact__r.Phone,
						AcctSeed__Billing_Contact__r.Email,
						AcctSeed__Billing_Country__c,
						AcctSeed__Date__c,
						AcctSeed__Billing_PostalCode__c,
						AcctSeed__Billing_State__c,
						AcctSeed__Billing_Street__c,
						AcctSeed__Billing_Terms_Name__c,
						AcctSeed__Billing_Comment__c,
						AcctSeed__Customer__r.Name,
						AcctSeed__Customer__r.AccountNumber,
						AcctSeed__Customer__r.Billing_Attention__c,
						AcctSeed__Customer__r.Drop_Ship_Account_Number__c,						
						AcctSeed__Customer__r.License_Number__c,
						AcctSeed__Customer__r.Shipping_Attention__c,
						AcctSeed__Customer__r.Phone,
						AcctSeed__Due_Date__c,
						AcctSeed__PO_Number__c,
						AcctSeedERP__Sales_Order__c,
						AcctSeedERP__Sales_Order__r.Id,
						AcctSeedERP__Sales_Order__r.Name,
						AcctSeedERP__Sales_Order__r.Owner.Name,
						AcctSeedERP__Sales_Order__r.Shipping_Method__c,
						AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__c,
						AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__r.Id,
						AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__r.Name,
						AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__r.ShippingCity,
						AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__r.ShippingPostalCode,
						AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__r.ShippingState,
						AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__r.ShippingStreet,
						AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__r.License_Number__c,
						AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__r.Phone,
						AcctSeed__Shipping_City__c,
						AcctSeed__Shipping_Contact__c,
						AcctSeed__Shipping_Contact__r.Name,
						AcctSeed__Shipping_Contact__r.Phone,
						AcctSeed__Shipping_Contact__r.Email,						
						AcctSeed__Shipping_Country__c,
						AcctSeed__Shipping_PostalCode__c,
						AcctSeed__Shipping_State__c,
						AcctSeed__Shipping_Street__c,
						AcctSeed__Total__c,
						Ship_To__c,
						Ship_To__r.Name,
						Shipping_Attention__c,
						(SELECT Id,
								AcctSeed__Product__c,
								AcctSeed__Product__r.Name,
								AcctSeed__Product__r.ProductCode,
								AcctSeed__Product__r.Storage_Requirement__c,
								AcctSeed__Product__r.Variable_Price__c,
								AcctSeed__Product__r.Pricing_Units__c,
								AcctSeed__Hours_Units__c,
								AcctSeed__Rate__c,
								AcctSeed__Total__c,
								AcctSeedERP__Sales_Order_Line__c,
								AcctSeedERP__Sales_Order_Line__r.Lot__c,
								AcctSeedERP__Sales_Order_Line__r.Lot__r.Name,
								AcctSeedERP__Sales_Order_Line__r.Lot__r.Expiration_Date__c,
								AcctSeedERP__Sales_Order_Line__r.Lot__r.Variant_Qty__c,
								AcctSeedERP__Sales_Order_Line__r.Variant_Unit_Price__c
						 FROM AcctSeed__Project_Billing_Lines__r
						 ORDER BY Name)
				 FROM AcctSeed__Billing__c
				 WHERE Id = :idBilling][0];

		accountDistributor = bill.AcctSeedERP__Sales_Order__r.Warehouse__r.Distributor__r;

		if(accountDistributor == null)
		{
			Account AUS = new Account();
			Account FLA = new Account();

			for(AcctSeedERP__Warehouse__c w :
					[SELECT Uniquefier__c,
						Distributor__r.Id,
						Distributor__r.Name,
						Distributor__r.ShippingCity,
						Distributor__r.ShippingPostalCode,
						Distributor__r.ShippingState,
						Distributor__r.ShippingStreet,
						Distributor__r.License_Number__c,
						Distributor__r.Phone
					 FROM AcctSeedERP__Warehouse__c
					 WHERE Uniquefier__c IN ('A1','A2')])
			{
				if(w.Uniquefier__c == 'A1') AUS = w.Distributor__r;
				else FLA = w.Distributor__r;
			}

			if(bill.AcctSeed__Shipping_State__c != null && bill.AcctSeed__Shipping_State__c.startsWithIgnoreCase('FL'))
			   accountDistributor = FLA;
			else 
			   accountDistributor = AUS;
		}
	}
}