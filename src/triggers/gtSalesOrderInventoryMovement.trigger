trigger gtSalesOrderInventoryMovement on AcctSeedERP__Sales_Order_Inventory_Movement__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if(!gcSalesOrderInventoryMovement.disableTrigger)
	{
		gcSalesOrderInventoryMovement.triggerHandler
			(trigger.oldMap,
			 trigger.newMap,
			 trigger.new,
			 trigger.isBefore,
			 trigger.isInsert,
			 trigger.isUpdate,
			 trigger.isDelete);
	}
}