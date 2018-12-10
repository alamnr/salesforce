global with sharing class gcBalanceSheet {

	global gcBalanceSheet(gcAccountingPeriod c){}
	global gcBalanceSheet(){}

	@RemoteAction @ReadOnly
	global static grid retrieveBalanceSheet(Id pIdPeriod)
	{
		map<String,row> mapRow = new map<String,Row>();

		set<Id> setIdPeriodsThisYear = new set<Id>();
		set<Id> setIdPeriods = new set<Id>();
		AcctSeed__Accounting_Period__c period = [SELECT Id, Name, AcctSeed__Start_Date__c, AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c WHERE Id =:pIdPeriod];
		for(AcctSeed__Accounting_Period__c p : [SELECT Id, Name FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__End_Date__c <= :period.AcctSeed__End_Date__c])
		{
			setIdPeriods.add(p.Id);
			
			if(p.Name.LEFT(4) == period.Name.LEFT(4))
				 setIdPeriodsThisYear.add(p.Id);
		}

		Id idLedger = [SELECT Id FROM AcctSeed__Ledger__c WHERE AcctSeed__Type__c = 'Transactional' LIMIT 1][0].Id;
		map<Id,AcctSeed__GL_Account__c> mapGL = new map<Id,AcctSeed__GL_Account__c>
			([SELECT Id, Name, AcctSeed__Type__c, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c
			 FROM AcctSeed__GL_Account__c
			 WHERE AcctSeed__Type__c = 'Balance Sheet']);

		//get the closing balance for each GL account
		for(AggregateResult aggRes : 
				[SELECT AcctSeed__GL_Account__c idGL,
				 SUM(AcctSeed__Transaction_Amount__c) sumAmount
				 FROM AcctSeed__Financial_Cube__c
				 WHERE AcctSeed__Ledger__c = :idLedger
				   AND AcctSeed__GL_Account__c  IN :mapGL.keySet()
				   AND AcctSeed__Accounting_Period__c IN :setIdPeriods				   
				   AND (AcctSeed__Transaction_Amount__c < 0 OR AcctSeed__Transaction_Amount__c > 0)
				   AND AcctSeed__Cube_Type__c = 'Period'
				 GROUP BY AcctSeed__GL_Account__c])
		{
			Id idGL = (Id)aggRes.get('idGL');
			Decimal decAmount = (Decimal)aggRes.get('sumAmount');

			if(!mapRow.containsKey(idGL))
				mapRow.put(idGL, new row(idGL));
			
			mapRow.get(idGL).mapRowDataDec.put('periodClose',decAmount);
			mapRow.get(idGL).mapRowDataDec.put('yearOpen',decAmount);
		}	

		//get the current year amounts for each GL account
		for(AggregateResult aggRes : 
				[SELECT AcctSeed__GL_Account__c idGL,
				 SUM(AcctSeed__Transaction_Amount__c) sumAmount
				 FROM AcctSeed__Financial_Cube__c
				 WHERE AcctSeed__Ledger__c = :idLedger
				   AND AcctSeed__GL_Account__c  IN :mapGL.keySet()
				   AND AcctSeed__Accounting_Period__c IN :setIdPeriodsThisYear			   
				   AND (AcctSeed__Transaction_Amount__c < 0 OR AcctSeed__Transaction_Amount__c > 0)
				   AND AcctSeed__Cube_Type__c = 'Period'
				 GROUP BY AcctSeed__GL_Account__c])
		{
			Id idGL = (Id)aggRes.get('idGL');
			Decimal decAmount = (Decimal)aggRes.get('sumAmount');

			if(!mapRow.containsKey(idGL))
				mapRow.put(idGL, new row(idGL));
			
			mapRow.get(idGL).mapRowDataDec.put('thisYear',decAmount);
			mapRow.get(idGL).mapRowDataDec.put('yearOpen',mapRow.get(idGL).mapRowDataDec.get('yearOpen') - decAmount);
		}	

		//create the retained earnings row
		Id idGLRE = [SELECT AcctSeed__Retained_Earnings_GL_Account__c FROM AcctSeed__Accounting_Settings__c][0].AcctSeed__Retained_Earnings_GL_Account__c;
		AcctSeed__GL_Account__c glRE = mapGL.get(idGLRE);
		mapRow.put('RetainedEarnings',new row('RetainedEarnings'));
		row re = mapRow.get('RetainedEarnings');
		re.mapRowDataStr.put('glName','Retained Earnings');
		re.mapRowDataStr.put('glSubType1',glRE.AcctSeed__Sub_Type_1__c);
		re.mapRowDataStr.put('glSubType2',glRE.AcctSeed__Sub_Type_2__c);
		re.mapRowDataDec.put('periodClose',0);
		re.mapRowDataDec.put('thisYear',0);
		re.mapRowDataDec.put('yearOpen',0);

		//collect the set of Ids for the profit & loss accounts
		set<Id> setIdGLPL = new set<Id>();
		for(AcctSeed__GL_Account__c gl : [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Type__c IN ('Revenue','Expense')])
		{
			setIdGLPL.add(gl.Id);
		}


		//calculate the retained earnings
		for(AggregateResult aggRes : 
				[SELECT AcctSeed__Accounting_Period__c idPeriod,
				 SUM(AcctSeed__Transaction_Amount__c) sumAmount
				 FROM AcctSeed__Financial_Cube__c
				 WHERE AcctSeed__Ledger__c = :idLedger
				   AND AcctSeed__GL_Account__c  IN :setIdGLPL
				   AND AcctSeed__Accounting_Period__c IN :setIdPeriods			   
				   AND (AcctSeed__Transaction_Amount__c < 0 OR AcctSeed__Transaction_Amount__c > 0)
				   AND AcctSeed__Cube_Type__c = 'Period'
				 GROUP BY AcctSeed__Accounting_Period__c])
		{
			Id idPeriod = (Id)aggRes.get('idPeriod');
			Decimal decAmount = (Decimal)aggRes.get('sumAmount');

			if(setIdPeriodsThisYear.contains(idPeriod))
			{
				re.mapRowDataDec.put('thisYear',re.mapRowDataDec.get('thisYear') + decAmount);
			}
			re.mapRowDataDec.put('periodClose',re.mapRowDataDec.get('periodClose') + decAmount);
		}
		re.mapRowDataDec.put('yearOpen',re.mapRowDataDec.get('periodClose') - re.mapRowDataDec.get('thisYear'));

		//cycle over the rows, and apply the GL fields
		for(String key : mapRow.keySet())
		{
			row r = mapRow.get(key);
			if(r.mapRowDataDec.get('yearOpen') == 0 && r.mapRowDataDec.get('thisYear') == 0 && r.mapRowDataDec.get('periodClose') == 0){
				mapRow.remove(key);
				continue;
			}
			if(key != 'RetainedEarnings' && mapGL.containsKey(key))
			{
				r.mapRowDataStr.put('glName', mapGL.get(key).Name);
				if(mapGL.get(key).AcctSeed__Sub_Type_1__c != null)
				r.mapRowDataStr.put('glSubType1', mapGL.get(key).AcctSeed__Sub_Type_1__c);
				if(mapGL.get(key).AcctSeed__Sub_Type_1__c != null)
				r.mapRowDataStr.put('glSubType2', mapGL.get(key).AcctSeed__Sub_Type_2__c);
			}
			r.convertAllToString();			
		}

		list<row> listRow = new list<row>();
		listRow.addAll(mapRow.values());
		listRow.sort();

		grid grid = new grid();
		grid.colModel.add(new col('glSubType1',''));
		grid.colModel.add(new col('glSubType2',''));
		grid.colModel.add(new col('glName','GL Account'));
		grid.colModel.add(new col('yearOpen','Year Open'));
		grid.colModel.add(new col('thisYear','This Year'));
		grid.colModel.add(new col('periodClose','Period Close'));

		//convert wrapped row to JSON array
		for(row r : listRow)
		{
			grid.data.add(r.mapRowDataStr);
		}

		return grid;
	}

	global class grid{

		global list<col> colModel{get;set;}
		global list<map<String,String>> data{get;set;}

		global grid()
		{
			colModel = new list<col>();
			data = new list<map<String,String>>();
		}
	}

	global class col{

		global String dataIndx{get;set;}
		global String title{get;set;}

		global map<String,String> mapProperty{get;set;} //this is a map of additional ad-hoc properties for a column, that will be needed by JavaScript in the browser
	
		global map<String,col> mapCol{get;set;} //a map of the subcolumns for a primary column
		global list<col> colModel{get;set;} //an ordered list of the subcolumns for a primary column

		global void init()
		{
			mapProperty = new map<String,String>();

			mapCol = new map<String,col>();
			colModel = new list<col>();
		}

		global col(String pDataIndx, String pTitle)
		{
			init();

			dataIndx = pDataIndx;
			title = pTitle;
		}

	}

	global class row implements Comparable{

		global map<String,String>  mapRowDataStr{get;set;}

		global map<String,Boolean> mapRowDataBool{get;set;}		
		global map<String,Decimal> mapRowDataDec{get;set;}
		global map<String,Integer> mapRowDataInt{get;set;}

		global void init()
		{
			mapRowDataStr 	= new map<String,String>();

			mapRowDataBool	= new map<String,Boolean>();			
			mapRowDataDec 	= new map<String,Decimal>();
			mapRowDataInt 	= new map<String,Integer>();
		}
		global row()
		{
			init();
		}
		global row(String idGL)
		{
			init();

			mapRowDataStr.put('idGL',idGL);
			mapRowDataStr.put('glSubType1','');
			mapRowDataStr.put('glSubType2','');
			mapRowDataDec.put('yearOpen',0);
			mapRowDataDec.put('thisYear',0);
			mapRowDataDec.put('periodClose',0);
		}

		global void convertAllToString()
		{
			//convert all of the decimals to strings
			for(String key :mapRowDataDec.keySet())
			{
				mapRowDataStr.put(key,String.valueOf(mapRowDataDec.get(key)));
			}
			//convert all of the integers to strings
			for(String key :mapRowDataInt.keySet())
			{
				mapRowDataStr.put(key,String.valueOf(mapRowDataInt.get(key)));
			}			
			//convert the boolean values to strings
			for(String key :mapRowDataBool.keySet())
			{
				if(mapRowDataBool.get(key))
					mapRowDataStr.put(key,'true');
				else
					mapRowDataStr.put(key,'false');
			}
		}
        //COMPARABLE INTERFACE FOR LIST SORTING
        global Integer compareTo(Object pCmp){          
            row cmp = (row)pCmp;

            //used to sort variance
            String glName 		= mapRowDataStr.get('glName');
            String glSubType1 	= mapRowDataStr.get('glSubType1');
            String glSubType2 	= mapRowDataStr.get('glSubType2');

            String CglName 		= cmp.mapRowDataStr.get('glName');
            String CglSubType1 	= cmp.mapRowDataStr.get('glSubType1');
            String CglSubType2 	= cmp.mapRowDataStr.get('glSubType2');


			if(glSubType1 != CglSubType1)
			{
				if(glSubType1 == 'Assets') return -1;
				if(CglSubType1 == 'Assets') return 1;
				if(glSubType1 == 'Equity') return 1;
				if(CglSubType1 == 'Equity') return -1;
				//the sub type must therefore be liability, which should be placed after assets
				if(CglSubType1 == 'Assets') return 1;
				return -1;
			}
			if(glSubType1 == 'Assets')
			{
				if(glSubType2 == CglSubType2)
				{
					if(glName < CglName) return -1;
					if(glName > CglName) return 1;
					return -1;
				}
				if(glSubType2 == 'Current Assets') return -1;
				if(CglSubType2 == 'Current Assets') return 1;
				if(glSubType2 == 'Accumulated Depreciation') return 1;
				if(CglSubType2 == 'Accumulated Depreciation') return -1;
				if(glSubType2 < CglSubType2) return -1;
				return 1;
			}
			if(glSubType1 == 'Liabilities')
			{
				if(glSubType2 == CglSubType2)
				{
					if(glName < CglName) return -1;
					if(glName > CglName) return 1;
					return -1;
				}
				if(glSubType2 < CglSubType2) return -1;
				return 1;
			}
			if(glSubType1 == 'Equity')
			{
				if(glSubType2 == CglSubType2)
				{
					if(glName < CglName) return -1;
					if(glName > CglName) return 1;
					return -1;
				}
				if(glSubType2 < CglSubType2) return -1;
				return 1;
			}
			return 1;
        } 
	}
}