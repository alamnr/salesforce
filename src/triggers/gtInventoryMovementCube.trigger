trigger gtInventoryMovementCube on Inventory_Movement_Cube__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcInventoryMovementCube.disableTrigger)
	{
		gcInventoryMovementCube.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}