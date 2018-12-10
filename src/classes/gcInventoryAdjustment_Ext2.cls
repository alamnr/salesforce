public without sharing class gcInventoryAdjustment_Ext2 {

    public gcInventoryAdjustment_Ext2(ApexPages.standardController c){}

    @RemoteAction @ReadOnly 
    public static list<map<string,string>> retrieveMoves(string idFilter)
    {
        list<map<string,string>> listJSON = new list<map<string,string>>();
        Date dateEarliestOpen = gcAccountingPeriod.dateEarliestOpen();

        for(AcctSeedERP__Inbound_Inventory_Movement__c move :
               [SELECT Id, Name,
                AcctSeedERP__Inventory_Balance__c,
                AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,
                AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Id,               
                AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Name,
                AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.ProductCode,
                AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Family,
                AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__r.Name,
                AcctSeedERP__Movement_Date__c,
                Lot__c,
                Lot__r.Name,
                AcctSeedERP__Quantity__c,
                Inventory_GL_Amount__c,
                    (SELECT 
                     AcctSeedERP__Inventory_Balance__c,
                     AcctSeedERP__Quantity__c,
                     Inventory_GL_Amount__c,
                     Lot__c
                     FROM AcctSeedERP__Outbound_Inventory_Movements__r)
                FROM AcctSeedERP__Inbound_Inventory_Movement__c
                WHERE Id = :idFilter 
                   OR (Inventory_Adjustment__c = :idFilter AND Inventory_Adjustment__c != null)
                ORDER BY AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Name,
                         AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.ProductCode,
                         CreatedDate,
                         Id])
        {
            map<string,string> m = new map<string,string>();

            Product2 p = move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r;

            Decimal qty = move.AcctSeedERP__Quantity__c;
            Decimal amt = move.Inventory_GL_Amount__c;
            if(qty == null) qty = 0;
            if(amt == null) amt = 0;

            for(AcctSeedERP__Outbound_Inventory_Movement__c moveOut : move.AcctSeedERP__Outbound_Inventory_Movements__r)
            {
                if(moveOut.AcctSeedERP__Quantity__c != null) qty -= moveOut.AcctSeedERP__Quantity__c;
                if(moveOut.Inventory_GL_Amount__c != null) amt -= moveOut.Inventory_GL_Amount__c;
            }

            Decimal avg = 0;
            if(qty != 0) avg = amt/qty;

            m.put('idMove',move.Id);
            m.put('idLot',move.Lot__c);
            m.put('avg',String.valueOf(avg.setScale(6)));
            m.put('amt',String.valueOf(amt.setScale(6)));
            m.put('lotName',move.Lot__r.Name);
            m.put('warehouseName',move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Warehouse__r.Name);
            m.put('idBalance',move.AcctSeedERP__Inventory_Balance__c);
            m.put('moveNumber', String.valueOf(Integer.valueOf(move.Name.replaceAll('[^0-9]',''))));
            m.put('idProduct', p.Id);
            m.put('productName',p.Name);
            m.put('productFamily',p.Family);
            m.put('productCode',p.ProductCode);
            m.put('qty',string.valueOf(qty.setScale(0)));

            m.put('periodIsOpen','false');
            if(move.AcctSeedERP__Movement_Date__c != null && move.AcctSeedERP__Movement_Date__c >= dateEarliestOpen)
                m.put('periodIsOpen','true');

            listJSON.add(m);
        }
        return listJSON;
    }

    @RemoteAction @ReadOnly 
    public static list<map<string,string>> retrieveInventory(string idAdjustment, string idObject)
    {
        set<string> setIdProduct = new set<string>();

        Inventory_Adjustment__c adj = [SELECT Warehouse__c, Product__c, Vendor__c, Adjustment_Type__c, Adjustment_Date__c FROM Inventory_Adjustment__c WHERE Id = :idAdjustment][0];

        if(adj.Product__c != null) setIdProduct.add(adj.Product__c);

        if(adj.Vendor__c != null)
        {
            for(Product2 p : [SELECT Id FROM Product2 WHERE AcctSeedERP__Default_Vendor__c = :adj.Vendor__c])
                setIdProduct.add(p.Id);
        }

        map<string,list<string>> mapFilters = new map<string,list<string>>();

        mapFilters.put('dateThru', new list<string>{String.valueOf(adj.Adjustment_Date__c.format())});
        if(adj.Warehouse__c != null)
        mapFilters.put('idWarehouse', new list<string>{adj.Warehouse__c});
        if(setIdProduct.size() > 0)
        mapFilters.put('idProduct', new list<string>(setIdProduct));
        if(idObject != null)
        {
        	String objectType = (Id.valueOf(idObject)).getSObjectType().getDescribe().getName();

        	system.debug(loggingLevel.error,'objectType: '+objectType);

        	if(objectType == 'Serial_Number__c')
        		mapFilters.put('idSerial', new list<string>{idObject});
        	else if(objectType == 'Lot__c')
        		mapFilters.put('idLot', new list<string>{idObject});
        	else if(objectType == 'Product2')
        	{
        		mapFilters.remove('idProduct');
        		mapFilters.put('idProduct', new list<string>{idObject});
        	}
        }

        return gcInventoryReport.inventorySummary(mapFilters, new list<string>{'idProduct','idLot','idSerial'});
    }

    @RemoteAction 
    public static map<string,string> updateAdjustment(String idMove, Decimal qtyNew, Decimal amtNew)
    {
        system.debug(loggingLevel.error,'update adjustment.... idMove: '+idMove+'; qtyNew: '+qtyNew+'; amtNew: '+amtNew);

    	qtyNew = qtyNew.setScale(6);
    	amtNew = amtNew.setScale(6);
        for(AcctSeedERP__Inbound_Inventory_Movement__c moveIn :
               [SELECT Id,
                AcctSeedERP__Quantity__c,
                AcctSeedERP__Type__c,
                AcctSeedERP__Unit_Cost__c,
                Cost_Override__c,
                Inventory_Adjustment__r.Adjustment_Type__c,
                Inventory_GL_Amount__c,
                    (SELECT Id,
                     AcctSeedERP__Type__c,
                     AcctSeedERP__Quantity__c,
                     AcctSeedERP__Unit_Cost__c,
                     Cost_Override__c,
                     Inventory_GL_Amount__c
                     FROM AcctSeedERP__Outbound_Inventory_Movements__r
                     LIMIT 1)
                FROM AcctSeedERP__Inbound_Inventory_Movement__c
                WHERE Id = :idMove])
        {
        	Decimal qtyOld = 0;
        	Decimal amtOld = 0;
        	if(moveIn.AcctSeedERP__Quantity__c != null) qtyOld += moveIn.AcctSeedERP__Quantity__c;
        	if(moveIn.Inventory_GL_Amount__c != null) amtOld += moveIn.Inventory_GL_Amount__c;

        	AcctSeedERP__Outbound_Inventory_Movement__c moveOut;
        	if(moveIn.AcctSeedERP__Outbound_Inventory_Movements__r.size() > 0) moveOut = moveIn.AcctSeedERP__Outbound_Inventory_Movements__r[0];
        	if(moveOut != null)
        	{
        		if(moveOut.AcctSeedERP__Quantity__c != null) qtyOld += moveOut.AcctSeedERP__Quantity__c;
        		if(moveOut.Inventory_GL_Amount__c != null) amtOld += moveOut.Inventory_GL_Amount__c;        		
        	}

        	qtyOld = qtyOld.setScale(6);
        	amtOld = amtOld.setScale(6);

        	if(qtyOld == qtyNew && amtOld == amtNew) continue;

        	if(qtyOld != qtyNew && moveIn.Inventory_Adjustment__r.Adjustment_Type__c == 'Quantity')
        	{
        		if(moveOut != null) delete moveOut;
        		moveIn.AcctSeedERP__Quantity__c = qtyNew;
        		moveIn.AcctSeedERP__Type__c = 'Accounting';
        		//moveIn.AcctSeedERP__Unit_Cost__c = 0;
        		moveIn.Cost_Override__c = false;
        		update moveIn;
        	}
        	else if(moveOut != null && moveIn.Inventory_Adjustment__r.Adjustment_Type__c != 'Quantity') 
        	{
        		moveIn.AcctSeedERP__Quantity__c = 1;
        		moveIn.AcctSeedERP__Type__c = 'Accounting';
        		moveIn.AcctSeedERP__Unit_Cost__c = 0;
        		moveIn.Cost_Override__c = true;

        		moveOut.AcctSeedERP__Quantity__c = 1;
        		moveOut.AcctSeedERP__Type__c = 'Accounting';
        		moveOut.AcctSeedERP__Unit_Cost__c = 0;
        		moveOut.Cost_Override__c = true;

        		if(amtNew >= 0)
        			moveIn.AcctSeedERP__Unit_Cost__c = amtNew;
        		else
        			moveOut.AcctSeedERP__Unit_Cost__c = amtNew * (-1);

        		update moveIn;
        		update moveOut;
        	}
        }
        return retrieveMoves(idMove)[0];
    }

	@RemoteAction 
	public static map<string,string> createAdjustment(String idAdjustment, String idObject)
	{
        Inventory_Adjustment__c adj = [SELECT Id, Warehouse__c, Product__c, Vendor__c, Adjustment_Type__c, Adjustment_Date__c FROM Inventory_Adjustment__c WHERE Id = :idAdjustment][0];

        Id idSerial;
        Id idLot;
        Id idProduct;
        Id idBalance;

        for(Serial_Number__c serial : [SELECT Id, Lot__c, Product__c FROM Serial_Number__c WHERE Id =:idObject])
        {
        	idSerial = serial.Id;
        	idLot = serial.Lot__c;
        	idProduct = serial.Product__c;
        	idObject = null;
        }
        if(idObject != null)
        for(Lot__c lot : [SELECT Id, Product__c FROM Lot__c WHERE Id =:idObject])
        {
        	idLot = lot.Id;
        	idProduct = lot.Product__c;
        	idObject = null;
        }
        if(idObject != null)
        for(Product2 p : [SELECT Id FROM Product2 WHERE Id = :idObject])
        {
        	idProduct = p.Id;
        	idObject = null;
        }

        if(idObject != null) return new map<string,string>();

        Id idWarehouse = adj.Warehouse__c;
        if(idWarehouse == null)
		idWarehouse = [SELECT Id FROM AcctSeedERP__Warehouse__c WHERE Uniquefier__c = 'ValueAdjustment'][0].Id;
		Id idLocation = [SELECT Id FROM AcctSeedERP__Location__c WHERE AcctSeedERP__Warehouse__c = :idWarehouse ORDER BY CreatedDate LIMIT 1][0].Id;

		idBalance = gcInventoryBalance.findOrCreateBalance(idProduct,idWarehouse,idLocation);  

		//If there is already a move for this balance and object then return
        for(AcctSeedERP__Inbound_Inventory_Movement__c move :
            [SELECT Id FROM AcctSeedERP__Inbound_Inventory_Movement__c
             WHERE Inventory_Adjustment__c != null
               AND Inventory_Adjustment__c = :adj.Id
               AND AcctSeedERP__Inventory_Balance__c = :idBalance AND Lot__c =:idLot AND Serial_Number__c = :idSerial])
        {
            return new map<string,string>(); 
        }

        Id idGL = null;

        if(adj.Adjustment_Type__c =='Quantity')
        {
            idGL = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Uniquefier__c = 'ValueAdjustment'][0].Id;
        }
        else if(adj.Adjustment_Type__c =='Value')
        {
            idGL = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Uniquefier__c = 'ValueAdjustment'][0].Id;
        }
        else
        {
            idGL = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Uniquefier__c = 'VendorAdjustment'][0].Id;
        }
		
        AcctSeedERP__Inbound_Inventory_Movement__c moveIn = new AcctSeedERP__Inbound_Inventory_Movement__c(
													            Inventory_Adjustment__c = idAdjustment,
													            AcctSeedERP__Credit_GL_Account__c = idGL,
													            AcctSeedERP__Inventory_Balance__c = idBalance,
													            AcctSeedERP__Movement_Date__c = adj.Adjustment_Date__c,       
													            AcctSeedERP__Quantity__c = 0,
													            AcctSeedERP__Type__c = 'Accounting',
													            AcctSeedERP__Unit_Cost__c = 0,
													            Cost_Override__c = false,
													            Lot__c = idLot,
													            Serial_Number__c = idSerial
        );
        
        Boolean boolOld = gcInventoryMovement.disableCostUpdate;
        gcInventoryMovement.disableCostUpdate = true;
		insert moveIn;
		gcInventoryMovement.disableCostUpdate = boolOld;

        if(adj.Adjustment_Type__c !='Quantity')
        {
	        AcctSeedERP__Outbound_Inventory_Movement__c moveOut = new AcctSeedERP__Outbound_Inventory_Movement__c(
                                                                        Inventory_Adjustment__c = idAdjustment,
															            AcctSeedERP__Debit_GL_Account__c = idGL,
															            AcctSeedERP__Inventory_Balance__c = idBalance,
															            AcctSeedERP__Movement_Date__c = adj.Adjustment_Date__c,       
															            AcctSeedERP__Quantity__c = 0,
															            AcctSeedERP__Type__c = 'Accounting',
															            AcctSeedERP__Unit_Cost__c = 0,
															            Cost_Override__c = false,
															            Lot__c = idLot,
															            Serial_Number__c = idSerial,
															            AcctSeedERP__Inbound_Inventory_Movement__c = moveIn.Id
															        );

	        boolOld = gcInventoryMovement.disableCostUpdate;
	        gcInventoryMovement.disableCostUpdate = true;
			insert moveOut;
			gcInventoryMovement.disableCostUpdate = boolOld;
        }

        return retrieveMoves(moveIn.Id)[0];
	}
}