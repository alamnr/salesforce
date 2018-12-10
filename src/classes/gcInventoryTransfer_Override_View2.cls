public without sharing class gcInventoryTransfer_Override_View2 {

    public gcInventoryTransfer_Override_View2(ApexPages.StandardController c) {}
    public gcInventoryTransfer_Override_View2() {}

    @RemoteAction @ReadOnly
    public static list<map<string,string>> retrieveOutboundMoves(String idFilter)
    {
        list<map<string,string>> listJSON = new list<map<string,string>>();

        Date dateEarliestOpen = gcAccountingPeriod.dateEarliestOpen();

        //these are the "Parent" moves, each of which corresponds to a detail line on the transfer page
        for(AcctSeedERP__Outbound_Inventory_Movement__c move :
               [SELECT Id, Name,
                AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__c,
                AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Name,             
                AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.ProductCode,
                AcctSeedERP__Movement_Date__c,
                AcctSeedERP__Quantity__c,
                Lot__c,
                Lot__r.Name,
                Lot__r.Expiration_Date__c,
                Lot__r.Variant_Qty__c,
                    (SELECT Id, AcctSeedERP__Movement_Date__c FROM AcctSeedERP__Inbound_Inventory_Movements__r ORDER BY AcctSeedERP__Movement_Date__c LIMIT 1)
                FROM AcctSeedERP__Outbound_Inventory_Movement__c
                WHERE Inventory_Transfer__c != NULL
                  AND AcctSeedERP__Inbound_Inventory_Movement__c = NULL
                  AND (Inventory_Transfer__c = :idFilter OR Id = :idFilter)
                ORDER BY AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.ProductCode, Lot__r.Name, Id])
        {
            map<string,string> m = new map<string,string>();
            Product2 p = move.AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r;

            m.put('idMove',move.Id);
            m.put('idLot',move.Lot__c);
            m.put('lotName',move.Lot__r.Name);
            m.put('moveNumber', String.valueOf(Integer.valueOf(move.Name.replaceAll('[^0-9]',''))));
            m.put('idProduct', p.Id);
            m.put('productName',p.Name);
            m.put('productCode',p.ProductCode);
            if(move.AcctSeedERP__Quantity__c != null)
                m.put('qty',string.valueOf(move.AcctSeedERP__Quantity__c.setScale(0)));
            else
                m.put('qty','0');

            if(move.Lot__r.Expiration_Date__c != null)
                m.put('lotExpirationDate',move.Lot__r.Expiration_Date__c.format());
            if(move.Lot__r.Variant_Qty__c != null)
                m.put('lotVariantQty',String.valueOf(move.Lot__r.Variant_Qty__c.setScale(0)));

            m.put('periodIsOpen','false');
            if(move.AcctSeedERP__Movement_Date__c != null && move.AcctSeedERP__Movement_Date__c >= dateEarliestOpen &&
                (move.AcctSeedERP__Inbound_Inventory_Movements__r.size() == 0 || move.AcctSeedERP__Inbound_Inventory_Movements__r[0].AcctSeedERP__Movement_Date__c >= dateEarliestOpen))
            {
                m.put('periodIsOpen','true');
            }

            listJSON.add(m);
        }

        return listJSON;
    }

    @RemoteAction @ReadOnly
    public static list<map<string,string>> searchProduct(String idTransfer, String strSearch)
    {
    	list<map<string,string>> listJSON = new list<map<string,string>>();

        Integer intMaxProductCount = 100;
        set<string> setIdProduct = new set<string>();
        for(Product2 p : 
                [SELECT Id
                 FROM Product2
                 WHERE IsActive = true
                   AND AcctSeed__Inventory_Product__c = true
                   AND (Name = :strSearch OR ProductCode = :strSearch)])
        {
            setIdProduct.add(p.Id);
        }
        strSearch = '%'+strSearch.replaceAll('[*]','%') +'%';
        Integer intSize = intMaxProductCount - setIdProduct.size();
        if(intSize < 0) intSize = 0;            
        for(Product2 p :
                [SELECT Id
                 FROM Product2
                 WHERE IsActive = true
                   AND AcctSeed__Inventory_Product__c = true
                   AND (Name LIKE :strSearch OR ProductCode LIKE :strSearch)
                   AND Id NOT IN :setIdProduct
                   AND Id IN (SELECT AcctSeedERP__Product__c FROM AcctSeedERP__Inventory_Balance__c WHERE AcctSeedERP__Available_Quantity__c > 0)
                 ORDER BY ProductCode, Name, Id
                 LIMIT :intSize])
        {
            setIdProduct.add(p.Id);
        }
        if(setIdProduct.size() == 0)
            return new list<map<string,string>>();

        Inventory_Transfer__c xfr = [SELECT Id, Outbound_Date__c, Warehouse_From__c FROM Inventory_Transfer__c WHERE Id =:idTransfer][0];

        map<string,list<string>> mapFilters = new map<string,list<string>>();
        mapFilters.put('idProduct', new list<string>(setIdProduct));
        mapFilters.put('dateThru', new list<string>{xfr.Outbound_Date__c.format()});

        list<string> listGroupBy = new list<string>{'idLot'};

        //retrieve the company-wide inventory for the lots of the identified products
        map<Id,cube> mapCube = new map<Id,cube>();
        for(gcInventoryMovementCube_Report.cube invCube : gcInventoryMovementCube_Report.inventoryAggRes(mapFilters,listGroupBy))
        {
            cube cube = new cube();
            cube.qtyOtherWhs = invCube.qty;
            mapCube.put(invCube.idLot,cube);
        }

        mapFilters.put('idWarehouse', new list<string>{xfr.Warehouse_From__c});
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
                mapCube.put(invCube.idLot,cube);
            }
        }

        //identify lots that are already included in the transfer
        for(AcctSeedERP__Outbound_Inventory_Movement__c move :
                [SELECT Lot__c
                 FROM AcctSeedERP__Outbound_Inventory_Movement__c
                 WHERE Inventory_Transfer__c =:idTransfer
                   AND Lot__c IN :mapCube.keySet()])
        {
            mapCube.get(move.Lot__c).boolAlreadyIncluded = true;
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

            listJSON.add(m);
        }
        
        return listJSON;
    }

    @RemoteAction
    public static string addMove(Id idTransfer, Id idLot)
    {
        Inventory_Transfer__c xfr = [SELECT Id, Outbound_Date__c, Warehouse_From__c FROM Inventory_Transfer__c WHERE Id =:idTransfer][0];

        String idBalance;

        //find an inventory balance for this lot, in this warehouse
        map<string,list<string>> mapFilters = new map<string,list<string>>();
        mapFilters.put('idLot', new list<string>{idLot});
        mapFilters.put('dateThru', new list<string>{xfr.Outbound_Date__c.format()});
        mapFilters.put('idWarehouse', new list<string>{xfr.Warehouse_From__c});

        list<string> listGroupBy = new list<string>{'idBalance'};

        for(gcInventoryMovementCube_Report.cube invCube : gcInventoryMovementCube_Report.inventoryAggRes(mapFilters,listGroupBy))
		{
            if(invCube.qty > 0)
            {
                idBalance = invCube.idBalance;
                break;
            }
        }

        if(idBalance == null) return '';

        Id idGLDebit = [SELECT AcctSeedERP__Product__r.AcctSeed__Inventory_GL_Account__c FROM AcctSeedERP__Inventory_Balance__c WHERE Id = :idBalance][0].AcctSeedERP__Product__r.AcctSeed__Inventory_GL_Account__c;

        AcctSeedERP__Outbound_Inventory_Movement__c move = new AcctSeedERP__Outbound_Inventory_Movement__c
        (
            AcctSeedERP__Debit_GL_Account__c = idGLDebit,
            AcctSeedERP__Inventory_Balance__c = idBalance,
            AcctSeedERP__Movement_Date__c = xfr.Outbound_Date__c,
            AcctSeedERP__Quantity__c = 1,
            AcctSeedERP__Type__c = 'Non-Accounting',
            AcctSeedERP__Unit_Cost__c = 0,
            Cost_Override__c = true,
            Inventory_Transfer__c = idTransfer,
            Lot__c = idLot
        );

        insert move;

        //return retrieveOutboundMoves(move.Id)[0];
        return '';
    }

    private class cube{
        Decimal qtyThisWhs{get;set;}
        Decimal qtyOtherWhs{get;set;}
        Boolean boolAlreadyIncluded{get;set;}

        private cube()
        {
            qtyThisWhs = 0;
            qtyOtherWhs = 0;
            boolAlreadyIncluded = false;
        }
    }
}