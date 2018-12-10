public class gcBatchDelete implements Database.Batchable<sObject>{
	
	list<sObject> listObj{get;set;}
	
	public gcBatchDelete(list<sObject> pListObj)
	{
		listObj = pListObj;
	}
		
	public Iterable<sObject> start(Database.BatchableContext info)
	{		
		return new sObjectIterable(listObj);
	}
	
	public void execute(Database.BatchableContext info, list<sObject> scope)
	{  
		gcBilling.disableTrigger=true;
		gcBillingLine.disableTrigger=true;
		gcInboundInventoryMovement.disableTrigger=true;
		gcOutboundInventoryMovement.disableTrigger=true;
		gcSalesOrder.disableTrigger=true;
		gcSalesOrderLine.disableTrigger=true;

		Database.delete(scope);		
	}
	
	public void finish(Database.BatchableContext info){}
	
	
	//ITERATOR
	public class sObjectIterator implements Iterator<sObject>{
		
		list<sObject> listObj{get;set;}
		Integer i{get;set;}
		
		//CONSTRUCTOR
		public sObjectIterator(list<sObject> pListObj)
		{
			listObj = pListObj;
			i=0;
		}
		
		public boolean hasNext()
		{
			if(i >= listObj.size()) return false;
			else return true;
		}
		
		public sObject next()
		{
			if(i < listObj.size())
			{
				i++;
				return listObj[i-1];
			}
			i++;
			return null;
		}
	}

	//ITERABLE
	public class sObjectIterable implements iterable<sObject>{
		
		list<sObject> listObj{get;set;}
		
		//CONSTRUCTOR
		public sObjectIterable(list<sObject> pListObj)
		{
			listObj = pListObj;
		}
		
		//ITERATOR
		public Iterator<sObject> Iterator()
		{
			return new sObjectIterator(listObj);
		}
	}
}