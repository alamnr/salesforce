trigger gtWarehouse on AcctSeedERP__Warehouse__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcWarehouse.disableTrigger)
	{
		gcWarehouse.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}