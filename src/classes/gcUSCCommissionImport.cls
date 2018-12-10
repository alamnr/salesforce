public with sharing class gcUSCCommissionImport {
	
	@RemoteAction
	public static Integer SaveData(List<fileData> fdata)
	{
		
		List<AcctSeed__Billing_Cash_Receipt__c> listBillingCR = new List<AcctSeed__Billing_Cash_Receipt__c>();
		
		Set<Id> setBillingIds = new Set<Id>();
		Map<Id,Decimal> cashToBill = new Map<Id,Decimal>();
		Integer orderCount = 0;
		Decimal PaymentTotal =0;
		Decimal tmpval;

		//Get the account id of the USC customer record
		Id idUSC = [SELECT Id FROM Account WHERE USC_Account_Number__c = 'USCOM01' ORDER BY CreatedDate LIMIT 1][0].Id;

		//Create the cash receipt
		for(fileData f: fdata)
		{
			orderCount += 1;
			PaymentTotal += f.Import_Commission;	
			setBillingIds.add(f.IdBilling);
			if (cashToBill.containsKey(f.IdBilling))
				tmpval = cashToBill.get(f.IdBilling) + f.Import_Commission;
			else
				tmpval = f.Import_Commission;

			cashToBill.put(f.IdBilling, tmpval);
		
		}

		AcctSeed__Cash_Receipt__c cashReceipt = new AcctSeed__Cash_Receipt__c(
			AcctSeed__Receipt_Date__c = Date.today(),
			AcctSeed__Amount__c = PaymentTotal,
			AcctSeed__Payment_Reference__c = 'IMPORT-' +  dateTime.now().format(),
			AcctSeed__Account__c = idUSC,
			AcctSeed__Status__c = 'Posted',
			AcctSeed__Purpose__c = 'Customer Receipt',
			Form_of_Payment__c = 'ACH / EFT');

		insert cashReceipt;
		
		//Next, create all the billing cash receipts
		for(AcctSeed__Billing__c b : [SELECT Id, AcctSeed__Accounting_Period__c, AcctSeed__Total__c
			 						  FROM AcctSeed__Billing__c
			 						  WHERE Id In :setBillingIds])
		{
			AcctSeed__Billing_Cash_Receipt__c bcr = new AcctSeed__Billing_Cash_Receipt__c(
				AcctSeed__Applied_Amount__c = cashToBill.get(b.Id),
				AcctSeed__Billing__c = b.Id,
				AcctSeed__Cash_Receipt__c = cashReceipt.Id,
				AcctSeed__Accounting_Period__c = b.AcctSeed__Accounting_Period__c);

			listBillingCR.add(bcr);
		}

		insert listBillingCR;
		return orderCount;
	}

	@RemoteAction
	public static list<fileData> ValidateData(List<fileData> fdata)
	{

		Map<String, AcctSeed__Billing__c> mapBillings = new Map<String, AcctSeed__Billing__c>();
		Map<String, AcctSeedERP__Sales_Order__c> mapSalesOrders = new Map<String, AcctSeedERP__Sales_Order__c>();
		Set<String> setProduct = new Set<String>();
		Set<String> setCustomer = new Set<String>();
		Set<String> setSOPNumber = new Set<String>();
		
		Map<String, Product2> mapProductName= new Map<String, Product2>();
		Map<String, Account> mapAccountName= new Map<String, Account>();

		//Create maps for customers and products

		for(fileData f: fdata){
			setCustomer.add(f.Customer_Number);
			setProduct.add(f.Item_Number);
			setSOPNumber.add(f.SOP_Number);
			
		}

		//Load matching products
		for (Product2 p : [SELECT Id, Product_Code_Uniquefier__c, Compounding_Profit_Share__c from Product2 where Product_Code_Uniquefier__c IN :setProduct
			AND Product_Code_Uniquefier__c != null])
		{
			mapProductName.put(p.Product_Code_Uniquefier__c, p);				
		}

		//Load matching accounts
		for (Account a : [SELECT Id, USC_Account_Number__c, Pricebook__c from Account where USC_Account_Number__c IN :setCustomer
			AND USC_Account_Number__c != null])
		{
			mapAccountName.put(a.USC_Account_Number__c, a);		
		}	

		mapProductName.remove(null);
		mapAccountName.remove(null);

		for(fileData f: fdata){
			//Check for existing customer
			if (mapAccountName.containsKey(f.Customer_Number))
		 	{
		 		f.IdAccount = mapAccountName.get(f.Customer_Number).Id;
         	}
         	//Check for existing product
         	if (mapProductName.containsKey(f.Item_Number))
		 	{
		 		f.IDProduct = mapProductName.get(f.Item_Number).Id;
		 		f.Contract_Percent = mapProductName.get(f.Item_Number).Compounding_Profit_Share__c;
         	}
         }

         //Next, grab the sales order to get the price fields		
		for(AcctSeedERP__Sales_Order__c so :
			[SELECT Id, AcctSeedERP__Customer__c, PO_Number__c,
				(SELECT Id, AcctSeedERP__Product__c, AcctSeedERP__Quantity_Ordered__c, AcctSeedERP__Unit_Price__c
				 FROM AcctSeedERP__Sales_Order_Line__r
				 ORDER BY Id)
		 	FROM AcctSeedERP__Sales_Order__c
		 	WHERE PO_Number__c In :setSOPNumber])
		{
    		mapSalesOrders.put(so.PO_Number__c, so);
    	}

		mapSalesOrders.remove(null);

		for(fileData f: fdata)
		{
			if (mapSalesOrders.containsKey(f.SOP_Number))
			{

				AcctSeedERP__Sales_Order__c so = mapSalesOrders.get(f.SOP_Number);
				f.IdSalesOrder = so.Id;

				for(AcctSeedERP__Sales_Order_Line__c sol : so.AcctSeedERP__Sales_Order_Line__r)
				{
					if (sol.AcctSeedERP__Quantity_Ordered__c == f.Quantity && sol.AcctSeedERP__Product__c == f.IdProduct && so.AcctSeedERP__Customer__c == f.IdAccount)
					{
						f.IdSalesOrderLine = sol.Id;
						f.Contract_Price = (sol.AcctSeedERP__Unit_Price__c * sol.AcctSeedERP__Quantity_Ordered__c);
					}
				}
			}
		}						        
		

		//Next, grab the billing to get the cost fields
		for(AcctSeed__Billing__c b :
			[SELECT Id, AcctSeed__Customer__c, AcctSeed__PO_Number__c,
				(SELECT Id, AcctSeed__Product__c, AcctSeed__Rate__c, AcctSeed__Hours_Units__c
				 FROM AcctSeed__Project_Billing_Lines__r
				 ORDER BY Id)
		 	FROM AcctSeed__Billing__c
		 	WHERE AcctSeed__PO_Number__c In :setSOPNumber])
		{
    		mapBillings.put(b.AcctSeed__PO_Number__c, b);
    	}

		mapBillings.remove(null);

		for(fileData f: fdata)
		{
			if (mapBillings.containsKey(f.SOP_Number))
			{
				AcctSeed__Billing__c b = mapBillings.get(f.SOP_Number);
				f.IdBilling = b.Id;
				for(AcctSeed__Billing_Line__c bl : b.AcctSeed__Project_Billing_Lines__r)
				{
					if (bl.AcctSeed__Hours_Units__c == f.Quantity && bl.AcctSeed__Product__c == f.IdProduct) 
					{
						f.IdBillingLine = bl.Id;
						f.Contract_Cost = bl.AcctSeed__Rate__c * bl.AcctSeed__Hours_Units__c;
					}
				}
			}
		}				        

		for(fileData f: fdata)
		{
			if (f.Contract_Percent != 0)
				f.Contract_Commission = (f.Contract_Price - f.Contract_Cost) * (f.Contract_Percent/100);
			else
				f.Contract_Commission = 0;


			if ((f.Import_Cost - f.Import_Price) != 0)
				f.Import_Percent = (f.Import_Commission/(f.Import_Price - f.Import_Cost)) * 100;
			else
				f.Import_Percent = 0;

			//Set the error fields

			Boolean Error_Product = (f.IdProduct == null);
	        Boolean Error_Account = (f.IdAccount == null);
	        Boolean Error_Cost  = (f.Contract_Cost != f.Import_Cost);
	        Boolean Error_Price = (f.Contract_Price != f.Import_Price);
	        Boolean Error_Commission = (f.Contract_Commission != f.Import_Commission);
	        Boolean Error_Percent = (f.Contract_Percent != f.Import_Percent);
	        Boolean Error_SOPNF = (f.IdSalesOrder == null);
	        Boolean Error_SOLNotFound = (f.IdSalesOrderLine == null);
	        Boolean Error_BLNotFound = (f.IdBillingLine == null);
	        Boolean Error_DupCashReceipt = false;
							
		    String errmessage = '';

		    if (Error_Account)
		    	errmessage += 'USC account not found, ';

        	if (Error_Product)
        		errmessage += 'product not found, ';

        	if (!Error_Account && !Error_Product && Error_SOPNF)
        		errmessage += 'SOP number not found in Sales Orders, ';

        	if (!Error_Account && !Error_Product && !Error_SOPNF && Error_SOLNotFound)
        		errmessage += 'SOP number found but not product/quantity, ';

        	if (!Error_Account && !Error_Product && !Error_SOPNF && !Error_SOLNotFound && Error_BLNotFound)
        		errmessage += 'matching billing line not found, ';

	        //only if everything was found do we check the actual cost/price fields
        	if (!Error_Account && !Error_Product && !Error_SOPNF && !Error_SOLNotFound && !Error_BLNotFound)
			{	
				if (Error_Cost)
        			errmessage += 'cost does not match contract, ';
        		if (Error_Price)
        			errmessage += 'price does not match contract, ';
				if (Error_Commission)
        			errmessage += 'commission does not match contract, ';
        		if (Error_Percent)
        			errmessage += 'profit share percentage does not match contract, ';
        	}
        
			if (!String.isBlank(errmessage))
	        	errmessage = errmessage.left(errmessage.length()-2);
			
			f.Error_Message = errmessage;
		}

		return fdata;
	}

	
	public class fileData
	{   

 		public String SOP_Number;
 		public String Item_Number;
 		public String Customer_Name;
 		public String Customer_Number;
 		public Decimal Quantity;
		public String Document_Date;
		public String Item_Description;
 		public String SOP_Type;
		public String Item_Plan;
		
        public Decimal Contract_Price;
        public Decimal Contract_Cost;
        public Decimal Contract_Percent;
        public Decimal Contract_Commission;
		public Decimal Import_Price;
        public Decimal Import_Cost;
        public Decimal Import_Percent;
        public Decimal Import_Commission;
        
        public Id IdAccount;
        public Id IdProduct;
        public Id IdSalesOrder;
        public Id IdSalesOrderLine;
        public Id IdBilling;
        public Id IdBillingLine;
 		public String Error_Message;
 		
	}

}