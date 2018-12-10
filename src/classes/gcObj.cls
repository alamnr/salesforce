global without sharing class gcObj {

	global map<String,String> mapProperty{get;set;}
	global map<String,gcObj> mapObj{get;set;}
	global list<gcObj> listObj{get;set;}
	global map<String,Decimal> mapDecimal{get;set;}

	private void init()
	{
		mapProperty = new map<String,String>();
		mapObj = new map<String,gcObj>();
		listObj = new list<gcObj>();	
		mapDecimal = new map<String,Decimal>();	
	}
	global gcObj()
	{
		init();
	}
}