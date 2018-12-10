public without sharing class gcDocument_PurchaseOrder {
	
	public transient AcctSeedERP__Purchase_Order__c order{get;set;}

	public Id idPurchaseOrder
	{
		get;
		set{
			idPurchaseOrder = value;
			init();			
		}
	}

	public gcDocument_PurchaseOrder() {}

	public void init() {
		order =	[SELECT Id, 
						Name,
						Owner.Name,

						AcctSeedERP__Order_Date__c,
						AcctSeedERP__Total__c,

						AcctSeedERP__Vendor__r.Name,
						AcctSeedERP__Vendor__r.Phone,
						AcctSeedERP__Vendor__r.License_Number__c,			
						AcctSeedERP__Vendor_Street__c,
						AcctSeedERP__Vendor_City__c,
						AcctSeedERP__Vendor_State__c,
						AcctSeedERP__Vendor_Postal_Code__c,
						AcctSeedERP__Vendor_Country__c,
						AcctSeedERP__Vendor_Contact__c,
						AcctSeedERP__Vendor_Contact__r.Name,
						AcctSeedERP__Vendor_Contact__r.Phone,
						AcctSeedERP__Vendor_Contact__r.Email,						
					
						AcctSeedERP__Shipping_Company__r.Name,	
						AcctSeedERP__Shipping_Company__r.Phone,	
						AcctSeedERP__Shipping_Company__r.Drop_Ship_Account_Number__c,
						AcctSeedERP__Shipping_Company__r.License_Number__c,
						AcctSeedERP__Shipping_Company__r.Shipping_Attention__c,
						AcctSeedERP__Shipping_Company__r.AcctSeed__Shipping_Contact__r.Name,	
						AcctSeedERP__Shipping_Company__r.AcctSeed__Shipping_Contact__r.Phone,		
						AcctSeedERP__Shipping_Street__c,
						AcctSeedERP__Shipping_City__c,
						AcctSeedERP__Shipping_State__c,
						AcctSeedERP__Shipping_Postal_Code__c,
						AcctSeedERP__Shipping_Country__c,
						AcctSeedERP__Shipping_Contact__c,
						AcctSeedERP__Shipping_Contact__r.Name,
						AcctSeedERP__Shipping_Contact__r.Phone,
						AcctSeedERP__Shipping_Contact__r.Email,

						(SELECT Id,
								AcctSeedERP__Product__c,
								AcctSeedERP__Product__r.Name,
								AcctSeedERP__Product__r.ProductCode,
								AcctSeedERP__Product__r.Storage_Requirement__c,
								AcctSeedERP__Product__r.Variable_Price__c,
								AcctSeedERP__Product__r.Pricing_Units__c,
								
								AcctSeedERP__Quantity__c,
								AcctSeedERP__Total__c,
								AcctSeedERP__Unit_Price__c,

								Variant_Unit_Price__c,
								Lot__c,
								Lot__r.Name,
								Lot__r.Expiration_Date__c,
								Lot__r.Variant_Qty__c								
						 FROM AcctSeedERP__Purchase_Order_Lines__r
						 ORDER BY Name)
				 FROM AcctSeedERP__Purchase_Order__c
				 WHERE Id = :idPurchaseOrder][0];
	}	
}