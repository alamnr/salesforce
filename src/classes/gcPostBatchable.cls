public class gcPostBatchable implements Database.Batchable<sObject>{
	
	list<sObject> listObj{get;set;}
	String strService{get;set;}
	
	public gcPostBatchable(list<sObject> pListObj, String pStrService)
	{
		listObj = pListObj;
		strService = pStrService;

	}
		
	public Iterable<sObject> start(Database.BatchableContext info)
	{		
		return new sObjectIterable(listObj);
	}
	
	public void execute(Database.BatchableContext info, list<sObject> scope)
	{  				
		list<AcctSeed.PostResult> listPostResult = new list<AcctSeed.PostResult>();
		
		if(strService == 'PostJournalEntries')
			listPostResult = AcctSeed.JournalEntryPostService.postJournalEntries(scope);
		else if(strService == 'UnpostJournalEntries')
			listPostResult = AcctSeed.JournalEntryPostService.unpostJournalEntries(scope);
		else if(strService == 'PostBillings')
			listPostResult = AcctSeed.BillingPostService.postBillings(scope);
		else if(strService == 'UnpostBillings')
			listPostResult = AcctSeed.BillingPostService.unpostBillings(scope);	
		else if(strService == 'PostPayables')
			listPostResult = AcctSeed.AccountPayablePostService.postAccountPayables(scope);
		else if(strService == 'UnpostPayables')
			listPostResult = AcctSeed.AccountPayablePostService.unpostAccountPayables(scope);			
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