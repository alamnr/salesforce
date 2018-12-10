global without sharing class gcInventoryReport{

    global gcInventoryReport(ApexPages.standardController ctrl){}
    global gcInventoryReport(){}

	global static string locale{get{return UserInfo.getLocale();}}

    @RemoteAction @ReadOnly
    global static list<map<string,string>> inventoryDetail(map<String,list<String>> mapFilters)
    {
        return inventorySummary(mapFilters, new list<String>{'idBalance','idLot','idSerial'});
    }

	@RemoteAction @ReadOnly
	global static list<map<string,string>> inventorySummary(map<String,list<String>> mapFilters, list<String> listGroupBy)
	{
		return inventoryDescription(gcInventoryMovementCube_Report.inventoryAggRes(mapFilters,listGroupBy));
	}

	global static list<map<string,string>> inventoryDescription(list<gcInventoryMovementCube_Report.cube> listCube)
	{
		list<map<string,string>> listObj = new list<map<string,string>>();

		map<Id,AcctSeedERP__Inventory_Balance__c> mapBalance = new map<Id,AcctSeedERP__Inventory_Balance__c>();
		map<Id,AcctSeedERP__Warehouse__c> mapWarehouse = new map<Id,AcctSeedERP__Warehouse__c>();
		map<Id,AcctSeedERP__Location__c> mapLocation = new map<Id,AcctSeedERP__Location__c>();
		map<Id,Product2> mapProduct = new map<Id,Product2>();
		map<Id,Lot__c> mapLot = new map<Id,Lot__c>();
		map<Id,Serial_Number__c> mapSerial = new map<Id,Serial_Number__c>();

		for(gcInventoryMovementCube_Report.cube c : listCube)
		{
			if(c.idBalance != null)		mapBalance.put(c.idBalance,null);
			if(c.idWarehouse != null)	mapWarehouse.put(c.idWarehouse,null);
			if(c.idLocation != null)	mapLocation.put(c.idLocation,null);
			if(c.idProduct != null)		mapProduct.put(c.idProduct,null);
			if(c.idLot != null)			mapLot.put(c.idLot,null);
			if(c.idSerial != null)		mapSerial.put(c.idSerial,null);
		}

		mapSerial.remove(null);
		if(mapSerial.size() > 0)
		for(Serial_Number__c serial : 
			[SELECT Id, 
					Name, 
					Lot__c, 
					Product__c
			FROM Serial_Number__c WHERE Id IN :mapSerial.keySet()])
		{
			mapSerial.put(serial.Id,serial);
			mapLot.put(serial.Lot__c,null);
			mapProduct.put(serial.Product__c,null);
		}

		mapLot.remove(null);
		if(mapLot.size() > 0)
		for(Lot__c lot : [SELECT Id, Name, Product__c, Expiration_Date__c, Variant_Qty__c FROM Lot__c WHERE Id IN :mapLot.keySet()])
		{
			mapLot.put(lot.Id,lot);
			mapProduct.put(lot.Product__c,null);
		}

		mapBalance.remove(null);
		if(mapBalance.size() > 0)
		for(AcctSeedERP__Inventory_Balance__c bal :
				[SELECT Id,
						AcctSeedERP__Warehouse__c,
						AcctSeedERP__Location__c,
						AcctSeedERP__Product__c
				FROM AcctSeedERP__Inventory_Balance__c
				WHERE Id IN : mapBalance.keySet()])
		{
			mapBalance.put(bal.Id,bal);
			mapWarehouse.put(bal.AcctSeedERP__Warehouse__c,null);
			mapLocation.put(bal.AcctSeedERP__Location__c,null);
			mapProduct.put(bal.AcctSeedERP__Product__c,null);
		}

		mapLocation.remove(null);
		if(mapLocation.size() > 0)
		for(AcctSeedERP__Location__c l : [SELECT Id, Name, AcctSeedERP__Warehouse__c FROM AcctSeedERP__Location__c WHERE Id IN : mapLocation.keySet()])
		{
			mapLocation.put(l.Id,l);
			mapWarehouse.put(l.AcctSeedERP__Warehouse__c,null);
		}

		mapWarehouse.remove(null);
		if(mapWarehouse.size() > 0)
		for(AcctSeedERP__Warehouse__c w : 
			[SELECT Id, 
					Name,
					Uniquefier__c,
					Account__r.ShippingCity, 
					Account__r.ShippingState, 
					Account__r.ShippingStreet, 
					Account__r.ShippingCountry,
					Account__r.ShippingLatitude, 
					Account__r.ShippingLongitude, 
					Account__r.ShippingPostalCode					
			 FROM AcctSeedERP__Warehouse__c WHERE Id IN : mapWarehouse.keySet()])
			mapWarehouse.put(w.Id,w);

		mapProduct.remove(null);
		if(mapProduct.size() > 0)
		for(Product2 p : 
			[SELECT Id, Name, Family, IsActive, ProductCode, AcctSeedERP__Serialized__c, Lot_Tracked__c, Variable_Price__c,
			 		AcctSeed__GL_Account_Variable_1__r.Name,
			 		AcctSeed__GL_Account_Variable_2__r.Name,
			 		AcctSeed__GL_Account_Variable_3__r.Name,
			 		AcctSeed__GL_Account_Variable_4__r.Name
			 FROM Product2 WHERE Id IN : mapProduct.keySet()])
			mapProduct.put(p.Id,p);

		for(gcInventoryMovementCube_Report.cube c : listCube)
		{
			AcctSeedERP__Inventory_Balance__c bal = mapBalance.get(c.idBalance);
			AcctSeedERP__Warehouse__c whs = mapWarehouse.get(c.idWarehouse);
			AcctSeedERP__Location__c loc = mapLocation.get(c.idLocation);
			Product2 product = mapProduct.get(c.idProduct);
			Lot__c lot = mapLot.get(c.idLot);
			Serial_Number__c serial = mapSerial.get(c.idSerial);

			if(lot == null && serial != null && mapLot.containsKey(serial.Lot__c))
				lot = mapLot.get(serial.Lot__c);

			if(product == null && serial != null)
				product = mapProduct.get(serial.Product__c);
			else if(product == null && lot != null)
				product = mapProduct.get(lot.Product__c);
			else if(product == null && bal != null)
				product = mapProduct.get(bal.AcctSeedERP__Product__c);

			if(whs == null && loc != null)
				whs = mapWarehouse.get(loc.AcctSeedERP__Warehouse__c);
			else if(whs == null && bal != null)
				whs = mapWarehouse.get(bal.AcctSeedERP__Warehouse__c);

			if(loc == null && bal != null)
				loc = mapLocation.get(bal.AcctSeedERP__Location__c);

			map<string,string> obj = new map<string,string>();

			if(bal != null)
				obj.put('idBalance',bal.Id);
			if(whs != null)
			{
				obj.put('idWarehouse',whs.Id);
				obj.put('warehouseName',whs.Name);
				obj.put('warehouseNum',whs.Uniquefier__c);
				obj.put('Address',whs.Account__r.ShippingStreet + ',' + whs.Account__r.ShippingCity + ',' + whs.Account__r.ShippingState + ' ' + whs.Account__r.ShippingPostalCode + ',' + whs.Account__r.ShippingCountry);
				obj.put('lat',String.valueOf(whs.Account__r.ShippingLatitude));
				obj.put('lng',String.valueOf(whs.Account__r.ShippingLongitude));
			}
			if(loc != null)
			{
				obj.put('idLocation',loc.Id);
				obj.put('locationName',loc.Name);
			}
			if(product != null)
			{
				obj.put('idProduct',product.Id);
				obj.put('productName',product.Name);
				obj.put('productCode',product.ProductCode);
				obj.put('productFamily',product.Family);
				obj.put('glv1Name',product.AcctSeed__GL_Account_Variable_1__r.Name);
				obj.put('glv2Name',product.AcctSeed__GL_Account_Variable_2__r.Name);
				obj.put('glv3Name',product.AcctSeed__GL_Account_Variable_3__r.Name);
				obj.put('glv4Name',product.AcctSeed__GL_Account_Variable_4__r.Name);

				if(product.IsActive)
					obj.put('productIsActive','true');
				else
					obj.put('productIsActive','false');

				if(product.AcctSeedERP__Serialized__c)
					obj.put('productIsSerialized','true');
				else
					obj.put('productIsSerialized','false');

				if(product.Lot_Tracked__c)
					obj.put('productIsLotTracked','true');
				else
					obj.put('productIsLotTracked','false');

				if(product.Variable_Price__c)
					obj.put('productIsVariablePrice','true');
				else
					obj.put('productIsVariablePrice','false');
			}
			if(lot != null)
			{
				obj.put('idLot',lot.Id);
				obj.put('lotName',lot.Name);

				if(lot.Expiration_Date__c != null)
					obj.put('lotExpirationDate', lot.Expiration_Date__c.format());

				if(lot.Variant_Qty__c != null)
					obj.put('lotVariantQty', String.valueOf(lot.Variant_Qty__c.setScale(6)));			
			}
			if(serial != null)
			{
				obj.put('idSerial',serial.Id);
				obj.put('serialName',serial.Name);
			}

			Decimal avg = 0;
			if(c.qty != 0)
				avg = c.amt / c.qty;

			obj.put('qty', String.valueOf(c.qty.setScale(6)));
			obj.put('amt', String.valueOf(c.amt.setScale(6)));
			obj.put('avg', String.valueOf(avg.setScale(6)));

			//for backward compatibility
			//obj.put('InventoryQuantity', 		String.valueOf(c.qty.setScale(6)));
			//obj.put('InventoryCost', 	 		String.valueOf(c.amt.setScale(6)));
			//obj.put('InventoryCost2',    		String.valueOf(c.amt.setScale(6)));
			//obj.put('InventoryAverageCost', 	String.valueOf(avg.setScale(6)));
			//obj.put('InventoryAverageCost2', 	String.valueOf(avg.setScale(6)));
			//obj.put('ObjectUnitCost', 		String.valueOf(avg.setScale(6)));

			listObj.add(obj);			
		}

		return listObj;
	}
}