trigger gtSalesOrderLine on AcctSeedERP__Sales_Order_Line__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcSalesOrderLine.disableTrigger)
	{
		gcSalesOrderLine.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}