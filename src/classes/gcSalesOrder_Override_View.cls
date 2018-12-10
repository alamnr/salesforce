global without sharing class gcSalesOrder_Override_View {
	
	public gcSalesOrder_Override_View(ApexPages.StandardController ctrl){}
	public gcSalesOrder_Override_View(){}

	@RemoteAction @ReadOnly
	public static list<map<string,string>> retrieveSalesOrderLines(Id idFilter)
	{
		list<map<string,string>> listJSON = new list<map<string,string>>();

		Date dateEarliestOpen = gcAccountingPeriod.dateEarliestOpen();

		for(AcctSeedERP__Sales_Order_Line__c sol :
			[SELECT Id, Name,
			 AcctSeedERP__Product__c,
			 AcctSeedERP__Product__r.Name,
			 AcctSeedERP__Product__r.AcctSeed__Inventory_Product__c,
			 AcctSeedERP__Product__r.Lot_Tracked__c,
			 AcctSeedERP__Product__r.Pricing_Units__c,
			 AcctSeedERP__Product__r.ProductCode,
			 AcctSeedERP__Product__r.Variable_Price__c,
			 AcctSeedERP__Quantity_Ordered__c,
			 AcctSeedERP__Sales_Order__r.Fill_Date__c,
			 AcctSeedERP__Unit_Price__c,
			 Expense__c,
			 Lot__c,
			 Lot__r.Name,
			 Lot__r.Expiration_Date__c,
			 Lot__r.Variant_Qty__c,
			 Price_Override__c,
			 Quantity_Filled__c,
			 Revenue__c,
			 Total_Filled__c,
			 Total_Ordered__c,
			 Variant_Unit_Price__c,
			 (SELECT Id, AcctSeedERP__Movement_Date__c FROM Outbound_Inventory_Movements__r ORDER BY AcctSeedERP__Movement_Date__c LIMIT 1),
			 (SELECT AcctSeed__Total__c FROM AcctSeedERP__Billing_Lines__r)
			 FROM AcctSeedERP__Sales_Order_Line__c
			 WHERE AcctSeedERP__Sales_Order__c = :idFilter OR Id = :idFilter])
		{
            map<string,string> m = new map<string,string>();

            m.put('idLine',sol.Id);
            m.put('lineNumber', String.valueOf(Integer.valueOf(sol.Name.replaceAll('[^0-9]',''))));

            m.put('idProduct', sol.AcctSeedERP__Product__c);

			m.put('productName',sol.AcctSeedERP__Product__r.Name);
			
			if(sol.AcctSeedERP__Product__r.AcctSeed__Inventory_Product__c)
			m.put('isInventory','true');
			else
			m.put('isInventory','false');

			if(sol.AcctSeedERP__Product__r.Lot_Tracked__c)
			m.put('isLotTracked','true');
			else
			m.put('isLotTracked','false');

			m.put('pricingUnits', sol.AcctSeedERP__Product__r.Pricing_Units__c);
			m.put('productCode', sol.AcctSeedERP__Product__r.ProductCode);
			
			if(sol.AcctSeedERP__Product__r.Variable_Price__c)
			m.put('isVariablePrice','true');
			else
			m.put('isVariablePrice','false');

			if(sol.AcctSeedERP__Quantity_Ordered__c != null)
			m.put('qtyOrdered',String.valueOf(sol.AcctSeedERP__Quantity_Ordered__c.setScale(0)));
			else
			m.put('qtyOrdered','0');

			if(sol.AcctSeedERP__Sales_Order__r.Fill_Date__c == null || sol.AcctSeedERP__Sales_Order__r.Fill_Date__c >= dateEarliestOpen)
			m.put('periodIsOpen','true');
			else
			m.put('periodIsOpen','false');

			if(sol.AcctSeedERP__Unit_Price__c != null)
			m.put('unitPrice',String.valueOf(sol.AcctSeedERP__Unit_Price__c.setScale(2)));
			else
			m.put('unitPrice','0');

			if(sol.Expense__c != null)
			m.put('expense',String.valueOf(sol.Expense__c.setScale(6)));

			if(sol.Lot__c != null)
			{
				m.put('idLot',sol.Lot__c);
				m.put('lotName',sol.Lot__r.Name);
			}

			if(sol.Lot__r.Expiration_Date__c != null)
			m.put('lotExpirationDate', sol.Lot__r.Expiration_Date__c.format());

			if(sol.Lot__r.Variant_Qty__c != null)
			m.put('lotVariantQty',String.valueOf(sol.Lot__r.Variant_Qty__c.setScale(2)));

			if(sol.Price_Override__c)
			m.put('priceOverride','true');
			else
			m.put('priceOverride','false');

			if(sol.Quantity_Filled__c != null)
			m.put('qtyFilled',String.valueOf(sol.Quantity_Filled__c.setScale(0)));
			else
			m.put('qtyFilled','0');

			if(sol.Revenue__c != null)
			m.put('revenue',String.valueOf(sol.Revenue__c.setScale(6)));
			else
			m.put('revenue','0');

			m.put('totalFilled',String.valueOf(sol.Total_Filled__c.setScale(6)));
			m.put('totalOrdered',String.valueOf(sol.Total_Ordered__c.setScale(6)));

			if(sol.Variant_Unit_Price__c != null)
			m.put('variantUnitPrice',String.valueOf(sol.Variant_Unit_Price__c.setScale(6)));
			else
			m.put('variantUnitPrice','0');

			if(sol.Outbound_Inventory_Movements__r.size() > 0)
			m.put('filled','true');
			else
			m.put('filled','false');

			if(sol.AcctSeedERP__Billing_Lines__r.size() > 0)
			m.put('billed','true');
			else
			m.put('billed','false');

            listJSON.add(m);
		}
		return listJSON;
	}

    @RemoteAction @ReadOnly
    public static list<map<string,string>> searchProduct(String idSalesOrder, String strSearch)
    {
    	list<map<string,string>> listJSON = new list<map<string,string>>();

        set<string> setIdProduct = new set<string>();
        map<Id,cube> mapCube = new map<Id,cube>();
        strSearch = '%'+strSearch+'%';
        for(Product2 p :
                [SELECT Id, AcctSeed__Inventory_Product__c
                 FROM Product2
                 WHERE IsActive = true
                   AND (Name LIKE :strSearch OR ProductCode LIKE :strSearch)])
        {
            setIdProduct.add(p.Id);
            if(!p.AcctSeed__Inventory_Product__c)
            	mapCube.put(p.Id, new cube());
        }
        if(setIdProduct.size() == 0)
            return new list<map<string,string>>();

        AcctSeedERP__Sales_Order__c so = [SELECT Id, Fill_Date__c, Warehouse__c FROM AcctSeedERP__Sales_Order__c WHERE Id =:idSalesOrder][0];

        map<string,list<string>> mapFilters = new map<string,list<string>>();
        mapFilters.put('idProduct', new list<string>(setIdProduct));
        mapFilters.put('dateThru', new list<string>{so.Fill_Date__c.format()});

        list<string> listGroupBy = new list<string>{'idLot'};

        //retrieve the company-wide inventory for the lots of the identified products

        for(gcInventoryMovementCube_Report.cube invCube : gcInventoryMovementCube_Report.inventoryAggRes(mapFilters,listGroupBy))
        {
            cube cube = new cube();
            cube.qtyOtherWhs = invCube.qty;
            if(invCube.qty != 0)
            cube.unitCost = invCube.amt/invCube.qty;
            mapCube.put(invCube.idLot,cube);
        }

        mapFilters.put('idWarehouse', new list<string>{so.Warehouse__c});

        //retrieve the inventory for identified products in THIS warehouse
        for(gcInventoryMovementCube_Report.cube invCube : gcInventoryMovementCube_Report.inventoryAggRes(mapFilters,listGroupBy))
        {
            cube cube = mapCube.get(invCube.idLot);
            if(cube != null)
            {
                cube.qtyThisWhs += invCube.qty;
                cube.qtyOtherWhs -= invCube.qty;
            }
            else
            {
                cube = new cube();
                cube.qtyThisWhs = invCube.qty;
            	if(invCube.qty != 0)
            	cube.unitCost = invCube.amt/invCube.qty;
                mapCube.put(invCube.idLot,cube);
            }
        }

        //identify products and lots that are already included in the sales order
        for(AcctSeedERP__Sales_Order_Line__c sol :
        	[SELECT AcctSeedERP__Product__c 
        	 FROM AcctSeedERP__Sales_Order_Line__c
        	 WHERE AcctSeedERP__Sales_Order__c = :idSalesOrder
        	   AND AcctSeedERP__Product__c  IN :mapCube.keySet()])
        {
        	mapCube.get(sol.AcctSeedERP__Product__c).boolAlreadyIncluded = true;
        }

        for(AcctSeedERP__Sales_Order_Line__c sol :
        	[SELECT Lot__c 
        	 FROM AcctSeedERP__Sales_Order_Line__c
        	 WHERE AcctSeedERP__Sales_Order__c = :idSalesOrder
        	   AND Lot__c IN :mapCube.keySet()])
        {
        	mapCube.get(sol.Lot__c).boolAlreadyIncluded = true;
        }

        for(Product2 p :
        	[SELECT Id, Name, ProductCode
        	 FROM Product2
        	 WHERE Id IN :mapCube.keySet()])
        {
            map<string,string> m = new map<string,string>();

            m.put('idProduct',p.Id);
            m.put('productName',p.Name);
            m.put('productCode',p.ProductCode);
            m.put('isInventory','false');

            if(mapCube.get(p.Id).boolAlreadyIncluded)
            	m.put('alreadyIncluded','true');
            else
            	m.put('alreadyIncluded','false');

            listJSON.add(m);        	
        }

        for(Lot__c lot : 
            [SELECT Id, Name,
                    Expiration_Date__c,
                    Product__r.Id, 
                    Product__r.Name, 
                    Product__r.ProductCode,
                    Variant_Qty__c
             FROM Lot__c 
             WHERE Id IN :mapCube.keySet()])
        {
            map<string,string> m = new map<string,string>();

            cube cube = mapCube.get(lot.Id);
            Decimal qty = cube.qtyThisWhs + cube.qtyOtherWhs;

            if(qty.setScale(6) == 0) continue;

            m.put('qtyThisWhs',String.valueOf(cube.qtyThisWhs.setScale(6)));
            m.put('qtyOtherWhs', String.valueOf(cube.qtyOtherWhs.setScale(6)));
            m.put('qty', String.valueOf(qty.setScale(6)));
            m.put('unitCost', String.valueOf(cube.unitCost.setScale(6)));

            m.put('idLot',lot.Id);
            m.put('lotName',lot.Name);

            m.put('idProduct',lot.Product__r.Id);
            m.put('productName',lot.Product__r.Name);
            m.put('productCode',lot.Product__r.ProductCode);

            if(lot.Expiration_Date__c != null)
                m.put('lotExpirationDate',lot.Expiration_Date__c.format());
            else
                m.put('lotExpirationDate','12/31/1999');

            if(lot.Variant_Qty__c != null)
                m.put('lotVariantQty',String.valueOf(lot.Variant_Qty__c.setScale(0)));

            if(cube.boolAlreadyIncluded)
                m.put('alreadyIncluded','true');
            else
                m.put('alreadyIncluded','false');

            m.put('isInventory','true');

            listJSON.add(m);
        }
        
        return listJSON;
    }

	@RemoteAction 
	public static map<string,string> createSalesOrderLine(String idSalesOrder, String idObject)
	{
        AcctSeedERP__Sales_Order__c so = [SELECT Id, Fill_Date__c, Warehouse__c FROM AcctSeedERP__Sales_Order__c WHERE Id =:idSalesOrder][0];

        Id idLot;
        Id idProduct;
        Id idBalance;

        for(Lot__c lot : 
        	[SELECT Id, Product__c,
				(SELECT Id FROM Sales_Order_Line__r WHERE AcctSeedERP__Sales_Order__c = :idSalesOrder LIMIT 1)
			 FROM Lot__c WHERE Id =:idObject])
        {
        	if(lot.Sales_Order_Line__r.size() > 0) //a sales order line already exists
        		return new map<string,string>();        	
        	idLot = lot.Id;
        	idProduct = lot.Product__c;
        	idObject = null;
        }
        if(idObject != null)
        for(Product2 p : 
        	[SELECT Id, 
				(SELECT Id FROM AcctSeedERP__Sales_Order_Line__r WHERE AcctSeedERP__Sales_Order__c = :idSalesOrder LIMIT 1)
        	FROM Product2 WHERE Id = :idObject])
        {
        	if(p.AcctSeedERP__Sales_Order_Line__r.size() > 0) //a sales order line already exists
        		return new map<string,string>();          	
        	idProduct = p.Id;
        	idObject = null;
        }

        if(idObject != null) return new map<string,string>(); //the idObject is not valid

		AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c();
		sol.AcctSeedERP__Sales_Order__c = idSalesOrder;
		sol.AcctSeedERP__Product__c = idProduct;
		sol.Lot__c = idLot;
		sol.AcctSeedERP__Quantity_Ordered__c = 1;
		sol.AcctSeedERP__Unit_Price__c = 0;

		insert sol;

		return retrieveSalesOrderLines(sol.Id)[0];
	}

	@RemoteAction
	public static string deleteSalesOrderLine(String idLine)
	{
		delete [SELECT Id FROM AcctSeedERP__Outbound_Inventory_Movement__c WHERE Sales_Order_Line__c != null AND Sales_Order_Line__c = :idLine];
		delete [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c WHERE Id = :idLine];
		return '';
	}

/*
	@RemoteAction
	public static map<string,string> updateUnitPrice(Id idLine, Decimal price)
	{
		AcctSeedERP__Sales_Order_Line__c line = [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c WHERE Id = :idLine][0];
		
		line.Variant_Unit_Price__c = null;
		line.AcctSeedERP__Unit_Price__c = price;
		if(price == null)
			line.Price_Override__c = false;
		else
			line.Price_Override__c = true;

		update line;
		
		return retrieveSalesOrderLines(line.Id)[0];
	}

	@RemoteAction
	public static map<string,string> updateVariantUnitPrice(Id idLine, Decimal price)
	{
		AcctSeedERP__Sales_Order_Line__c line = [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c WHERE Id = :idLine][0];
		
		line.Variant_Unit_Price__c = price;
		line.AcctSeedERP__Unit_Price__c = null;
		if(price == null)
			line.Price_Override__c = false;
		else
			line.Price_Override__c = true;

		update line;
		
		return retrieveSalesOrderLines(line.Id)[0];
	}
*/
	@RemoteAction
	public static map<string,string> updatePrice(Id idLine, Decimal price)
	{
		AcctSeedERP__Sales_Order_Line__c line = [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c WHERE Id = :idLine][0];
		
		line.AcctSeedERP__Unit_Price__c = price;
		line.Variant_Unit_Price__c = price;

		if(price == null)
			line.Price_Override__c = false;
		
		else
			line.Price_Override__c = true;
		
		update line;
		
		return retrieveSalesOrderLines(line.Id)[0];
	}

	@RemoteAction
	public static map<string,string> updateQtyOrdered(Id idSalesOrderLine, Decimal qty)
	{
		AcctSeedERP__Sales_Order_Line__c line = [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c WHERE Id = :idSalesOrderLine];
		
		if(qty == null) qty = 0;
		line.AcctSeedERP__Quantity_Ordered__c = qty;
		
		update line;
		
		return retrieveSalesOrderLines(line.Id)[0];
	}

	@RemoteAction
	public static map<string,string> updateQtyFilled(Id idLine, Decimal qty)
	{	
		if(qty == null) qty = 0;

		AcctSeedERP__Sales_Order_Line__c line = [SELECT Id, AcctSeedERP__Product__c, AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c, Lot__c,
														AcctSeedERP__Sales_Order__r.Warehouse__c, AcctSeedERP__Unit_Price__c,
														AcctSeedERP__Sales_Order__r.Fill_Date__c, Reversal_Unit_Cost__c,
														Quantity_Filled__c, AcctSeedERP__Sales_Order__r.Reversal__c,
														(SELECT Id, AcctSeedERP__Quantity__c FROM Outbound_Inventory_Movements__r) 
												 FROM AcctSeedERP__Sales_Order_Line__c
												 WHERE Id = :idLine][0];

		AcctSeedERP__Outbound_Inventory_Movement__c moveOut;
		if(line.Outbound_Inventory_Movements__r.size() > 0)
		{
			moveOut = line.Outbound_Inventory_Movements__r[0];
			if(qty.setScale(6) == null || qty.setScale(6) == 0)
				delete moveOut;
			else if(moveOut.AcctSeedERP__Quantity__c.setScale(6) != qty.setScale(6))
			{
				moveOut.AcctSeedERP__Quantity__c = qty.setScale(6);
				update moveOut;
			}
		}
		else
		{
			Id idLocation = [SELECT Id FROM AcctSeedERP__Location__c WHERE AcctSeedERP__Warehouse__c = :line.AcctSeedERP__Sales_Order__r.Warehouse__c ORDER BY CreatedDate][0].Id;
			Id idBalance = gcInventoryBalance.findOrCreateBalance(line.AcctSeedERP__Product__c, line.AcctSeedERP__Sales_Order__r.Warehouse__c, idLocation);
			moveOut = new AcctSeedERP__Outbound_Inventory_Movement__c
			(			
				AcctSeedERP__Debit_GL_Account__c = line.AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c,
				AcctSeedERP__Inventory_Balance__c = idBalance,
				AcctSeedERP__Movement_Date__c = line.AcctSeedERP__Sales_Order__r.Fill_Date__c,
				Sales_Order_Line__c = idLine,
				AcctSeedERP__Quantity__c = qty.setScale(6),
				AcctSeedERP__Type__c = 'Accounting',
				AcctSeedERP__Unit_Cost__c = 0,
				Lot__c = line.Lot__c
			);

			if (!String.isBlank(line.AcctSeedERP__Sales_Order__r.Reversal__c))
			{
				moveOut.Cost_Override__c = true;
				if (line.Reversal_Unit_Cost__c != null)
					moveOut.AcctSeedERP__Unit_Cost__c = line.Reversal_Unit_Cost__c;
			}
			insert moveOut;
		}

		return retrieveSalesOrderLines(idLine)[0];
	}

	webservice static Id cloneWithLines(Id idSalesOrder, Boolean boolReverse)
	{
		Decimal UnitCost;

		AcctSeedERP__Sales_Order__c so = 
			[SELECT 
			 Carrier__c,
			 AcctSeedERP__Customer__c,
			 AcctSeedERP__Opportunity__c,
			 Pricebook__c,
			 AcctSeedERP__Shipping_City__c,
			 AcctSeedERP__Shipping_Country__c,
			 Shipping_Method__c,
			 AcctSeedERP__Shipping_PostalCode__c,
			 AcctSeedERP__Shipping_State__c,
			 AcctSeedERP__Shipping_Street__c,
			 Warehouse__c
			 FROM AcctSeedERP__Sales_Order__c
			 WHERE Id =: idSalesOrder][0].clone(false,true,false,false);

		if(boolReverse)
			so.Reversal__c = idSalesOrder;
		
		insert so;

		list<AcctSeedERP__Sales_Order_Line__c> listSOL = new list<AcctSeedERP__Sales_Order_Line__c>();

		for(AcctSeedERP__Sales_Order_Line__c x : 
				[SELECT AcctSeedERP__GL_Account_Variable_1__c,
						AcctSeedERP__GL_Account_Variable_2__c,
						AcctSeedERP__GL_Account_Variable_3__c,
						AcctSeedERP__GL_Account_Variable_4__c,
						Lot__c,
						Expense__c,
						AcctSeedERP__Manufacturing_Order__c,
						AcctSeedERP__Product__c,
						AcctSeedERP__Project__c,
						AcctSeedERP__Project_Task__c,
						AcctSeedERP__Purchase_Order_Line__c,
						AcctSeedERP__Quantity_Ordered__c,
						AcctSeedERP__Unit_Price__c,
						Variant_Unit_Price__c
				 FROM AcctSeedERP__Sales_Order_Line__c
				 WHERE AcctSeedERP__Sales_Order__c = :idSalesOrder])
		{

			if (x.AcctSeedERP__Quantity_Ordered__c != 0 && boolReverse)
				UnitCost = (x.Expense__c/x.AcctSeedERP__Quantity_Ordered__c);

			x.Expense__c = null;

			AcctSeedERP__Sales_Order_Line__c sol = x.clone(false,true,false,false);
			sol.Price_Override__c = true;
			sol.AcctSeedERP__Sales_Order__c = so.Id;

			if(boolReverse){
				sol.Reversal_Unit_Cost__c = UnitCost;
				sol.Price_Override__c = true;
				sol.AcctSeedERP__Quantity_Ordered__c *= -1;
			}

			listSOL.add(sol);
		}

		insert listSOL;

		return so.Id;
	}


    private class cube{
        Decimal qtyThisWhs{get;set;}
        Decimal qtyOtherWhs{get;set;}
        Decimal unitCost{get;set;}
        Boolean boolAlreadyIncluded{get;set;}

        private cube()
        {
            qtyThisWhs = 0;
            qtyOtherWhs = 0;
            unitCost = 0;
            boolAlreadyIncluded = false;
        }
    }
}