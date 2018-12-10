global without sharing class gcSearch{

	global gcSearch(ApexPages.standardController ctrl){}
	global gcSearch(){}

	@RemoteAction @ReadOnly
	global static list<row> searchProduct(String strSearch, String idWarehouse, Integer intMaxResultCount)
	{
		if(intMaxResultCount == 0 || intMaxResultCount == null) intMaxResultCount = 10;
		
		map<Id,row> mapRow = new map<Id,row>();
		list<row> listRow = new list<row>();

		for(Product2 p : 
				[SELECT Id, Name, Family, ProductCode, AcctSeedERP__Serialized__c
				 FROM Product2
				 WHERE IsActive = true
				   AND AcctSeed__Inventory_Product__c = true
				   AND (Name = :strSearch OR ProductCode = :strSearch)
				 ORDER BY ProductCode, Name, Id])
		{
			row row = new row(p);
			mapRow.put(p.Id,row);
			listRow.add(row);
		}

		strSearch = '%'+strSearch.replaceAll('[*]','%') +'%';
		Integer intSize = intMaxResultCount - listRow.size();
		if(intSize < 0) intSize = 0;			
		for(Product2 p :
				[SELECT Id, Name, Family, ProductCode, AcctSeedERP__Serialized__c
				 FROM Product2
				 WHERE IsActive = true
				   AND AcctSeed__Inventory_Product__c = true
				   AND (Name LIKE :strSearch OR ProductCode LIKE :strSearch)
				   AND Id NOT IN :mapRow.keySet()
				 ORDER BY ProductCode, Name, Id
				 LIMIT :intSize])
		{
			row row = new row(p);
			mapRow.put(p.Id,row);
			listRow.add(row);
		}

		for(AggregateResult aggRes :
				[SELECT AcctSeedERP__Product__c idProduct, SUM(AcctSeedERP__Available_Quantity__c) qty
				 FROM AcctSeedERP__Inventory_Balance__c
				 WHERE AcctSeedERP__Product__c IN :mapRow.keySet()
				   AND (AcctSeedERP__Available_Quantity__c < 0 OR AcctSeedERP__Available_Quantity__c > 0)
				 GROUP BY AcctSeedERP__Product__c])
		{
			Decimal decQty = (Decimal)aggRes.get('qty');
			Id idProduct = (Id)aggRes.get('idProduct');
			
			mapRow.get(idProduct).mapProperty.put('qtyAllWarehouses',String.valueOf(decQty.setScale(0)));
		}

		for(AggregateResult aggRes :
				[SELECT AcctSeedERP__Product__c idProduct, SUM(AcctSeedERP__Available_Quantity__c) qty
				 FROM AcctSeedERP__Inventory_Balance__c
				 WHERE AcctSeedERP__Product__c IN :mapRow.keySet()
				   AND (AcctSeedERP__Available_Quantity__c < 0 OR AcctSeedERP__Available_Quantity__c > 0)
				   AND AcctSeedERP__Warehouse__c = :idWarehouse
				 GROUP BY AcctSeedERP__Product__c])
		{
			Decimal decQty = (Decimal)aggRes.get('qty');
			Id idProduct = (Id)aggRes.get('idProduct');
			
			mapRow.get(idProduct).mapProperty.put('qtyThisWarehouse',String.valueOf(decQty.setScale(0)));
		}
		
		return listRow;
	}


	global class row
	{
		global map<String,String> mapProperty{get;set;}
		private map<String,Boolean> mapBoolean{get;set;}
		private map<String,Decimal> mapDecimal{get;set;}
		private map<String,Integer> mapInteger{get;set;}

		global void init()
		{
			mapProperty = new map<String,String>();
			mapBoolean = new map<String,Boolean>();
			mapDecimal = new map<String,Decimal>();
			mapInteger = new map<String,Integer>();
		}

		global row()
		{
			init();
		}

		global row(Product2 product)
		{
			init();
			mapProperty.put('idProduct',product.Id);
			mapProperty.put('productFamily',product.Family);
			mapProperty.put('productName',product.Name);
			mapProperty.put('productCode',product.ProductCode);

			if(product.AcctSeedERP__Serialized__c)
				mapProperty.put('isSerialized','true');
			else
				mapProperty.put('idSerialized','false');

			if(product.Lot_Tracked__c)
				mapProperty.put('isLotTracked','true');
			else
				mapProperty.put('isLotTracked','false');

			mapProperty.put('qtyAllWarehouses',String.valueOf(0));
			mapProperty.put('qtyThisWarehouse',String.valueOf(0));

		}

		global void convertAllToString()
		{
			//convert all of the decimals to strings
			for(String key :mapDecimal.keySet())
			{
				mapProperty.put(key,String.valueOf(mapDecimal.get(key)));
			}
			//convert all of the integers to strings
			for(String key :mapInteger.keySet())
			{
				mapProperty.put(key,String.valueOf(mapInteger.get(key)));
			}			
			//convert the boolean values to strings
			for(String key :mapBoolean.keySet())
			{
				if(mapBoolean.get(key))
					mapProperty.put(key,'true');
				else
					mapProperty.put(key,'false');
			}
		}
	}
}