global without sharing class gcInventoryMovementReport {

	global gcInventoryMovementReport(ApexPages.standardController ctrl){}
	global gcInventoryMovementReport(){}

	@RemoteAction @ReadOnly
	global static list<gcObj> inventoryMovementSummary(map<String,list<String>> mapFilters, list<String> listGroupBy)
	{
		set<String> setGroupBy = new set<String>();
		setGroupBy.addAll(listGroupBy);

		set<String> setIdOrig = new set<String>();
		set<String> setIdDest = new set<String>();
		set<String> setIdVendor = new set<String>();
		set<String> setIdProduct = new set<String>();
		set<String> setIdLot = new set<String>();

		Date dateFrom;
		Date dateThru;

		if(mapFilters.containsKey('idOrig'))
			setIdOrig.addAll(mapFilters.get('idOrig'));
		if(mapFilters.containsKey('idDest'))
			setIdDest.addAll(mapFilters.get('idDest'));
		if(mapFilters.containsKey('idVendor'))
			setIdVendor.addAll(mapFilters.get('idVendor'));
		if(mapFilters.containsKey('idProduct'))
			setIdProduct.addAll(mapFilters.get('idProduct'));
		if(mapFilters.containsKey('idLot'))
			setIdLot.addAll(mapFilters.get('idLot'));


		if(mapFilters.containsKey('dateFrom'))
		{
			dateFrom = date.parse(mapFilters.get('dateFrom')[0]);
		}

		if(mapFilters.containsKey('dateThru'))
		{
			dateThru = date.parse(mapFilters.get('dateThru')[0]);
		}

		list<sObject> listAggRes = new list<sObject>();
		map<String,cube> mapCube = new map<String,cube>();

		String soqlSELECT;
		String soqlGROUP;
		String soqlWHERE;
		String soql;

		//aggregate the outbound inventory movements that are under a sales order

		soqlSELECT = 'SELECT ';
		soqlSELECT += ' AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__r.Account__c idOrig, '; //origin
		soqlSELECT += ' Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c idDest, '; //destination
		soqlSELECT += ' AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c idProduct, '; //product
		soqlSELECT += ' sum(AcctSeedERP__Quantity__c) qty ';

		soqlGROUP = ' GROUP BY ';
		soqlGROUP += '  AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__r.Account__c ';
		soqlGROUP += ', Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c ';
		soqlGROUP += ', AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c ';

		if(setGroupBy.contains('idLot'))
		{
				soqlSELECT += ', Lot__c idLot ';
				soqlGROUP  += ', Lot__c ';
		}
		if(setGroupBy.contains('dateMove'))
		{
				soqlSELECT += ', AcctSeedERP__Movement_Date__c dateMove ';
				soqlGROUP  += ', AcctSeedERP__Movement_Date__c ';
		}
		if(setGroupBy.contains('idParent'))
		{
				soqlSELECT += ', Sales_Order_Line__r.AcctSeedERP__Sales_Order__c idParent ';
				soqlGROUP  += ', Sales_Order_Line__r.AcctSeedERP__Sales_Order__c ';
		}

		//construct the WHERE clause
		soqlWHERE = ' WHERE Sales_Order_Line__c != null ';

		if(setIdOrig.size() > 0)
		{
			soqlWHERE += ' AND AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__r.Account__c IN : setIdOrig ';
		}
		if(setIdDest.size() > 0)
		{
			soqlWHERE += ' AND Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c IN : setIdDest ';
		}
		if(setIdVendor.size() > 0)
		{
			soqlWHERE += ' AND AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c IN : setIdVendor ';
		}
		if(setIdProduct.size() > 0)
		{
			soqlWHERE += ' AND AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c IN : setIdProduct ';
		}
		if(setIdLot.size() > 0)
		{
			soqlWHERE += ' AND Lot__c IN : setIdLot ';
		}
		if(dateFrom != null)
		{
			soqlWHERE += ' AND AcctSeedERP__Movement_Date__c >= :dateFrom ';
		}
		if(dateThru != null)
		{
			soqlWHERE += ' AND AcctSeedERP__Movement_Date__c <= :dateThru ';
		}

		soql = soqlSELECT + ' FROM AcctSeedERP__Outbound_Inventory_Movement__c ' + soqlWHERE + soqlGROUP;		

		listAggRes.clear();
		listAggRes.addAll(Database.query(soql));

		for(sObject aggRes : listAggRes)
		{
			Decimal qty = (Decimal)aggRes.get('qty');
			if(qty == null) qty = 0;

			Id idOrig 		= null;
			Id idDest 		= null;
			Id idVendor 	= null;
			Id idProduct 	= null;
			Id idLot 		= null;
			Id idSerial 		= null;
			Id idParent 		= null;
			Date dateMove 	= null;

			idOrig 		= (Id)aggRes.get('idOrig');
			idDest  	= (Id)aggRes.get('idDest');
			idProduct 	= (Id)aggRes.get('idProduct');
			if(setGroupBy.contains('idVendor')) 	idVendor 	= (Id)aggRes.get('idVendor');
			if(setGroupBy.contains('idLot')) 		idLot 		= (Id)aggRes.get('idLot');
			if(setGroupBy.contains('idSerial')) 		idSerial 		= (Id)aggRes.get('idSerial');
			if(setGroupBy.contains('idParent')) 	idParent 	= (Id)aggRes.get('idParent');
			if(setGroupBy.contains('dateMove'))		dateMove 	= (Date)aggRes.get('dateMove');

			String key = 'sale';
			if(qty < 0) key='return';
			if(idOrig 		!= null) 	key += idOrig;
			if(idDest 		!= null) 	key += idDest;
			if(idVendor 	!= null) 	key += idVendor;
			if(idProduct 	!= null) 	key += idProduct;
			if(idLot 		!= null) 	key += idLot;
			if(idSerial 		!= null) 	key += idSerial;
			if(idParent 	!= null) 	key += idParent;
			if(dateMove 	!= null) 	key += String.valueOf(dateMove);

			if(key == 'sale' || key == 'return') continue;

			if(!mapCube.containsKey(key))
				mapCube.put(key, new cube(idOrig, idDest, idVendor, idProduct, idLot, idSerial, idParent, dateMove));

			cube cube = mapCube.get(key);
			cube.qty += qty;

			if(cube.qty < 0) cube.moveType = 'return';
			else cube.moveType = 'sale';
		}

		//aggregate the outbound inventory movements that are under an inventory transfer

		soqlSELECT = 'SELECT ';
		soqlSELECT += ' Inventory_Transfer__r.Warehouse_From__r.Account__c idOrig, ';
		soqlSELECT += ' Inventory_Transfer__r.Warehouse_To__r.Account__c idDest, '; //destination
		soqlSELECT += ' AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c idProduct, '; //product
		soqlSELECT += ' sum(AcctSeedERP__Quantity__c) qty ';

		soqlGROUP = ' GROUP BY ';
		soqlGROUP += '  Inventory_Transfer__r.Warehouse_From__r.Account__c ';
		soqlGROUP += ', Inventory_Transfer__r.Warehouse_To__r.Account__c ';
		soqlGROUP += ', AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c ';

		if(setGroupBy.contains('idLot'))
		{
				soqlSELECT += ', Lot__c idLot ';
				soqlGROUP  += ', Lot__c ';
		}
		if(setGroupBy.contains('dateMove'))
		{
				soqlSELECT += ', Inventory_Transfer__r.Inbound_Date__c dateMove ';
				soqlGROUP  += ', Inventory_Transfer__r.Inbound_Date__c ';
		}
		if(setGroupBy.contains('idParent'))
		{
				soqlSELECT += ', Inventory_Transfer__c idParent ';
				soqlGROUP  += ', Inventory_Transfer__c ';
		}

		//construct the WHERE clause
		soqlWHERE = ' WHERE Inventory_Transfer__c != null ';
		soqlWHERE += ' AND Inventory_Transfer__r.Inbound_Date__c != null ';
		soqlWHERE += ' AND AcctSeedERP__Inbound_Inventory_Movement__c = null ';

		if(setIdOrig.size() > 0)
		{
			soqlWHERE += ' AND Inventory_Transfer__r.Warehouse_From__r.Account__c IN : setIdOrig ';
		}
		if(setIdDest.size() > 0)
		{
			soqlWHERE += ' AND Inventory_Transfer__r.Warehouse_To__r.Account__c IN : setIdDest ';
		}
		if(setIdVendor.size() > 0)
		{
			soqlWHERE += ' AND AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c IN : setIdVendor ';
		}
		if(setIdProduct.size() > 0)
		{
			soqlWHERE += ' AND AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c IN : setIdProduct ';
		}
		if(setIdLot.size() > 0)
		{
			soqlWHERE += ' AND Lot__c IN : setIdLot ';
		}
		if(dateFrom != null)
		{
			soqlWHERE += ' AND Inventory_Transfer__r.Inbound_Date__c >= :dateFrom ';
		}
		if(dateThru != null)
		{
			soqlWHERE += ' AND Inventory_Transfer__r.Inbound_Date__c <= :dateThru ';
		}

		soql = soqlSELECT + ' FROM AcctSeedERP__Outbound_Inventory_Movement__c ' + soqlWHERE + soqlGROUP;		

		listAggRes.clear();
		listAggRes.addAll(Database.query(soql));

		for(sObject aggRes : listAggRes)
		{
			Decimal qty = (Decimal)aggRes.get('qty');
			if(qty == null) qty = 0;

			Id idOrig 		= null;
			Id idDest 		= null;
			Id idVendor 	= null;
			Id idProduct 	= null;
			Id idLot 		= null;
			Id idSerial 		= null;
			Id idParent 	= null;
			Date dateMove 	= null;

			idOrig 		= (Id)aggRes.get('idOrig');
			idDest  	= (Id)aggRes.get('idDest');
			idProduct 	= (Id)aggRes.get('idProduct');
			if(setGroupBy.contains('idVendor')) 	idVendor 	= (Id)aggRes.get('idVendor');
			if(setGroupBy.contains('idLot')) 		idLot 		= (Id)aggRes.get('idLot');
			if(setGroupBy.contains('idSerial')) 		idSerial 		= (Id)aggRes.get('idSerial');
			if(setGroupBy.contains('idParent')) 	idParent 	= (Id)aggRes.get('idParent');
			if(setGroupBy.contains('dateMove'))		dateMove 	= (Date)aggRes.get('dateMove');

			String key = 'transfer';
			if(idOrig 		!= null) 	key += idOrig;
			if(idDest 		!= null) 	key += idDest;
			if(idVendor 	!= null) 	key += idVendor;
			if(idProduct 	!= null) 	key += idProduct;
			if(idLot 		!= null) 	key += idLot;
			if(idSerial 		!= null) 	key += idSerial;
			if(idParent 	!= null) 	key += idParent;
			if(dateMove 	!= null) 	key += String.valueOf(dateMove);

			if(key == 'transfer') continue;

			if(!mapCube.containsKey(key))
				mapCube.put(key, new cube(idOrig, idDest, idVendor, idProduct, idLot, idSerial, idParent, dateMove));

			cube cube = mapCube.get(key);
			cube.qty += qty;

			cube.moveType = 'transfer';
		}

		list<cube> listCube = new list<cube>();

		map<Id,Account> mapAccount = new map<Id,Account>();
		map<Id,Product2> mapProduct = new map<Id,Product2>();
		map<Id,Lot__c> mapLot = new map<Id,Lot__c>();
		map<Id,Serial_Number__c> mapSerial = new map<Id,Serial_Number__c>();
		map<Id,AcctSeedERP__Sales_Order__c> mapOrder = new map<Id,AcctSeedERP__Sales_Order__c>();
		map<Id,Inventory_Transfer__c> mapTransfer = new map<Id,Inventory_Transfer__c>();
		set<Id> setIdParent = new set<Id>();

		for(cube cube :mapCube.values())
		{
			if(cube.qty.setScale(2) != 0)
			{
				mapAccount.put(cube.idOrig,null);
				mapAccount.put(cube.idDest,null);
				mapAccount.put(cube.idVendor,null);
				mapProduct.put(cube.idProduct,null);
				mapLot.put(cube.idLot,null);
				mapSerial.put(cube.idSerial,null);
				setIdParent.add(cube.idParent);

				listCube.add(cube);
			}
		}


		mapSerial.remove(null);
		for(Serial_Number__c serial : [SELECT Id, Name, Lot__c, Product__c FROM Serial_Number__c WHERE Id IN :mapSerial.keySet()])
		{
			mapSerial.put(serial.Id,serial);
			mapLot.put(serial.Lot__c,null);
			mapProduct.put(serial.Product__c,null);
		}

		mapLot.remove(null);
		for(Lot__c lot : [SELECT Id, Name, Product__c, Expiration_Date__c, Variant_Qty__c FROM Lot__c WHERE Id IN :mapLot.keySet()])
		{
			mapLot.put(lot.Id,lot);
			mapProduct.put(lot.Product__c,null);
		}

		mapProduct.remove(null);
		for(Product2 p : 
			[SELECT Id, Name, Family, IsActive, ProductCode, AcctSeedERP__Serialized__c, Lot_Tracked__c, Variable_Price__c,
			 		AcctSeed__GL_Account_Variable_1__r.Name,
			 		AcctSeed__GL_Account_Variable_2__r.Name,
			 		AcctSeed__GL_Account_Variable_3__r.Name,
			 		AcctSeed__GL_Account_Variable_4__r.Name,
			 		AcctSeedERP__Default_Vendor__c
			 FROM Product2 WHERE Id IN : mapProduct.keySet()])
		{
			mapProduct.put(p.Id,p);
			mapAccount.put(p.AcctSeedERP__Default_Vendor__c,null);
		}

		for(AcctSeedERP__Sales_Order__c so : 
			[SELECT Id, Name, AcctSeedERP__Customer__c, (SELECT Id, Name FROM AcctSeedERP__Billings__r)
			 FROM AcctSeedERP__Sales_Order__c
			 WHERE Id IN : setIdParent])
		{
			mapOrder.put(so.Id,so);
			mapAccount.put(so.AcctSeedERP__Customer__c, null);
		}
		for(Inventory_Transfer__c tfr :
			[SELECT Id, Name
			 FROM Inventory_Transfer__c
			 WHERE Id IN : setIdParent])
		{
			mapTransfer.put(tfr.Id,tfr);
		}

		mapAccount.remove(null);
		for(Account a : 
			[SELECT Id, Name, AccountNumber,
			 ShippingStreet,
			 ShippingCity,
			 ShippingState,
			 ShippingPostalCode,
			 DEA_Number__c, 
			 License_Number__c
			 FROM Account
			 WHERE Id IN : mapAccount.keySet()])
		{
			mapAccount.put(a.Id,a);
		}

		list<gcObj> listObj = new list<gcObj>();
		Account orig = new Account();
		Account dest = new Account();
		Account vendor = new Account();
		Product2 product = new Product2();
		Lot__c lot = new Lot__c();
		Serial_Number__c serial = new Serial_Number__c();
		AcctSeedERP__Sales_Order__c order = new AcctSeedERP__Sales_Order__c();
		Inventory_Transfer__c transfer = new Inventory_Transfer__c();

		for(cube cube : listCube)
		{
			orig = mapAccount.get(cube.idOrig);
			dest = mapAccount.get(cube.idDest);
			product = mapProduct.get(cube.idProduct);

			vendor = mapAccount.get(product.AcctSeedERP__Default_Vendor__c);
			if(vendor == null) vendor = new Account(Name='---blank---');

			lot = mapLot.get(cube.idLot);
			serial = mapSerial.get(cube.idSerial);
			order = mapOrder.get(cube.idParent);
			transfer = mapTransfer.get(cube.idParent);

			if(lot == null && serial != null && mapLot.containsKey(serial.Lot__c))
				lot = mapLot.get(serial.Lot__c);

			if(product == null && serial != null)
				product = mapProduct.get(serial.Product__c);
			else if(product == null && lot != null)
				product = mapProduct.get(lot.Product__c);
			
			gcObj obj = new gcObj();

			if(orig != null)
			{
				obj.mapProperty.put('idOrig', orig.Id);
				obj.mapProperty.put('origName', orig.Name);
				obj.mapProperty.put('origAccount', orig.AccountNumber);
				obj.mapProperty.put('origLicense', orig.License_Number__c);
				obj.mapProperty.put('origDEA', orig.DEA_Number__c);
				obj.mapProperty.put('origShippingStreet', orig.ShippingStreet);
				obj.mapProperty.put('origShippingCity', orig.ShippingCity);
				obj.mapProperty.put('origShippingState', orig.ShippingState);
				obj.mapProperty.put('origShippingPostalCode', orig.ShippingPostalCode);				
			}
			if(dest != null)
			{
				obj.mapProperty.put('idDest', dest.Id);
				obj.mapProperty.put('destName', dest.Name);
				obj.mapProperty.put('destAccount', dest.AccountNumber);
				obj.mapProperty.put('destLicense', dest.License_Number__c);
				obj.mapProperty.put('destDEA', dest.DEA_Number__c);
				obj.mapProperty.put('destShippingStreet', dest.ShippingStreet);
				obj.mapProperty.put('destShippingCity', dest.ShippingCity);
				obj.mapProperty.put('destShippingState', dest.ShippingState);
				obj.mapProperty.put('destShippingPostalCode', dest.ShippingPostalCode);
			}

			if(vendor != null)
			{
				obj.mapProperty.put('idVendor', vendor.Id);
				obj.mapProperty.put('vendorName', vendor.Name);
			}

			if(product != null)
			{
				obj.mapProperty.put('idProduct',product.Id);
				obj.mapProperty.put('productName',product.Name);
				obj.mapProperty.put('productCode',product.ProductCode);
				obj.mapProperty.put('productFamily',product.Family);
				obj.mapProperty.put('glv1Name',product.AcctSeed__GL_Account_Variable_1__r.Name);
				obj.mapProperty.put('glv2Name',product.AcctSeed__GL_Account_Variable_2__r.Name);
				obj.mapProperty.put('glv3Name',product.AcctSeed__GL_Account_Variable_3__r.Name);
				obj.mapProperty.put('glv4Name',product.AcctSeed__GL_Account_Variable_4__r.Name);

				if(product.IsActive)
					obj.mapProperty.put('productIsActive','true');
				else
					obj.mapProperty.put('productIsActive','false');

				if(product.AcctSeedERP__Serialized__c)
					obj.mapProperty.put('productIsSerialized','true');
				else
					obj.mapProperty.put('productIsSerialized','false');

				if(product.Lot_Tracked__c)
					obj.mapProperty.put('productIsLotTracked','true');
				else
					obj.mapProperty.put('productIsLotTracked','false');

				if(product.Variable_Price__c)
					obj.mapProperty.put('productIsVariablePrice','true');
				else
					obj.mapProperty.put('productIsVariablePrice','false');
			}
			if(lot != null)
			{
				obj.mapProperty.put('idLot',lot.Id);
				obj.mapProperty.put('lotName',lot.Name);

				if(lot.Expiration_Date__c != null)
					obj.mapProperty.put('lotExpirationDate', lot.Expiration_Date__c.format());

				if(lot.Variant_Qty__c != null)
					obj.mapProperty.put('lotVariantQty', String.valueOf(lot.Variant_Qty__c.setScale(6)));			
			}
			if(serial != null)
			{
				obj.mapProperty.put('idSerial',serial.Id);
				obj.mapProperty.put('serialName',serial.Name);
			}
			if(cube.dateMove != null)
			{
				obj.mapProperty.put('dateMove',cube.dateMove.format());
			}

			if(order != null)
			{
				if(order.AcctSeedERP__Billings__r.size() > 0)
				{
					obj.mapProperty.put('idParent', order.AcctSeedERP__Billings__r[0].Id);
					obj.mapProperty.put('parentName', 'B-'+order.AcctSeedERP__Billings__r[0].Name);
				}
				else
				{
					obj.mapProperty.put('idParent', order.Id);
					obj.mapProperty.put('parentName', order.Name);
				}
			}

			if(transfer != null)
			{
				obj.mapProperty.put('idParent', transfer.Id);
				obj.mapProperty.put('parentName', transfer.Name);				
			}

			obj.mapProperty.put('qty', String.valueOf(cube.qty.setScale(6)));
			obj.mapProperty.put('moveType',cube.moveType);

			listObj.add(obj);			
		}

		return listObj;
	}

	global class cube{
		global Decimal qty{get;set;}

		global Id idOrig{get;set;}
		global Id idDest{get;set;}
		global Id idVendor{get;set;}
		global Id idProduct{get;set;}
		global Id idLot{get;set;}
		global Id idSerial{get;set;}
		global Id idParent{get;set;}
		global date dateMove{get;set;}
		global String moveType{get;set;}

		global cube(Id pIdOrig, Id pIdDest, Id pIdVendor, Id pIdProduct, Id pIdLot, Id pIdSerial, Id pIdParent, Date pDateMove)
		{
			idOrig = pIdOrig;
			idDest = pIdDest;
			idVendor = pIdVendor;
			idProduct = pIdProduct;
			idLot = pIdLot;
			idSerial = pIdSerial;
			idParent = pIdParent;
			dateMove = pDateMove;
			moveType = null;
			qty = 0;
		}
	}
}