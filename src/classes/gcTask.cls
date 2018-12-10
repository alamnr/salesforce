global without sharing class gcTask {

	global static Boolean disableTrigger{
		get{
			if(disableTrigger == null) return false;
			else return disableTrigger;
		}
		set{
			if(value == null) disableTrigger = false;
			else disableTrigger = value;
		}
	}

	global static void triggerHandler
		(map<Id,Task> oldMap,
		 map<Id,Task> newMap,
		 list<Task> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{
		if(oldMap == NULL) oldMap = new map<Id,Task>();
		if(newMap == NULL) newMap = new map<Id,Task>();
		if(listNew == NULL) listNew = new list<Task>();

		updateAndValidate(oldMap,newMap,listNew,boolIsBefore,boolIsInsert,boolIsUpdate,boolIsDelete);
		
		if(boolIsBefore)
		{
			if(boolIsInsert)
			{

			}
			if(boolIsUpdate)
			{

			}
			if(boolIsDelete)
			{

			}
		}
		else //i.e. trigger.isAfter
		{
			if(boolIsInsert)
			{
				handleEmailAttachment(listNew);
			}
			if(boolIsUpdate)
			{

			}
			if(boolIsDelete)
			{

			}
		}			
	}

	global static void updateAndValidate
		(map<Id,Task> oldMap,
		 map<Id,Task> newMap,
		 list<Task> listNew,
		 Boolean boolIsBefore,
		 Boolean boolIsInsert,
		 Boolean boolIsUpdate,
		 Boolean boolIsDelete)
	{

	}

	
	global static void handleEmailAttachment(list<Task> listNew)
	{
		Set<Id> setIdAttachment = new Set<Id>();
		for(Task tsk: listNew)
		{
			if(tsk.subject.startsWith('Email:'))
			{
				String strEmailBodyText = tsk.Description;
				String strSearch='[do not delete ref:';
				if(strEmailBodyText.contains(strSearch))
				{
					Integer intStart = strEmailBodyText.IndexOf(strSearch) + strSearch.length();
					Id idAttachment = strEmailBodyText.substring(intStart, intStart+18);
					setIdAttachment.add(idAttachment);
				}				
			}
		}

		List<Attachment> listAttachmentToUpdate = new List<Attachment>();
		for(Attachment att : [SELECT Id, Name FROM Attachment WHERE Id IN :setIdAttachment])
		{
			att.Name = att.Name.replace('.pdf',' ***SENT.pdf');
			listAttachmentToUpdate.add(att);
		}

		if(listAttachmentToUpdate.size() > 0) 
		{
			update listAttachmentToUpdate;
		}
	}
}