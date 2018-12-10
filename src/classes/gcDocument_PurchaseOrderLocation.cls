public with sharing class gcDocument_PurchaseOrderLocation {
	
	public transient AcctSeedERP__Purchase_Order__c order{get;set;}
	public transient list<pLine> poLines{get;set;}

	public Id idPurchaseOrder
	{
		get;
		set{
			idPurchaseOrder = value;
			init();			
		}
	}

	public gcDocument_PurchaseOrderLocation() {}

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
						AcctSeedERP__Shipping_Contact__r.Email
				 FROM AcctSeedERP__Purchase_Order__c
				 WHERE Id = :idPurchaseOrder][0];

		poLines = new list<pLine>();

		for(AcctSeedERP__Purchase_Order_Line__c pol : 
			 [SELECT AcctSeedERP__Product__c, AcctSeedERP__Product__r.Name, AcctSeedERP__Product__r.ProductCode,
				AcctSeedERP__Product__r.Storage_Requirement__c, AcctSeedERP__Product__r.Variable_Price__c,
				AcctSeedERP__Product__r.Pricing_Units__c, AcctSeedERP__Quantity__c,
				AcctSeedERP__Total__c, AcctSeedERP__Unit_Price__c, Variant_Unit_Price__c, Lot__c,
				Lot__r.Name, Lot__r.Expiration_Date__c, Lot__r.Variant_Qty__c,
				(SELECT Id, Name, AcctSeedERP__Location__c, AcctSeedERP__Quantity__c, AcctSeedERP__Unit_Cost__c, 
				AcctSeedERP__Warehouse__c, Total__c
				FROM AcctSeedERP__Purchase_Order_Inventory_Movements__r)
				FROM AcctSeedERP__Purchase_Order_Line__c
				WHERE AcctSeedERP__Purchase_Order__r.Id = :idPurchaseOrder])
		{
			

			if (pol.AcctSeedERP__Purchase_Order_Inventory_Movements__r.size() == 0)
			{
				pLine p = new pLine();
				p.ProductName = pol.AcctSeedERP__Product__r.Name;
				p.ProductCode = pol.AcctSeedERP__Product__r.ProductCode;
				p.Storage_Requirement = pol.AcctSeedERP__Product__r.Storage_Requirement__c;
				p.Variable_Price = pol.AcctSeedERP__Product__r.Variable_Price__c;
				p.Variant_Qty = pol.Lot__r.Variant_Qty__c;
				p.Pricing_Units = pol.AcctSeedERP__Product__r.Pricing_Units__c;
				p.Variable_Price = pol.AcctSeedERP__Product__r.Variable_Price__c;
				p.LotName = pol.Lot__r.Name;
				p.Warehouse = '';
				p.Expiration_Date = pol.Lot__r.Expiration_Date__c;
				p.Quantity = pol.AcctSeedERP__Quantity__c;
				p.Unit_Cost = pol.AcctSeedERP__Unit_Price__c;
				p.LineTotal = pol.AcctSeedERP__Total__c;
				poLines.add(p); 
			}
			else
			{
				for(AcctSeedERP__Purchase_Order_Inventory_Movement__c pom : pol.AcctSeedERP__Purchase_Order_Inventory_Movements__r)
				{
					pLine p = new pLine();
					p.ProductName = pol.AcctSeedERP__Product__r.Name;
					p.ProductCode = pol.AcctSeedERP__Product__r.ProductCode;
					p.Storage_Requirement = pol.AcctSeedERP__Product__r.Storage_Requirement__c;
					p.Variable_Price = pol.AcctSeedERP__Product__r.Variable_Price__c;
					p.Variant_Qty = pol.Lot__r.Variant_Qty__c;
					p.Pricing_Units = pol.AcctSeedERP__Product__r.Pricing_Units__c;
					p.Variable_Price = pol.AcctSeedERP__Product__r.Variable_Price__c;
					p.LotName = pol.Lot__r.Name;
					p.Expiration_Date = pol.Lot__r.Expiration_Date__c;
					p.Warehouse = pom.AcctSeedERP__Warehouse__c;
					p.Quantity = pom.AcctSeedERP__Quantity__c;
					p.Unit_Cost = pom.AcctSeedERP__Unit_Cost__c;
					p.LineTotal = pom.Total__c;
					poLines.add(p);
				}
			}
		}
	}


	public class pLine
	{   
		public String ProductName{get;set;}  
		public String ProductCode{get;set;}  
		public String  Storage_Requirement{get;set;}  
		public Boolean Variable_Price{get;set;}  
		public Decimal Variant_Qty{get;set;}  
		public String  Pricing_Units{get;set;}  
		public String LotName{get;set;}  
		public Date Expiration_Date{get;set;}  
		public String Warehouse{get;set;}  
		public Decimal Quantity{get;set;}  
		public Decimal Unit_Cost{get;set;}  
		public Decimal LineTotal{get;set;}  
	}

}