global with sharing class gcAgedAP{
    
    global gcAgedAP(ApexPages.standardController ctrl){}
    global gcAgedAP(gcAccountingPeriod c){}
    global gcAgedAP(){}

    @RemoteAction @ReadOnly
    global static map<Id,cube> retrieveAgedAp(string idPeriod, string strAgeMode, list<string> listIdPayee)
    {
        set<Id> setIdPayee = new set<Id>();
        map<Id,cube> mapCube = new map<Id,cube>();
        map<Id,cube> mapCubePayee = new map<Id,cube>();

        Id idDummy = Id.valueOf('001000000000000000');

        if(strAgeMode != 'dueDate') strAgeMode = 'issueDate';

        //retrieve all periods prior to and including the selected period
        AcctSeed__Accounting_Period__c period = [SELECT Id, AcctSeed__Start_Date__c, AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c WHERE Id = :idPeriod][0];

        set<Id> setIdPeriods = new set<Id>();
        for(AcctSeed__Accounting_Period__c p : [SELECT Id FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c <= :period.AcctSeed__Start_Date__c])
        {
            setIdPeriods.add(p.Id);
        }

        //retrieve the AP control account
        Id idGLAP = [SELECT AcctSeed__AP_Control_GL_Account__c FROM AcctSeed__Accounting_Settings__c ORDER BY CreatedDate][0].AcctSeed__AP_Control_GL_Account__c;

        list<sObject> listAggObj = new list<sObject>();

        if(listIdPayee != null && listIdPayee.size() > 0)
        {
            for(string idPayee : listIdPayee)
            {
                if(idPayee == null) idPayee = idDummy;
                setIdPayee.add(Id.valueOf(idPayee));
                mapCubePayee.put(Id.valueOf(idPayee), new cube());
            }
        }
        setIdPayee.remove(null);
        mapCubePayee.remove(null);

        String soql;
        soql  = ' SELECT ';
        soql += ' AcctSeed__Account__c idAccount, ';
        soql += ' AcctSeed__Employee__c idEmployee, ';
        soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c idContactAP, ';
        soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c idEmployeeAP, ';        
        soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Contact__c idContactCD, ';
        soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Employee__c idEmployeeCD, ';        
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c idAccountSre, ';
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c idContactSre, ';
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c idEmployeeSre, ';                
        soql += ' sum(AcctSeed__Amount__c) amt ';
        soql += ' FROM AcctSeed__Transaction__c ';
        soql += ' WHERE AcctSeed__GL_Account__c = :idGLAP ';
        soql += ' AND AcctSeed__Accounting_Period__c IN :setIdPeriods ';
        soql += ' AND (AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0) ';

        if(setIdPayee.size() > 0)
        {
            soql += ' AND ( ';
            soql += ' AcctSeed__Account__c IN :setIdPayee OR ';
            soql += ' AcctSeed__Employee__c IN :setIdPayee OR ';    
            soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c IN :setIdPayee OR ';
            soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c IN :setIdPayee OR ';         
            soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Contact__c IN :setIdPayee OR ';
            soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Employee__c IN :setIdPayee OR ';         
            soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c IN :setIdPayee OR ';
            soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c IN :setIdPayee OR ';
            soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c IN :setIdPayee ';

            if(setIdPayee.contains(idDummy))
            {
                soql += ' OR (';
                soql += ' AcctSeed__Account__c  = null AND ';
                soql += ' AcctSeed__Employee__c = null AND ';
                soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c = null AND ';
                soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c = null AND ';                
                soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Contact__c = null AND ';
                soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Employee__c = null AND ';                
                soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c = null AND ';
                soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c = null AND ';
                soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c = null) ';
            }

            soql += ' )';
        }

        soql += ' GROUP BY ';
        soql += ' AcctSeed__Account__c, ';
        soql += ' AcctSeed__Employee__c, ';
        soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c, ';
        soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c, ';      
        soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Contact__c, ';
        soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Employee__c, ';
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c, ';
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c, ';
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c ';

        soql += ' HAVING (sum(AcctSeed__Amount__c) < 0 OR sum(AcctSeed__Amount__c) > 0)';

        listAggObj.addAll(Database.query(soql));

        for(sObject aggRes : listAggObj)
        {
            Id idPayee = (Id)aggRes.get('idAccount');
            if(idPayee == null)
               idPayee = (Id)aggRes.get('idEmployee');
            if(idPayee == null)
               idPayee = (Id)aggRes.get('idEmployeeAP');
            if(idPayee == null)
               idPayee = (Id)aggRes.get('idEmployeeCD');
            if(idPayee == null)
               idPayee = (Id)aggRes.get('idContactAP');
            if(idPayee == null)
               idPayee = (Id)aggRes.get('idContactCD');
            if(idPayee == null)
               idPayee = (Id)aggRes.get('idAccountSre');
            if(idPayee == null)
               idPayee = (Id)aggRes.get('idContactSre');
            if(idPayee == null)
               idPayee = (Id)aggRes.get('idEmployeeSre');
            if(idPayee == null)
               idPayee = idDummy;

            Decimal amt = (Decimal)aggRes.get('amt');

            if(!mapCubePayee.containsKey(idPayee))
            {
                mapCubePayee.put(idPayee, new cube());
            }
            mapCubePayee.get(idPayee).decBalance -= amt;
        }

        //include any payees having a non-zero balance, in addition to any payees that were explicitly requested
        for(Id idPayee : mapCubePayee.keySet())
        {
            if(mapCubePayee.get(idPayee).decBalance.setScale(2) != 0)
                setIdPayee.add(idPayee);
        }

        soql  = ' SELECT Id, ';
        soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__c, ';
        soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c, ';
        soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c, ';        
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__c, ';
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c, ';
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c, ';
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c, ';              
        soql += ' AcctSeed__Cash_Disbursement__c, ';
        soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Contact__c, ';
        soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Employee__c, ';        
        soql += ' AcctSeed__Account__c, ';
        soql += ' AcctSeed__Employee__c, ';
        soql += ' AcctSeed__Amount__c ';
        soql += ' FROM AcctSeed__Transaction__c ';
        soql += ' WHERE AcctSeed__GL_Account__c = :idGLAP ';
        soql += ' AND AcctSeed__Accounting_Period__c IN : setIdPeriods ';
        soql += ' AND (AcctSeed__Amount__c < 0 OR AcctSeed__Amount__c > 0) ';
        soql += ' AND ( ';
        soql += ' AcctSeed__Account__c  IN :setIdPayee OR ';
        soql += ' AcctSeed__Employee__c IN :setIdPayee OR  ';
        soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c IN : setIdPayee OR ';
        soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c IN : setIdPayee OR ';        
        soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Contact__c IN :setIdPayee OR ';
        soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Employee__c IN :setIdPayee OR ';        
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c IN :setIdPayee OR ';                       
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c IN :setIdPayee OR ';
        soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c IN :setIdPayee ';

            if(setIdPayee.contains(idDummy))
            {
                soql += ' OR (';
                soql += ' AcctSeed__Account__c  = null AND ';
                soql += ' AcctSeed__Employee__c = null AND ';
                soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c = null AND ';
                soql += ' AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c = null AND ';
                soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Contact__c = null AND ';
                soql += ' AcctSeed__Cash_Disbursement__r.AcctSeed__Employee__c = null AND '; 
                soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c = null AND ';
                soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c = null AND ';
                soql += ' AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c = null) ';
            }

        soql += ' ) ';

        map<Id,Id> mapSreToAp = new map<Id,Id>();

        for(AcctSeed__Transaction__c txn : Database.query(soql))
        {
            Id idRecord;
            Id idPayee = txn.AcctSeed__Account__c;
            if(idPayee == null)
               idPayee = txn.AcctSeed__Employee__c;

            if(txn.AcctSeed__Account_Payable_Line__c != null)
            {
                idRecord = txn.AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__c;
                if(idPayee == null)
                   idPayee = txn.AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c;
                if(idPayee == null)
                   idPayee = txn.AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c;                   
            }
            else if(txn.AcctSeed__Cash_Disbursement__c != null)
            {
                idRecord = txn.AcctSeed__Cash_Disbursement__c;
                if(idPayee == null)
                   idPayee = txn.AcctSeed__Cash_Disbursement__r.AcctSeed__Contact__c;
                if(idPayee == null)
                   idPayee = txn.AcctSeed__Cash_Disbursement__r.AcctSeed__Employee__c;              
            }
            else if(txn.AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__c != null)
            {
                mapSreToAp.put(txn.AcctSeed__Scheduled_Revenue_Expense__c, txn.AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__c);
                idRecord = txn.AcctSeed__Scheduled_Revenue_Expense__c;
                if(idPayee == null)
                   idPayee = txn.AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c;
                if(idPayee == null)
                   idPayee = txn.AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Contact__c;
                if(idPayee == null)
                   idPayee = txn.AcctSeed__Scheduled_Revenue_Expense__r.AcctSeed__Account_Payable__r.AcctSeed__Employee__c;
            }
            else
            {
                idRecord = txn.Id;
            }

            if(idPayee == null) idPayee = idDummy;

            if(!mapCube.containsKey(idRecord))
            {
                mapCube.put(idRecord, new cube(idPayee));
            }
            mapCube.get(idRecord).decBalance -= txn.AcctSeed__Amount__c;
        }

        //apply the AP credit memos against the AP balances
        for(AcctSeed__AP_Credit_Memo__c apc : 
                [SELECT AcctSeed__Account_Payable_Invoice__c, 
                        AcctSeed__Account_Payable_Credit_Memo__c, 
                        AcctSeed__Amount__c
                 FROM AcctSeed__AP_Credit_Memo__c
                 WHERE AcctSeed__Account_Payable_Invoice__c IN : mapCube.keySet()
                   AND AcctSeed__Account_Payable_Credit_Memo__c IN : mapCube.keySet()])
        {
            mapCube.get(apc.AcctSeed__Account_Payable_Invoice__c).decBalance += apc.AcctSeed__Amount__c;
            mapCube.get(apc.AcctSeed__Account_Payable_Credit_Memo__c).decBalance -= apc.AcctSeed__Amount__c;    
        }

        //apply the AP disbursements against the AP balances
        for(AcctSeed__AP_Disbursement__c apd : 
                [SELECT AcctSeed__Account_Payable__c,
                        AcctSeed__Cash_Disbursement__c,
                        AcctSeed__Paid_Amount__c, 
                        AcctSeed__Discount_Amount__c
                 FROM AcctSeed__AP_Disbursement__c
                 WHERE AcctSeed__Account_Payable__c IN : mapCube.keySet()
                   AND AcctSeed__Cash_Disbursement__c IN :mapCube.keySet()])
        {
            mapCube.get(apd.AcctSeed__Account_Payable__c).decBalance -= (apd.AcctSeed__Paid_Amount__c + apd.AcctSeed__Discount_Amount__c);
            mapCube.get(apd.AcctSeed__Cash_Disbursement__c).decBalance += (apd.AcctSeed__Paid_Amount__c + apd.AcctSeed__Discount_Amount__c);
        }

        //transfer the SRE balance to the parent AP balance
        //the SRE that looks up to an AP is one way to remove an AP from the AP aging report
        for(Id idSre : mapSreToAp.keySet())
        {
            Id idAp = mapSreToAp.get(idSRE);
            if(mapCube.containsKey(idSre) && mapCube.containsKey(idAp))
            {
                mapCube.get(idAp).decBalance += mapCube.get(idSre).decBalance;
                mapCube.get(idSre).decBalance = 0;
            }
        }

        set<Id> setIdRemove = new set<Id>();
        for(Id idRecord : mapCube.keySet())
        {
            if(mapCube.get(idRecord).decBalance.setScale(2) == 0)
                setIdRemove.add(idRecord);
            else
                mapCube.get(idRecord).decCurrent = mapCube.get(idRecord).decBalance;
        }
        for(Id idRecord : setIdRemove)
        {
            mapCube.remove(idRecord);
        }

        Date dateAsOf = period.AcctSeed__End_Date__c;
        //if the report is being run for the current period, adjust the as-of date to the current date
        if(date.today() >= period.AcctSeed__Start_Date__c && date.today() <= period.AcctSeed__End_Date__c)
            dateAsOf = date.today();

        //spread the balance out to different age groups
        for(AcctSeed__Account_Payable__c ap : 
                [SELECT Id, AcctSeed__Date__c, AcctSeed__Due_Date__c, AcctSeed__Total__c
                 FROM AcctSeed__Account_Payable__c
                 WHERE Id IN : mapCube.keySet()])
        {
            cube cube = mapCube.get(ap.Id);

            Date dateAP = ap.AcctSeed__Due_Date__c;
            if(strAgeMode == 'issueDate')
                 dateAP = ap.AcctSeed__Date__c;
            if(dateAP == null) dateAP = dateAsOf;

            Integer intAge = dateAp.daysBetween(dateAsOf);

            if(intAge > 90)
            {
                cube.dec91 += cube.decBalance;
                cube.decCurrent -= cube.decBalance;
            }
            else if(intAge > 60)
            {
                cube.dec61 += cube.decBalance;
                cube.decCurrent -= cube.decBalance;
            }
            else if(intAge > 30)
            {
                cube.dec31 += cube.decBalance;
                cube.decCurrent -= cube.decBalance;
            }
            else if(intAge > 0)
            {
                cube.dec01 += cube.decBalance;
                cube.decCurrent -= cube.decBalance;
            }

            if(ap.AcctSeed__Total__c != null)
                cube.decTotal = ap.AcctSeed__Total__c; 
        }

        return mapCube;
    }

    @RemoteAction @ReadOnly 
    global static map<Id,cube> summarizeByPayee(map<Id,cube> mapCubeRecord)
    {
        map<Id,cube> mapCubePayee = new map<Id,cube>();

        for(cube cubeRecord :mapCubeRecord.values())
        {
            Id idPayee = cubeRecord.idPayee;

            if(!mapCubePayee.containsKey(idPayee))
                mapCubePayee.put(idPayee, new cube(idPayee));

            cube cubePayee = mapCubePayee.get(idPayee);

            cubePayee.decTotal      += cubeRecord.decTotal;
            cubePayee.decBalance    += cubeRecord.decBalance;
            cubePayee.decCurrent    += cubeRecord.decCurrent;
            cubePayee.dec01         += cubeRecord.dec01;
            cubePayee.dec31         += cubeRecord.dec31;
            cubePayee.dec61         += cubeRecord.dec61;
            cubePayee.dec91         += cubeRecord.dec91;
        }

        return mapCubePayee;
    }

    @RemoteAction @ReadOnly 
    global static list<gcObj> retrieveAgedApSummary(string idPeriod, string strAgeMode)
    {
        map<Id,cube> mapCubePayee = summarizeByPayee(retrieveAgedAp(idPeriod, strAgeMode, null));
        map<Id,gcObj> mapObj = new map<Id,gcObj>();

        for(Id idPayee :mapCubePayee.keySet())
        {
            cube cube = mapCubePayee.get(idPayee);

            gcObj obj = new gcObj();

            obj.mapProperty.put('idPayee',idPayee);
            obj.mapProperty.put('payeeName',' ---none---');
            obj.mapProperty.put('dec91',String.valueOf(cube.dec91.setScale(6)));
            obj.mapProperty.put('dec61',String.valueOf(cube.dec61.setScale(6)));
            obj.mapProperty.put('dec31',String.valueOf(cube.dec31.setScale(6)));
            obj.mapProperty.put('dec01',String.valueOf(cube.dec01.setScale(6)));
            obj.mapProperty.put('decCurrent',String.valueOf(cube.decCurrent.setScale(6)));
            obj.mapProperty.put('decBalance',String.valueOf(cube.decBalance.setScale(6)));
            obj.mapProperty.put('decTotal',String.valueOf(cube.decTotal.setScale(6)));

            mapObj.put(idPayee,obj);        
        }

        for(Account a : [SELECT Id, Name FROM Account WHERE Id IN : mapObj.keySet()])
        {
            mapObj.get(a.Id).mapProperty.put('payeeName', a.Name);
        }

        for(User u : [SELECT Id, Name FROM User WHERE Id IN : mapObj.keySet()])
        {
            mapObj.get(u.Id).mapProperty.put('payeeName', u.Name);
        }

        for(Contact c : [SELECT Id, Name FROM Contact WHERE Id IN : mapObj.keySet()])
        {
            mapObj.get(c.Id).mapProperty.put('payeeName', c.Name);
        }

        return mapObj.values();
    }

    @RemoteAction @ReadOnly 
    global static list<gcObj> retrieveAgedApDetail(string idPeriod, string strAgeMode, list<string> listIdPayee)
    {
        map<Id,cube> mapCube = retrieveAgedAp(idPeriod, strAgeMode, listIdPayee);
        map<Id,gcObj> mapObj = new map<Id,gcObj>();

        for(Id idRecord :mapCube.keySet())
        {
            cube cube = mapCube.get(idRecord);

            gcObj obj = new gcObj();

            obj.mapProperty.put('idRecord',idRecord);
            obj.mapProperty.put('dec91',String.valueOf(cube.dec91.setScale(6)));
            obj.mapProperty.put('dec61',String.valueOf(cube.dec61.setScale(6)));
            obj.mapProperty.put('dec31',String.valueOf(cube.dec31.setScale(6)));
            obj.mapProperty.put('dec01',String.valueOf(cube.dec01.setScale(6)));
            obj.mapProperty.put('decCurrent',String.valueOf(cube.decCurrent.setScale(6)));
            obj.mapProperty.put('decBalance',String.valueOf(cube.decBalance.setScale(6)));
            obj.mapProperty.put('decTotal',String.valueOf(cube.decTotal.setScale(6)));

            mapObj.put(idRecord,obj);  
        }

        for(AcctSeed__Account_Payable__c ap : 
                [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Due_Date__c, AcctSeed__Payee__c
                 FROM AcctSeed__Account_Payable__c
                 WHERE Id IN : mapObj.keySet()])
        {
            gcObj obj = mapObj.get(ap.Id);
            obj.mapProperty.put('recordName',ap.Name);
            obj.mapProperty.put('payeeName',ap.AcctSeed__Payee__c);

            if(strAgeMode == 'issueDate' && ap.AcctSeed__Date__c != null)
                obj.mapProperty.put('recordDate',ap.AcctSeed__Date__c.format());
            else if(strAgeMode == 'dueDate' && ap.AcctSeed__Due_Date__c != null)
                obj.mapProperty.put('recordDate',ap.AcctSeed__Due_Date__c.format());
        }
        for(AcctSeed__Cash_Disbursement__c cd :
                [SELECT Id, Name, AcctSeed__Disbursement_Date__c, AcctSeed__Payee__c
                 FROM AcctSeed__Cash_Disbursement__c
                 WHERE Id IN :mapObj.keySet()])
        {
            gcObj obj = mapObj.get(cd.Id);
            obj.mapProperty.put('recordName',cd.Name);
            obj.mapProperty.put('payeeName',cd.AcctSeed__Payee__c);
            if(cd.AcctSeed__Disbursement_Date__c != null)
            obj.mapProperty.put('recordDate',cd.AcctSeed__Disbursement_Date__c.format());
        }
        for(AcctSeed__Scheduled_Revenue_Expense__c sre : 
                [SELECT Id, Name, AcctSeed__Accounting_Period__r.AcctSeed__End_Date__c, AcctSeed__Account2__r.Name
                 FROM AcctSeed__Scheduled_Revenue_Expense__c
                 WHERE Id IN :mapObj.keySet()])
        {
            gcObj obj = mapObj.get(sre.Id);
            obj.mapProperty.put('recordName',sre.Name);
            if(sre.AcctSeed__Account2__c != null)
                obj.mapProperty.put('payeeName',sre.AcctSeed__Account2__r.Name);

            if(sre.AcctSeed__Accounting_Period__c != null)
                obj.mapProperty.put('recordDate',sre.AcctSeed__Accounting_Period__r.AcctSeed__End_Date__c.format());
        }
        for(AcctSeed__Transaction__c txn :
                [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Account__r.Name
                 FROM AcctSeed__Transaction__c
                 WHERE Id IN :mapObj.keySet()])
        {
            gcObj obj = mapObj.get(txn.Id);
            obj.mapProperty.put('recordName',txn.Name);

            if(txn.AcctSeed__Account__c != null)
                obj.mapProperty.put('payeeName',txn.AcctSeed__Account__r.Name);

            if(txn.AcctSeed__Date__c != null)
            obj.mapProperty.put('recordDate',txn.AcctSeed__Date__c.format());            
        }

        return mapObj.values();
    }

    global class cube{

        global Decimal dec91{get;set;}
        global Decimal dec61{get;set;}
        global Decimal dec31{get;set;}
        global Decimal dec01{get;set;}
        global Decimal decCurrent{get;set;}
        global Decimal decBalance{get;set;}
        global Decimal decTotal{get;set;}

        global Id idPayee{get;set;}

        global void init()
        {
            dec91 = 0;
            dec61 = 0;
            dec31 = 0;
            dec01 = 0;
            decCurrent = 0;
            decBalance = 0;
            decTotal = 0;
        }
        global cube()
        {
            init();
        }
        global cube(Id pIdPayee)
        {
            init();
            idPayee = pIdPayee;
        }
    }
}