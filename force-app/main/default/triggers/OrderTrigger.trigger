/**
* @author:		 Cyril Lepretre
* @date:		 25/05/2020
* @description:	 Trigger on orders
*
*/

trigger OrderTrigger on Order (after delete) {
	List<Order> triggerDeletedOrders = (List<Order>) Trigger.Old;
	// Business logic in OrderTriggerHandler class
	OrderTriggerHandler.desactivateAccountIfNoOrdersLeft(triggerDeletedOrders);
}