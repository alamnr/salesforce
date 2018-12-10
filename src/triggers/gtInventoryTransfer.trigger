trigger gtInventoryTransfer on Inventory_Transfer__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcInventoryTransfer.disableTrigger)
	{
		gcInventoryTransfer.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}