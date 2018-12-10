trigger gtLocation on AcctSeedERP__Location__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcLocation.disableTrigger)
	{
		gcLocation.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}