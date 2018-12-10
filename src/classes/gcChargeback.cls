global without sharing class gcChargeback {
	
	global gcChargeback() {}

	@RemoteAction @ReadOnly 
	global static list<gcObj> retrieveBillings(string strDateFrom, string strDateThru, string idVendor, string idSalesOrder)
	{
		list<gcObj> listObj = new list<gcObj>();
		Date dateFrom;
		Date dateThru;

		if(strDateFrom != null) dateFrom = date.parse(strDateFrom);
		if(strDateThru != null) dateThru = date.parse(strDateThru);

		set<Id> setIdBilling = new set<Id>();

		String  soqlSELECT = 'SELECT ';
				soqlSELECT += ' AcctSeed__Billing__c ';
				soqlSELECT += ' FROM AcctSeed__Billing_Line__c ';

		//construct the WHERE clause
		String 	soqlWHERE = ' WHERE ';
		if(idSalesOrder != null)
		{
			if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
			soqlWHERE += ' AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__c = :idSalesOrder ';		
		}
		if(dateFrom != null)
		{
			if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
			soqlWHERE += ' AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.Fill_Date__c >= :dateFrom ';
		}
		if(dateThru != null)
		{
			if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
			soqlWHERE += ' AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.Fill_Date__c <= :dateThru ';			
		}
		if(idVendor != null)
		{
			if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
			soqlWHERE += ' AcctSeed__Product__r.AcctSeedERP__Default_Vendor__c = :idVendor ';			
		}

		if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
		soqlWHERE += '  AcctSeed__Revenue_GL_Account__r.Uniquefier__c = \'ChargeBack\' ';					

		String soql = soqlSELECT + soqlWHERE;

		for(AcctSeed__Billing_Line__c line : Database.query(soql))
		{
			setIdBilling.add(line.AcctSeed__Billing__c);
		}

		for(AcctSeed__Billing__c b :
			[SELECT Id, Name,
				AcctSeed__Accounting_Period__r.Name,
				AcctSeed__Customer__r.Name,
				AcctSeed__Total__c,
				AcctSeed__Balance__c,
				AcctSeed__Date__c,
				AcctSeed__Status__c,
				LastModifiedDate,
				LastModifiedBy.Name
			 FROM AcctSeed__Billing__c
			 WHERE Id IN : setIdBilling
			 ORDER BY LastModifiedDate DESC, Id])
		{
			gcObj obj = new gcObj();

			obj.mapProperty.put('idBilling',b.Id);
			obj.mapProperty.put('billingNumber', String.valueOf(Integer.valueOf(b.Name.replaceAll('[^0-9]',''))));
			obj.mapProperty.put('periodName',b.AcctSeed__Accounting_Period__r.Name);
			obj.mapProperty.put('customerName', b.AcctSeed__Customer__r.Name);
			if(b.AcctSeed__Date__c != null)
				obj.mapProperty.put('billingDate',b.AcctSeed__Date__c.format());
			obj.mapProperty.put('billingTotal',String.valueOf(b.AcctSeed__Total__c.setScale(6)));
			obj.mapProperty.put('billingBalance',String.valueOf(b.AcctSeed__Balance__c.setScale(6)));
			obj.mapProperty.put('status',b.AcctSeed__Status__c);
			obj.mapProperty.put('lastModifiedDate',b.LastModifiedDate.format());
			obj.mapProperty.put('lastModifiedBy',b.LastModifiedBy.Name);

			listObj.add(obj);
		}

		return listObj;

	}

	@RemoteAction @ReadOnly 
	global static list<gcObj> retrieveSalesOrderLines(string strDateFrom, string strDateThru, string idVendor, string idSalesOrder)
	{
		list<gcObj> listObj = new list<gcObj>();
		Date dateFrom;
		Date dateThru;

		if(strDateFrom != null) dateFrom = date.parse(strDateFrom);
		if(strDateThru != null) dateThru = date.parse(strDateThru);

		//map<Id, gcObj> mapObj = new map<Id, gcObj>();

		String  soqlSELECT = 'SELECT ';
				soqlSELECT += ' Id, Name, ';
				soqlSELECT += ' AcctSeedERP__Product__c, ';
				soqlSELECT += ' AcctSeedERP__Product__r.Name, ';
				soqlSELECT += ' AcctSeedERP__Product__r.Lot_Tracked__c, ';
				soqlSELECT += ' AcctSeedERP__Product__r.Pricing_Units__c, ';
				soqlSELECT += ' AcctSeedERP__Product__r.ProductCode, ';
				soqlSELECT += ' AcctSeedERP__Product__r.Variable_Price__c, ';
				soqlSELECT += ' AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c, ';
				soqlSELECT += ' AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__r.Name, ';
				soqlSELECT += ' AcctSeedERP__Sales_Order__c, ';
				soqlSELECT += ' AcctSeedERP__Sales_Order__r.Name, ';				
				soqlSELECT += ' AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c, ';
				soqlSELECT += ' AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Name, ';								
				soqlSELECT += ' AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Chargeback_Pricebook__c, ';
				soqlSELECT += ' AcctSeedERP__Sales_Order__r.Fill_Date__c, ';
				soqlSELECT += ' Quantity_Filled__c, ';
				soqlSELECT += ' Total_Filled__c, ';

				soqlSELECT += ' Lot__c, ';
				soqlSELECT += ' Lot__r.Name, ';
				soqlSELECT += ' Lot__r.Expiration_Date__c, ';
				soqlSELECT += ' Lot__r.Variant_Qty__c, ';

				soqlSELECT += ' (SELECT AcctSeedERP__Quantity__c, Total__c FROM Outbound_Inventory_Movements__r), ';
				soqlSELECT += ' (SELECT Id, AcctSeed__Total__c, AcctSeed__Revenue_GL_Account__r.Uniquefier__c FROM AcctSeedERP__Billing_Lines__r) ';

				soqlSELECT += ' FROM AcctSeedERP__Sales_Order_Line__c ';

		//construct the WHERE clause
		String 	soqlWHERE = ' WHERE ';
		if(idSalesOrder != null)
		{
			if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
			soqlWHERE += ' AcctSeedERP__Sales_Order__c = :idSalesOrder ';			
		}
		if(dateFrom != null)
		{
			if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
			soqlWHERE += ' AcctSeedERP__Sales_Order__r.Fill_Date__c >= :dateFrom ';
		}
		if(dateThru != null)
		{
			if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
			soqlWHERE += ' AcctSeedERP__Sales_Order__r.Fill_Date__c <= :dateThru ';			
		}
		if(idVendor != null)
		{
			if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
			soqlWHERE += ' AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c = :idVendor ';			
		}

		if(soqlWHERE != ' WHERE ') soqlWHERE += ' AND ';
		soqlWHERE += ' AcctSeedERP__Product__r.Family = \'Distribution\' AND AcctSeedERP__Product__r.AcctSeed__Inventory_Product__c = true ';	

		//if(soqlWHERE == ' WHERE ') soqlWHERE = '';

		String soql = soqlSELECT + soqlWHERE;

		//retrieve the sales order lines
		list<AcctSeedERP__Sales_Order_Line__c> listSOL = new list<AcctSeedERP__Sales_Order_Line__c>();
		//listSOL.addAll(Database.query(soql));

		set<Id> setIdProduct = new set<Id>();
		map<Id,Pricebook2> mapPriceBook = new map<Id,Pricebook2>();

		for(AcctSeedERP__Sales_Order_Line__c sol : Database.query(soql))
		{
			listSOL.add(sol);
			setIdProduct.add(sol.AcctSeedERP__Product__c);
			mapPricebook.put(sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Chargeback_Pricebook__c, null);
		}
		setIdProduct.remove(null);
		mapPricebook.remove(null);

		for(Pricebook2 pb :
			[SELECT Id,
			 (SELECT Id, IsActive, Product2Id, Effective_Date__c, CreatedDate, UnitPrice
			  FROM PricebookEntries
			  WHERE Product2Id IN :setIdProduct
			  ORDER BY Effective_Date__c DESC, CreatedDate DESC, Id DESC)
			FROM Pricebook2
			WHERE Id IN :mapPricebook.keySet()])
		{
			mapPricebook.put(pb.Id,pb);
		}

		for(AcctSeedERP__Sales_Order_Line__c sol : listSOL)
		{
			gcObj obj = new gcObj();
			//find the chargeback price
			Decimal price = 0;

			if(mapPricebook.containsKey(sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Chargeback_Pricebook__c))
			{
				for(PricebookEntry pbe : mapPricebook.get(sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Chargeback_Pricebook__c).PricebookEntries)
				{
					if(pbe.Product2Id != sol.AcctSeedERP__Product__c || pbe.Effective_Date__c > sol.AcctSeedERP__Sales_Order__r.Fill_Date__c) continue;
					price = pbe.UnitPrice;
					break;
				}
			}

			obj.mapProperty.put('idSalesOrderLine',sol.Id);
			obj.mapProperty.put('idSalesOrder',sol.AcctSeedERP__Sales_Order__c);
			obj.mapProperty.put('salesOrderNumber',String.valueOf(Integer.valueOf(sol.AcctSeedERP__Sales_Order__r.Name.replaceAll('[^0-9]',''))));
			obj.mapProperty.put('salesOrderLineNumber',String.valueOf(Integer.valueOf(sol.Name.replaceAll('[^0-9]',''))));

			obj.mapProperty.put('idCustomer',sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c);
			obj.mapProperty.put('customerName',sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Name);

			obj.mapProperty.put('idVendor',sol.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c);
			obj.mapProperty.put('vendorName',sol.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__r.Name);

			obj.mapProperty.put('idProduct',sol.AcctSeedERP__Product__c);
			obj.mapProperty.put('productName',sol.AcctSeedERP__Product__r.Name);
			obj.mapProperty.put('productCode',sol.AcctSeedERP__Product__r.ProductCode);
			obj.mapProperty.put('pricingUnits',sol.AcctSeedERP__Product__r.Pricing_Units__c);

			obj.mapProperty.put('idLot',sol.Lot__c);
			obj.mapProperty.put('lotName',sol.Lot__r.Name);

			if(sol.AcctSeedERP__Sales_Order__r.Fill_Date__c != null)
				obj.mapProperty.put('fillDate', sol.AcctSeedERP__Sales_Order__r.Fill_Date__c.format());

			if(sol.Lot__r.Expiration_Date__c != null)
				obj.mapProperty.put('lotExpirationDate', sol.Lot__r.Expiration_Date__c.format());

			if(sol.Lot__r.Variant_Qty__c != null)
				obj.mapProperty.put('lotVariantQty', String.valueOf(sol.Lot__r.Variant_Qty__c.setScale(6)));

			if(sol.Quantity_Filled__c == null) sol.Quantity_Filled__c = 0;
			obj.mapProperty.put('qtyFilled',String.valueOf(sol.Quantity_Filled__c.setScale(6)));
			obj.mapProperty.put('totalFilled',String.valueOf(sol.Total_Filled__c.setScale(6)));

			Decimal totalCost = 0;
			for(AcctSeedERP__Outbound_Inventory_Movement__c move : sol.Outbound_Inventory_Movements__r)
				totalCost += move.Total__c;

			obj.mapProperty.put('totalCost',String.valueOf(totalCost.setScale(6)));

			if(sol.AcctSeedERP__Product__r.Variable_Price__c && sol.Lot__r.Variant_Qty__c != null)
			{
				obj.mapProperty.put('variantUnitPrice',String.valueOf(price.setScale(6)));
				price *= sol.Lot__r.Variant_Qty__c;
			}

			obj.mapProperty.put('unitPrice',String.valueOf(price.setScale(6)));

			Decimal chargebackPotential = sol.Quantity_Filled__c * price;
			obj.mapProperty.put('chargebackPotential',String.valueOf(chargebackPotential.setScale(6)));

			Decimal chargebackBilled = 0;
			String idBillingLine = null;
			for(AcctSeed__Billing_Line__c line : sol.AcctSeedERP__Billing_Lines__r)
			{
				if(line.AcctSeed__Revenue_GL_Account__r.Uniquefier__c == 'ChargeBack')
				{
					chargebackBilled += line.AcctSeed__Total__c;
					idBillingLine = line.Id;
				}
			}
			if(idBillingLine != null)
				obj.mapProperty.put('idBillingLine',idBillingLine);
			obj.mapProperty.put('chargebackBilled',String.valueOf(chargebackBilled.setScale(6)));


			if(chargebackPotential != 0 && chargebackBilled == 0)
				 obj.mapProperty.put('enableChargeback','true');
			else obj.mapProperty.put('enableChargeback','false');

			obj.mapProperty.put('selectChargeback','false');

			listObj.add(obj);
		}

		return listObj;
	}

	@RemoteAction
	global static list<string> createBillings(list<string> listIdSalesOrderLine)
	{
		map<Id,list<AcctSeed__Billing_Line__c>> mapVendorListBillingLine = new map<Id,list<AcctSeed__Billing_Line__c>>();
		map<Id,AcctSeed__Billing__c> mapVendorBilling = new map<Id,AcctSeed__Billing__c>();

		map<Id,AcctSeedERP__Sales_Order_Line__c> mapSOL = new map<Id,AcctSeedERP__Sales_Order_Line__c>();

		Id idGLChargeBack = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Uniquefier__c = 'ChargeBack'][0].Id;

		Date dateMaxFill = date.newInstance(2015,3,1);

		set<Id> setIdProduct = new set<Id>();
		map<Id,PriceBook2> mapPricebook = new map<Id,Pricebook2>();
		//cycle over the sales order lines
		for(AcctSeedERP__Sales_Order_Line__c sol :
			[SELECT Id,
					Quantity_Filled__c,
					AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c,
					AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Chargeback_Pricebook__c,
					AcctSeedERP__Sales_Order__r.Fill_Date__c,
					Lot__c,
					Lot__r.Name,
					Lot__r.Product__c,
					Lot__r.Product__r.AcctSeedERP__Default_Vendor__c,
					Lot__r.Product__r.Variable_Price__c,
					Lot__r.Variant_Qty__c,
					(SELECT Id 
					 FROM AcctSeedERP__Billing_Lines__r 
					 WHERE AcctSeed__Revenue_GL_Account__r.Uniquefier__c = 'ChargeBack'
					   AND AcctSeed__Total__c != 0
					   AND AcctSeed__Parent_Status__c = 'Posted'
					 LIMIT 1)					
			FROM AcctSeedERP__Sales_Order_Line__c
			WHERE Id IN :listIdSalesOrderLine
			  AND AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c != null
			  AND Lot__r.Product__r.AcctSeedERP__Default_Vendor__c != null
			  AND (Quantity_Filled__c < 0 OR Quantity_Filled__c > 0)])
		{
			//if a chargeback billing already exists for the sales order line, do nothing
			if(sol.AcctSeedERP__Billing_Lines__r.size() > 0) continue;
			//if it's an SD lot, do nothing
			if(sol.Lot__r.Name.right(1) == '*') continue;
			//if the customer does not have a chargeback pricebook, do nothing
			if(sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Chargeback_Pricebook__c == null) continue;

			if(dateMaxFill == null || dateMaxFill < sol.AcctSeedERP__Sales_Order__r.Fill_Date__c)
				dateMaxFill = sol.AcctSeedERP__Sales_Order__r.Fill_Date__c;

			mapPricebook.put(sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Chargeback_Pricebook__c, null);
			setIdProduct.add(sol.Lot__r.Product__c);
			mapSOL.put(sol.Id,sol);
		}

		for(Pricebook2 pb :
			[SELECT Id,
			 (SELECT Id, IsActive, Product2Id, Effective_Date__c, CreatedDate, UnitPrice
			  FROM PricebookEntries
			  WHERE Product2Id IN :setIdProduct
			  ORDER BY Effective_Date__c DESC, CreatedDate DESC, Id DESC)
			FROM Pricebook2
			WHERE Id IN :mapPricebook.keySet()])
		{
			mapPricebook.put(pb.Id,pb);
		}

		//create the billing lines
		for(AcctSeedERP__Sales_Order_Line__c sol : mapSOL.values())
		{
			Id idCustomer = sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c;

			Lot__c lot = sol.Lot__r;
			Id idVendor = lot.Product__r.AcctSeedERP__Default_Vendor__c;
			Id idProduct = lot.Product__c;

			//confirm that a non-zero pricebook entry exists
			Decimal price = 0;

			if(mapPricebook.containsKey(sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Chargeback_Pricebook__c))
			{
				for(PricebookEntry pbe : mapPricebook.get(sol.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__r.Chargeback_Pricebook__c).PricebookEntries)
				{
					if(pbe.Product2Id != idProduct || pbe.Effective_Date__c > sol.AcctSeedERP__Sales_Order__r.Fill_Date__c) continue;
					price = pbe.UnitPrice;
					break;
				}
			}

			if(price == null || price == 0) continue;

			if(lot.Product__r.Variable_Price__c)
			   price *= sol.Lot__r.Variant_Qty__c;

			if(!mapVendorListBillingLine.containsKey(idVendor))
				mapVendorListBillingLine.put(idVendor,new list<AcctSeed__Billing_Line__c>());

			mapVendorListBillingLine.get(idVendor).add(new AcctSeed__Billing_Line__c(
					AcctSeed__Comment__c = 'lot: '+lot.Name,
					AcctSeed__Product__c = idProduct,
					AcctSeed__Hours_Units__c = sol.Quantity_Filled__c,
					AcctSeed__Rate__c = price,
					AcctSeed__Revenue_GL_Account__c = idGLChargeBack,
					AcctSeedERP__Sales_Order_Line__c = sol.Id));
		}


		if(dateMaxFill == null || dateMaxFill > date.Today()) dateMaxFill = date.Today();
		Id idPeriod = [SELECT Id FROM AcctSeed__Accounting_Period__c
					   WHERE AcctSeed__Status__c = 'Open'
					     AND AcctSeed__End_Date__c >= :dateMaxFill
					   ORDER BY AcctSeed__Start_Date__c
					   LIMIT 1][0].Id;

		list<AcctSeed__Billing__c> listBilling = new list<AcctSeed__Billing__c>();
		//create a billing for each vendor
		for(Id idVendor : mapVendorListBillingLine.keySet())
		{
			listBilling.add(new AcctSeed__Billing__c(
				AcctSeed__Accounting_Period__c = idPeriod,
				AcctSeed__Date__c = date.Today(),
				AcctSeed__Customer__c = idVendor			
			));
		}
		insert listBilling;
		mapVendorBilling.clear();
		for(AcctSeed__Billing__c b : listBilling)
		{
			mapVendorBilling.put(b.AcctSeed__Customer__c,b);
		}

		list<AcctSeed__Billing_Line__c> listBL = new list<AcctSeed__Billing_Line__c>();
		for(Id idVendor : mapVendorBilling.keySet())
		{
			for(AcctSeed__Billing_Line__c bl : mapVendorListBillingLine.get(idVendor))
			{
				bl.AcctSeed__Billing__c = mapVendorBilling.get(idVendor).Id;
				listBL.add(bl);
			}
		}

		gcBillingLine.disableTrigger = true;
		insert listBL;

		if(listBilling.size() > 0)
		{
			AcctSeed.BillingPostService.postBillings(listBilling);
			list<string> listIdBilling = new list<string>();
			for(AcctSeed__Billing__c b : listBilling) listIdBilling.add(b.Id);
			return listIdBilling;
		}
		return new list<string>();
	}





}