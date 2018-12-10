trigger gtAccountRelationship on Account_Relationship__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcAccountRelationship.disableTrigger)
	{
		gcAccountRelationship.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}

}