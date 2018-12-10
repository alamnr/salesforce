trigger gtProduct on Product2 (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcProduct.disableTrigger)
	{
		gcProduct.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}