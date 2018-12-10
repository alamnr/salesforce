trigger gtTask on Task (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
	if(!gcTask.disableTrigger)
	{
		gcTask.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}