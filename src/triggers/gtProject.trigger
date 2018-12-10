trigger gtProject on AcctSeed__Project__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcProject.disableTrigger)
	{
		gcProject.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}