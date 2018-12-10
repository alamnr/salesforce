trigger gtLot on Lot__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcLot.disableTrigger)
	{
		gcLot.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}