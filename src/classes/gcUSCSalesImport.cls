public with sharing class gcUSCSalesImport {

    public class gimbalException extends Exception {}


    @RemoteAction
    public static String SaveData(List<USC_Invoice_Data__c> fdata)
    {
        
    //    Try{

            List<USC_Invoice_Data__c> updIssueRecs = new List<USC_Invoice_Data__c>();
            List<USC_Invoice_Data__c> delIssueRecs = new List<USC_Invoice_Data__c>();
            List<AcctSeed__Billing_Line__c> listBillingLines = new List<AcctSeed__Billing_Line__c>();
            List<AcctSeed__Billing__c> listBillings = new List<AcctSeed__Billing__c>();
            List<AcctSeedERP__Sales_Order__c> listSO = new List<AcctSeedERP__Sales_Order__c>();
            List<AcctSeedERP__Sales_Order_Line__c> listSOL = new List<AcctSeedERP__Sales_Order_Line__c>();
            Set<Id> setNewSO = new Set<Id>();
            Map<String, Id> mapNewSO= new Map<String, Id>();
            Map<String, Id> mapNewBillings= new Map<String, Id>();
            String lastSOP = '';
            Integer orderCount = 0;
            Decimal UnitCost;
            Decimal UnitPrice;

            //Get the account id of the USC customer record
            Id idUSC = gcConstants.fetchIdUSCAccount();
            Id idWareHouse = gcConstants.fetchIdUSCWarehouse();

            //Add all the sales orders
            for(USC_Invoice_Data__c f: fdata)
            {

                if (!f.Has_Error__c && !f.SalesOrderCreated__c)
                {

                    if (f.SOP_Number__c != lastSOP)
                    {
                        orderCount += 1;
                        lastSOP = f.SOP_Number__c;
                        AcctSeedERP__Sales_Order__c so = new AcctSeedERP__Sales_Order__c(
                        AcctSeedERP__Customer__c = f.Customer__c,
                        PO_Number__c = f.SOP_Number__c,
                        Fill_Date__c =  f.Invoice_Date__c,
                        Type__c = 'Commission',
                        Warehouse__c = idWareHouse,
                        Pricebook__c = f.Pricebook__c,
                        AcctSeedERP__Status__c = '2 - Closed');
                        listSO.add(so);
                    }
                }
            }

            if (listSO.size() > 0)
                insert listSO;

            for(AcctSeedERP__Sales_Order__c so: listSO){        
                mapNewSO.put(so.PO_Number__c,so.Id);
                setNewSO.add(so.Id);
            }

            //Next, add all the sales order lines
            for(USC_Invoice_Data__c f: fdata)
            {

                if (!f.Has_Error__c && !f.SalesOrderCreated__c)
                {
                    f.SalesOrderCreated__c = true;

                    UnitPrice = (f.Dispute_Price__c || f.Accept_Price__c ? f.Resolved_Unit_Price__c : f.Import_Unit_Price__c);
                    UnitCost = (f.Dispute_Cost__c || f.Accept_Cost__c ? f.Resolved_Unit_Cost__c : f.Import_Unit_Cost__c);

                    AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c(
                        AcctSeedERP__Sales_Order__c = mapNewSO.get(f.SOP_Number__c),
                        AcctSeedERP__Product__c = f.Product__c,
                        Quantity_Filled__c = f.QTY__c,
                        AcctSeedERP__Quantity_Ordered__c = f.QTY__c,
                        AcctSeedERP__Unit_Price__c = UnitPrice,
                        USC_Unit_Cost__c = (UnitPrice - UnitCost) * f.Contract_Share_Percent__c);
                    listSOL.add(sol);
                }
            }

            system.debug('listSOL: ' + listSOL.size());
            if (listSOL.size() > 0)
                insert listSOL;     

            //Next, grab the newly added sales order to create the billing records
            for(AcctSeedERP__Sales_Order__c so : [SELECT Id, AcctSeedERP__Customer__c,Fill_Date__c, AcctSeedERP__Opportunity__c, PO_Number__c
                                                  FROM AcctSeedERP__Sales_Order__c
                                                  WHERE Id In :setNewSO])
            {
                AcctSeed__Billing__c b = new AcctSeed__Billing__c(
                    AcctSeed__Date__c = so.Fill_Date__c,
                    AcctSeed__Customer__c = idUSC,
                    AcctSeed__Opportunity__c = so.AcctSeedERP__Opportunity__c,
                    AcctSeed__PO_Number__c = so.PO_Number__c,
                    AcctSeedERP__Sales_Order__c = so.Id);

                listBillings.add(b);
            }

            if (listbillings.size() > 0)
                insert listbillings;

            for(AcctSeed__Billing__c b: listBillings){      
                mapNewBillings.put(b.AcctSeed__PO_Number__c,b.Id);
            }

            //Next, grab the newly added sales order lines to create the billing line records
            for(AcctSeedERP__Sales_Order_Line__c sol :
                [SELECT Id, AcctSeedERP__GL_Account_Variable_1__c, AcctSeedERP__GL_Account_Variable_2__c,
                        AcctSeedERP__GL_Account_Variable_3__c, AcctSeedERP__GL_Account_Variable_4__c,
                        AcctSeedERP__Product__c, AcctSeedERP__Project__c, AcctSeedERP__Project_Task__c,
                        Quantity_Filled__c, AcctSeedERP__Quantity_Ordered__c, USC_Unit_Cost__c,
                        AcctSeedERP__Sales_Order__r.PO_Number__c
                 FROM AcctSeedERP__Sales_Order_Line__c
                 WHERE AcctSeedERP__Sales_Order__r.Id In :setNewSO])
            {
                AcctSeed__Billing_Line__c bl = new AcctSeed__Billing_Line__c(
                    AcctSeed__Billing__c = mapNewBillings.get(sol.AcctSeedERP__Sales_Order__r.PO_Number__c),
                    Override__c = true,
                    AcctSeed__GL_Account_Variable_1__c = sol.AcctSeedERP__GL_Account_Variable_1__c,
                    AcctSeed__GL_Account_Variable_2__c = sol.AcctSeedERP__GL_Account_Variable_2__c,
                    AcctSeed__GL_Account_Variable_3__c = sol.AcctSeedERP__GL_Account_Variable_3__c,
                    AcctSeed__GL_Account_Variable_4__c = sol.AcctSeedERP__GL_Account_Variable_4__c,
                    AcctSeed__Product__c = sol.AcctSeedERP__Product__c,
                    AcctSeed__Project__c = sol.AcctSeedERP__Project__c,
                    AcctSeed__Project_Task__c = sol.AcctSeedERP__Project_Task__c,
                    AcctSeed__Hours_Units__c = sol.AcctSeedERP__Quantity_Ordered__c,
                    AcctSeed__Rate__c = sol.USC_Unit_Cost__c,
                    AcctSeedERP__Sales_Order_Line__c = sol.Id);

                listBillingLines.add(bl);
            }

            if (listBillingLines.size() > 0)
            {
                insert listBillingLines;
                //Post the billings
                AcctSeed.BillingPostService.postBillings(listBillings);
            }

            
            for(USC_Invoice_Data__c f: fdata)
            {

                if (!f.Has_Error__c)
                    f.SalesOrderCreated__c = true;

                if (!f.Has_Error__c && !f.Dispute_Cost__c && !f.Dispute_Price__c && !f.Accept_Cost__c && !f.Accept_Price__c)
                {
                    if (f.Id != null)
                        delIssueRecs.add(f);
                }
                else
                {
                    system.debug(f.Id);
                    updIssueRecs.add(f);
                }
            }


            for(USC_Invoice_Data__c f: updIssueRecs)
            {

                if (mapNewSO.containsKey(f.SOP_Number__c))
                    f.Sales_Order__c = mapNewSO.get(f.SOP_Number__c);
            }

            if (updIssueRecs.size() > 0)
                upsert updIssueRecs;
            if (delIssueRecs.size() > 0)
                delete delIssueRecs;

            return '';

    //    }
    //    catch(Exception e) {
    //        system.debug('Error: ' + e.getMessage());
    //        return e.getMessage();
    //    }    
    }

    @RemoteAction
    public static list<USC_Invoice_Data__c> ValidateData(List<USC_Invoice_Data__c> fdata, Boolean saveData)
    {

        //Try{

            Set<String> setProduct = new Set<String>();
            Set<String> setCustomer = new Set<String>();
            Set<String> setImportSOPNumber = new Set<String>();
            Set<String> setSavedSOPNumber = new Set<String>();
            
            Map<String, Product2> mapProductCode= new Map<String, Product2>();
            Map<String, Account> mapAccountName= new Map<String, Account>();

            Map<Id, Product2> mapProduct= new Map<Id, Product2>();
            Map<Id, Account> mapAccount= new Map<Id, Account>();

            //Create maps for customers and products
            for(USC_Invoice_Data__c f: fdata){
                setCustomer.add(f.Customer_Number__c);
                setProduct.add(f.Item_Number__c);
                setImportSOPNumber.add(f.SOP_Number__c);
            }

            //Load products that match Product_Code_NDC_without_dashes__c
            for (Product2 p : [SELECT Id, Product_Code_NDC_without_dashes__c, ProductCode, Compounding_Profit_Share__c FROM Product2 WHERE Product_Code_NDC_without_dashes__c IN :setProduct])
            {
                mapProductCode.put(p.Product_Code_NDC_without_dashes__c, p);        
                mapProduct.put(p.Id, p);        
            }

            //Load products that match ProductCode
            for (Product2 p : [SELECT Id, Product_Code_NDC_without_dashes__c, ProductCode, Compounding_Profit_Share__c FROM Product2 WHERE ProductCode IN :setProduct])
            {
                mapProductCode.put(p.ProductCode, p);       
                mapProduct.put(p.Id, p);        
            }

            //Load matching accounts
            for (Account a : [SELECT Id, USC_Account_Number__c, Pricebook__c FROM Account WHERE USC_Account_Number__c IN :setCustomer
                AND USC_Account_Number__c != null])
            {
                mapAccountName.put(a.USC_Account_Number__c, a);     
                mapAccount.put(a.Id, a);
            }

            //Load the set of matching SOPNumbers
            for (AcctSeedERP__Sales_Order__c so : [SELECT Id, PO_Number__c FROM AcctSeedERP__Sales_Order__c WHERE PO_Number__c IN :setImportSOPNumber])
            {
                setSavedSOPNumber.add(so.PO_Number__c);     
            }       

            //Load the set of matching SOPNumbers (from the issues table as well, but only if this is new data)
            if (!saveData){
                for (USC_Invoice_Data__c f : [SELECT Id, SOP_Number__c FROM USC_Invoice_Data__c WHERE SOP_Number__c IN :setImportSOPNumber])
                {
                    setSavedSOPNumber.add(f.SOP_Number__c);     
                }   
            }

            mapProductCode.remove(null);
            mapAccountName.remove(null);
            mapProduct.remove(null);
            mapAccount.remove(null);

            for(USC_Invoice_Data__c f: fdata){
                //Check for existing customer
                if (mapAccountName.containsKey(f.Customer_Number__c))
                {
                    f.Customer__c = mapAccountName.get(f.Customer_Number__c).Id;
                    f.Pricebook__c = mapAccountName.get(f.Customer_Number__c).Pricebook__c;
                }
                //Check for existing product
                if (mapProductCode.containsKey(f.Item_Number__c))
                {
                    f.Product__c = mapProductCode.get(f.Item_Number__c).Id;
                    f.Contract_Share_Percent__c = mapProductCode.get(f.Item_Number__c).Compounding_Profit_Share__c;
                    if (f.Contract_Share_Percent__c == null)
                        f.Contract_Share_Percent__c = 0;
                    if (f.Contract_Share_Percent__c != 0)
                        f.Contract_Share_Percent__c = (f.Contract_Share_Percent__c/100);
                }
                //Check for existing Sales Order
                f.Error_DupSalesOrder__c = setSavedSOPNumber.contains(f.SOP_Number__c);
            }

            //***GET THE CONTRACTED PRICE AND UNIT PRICE
            //This is based on the customer pricebook, if the product is not in the customer pricebook or
            //there is no specified pricebook for the customer then it's an error
        
            
            map<Id,map<Id,Decimal>> mapProductPricebookPrice = new map<Id,map<Id,Decimal>>();

            for(USC_Invoice_Data__c f: fdata)
            {
                if (f.Product__c != NULL && f.Pricebook__c != NULL)
                    mapProductPricebookPrice.put(f.Product__c,new map<Id,Decimal>());
            }
            mapProductPricebookPrice.remove(NULL);

            //collect the products, with prices
            if(mapProduct.size() > 0)
            for(Product2 p :
                [SELECT Id, Name, ProductCode, Variable_Price__c,
                    (SELECT Id, IsActive, UnitPrice, 
                            PriceBook2Id, PriceBook2.Name, PriceBook2.IsActive, PriceBook2.IsStandard
                     FROM PriceBookEntries
                     WHERE IsActive = true
                       AND PriceBook2.IsActive = true
                     ORDER BY CreatedDate desc)
                 FROM Product2
                 WHERE Id IN : mapProduct.keySet()])
            {
                
                if (mapProductPricebookPrice.containsKey(p.Id))
                {
                    map<Id,Decimal> mapPricebookPrice = mapProductPricebookPrice.get(p.Id);
                    for(PriceBookEntry pbe : p.PriceBookEntries)
                    {
                        mapPricebookPrice.put(pbe.Pricebook2Id,pbe.UnitPrice);
                    }
                }
            } 

            //Get the correct price from the correct pricebook
            for(USC_Invoice_Data__c f: fdata)
            {
                if (f.Product__c !=null)
                {
                    Decimal decUnitPrice = 0;
                    map<Id,Decimal> mapPricebookPrice = mapProductPricebookPrice.get(f.Product__c);

                    if(f.Pricebook__c != NULL && mapPricebookPrice.containsKey(f.Pricebook__c) &&  mapPricebookPrice.get(f.Pricebook__c) != NULL)
                    {
                        decUnitPrice = mapPricebookPrice.get(f.Pricebook__c);                   
                        f.Contract_Unit_Price__c = decUnitPrice;
                    }
                    else
                    {
                        f.Contract_Unit_Price__c = null;
                    }
                }
            }       

            //***GET THE CONTRACTED UNIT COST
            //identify the net cost price book

            Id IdPricebookCost = gcConstants.fetchIdNetCostPricebook();
            map<Id,Decimal> mapContractCost = new map<Id,Decimal>();

            //collect the products, with prices
            if(mapProduct.size() > 0)
            {
                for(PriceBookEntry p :
                         [SELECT Product2Id, UnitPrice
                         FROM PriceBookEntry
                         WHERE IsActive = true AND PriceBook2.IsActive = true
                         AND PriceBook2.Id = :IdPricebookCost AND Product2Id IN : mapProduct.keySet()])
                {
                    mapContractCost.put(p.Product2Id, p.UnitPrice);
                }

                mapContractCost.remove(null);

                for(USC_Invoice_Data__c f: fdata)
                {

                    if (f.Product__c != null)
                    {
                        Decimal decUnitCost = 0;
                    
                        if (mapContractCost.containsKey(f.Product__c))
                        {
                            decUnitCost = mapContractCost.get(f.Product__c);            
                            f.Contract_Unit_Cost__c = decUnitCost;  
                        }
                        else
                        {
                            f.Contract_Unit_Cost__c = null;
                        }
                    }
                }       
            }

            Date dateEarliestOpen = [SELECT AcctSeed__Start_Date__c 
                                     FROM AcctSeed__Accounting_Period__c 
                                     WHERE AcctSeed__Status__c = 'Open' 
                                     ORDER BY AcctSeed__Start_Date__c LIMIT 1][0].AcctSeed__Start_Date__c;

            Set<String> setSOPwithErrors = new Set<String>();
            String ActionSort;

            for(USC_Invoice_Data__c f: fdata)
            {
                f.Has_Error__c = false;
                f.Period_Closed__c = (dateEarliestOpen.daysBetween(f.Invoice_Date__c) < 0); 
                if (f.Period_Closed__c)
                    f.Has_Error__c = true;
                if ((f.Error_DupSalesOrder__c) || (f.Product__c == null) || (f.Customer__c == null) || (f.Pricebook__c == null))
                    f.Has_Error__c = true;
                if (f.Contract_Unit_Cost__c == NULL) 
                    f.Has_Error__c = true;              
                if ((f.Import_Unit_Cost__c != f.Contract_Unit_Cost__c) && !f.Dispute_Cost__c && !f.Accept_Cost__c)
                    f.Has_Error__c = true;
                if ((f.Import_Unit_Price__c != f.Contract_Unit_Price__c) && !f.Dispute_Price__c && !f.Accept_Price__c)
                    f.Has_Error__c = true;
                if ((f.Dispute_Cost__c || f.Accept_Cost__c) && !f.Cost_Resolved__c)
                    f.Has_Error__c = true;
                if ((f.Dispute_Price__c || f.Accept_Price__c) && !f.Price_Resolved__c)
                    f.Has_Error__c = true;
                if (f.Has_Error__c == true)
                    setSOPwithErrors.add(f.SOP_Number__c);
            
                ActionSort = '';
                ActionSort += (f.Error_DupSalesOrder__c ? '1' : '0');
                ActionSort += (f.Customer__c == null ? '1' : '0');
                ActionSort += ((f.Product__c != null && f.Customer__c != null && f.Pricebook__c == null) ? '1' : '0');
                ActionSort += ((f.Product__c != null && f.Contract_Unit_Cost__c == null) ? '1' : '0');
                ActionSort += ((f.Product__c != null && f.Import_Unit_Cost__c != f.Contract_Unit_Cost__c && !f.Dispute_Cost__c && !f.Accept_Cost__c) ? '1' : '0');
                ActionSort += ((f.Pricebook__c != null && f.Customer__c != null && f.Contract_Unit_Price__c == null) ? '1' : '0');
                ActionSort += ((f.Pricebook__c != null && f.Customer__c != null && f.Import_Unit_Price__c != f.Contract_Unit_Price__c && !f.Dispute_Price__c && !f.Accept_Price__c) ? '1' : '0');               
                f.Action_Sort__c = ActionSort;
            }


            //Need to make sure every line on an invoice is valid before any line is valid      
            for(USC_Invoice_Data__c f: fdata)
            {
                if (setSOPwithErrors.contains(f.SOP_Number__c)) 
                    f.Has_Error__c = true;
            }   

            if (saveData)
            {
                string savemsg = SaveData(fdata);
                if (!String.isBlank(savemsg))
                {
                    system.debug('Error: ' + savemsg);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + savemsg));
                }
        
                return null;
            }
            else
                return fdata;
        //}
        //catch(Exception ex) {
        //    system.debug('Error: ' + ex.getMessage());
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex.getMessage()));
        //    return null;
        //}
    }

    @RemoteAction
    public static list<USC_Invoice_Data__c> LoadIssues()
    {

        list<USC_Invoice_Data__c> listInvoices = new list<USC_Invoice_Data__c>();

        for (USC_Invoice_Data__c u : [SELECT Id, Name, Contract_Unit_Cost__c, Contract_Unit_Price__c, 
            Customer__c, Customer_Name__c, Customer_Number__c, Error_DupSalesOrder__c, Period_Closed__c, Has_Error__c, 
            Import_Address__c, Import_City__c, Import_State__c, Import_Unit_Cost__c, Import_Unit_Price__c, 
            Import_Zip__c, Invoice_Date__c, Item_Description__c, Item_Number__c, Pricebook__c, Product__c, QTY__c, 
            SOP_Number__c, Dispute_Cost__c, Dispute_Price__c, Action_Sort__c,
            Accept_Cost__c, Accept_Price__c, Resolved_Unit_Cost__c, Resolved_Unit_Price__c, Cost_Resolved__c, Price_Resolved__c
            FROM USC_Invoice_Data__c WHERE SalesOrderCreated__c = false ORDER BY SOP_Number__c])
        {
            listInvoices.add(u);        
        }

        return listInvoices;
    }

    @RemoteAction
    public static list<USC_Invoice_Data__c> LoadDisputes(Boolean IncludeResolved)
    {

        list<USC_Invoice_Data__c> listInvoices = new list<USC_Invoice_Data__c>();

        if (includeResolved)
            listInvoices = [SELECT Id, Name, Contract_Unit_Cost__c, Contract_Unit_Price__c, 
            Customer__c, Customer_Name__c, Customer_Number__c, Error_DupSalesOrder__c, Period_Closed__c, Has_Error__c, 
            Import_Address__c, Import_City__c, Import_State__c, Import_Unit_Cost__c, Import_Unit_Price__c, 
            Import_Zip__c, Invoice_Date__c, Item_Description__c, Item_Number__c, Pricebook__c, Product__c, QTY__c, 
            SOP_Number__c, Dispute_Cost__c, Dispute_Price__c, SalesOrderCreated__c, Action_Sort__c,
            Accept_Cost__c, Accept_Price__c, Resolved_Unit_Cost__c, Resolved_Unit_Price__c, Cost_Resolved__c, Price_Resolved__c,
            Sales_Order__c, Sales_Order_Name__c, Email_Sent_Date__c
            FROM USC_Invoice_Data__c WHERE Dispute_Cost__c = true or Dispute_Price__c = true or Accept_Cost__c = true or Accept_Price__c = true
            ORDER BY SOP_Number__c];
        else
            listInvoices = [SELECT Id, Name, Contract_Unit_Cost__c, Action_Sort__c, Contract_Unit_Price__c, 
            Customer__c, Customer_Name__c, Customer_Number__c, Error_DupSalesOrder__c, Period_Closed__c, Has_Error__c, 
            Import_Address__c, Import_City__c, Import_State__c, Import_Unit_Cost__c, Import_Unit_Price__c, 
            Import_Zip__c, Invoice_Date__c, Item_Description__c, Item_Number__c, Pricebook__c, Product__c, QTY__c, 
            SOP_Number__c, Dispute_Cost__c, Dispute_Price__c, SalesOrderCreated__c,
            Accept_Cost__c, Accept_Price__c, Resolved_Unit_Cost__c, Resolved_Unit_Price__c, Cost_Resolved__c, Price_Resolved__c,
            Sales_Order__c, Sales_Order_Name__c, Email_Sent_Date__c
            FROM USC_Invoice_Data__c WHERE (Dispute_Cost__c = true and Cost_Resolved__c = false) or (Dispute_Price__c = true and Price_Resolved__c = false) or
            (Accept_Cost__c = true and Cost_Resolved__c = false) or (Accept_Price__c = true and Price_Resolved__c = false)
            ORDER BY SOP_Number__c];

        return listInvoices;
    }

    @RemoteAction @ReadOnly
    public static list<gcObj> searchCustomers(String strSearch)
    {

        Try{

            set<String> setIdAcct = new set<String>();

            if (String.isBlank(strSearch))
            {
                for(Account a : 
                        [SELECT Id FROM Account ORDER BY Name LIMIT 100])
                {
                    setIdAcct.add(a.Id);
                }
            }
            else
            {
                for(Account a : 
                        [SELECT Id FROM Account
                         WHERE (Name = :strSearch OR AccountNumber = :strSearch OR USC_Account_Number__c = :strSearch OR BillingStreet = :strSearch)
                         ORDER BY Name LIMIT 100])
                {
                    setIdAcct.add(a.Id);
                }

                strSearch = '%'+strSearch.replaceAll('[*]','%') +'%';
                    
                for(Account a :
                        [SELECT Id FROM Account
                         WHERE (Name LIKE :strSearch OR AccountNumber LIKE :strSearch OR USC_Account_Number__c LIKE :strSearch OR BillingStreet LIKE :strSearch)                 
                         ORDER BY Name LIMIT 100])
                {
                    setIdAcct.add(a.Id);
                }
            }

            map<Id,gcObj> mapObj = new map<Id,gcObj>();
            for(Account a : [SELECT Id, Name, AccountNumber, USC_Account_Number__c, BillingStreet
                            FROM Account WHERE Id IN :setIdAcct])
            {
                gcObj obj = new gcObj();
                obj.mapProperty.put('Id',a.Id);
                obj.mapProperty.put('actions','');
                obj.mapProperty.put('Name',a.Name);
                obj.mapProperty.put('AccountNumber',a.AccountNumber);
                obj.mapProperty.put('USC_Account_Number__c',a.USC_Account_Number__c);
                obj.mapProperty.put('BillingStreet',a.BillingStreet);

                mapObj.put(a.Id,obj);
            }
        
            return mapObj.values();
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }

        
    }

    @RemoteAction
    public static String createPricebook(List<USC_Invoice_Data__c> fdata)
    {
       
        Id idStandardPriceBook = gcConstants.fetchIdStandardPriceBook();
        List<PriceBookEntry> lstPBEStandard = new List<PriceBookEntry>();
        Map<Id,PriceBook2> mapPB = new Map<Id,PriceBook2>();
        List<PriceBookEntry> lstPBE = new List<PriceBookEntry>();
        Set<Id> setProductsInStandard = new Set<Id>();
        Map<Id, Decimal> mapAllProducts = new Map<Id, Decimal>();
        //CustomerId, ProductID, Price
        Map<Id,Map<Id, Decimal>> mapCusToProd = new Map<Id,Map<Id, Decimal>>();
        

        for(USC_Invoice_Data__c d : fdata)
        {

            system.debug(d.Product__c);
            if(!mapCusToProd.containsKey(d.Customer__c))
                mapCusToProd.put(d.Customer__c, new Map<Id, Decimal>());

            if(!mapCusToProd.get(d.Customer__c).containsKey(d.Product__c))
                mapCusToProd.get(d.Customer__c).put(d.Product__c, d.Import_Unit_Price__c);

            mapAllProducts.put(d.Product__c, d.Import_Unit_Price__c);
        }

        for(PricebookEntry pbe : [SELECT Id, Product2Id  FROM PricebookEntry WHERE Pricebook2Id = :idStandardPriceBook and Product2Id IN :mapAllProducts.keyset()])
        {
            system.debug('Standard: ' + pbe.Id);
            setProductsInStandard.add(pbe.Product2Id);
        }

        List<Account> lstCustomer = [select Id, Name, Pricebook__c from Account WHERE Id IN :mapCusToProd.keyset()];
        List<Account> lstCustomerUpdate = new List<Account>();

        
        //First make sure the product is in the standard price book, if not then add it because it has to
        //be in the standard pricebook in order to be in the custom pricebook
        for (Id idProd : mapAllProducts.keyset())
        {
            if(!setProductsInStandard.contains(idProd))
            {
                system.debug('Standard');
                PricebookEntry pbe = new PricebookEntry(
                    IsActive = true,
                    UnitPrice = mapAllProducts.get(idProd),
                    Effective_Date__c = date.newInstance(2015, 1, 1),
                    Pricebook2Id = idStandardPriceBook,
                    Product2Id = idProd,
                    UseStandardPrice = false);
                lstPBEStandard.add(pbe);
            }
        }

        if (lstPBEStandard.size() > 0)
            insert lstPBEStandard;

        //Next add a pricebook for each account if it doesn't have one
        for(Account a :lstCustomer)
        {
            if (a.Pricebook__c == null)
            {
                Pricebook2 p = new Pricebook2(
                    Name = a.Name,
                    IsActive = true,
                    Price_Expiration_Date__c = date.newInstance(2050, 1, 1));
                mapPB.put(a.Id, p);
            }
        }
        if (mapPB.values().size() > 0)
            insert mapPB.values();

        //Update the pricebook for each customer
        for(Account a :lstCustomer)
        {
            if (mapPB.containsKey(a.Id))
            {
                a.Pricebook__c = mapPB.get(a.Id).Id;
                lstCustomerUpdate.add(a);
            }
        }
        if (lstCustomerUpdate.size() > 0)
            update lstCustomerUpdate;

        //Now add a pricebook entry for every customer/product 
        for(Id idCus :mapCusToProd.keyset())
        {
            for (Id idProd : mapCusToProd.get(idCus).keyset())
            {
                PricebookEntry pbe = new PricebookEntry(
                    IsActive = true,
                    Effective_Date__c = date.newInstance(2015, 1, 1),
                    UnitPrice = mapCusToProd.get(idCus).get(idProd),
                    Pricebook2Id = mapPB.get(idCus).Id,
                    Product2Id = idProd,
                    UseStandardPrice = false);
                lstPBE.add(pbe);
            }
        }
    
        if (lstPBE.size() > 0)
        insert lstPBE;

        return '';

    }
    
    @RemoteAction
    public static string deleteSalesOrder(List<String> lstSOP_Number)
    {

        Try{
            List<USC_Invoice_Data__c> orderLines = [SELECT Id FROM USC_Invoice_Data__c WHERE SOP_Number__c IN :lstSOP_Number];
            delete orderLines;
            return '';
            
        }
        catch(Exception e) {
            return e.getMessage();
        }
    }

    @RemoteAction
    public static string updateResolvedUnitCost(string SOP_Number, integer QTY, string Item_Number, Decimal newUnitCost)
    {
        Try{

            List<USC_Invoice_Data__c> orderLines = new List<USC_Invoice_Data__c>();

            for(USC_Invoice_Data__c d : [SELECT Id, Resolved_Unit_Cost__c FROM USC_Invoice_Data__c WHERE SOP_Number__c = :SOP_Number
            AND QTY__c = :QTY AND Item_Number__c = :Item_Number])
            {
                d.Resolved_Unit_Cost__c = newUnitCost;
                orderlines.add(d);
            }

            update orderLines;
            
            return '';
        }
        catch(Exception e) {
            return e.getMessage();
        }
    }

    @RemoteAction
    public static string updateResolvedUnitPrice(string SOP_Number, integer QTY, string Item_Number, Decimal newUnitPrice)
    {
        Try{

            List<USC_Invoice_Data__c> orderLines = new List<USC_Invoice_Data__c>();

            for(USC_Invoice_Data__c d : [SELECT Id, Resolved_Unit_Price__c FROM USC_Invoice_Data__c WHERE SOP_Number__c = :SOP_Number
            AND QTY__c = :QTY AND Item_Number__c = :Item_Number])
            {
                d.Resolved_Unit_Price__c = newUnitPrice;
                orderlines.add(d);
            }

            update orderLines;
            
            return '';
        }
        catch(Exception e) {
            return e.getMessage();
        }
    }

    @RemoteAction
    public static string addPrice(List<USC_Invoice_Data__c> fdata)
    {
        Id idStandardPriceBook = gcConstants.fetchIdStandardPriceBook();
        List<PriceBookEntry> lstPBEStandard = new List<PriceBookEntry>();
        Set<Id> setProductsInStandard = new Set<Id>();
        Map<Id, Decimal> mapAllProducts = new Map<Id, Decimal>();
        Map<Id, Id> mapCusToPB = new Map<Id, Id>();
        Map<Id,Map<Id, Decimal>> mapCusToProd = new Map<Id,Map<Id, Decimal>>();
        List<PriceBookEntry> lstPBE = new List<PriceBookEntry>();

        for(USC_Invoice_Data__c d : fdata)
        {
            if(!mapCusToProd.containsKey(d.Customer__c))
                mapCusToProd.put(d.Customer__c, new Map<Id, Decimal>());
            if(!mapCusToProd.get(d.Customer__c).containsKey(d.Product__c))
                mapCusToProd.get(d.Customer__c).put(d.Product__c, d.Import_Unit_Price__c);
            mapAllProducts.put(d.Product__c, d.Import_Unit_Price__c);
            mapCusToPB.put(d.Customer__c,d.Pricebook__c);
        }

        for(PricebookEntry pbe : [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :idStandardPriceBook and Product2Id IN :mapAllProducts.keyset()])
        {
            setProductsInStandard.add(pbe.Product2Id);
        }

        //First make sure the product is in the standard price book, if not then add it 
        for (Id idProd : mapAllProducts.keyset())
        {
            if(!setProductsInStandard.contains(idProd))
            {
                PricebookEntry pbe = new PricebookEntry(
                    IsActive = true,
                    UnitPrice = mapAllProducts.get(idProd),
                    Effective_Date__c = date.newInstance(2015, 1, 1),
                    Pricebook2Id = idStandardPriceBook,
                    Product2Id = idProd,
                    UseStandardPrice = false);
                lstPBEStandard.add(pbe);
            }
        }
        if (lstPBEStandard.size() > 0)
            insert lstPBEStandard;


        for(Id idCus :mapCusToProd.keyset())
        {
            if (mapCusToProd.get(idCus) != null){
                for (Id idProd : mapCusToProd.get(idCus).keyset())
                {
                    PricebookEntry pbe = new PricebookEntry(
                        IsActive = true,
                        Effective_Date__c = date.newInstance(2015, 1, 1),
                        UnitPrice = mapCusToProd.get(idCus).get(idProd),
                        Pricebook2Id = mapCusToPB.get(idCus),
                        Product2Id = idProd,
                        UseStandardPrice = false);
                    lstPBE.add(pbe);
                }
            }
        }
    
        if (lstPBE.size() > 0)
        insert lstPBE;

        return '';
    }

    @RemoteAction
    public static string addCost(List<USC_Invoice_Data__c> fdata)
    {

        Id idStandardPriceBook = gcConstants.fetchIdStandardPriceBook();
        Id idNetCostPricebook = gcConstants.fetchIdNetCostPricebook();
        List<PriceBookEntry> lstPBEStandard = new List<PriceBookEntry>();
        Set<Id> setProductsInStandard = new Set<Id>();
        Map<Id, Decimal> mapAllProducts = new Map<Id, Decimal>();
        List<PriceBookEntry> lstPBE = new List<PriceBookEntry>();
        Map<Id,Decimal> mapProducts = new Map<Id,Decimal>();

        for(USC_Invoice_Data__c d : fdata)
        {
            mapAllProducts.put(d.Product__c, d.Import_Unit_Cost__c);
        }

        for(PricebookEntry pbe : [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :idStandardPriceBook and Product2Id IN :mapAllProducts.keyset()])
        {
            setProductsInStandard.add(pbe.Product2Id);
        }

        //First make sure the product is in the standard price book, if not then add it 
        for (Id idProd : mapAllProducts.keyset())
        {
            if(!setProductsInStandard.contains(idProd))
            {
                PricebookEntry pbe = new PricebookEntry(
                    IsActive = true,
                    UnitPrice = mapAllProducts.get(idProd),
                    Effective_Date__c = date.newInstance(2015, 1, 1),
                    Pricebook2Id = idStandardPriceBook,
                    Product2Id = idProd,
                    UseStandardPrice = false);
                lstPBEStandard.add(pbe);
            }
        }
        if (lstPBEStandard.size() > 0)
            insert lstPBEStandard;
 
        for (Id idProd : mapAllProducts.keyset())
        {
            PricebookEntry pbe = new PricebookEntry(
                IsActive = true,
                Effective_Date__c = date.newInstance(2015, 1, 1),
                UnitPrice = mapAllProducts.get(idProd),
                Pricebook2Id = idNetCostPricebook,
                Product2Id = idProd,
                UseStandardPrice = false);
            lstPBE.add(pbe);
        }
        
        if (lstPBE.size() > 0)
        insert lstPBE;

        return '';
    }


    @RemoteAction
    public static string sendUSCEmail(List<String> lstSOP)
    {
        

        String pStrComponent = 'USCOverride';
        String pIdParent = gcConstants.fetchIdUSCAccount();
        String pIdContact = gcConstants.fetchIdUSCAccount();
        String idEmailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'USC Override' ORDER BY CreatedDate LIMIT 1][0].Id;
        String strSOP='';
        for(String s :lstSOP)
        {
            strSOP += s + ',';
        }
        strSOP.removeEnd(',');
        
        String strTimeStamp = dateTime.now().format();
        String strFileName = 'USC Pricing Issue v'+strTimeStamp+'.pdf';

        Attachment att = new Attachment(name=strFileName);
        pageReference documentPDF = new pageReference('/apex/gpDocument');

        documentPDF.getParameters().put('idParent',strSOP);
        documentPDF.getParameters().put('component',pStrComponent);
        
        Blob body;
        try {
            body = documentPDF.getContentAsPdf();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
    

        att.body = body;
        att.parentId = pIdParent;
        att.isPrivate = false;
        att.ContentType='application/pdf';
        insert att;
        
        //att = [SELECT Id, Name, ParentId FROM Attachment WHERE Id =:att.Id][0];
        
        String myURL = '/email/author/emailauthor.jsp?idParent=' + strSOP;
               myURL += '&retURL=/' + att.ParentId;
               myURL += '&p6=' + EncodingUtil.urlEncode(att.Name,'UTF-8'); //email.subject
               myURL += '&p3_lkid=' + att.ParentId;
               myURL += '&template_id='+idEmailTemplate;
               myURL += '&new_template=1'; //include the attachment from the VF template
               myURL += '&idAttachment='+att.Id;
               myURL += '&component='+pStrComponent;
               myURL += '&p2_lkid='+pIdContact;

        List<USC_Invoice_Data__c> lstUSCData = new List<USC_Invoice_Data__c>();
        for(USC_Invoice_Data__c d : [SELECT Id, Email_Sent_Date__c FROM USC_Invoice_Data__c WHERE Name IN :lstSOP])
        {
            d.Email_Sent_Date__c = date.Today();
            lstUSCData.add(d);
        }
        if (lstUSCData.size() > 0)
            update lstUSCData;

        return myURL;
    }
    
    @RemoteAction
    public static string createCustomer(List<USC_Invoice_Data__c> fdata)
    {

        Map<String, Account> mapAccount = new Map<String, Account>();

        for(USC_Invoice_Data__c d : fdata)
        {
            Account a = new Account(
                Name = d.Customer_Name__c,
                AccountNumber = d.Customer_Number__c,
                USC_Account_Number__c = d.Customer_Number__c,
                Type = 'Customer',
                BillingCity = d.Import_City__c,
                BillingPostalCode = d.Import_Zip__c,
                BillingState = getStateName(d.Import_State__c),
                BillingStreet = d.Import_Address__c);
            mapAccount.put(d.Customer_Number__c,a);
        }
        
        if (mapAccount.values().size() > 0)
            insert mapAccount.values();

        return '';
      
    }

    @RemoteAction
    public static string matchAccount(Id IdCustomer, String Customer_Number)
    {

        Try{
            
            List<Account> lstAcct = new List<Account>();

            for(Account a : [SELECT Id, USC_Account_Number__c FROM Account WHERE Id =:IdCustomer])
            {
                a.USC_Account_Number__c = Customer_Number;
                lstAcct.add(a);
            }

            if (lstAcct.size() > 0)
                update lstAcct;

            return '';
        }
        catch(Exception e) {
            return e.getMessage();
        }
    }

    public static string getStateName(string stateAbbr)
    {

        String StateName;

        if (stateAbbr=='AL') StateName = 'Alabama';
        else if (stateAbbr=='AK') StateName = 'Alaska';
        else if (stateAbbr=='AZ') StateName = 'Arizona';
        else if (stateAbbr=='AR') StateName = 'Arkansas';
        else if (stateAbbr=='CA') StateName = 'California';
        else if (stateAbbr=='CO') StateName = 'Colorado';
        else if (stateAbbr=='CT') StateName = 'Connecticut';
        else if (stateAbbr=='DE') StateName = 'Delaware';
        else if (stateAbbr=='FL') StateName = 'Florida';
        else if (stateAbbr=='GA') StateName = 'Georgia';
        else if (stateAbbr=='HI') StateName = 'Hawaii';
        else if (stateAbbr=='ID') StateName = 'Idaho';
        else if (stateAbbr=='IL') StateName = 'Illinois';
        else if (stateAbbr=='IN') StateName = 'Indiana';
        else if (stateAbbr=='IA') StateName = 'Iowa';
        else if (stateAbbr=='KS') StateName = 'Kansas';
        else if (stateAbbr=='KY') StateName = 'Kentucky';
        else if (stateAbbr=='LA') StateName = 'Louisiana';
        else if (stateAbbr=='ME') StateName = 'Maine';
        else if (stateAbbr=='MD') StateName = 'Maryland';
        else if (stateAbbr=='MA') StateName = 'Massachusetts';
        else if (stateAbbr=='MI') StateName = 'Michigan';
        else if (stateAbbr=='MN') StateName = 'Minnesota';
        else if (stateAbbr=='MS') StateName = 'Mississippi';
        else if (stateAbbr=='MO') StateName = 'Missouri';
        else if (stateAbbr=='MT') StateName = 'Montana';
        else if (stateAbbr=='NE') StateName = 'Nebraska';
        else if (stateAbbr=='NV') StateName = 'Nevada';
        else if (stateAbbr=='NH') StateName = 'New Hampshire';
        else if (stateAbbr=='NJ') StateName = 'New Jersey';
        else if (stateAbbr=='NM') StateName = 'New Mexico';
        else if (stateAbbr=='NY') StateName = 'New York';
        else if (stateAbbr=='NC') StateName = 'North Carolina';
        else if (stateAbbr=='ND') StateName = 'North Dakota';
        else if (stateAbbr=='OH') StateName = 'Ohio';
        else if (stateAbbr=='OK') StateName = 'Oklahoma';
        else if (stateAbbr=='OR') StateName = 'Oregon';
        else if (stateAbbr=='PA') StateName = 'Pennsylvania';
        else if (stateAbbr=='RI') StateName = 'Rhode Island';
        else if (stateAbbr=='SC') StateName = 'South Carolina';
        else if (stateAbbr=='SD') StateName = 'South Dakota';
        else if (stateAbbr=='TN') StateName = 'Tennessee';
        else if (stateAbbr=='TX') StateName = 'Texas';
        else if (stateAbbr=='UT') StateName = 'Utah';
        else if (stateAbbr=='VT') StateName = 'Vermont';
        else if (stateAbbr=='VA') StateName = 'Virginia';
        else if (stateAbbr=='WA') StateName = 'Washington';
        else if (stateAbbr=='WV') StateName = 'West Virginia';
        else if (stateAbbr=='WI') StateName = 'Wisconsin';
        else if (stateAbbr=='WY') StateName = 'Wyoming';

        return stateName;
    }



}