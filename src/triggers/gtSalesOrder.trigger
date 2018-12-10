trigger gtSalesOrder on AcctSeedERP__Sales_Order__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcSalesOrder.disableTrigger)
	{
		gcSalesOrder.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}