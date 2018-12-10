global with sharing class gcIncomeStatement {

	global gcIncomeStatement(ApexPages.StandardController c){}
	global gcIncomeStatement(gcAccountingPeriod c){}
	global gcIncomeStatement(){}

	@RemoteAction @ReadOnly
	global static grid retrieveIncomeStatement(Id pIdPeriod)
	{
		Id idLedger = [SELECT Id FROM AcctSeed__Ledger__c WHERE AcctSeed__Type__c = 'Transactional'][0].Id;

		AcctSeed__Accounting_Period__c period = new AcctSeed__Accounting_Period__c(); //the period for which the income statement is being run
		for(AcctSeed__Accounting_Period__c p :
				[SELECT Id, Name, AcctSeed__Start_Date__c, AcctSeed__End_Date__c
				 FROM AcctSeed__Accounting_Period__c 
				 WHERE Id = : pIdPeriod])
		{
			period = p;
		}

		map<Id,AcctSeed__Accounting_Period__c> mapPeriod = new map<Id,AcctSeed__Accounting_Period__c>();
		list<AcctSeed__Accounting_Period__c> listPeriod = new list<AcctSeed__Accounting_Period__c>();

		map<String,list<Id>> mapIntervalToPeriods = new map<String,list<Id>>();
		map<Id,String> mapPeriodToInterval = new map<Id,String>();

		list<String> listIntervalName = new list<String>{'Q1','Q2','Q3','Q4'};
		for(String strInterval : listIntervalName)
		{
			mapIntervalToPeriods.put(strInterval, new list<Id>());
		}

		for(AcctSeed__Accounting_Period__c p: 
			[SELECT Id, Name, AcctSeed__Start_Date__c, AcctSeed__End_Date__c 
			 FROM AcctSeed__Accounting_Period__c 
			 WHERE AcctSeed__End_Date__c < = :period.AcctSeed__End_Date__c 
			 ORDER BY AcctSeed__End_Date__c])
		{
			if(p.Name.LEFT(4) == period.Name.LEFT(4))
			{
				Integer intPeriod = Integer.valueOf(p.Name.RIGHT(2));
				String strQuarter;
				
					 if(intPeriod <= 3) strQuarter = 'Q1';
				else if(intPeriod <= 6) strQuarter = 'Q2';
				else if(intPeriod <= 9) strQuarter = 'Q3';
				else strQuarter = 'Q4';
					
				mapPeriod.put(p.Id,p);
				listPeriod.add(p);

				mapIntervalToPeriods.get(strQuarter).add(p.Id);
				mapPeriodToInterval.put(p.Id,strQuarter);
			}
		}

		//collect the GL accounts, and prepare the row map
		map<Id,AcctSeed__GL_Account__c> mapGL = new map<Id,AcctSeed__GL_Account__c>();
		map<String,row> mapRow = new map<String,row>();
		for(AcctSeed__GL_Account__c gl : 
			[SELECT Id, Name, AcctSeed__Type__c, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c
			 FROM AcctSeed__GL_Account__c 
			 WHERE AcctSeed__Type__c IN ('Revenue','Expense')])
		{
			mapGL.put(gl.Id, gl);

			row row = new row();
			for(Id idPeriod : mapPeriod.keySet())
			{
				row.mapDecimal.put(idPeriod,0);
			}
			for(String intervalName : listIntervalName)
			{
				row.mapDecimal.put(intervalName,0);
			}
			row.mapDecimal.put('YTD',0);
			row.mapProperty.put('idGL',gl.Id);
			mapRow.put(gl.Id, row);
		}


		list<AggregateResult> listAggRes = new list<AggregateResult>();
		for(AggregateResult aggRes :
				[SELECT AcctSeed__GL_Account__c idGL, 
						AcctSeed__Accounting_Period__c idPeriod,
						sum(AcctSeed__Transaction_Amount__c) amt 
				 FROM AcctSeed__Financial_Cube__c
				 WHERE AcctSeed__Ledger__c = :idLedger
				   AND AcctSeed__GL_Account__c IN :mapGL.keySet()
				   AND AcctSeed__Accounting_Period__c IN :mapPeriod.keySet()				   
				   AND AcctSeed__Cube_Type__c = 'Period'
				   AND (AcctSeed__Transaction_Amount__c > 0 OR AcctSeed__Transaction_Amount__c < 0)
				 GROUP BY AcctSeed__GL_Account__c, AcctSeed__Accounting_Period__c])
		{
			Id idGL = (Id)aggRes.get('idGL');
			Id idPeriod = (Id)aggRes.get('idPeriod');
			Decimal amt = (Decimal)aggRes.get('amt');

			row row = mapRow.get(idGL);
			row.mapDecimal.put(idPeriod, amt);

			row.mapDecimal.put('YTD',row.mapDecimal.get('YTD') + amt);

			String strQuarter = mapPeriodToInterval.get(idPeriod);
			row.mapDecimal.put(strQuarter,row.mapDecimal.get(strQuarter) + amt);
		}

		//if a row in mapRow had net zero value in all periods, remove it
		for(Id idGL : mapGL.keySet()){
			row row = mapRow.get(idGL);
			Boolean hasAmount = false;
			for(Decimal amt : row.mapDecimal.values())
			{
				if(amt != 0)
				{
					hasAmount = true;
					break;
				}
			}
			if(!hasAmount){
				mapRow.remove(idGL);
			}
		}

		//cycle over the remaining (i.e. non-zero) rows, and apply the GL fields
		for(Id idGL : mapRow.keySet())
		{
			row row = mapRow.get(idGL);
			AcctSeed__GL_Account__c gl = mapGL.get(idGL);

			row.mapProperty.put('glType', gl.AcctSeed__Type__c);
			row.mapProperty.put('glSubType1', gl.AcctSeed__Sub_Type_1__c);
			row.mapProperty.put('glName', gl.Name);

			//negate the revenue; positive revenue is a credit; credits are stored as negative transaction amounts
			if(gl.AcctSeed__Type__c == 'Revenue'){
				for(String strInterval : row.mapDecimal.keySet()){
					row.mapDecimal.put(strInterval, row.mapDecimal.get(strInterval) * (-1));
				}
			}

			row.convertAllToString();
		}

		list<row> listRow = new list<row>();
		listRow.addAll(mapRow.values());
		listRow.sort();



		list<col> listCol = new list<col>();
		//add the identifying columns
		listCol.add(new col('glType',''));
		listCol.add(new col('glSubType1',''));
		listCol.add(new col('glName','GL Account'));

		//add the period columns
		for(AcctSeed__Accounting_Period__c p : listPeriod)
		{
			col col = new col(p.Id,p.Name);

			col.mapProperty.put('idPeriodFrom',p.Id);
			col.mapProperty.put('periodFromName',p.Name);
			col.mapProperty.put('periodFromDate',p.AcctSeed__Start_Date__c.format());

			col.mapProperty.put('idPeriodThru',p.Id);
			col.mapProperty.put('periodThruName',p.Name);
			col.mapProperty.put('periodThruDate',p.AcctSeed__Start_Date__c.format());

			col.mapProperty.put('gColType','period');

			listCol.add(col);
		}

		//add the interval columns
		for(String strInterval : listIntervalName)
		{
			col col = new col(strInterval,strInterval);

			AcctSeed__Accounting_Period__c periodFrom = new AcctSeed__Accounting_Period__c();
			AcctSeed__Accounting_Period__c periodThru = new AcctSeed__Accounting_Period__c();

			list<Id> listIntervalPeriods = mapIntervalToPeriods.get(strInterval);
			if(listIntervalPeriods.size() > 0)
			{
				periodFrom = mapPeriod.get(listIntervalPeriods[0]);
				periodThru = mapPeriod.get(listIntervalPeriods[listIntervalPeriods.size() - 1]);

				col.mapProperty.put('idPeriodFrom',periodFrom.Id);
				col.mapProperty.put('periodFromName',periodFrom.Name);
				col.mapProperty.put('periodFromDate',periodFrom.AcctSeed__Start_Date__c.format());

				col.mapProperty.put('idPeriodThru',periodThru.Id);
				col.mapProperty.put('periodThruName',periodThru.Name);
				col.mapProperty.put('periodThruDate',periodThru.AcctSeed__End_Date__c.format());

				col.mapProperty.put('gColType','quarter');

				listCol.add(col);
			}
			
		}

		//add the YTD column
		if(listPeriod.size() > 0)
		{
			col col = new col('YTD',period.Name.LEFT(4));

			AcctSeed__Accounting_Period__c periodFrom = listPeriod[0];
			AcctSeed__Accounting_Period__c periodThru = listPeriod[listPeriod.size() - 1];

			col.mapProperty.put('idPeriodFrom',periodFrom.Id);
			col.mapProperty.put('periodFromName',periodFrom.Name);
			col.mapProperty.put('periodFromDate',periodFrom.AcctSeed__Start_Date__c.format());

			col.mapProperty.put('idPeriodThru',periodThru.Id);
			col.mapProperty.put('periodThruName',periodThru.Name);
			col.mapProperty.put('periodThruDate',periodThru.AcctSeed__End_Date__c.format());

			listCol.add(col);
		}

		grid grid = new grid();

		//convert wrapped row to JSON array
		for(row row : listRow)
		{
			grid.data.add(row.mapProperty);
		}
		for(col col : listCol)
		{
			grid.colModel.add(col.mapProperty);
		}

		return grid;
	}


	global class grid{

		global list<map<String,String>> colModel{get;set;}
		global list<map<String,String>> data{get;set;}

		global grid()
		{
			colModel = new list<map<String,String>>();
			data 	 = new list<map<String,String>>();
		}
	}

	global class col{

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

			mapProperty.put('dataIndx',pDataIndx);
			mapProperty.put('title',pTitle);
		}
	}

	global class row implements Comparable{

		global map<String,String>  mapProperty{get;set;}

		global map<String,Boolean> mapBoolean{get;set;}
		global map<String,Decimal> mapDecimal{get;set;}
		global map<String,Integer> mapInteger{get;set;}


		global void init()
		{
			mapProperty = new map<String,String>();

			mapBoolean	= new map<String,Boolean>();			
			mapDecimal 	= new map<String,Decimal>();
			mapInteger 	= new map<String,Integer>();
		}
		global row()
		{
			init();
		}


		global void convertAllToString()
		{
			//convert all of the decimals to strings
			for(String key :mapDecimal.keySet())
			{
				mapProperty.put(key,String.valueOf(mapDecimal.get(key).setScale(6)));
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
		//COMPARABLE INTERFACE FOR LIST SORTING
		global Integer compareTo(Object pCmp){          
			row cmp = (row)pCmp;

			//used to sort variance
			String glName 		= mapProperty.get('glName');
			String glType 		= mapProperty.get('glType');
			String glSubType1 	= mapProperty.get('glSubType1');
			String glSubType2 	= mapProperty.get('glSubType2');

			String CglName 		= cmp.mapProperty.get('glName');
			String CglType 		= cmp.mapProperty.get('glType');
			String CglSubType1 	= cmp.mapProperty.get('glSubType1');
			String CglSubType2 	= cmp.mapProperty.get('glSubType2');

			if(glType != CglType)
			{
				if(glType == 'Revenue') return -1;
				return 1;
			}
			else if(glSubType1 != CglSubType1)
			{
				if(glSubType1 == 'Revenue' && CglSubType1 != 'Revenue') return -1;
				if(glSubType1 != 'Revenue' && CglSubType1 == 'Revenue') return 1;

				//at this point, neither gl account is revenue; Operating Expense should be sorted higher than other expenses
				if(glSubType1 == 'Operating Expense' && CglSubType1 != 'Operating Expense') return -1;
				if(glSubType1 != 'Operating Expense' && CglSubType1 == 'Operating Expense') return 1;

				//at this point, neither gl account is revenue or operating expense; Overhead Expense should be sorted next
				if(glSubType1 == 'Overhead Expense' && CglSubType1 != 'Overhead Expense') return -1;
				if(glSubType1 != 'Overhead Expense' && CglSubType1 == 'Overhead Expense') return 1;

				//if it's neither Revenue, nor Operating Expense, nor Overhead Expense, then it's an error, and it should be at the bottom of the list
				return 1;
			}
			else if(glName < CglName) return -1;
			else return 1;
		} 
	}	
}