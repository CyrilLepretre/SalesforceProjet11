/**
* @author:		 Cyril Lepretre
* @date:		 25/05/2020
* @description:	 Handler of the trigger on order, includes all the business logic
*
*/

public with sharing class OrderTriggerHandler {
	
	/**
	* Returns nothing
	*
	* The desactivateAccountIfNoOrdersLeft method desactivates accounts from a list of orders
	* If the accounts from the list of orders have no order remaining, Active__c field is set to false, nothing else
	*
	* @param		orders
	* @return		void
	*/
	public static void desactivateAccountIfNoOrdersLeft(List<Order> orders) {
		List<Account> accountsToDesactivate = new List<Account>();
		Set<Id> accountIdsWithOrderDeleted = new Set<Id>();
		Set<Id> accountIdsWithOrderDeletedAndOrderRemaining = new Set<Id>();
		// First build a Set with account ids of orders deleted
		for (Order order : orders) {
			if (String.isNotBlank(order.AccountId)) {
				accountIdsWithOrderDeleted.add(order.AccountId);
			}
		}
		// Then query accounts and query all orders of each account to verify the ones withtout any order after the delete
		if (!accountIdsWithOrderDeleted.isEmpty()) {
			List<Account> accountsWithOrderDeleted = [SELECT Id, Active__c FROM Account WHERE Id IN :accountIdsWithOrderDeleted];
			List<Order> accountsOrders = [SELECT Id, AccountId FROM Order WHERE AccountId IN :accountIdsWithOrderDeleted];

			if (!accountsOrders.isEmpty()) {
				for (Order order : accountsOrders) {
					accountIdsWithOrderDeletedAndOrderRemaining.add(order.AccountId);
				}
			}
			if (!accountsWithOrderDeleted.isEmpty()) {
				for (Account account : accountsWithOrderDeleted) {
					// If the account is not included in the list of the ones with remaining orders, then we can desactivate it
					if ((accountIdsWithOrderDeletedAndOrderRemaining.isEmpty()) || (!accountIdsWithOrderDeletedAndOrderRemaining.contains(account.Id))) {
						account.Active__c = false;
						accountsToDesactivate.add(account);
					}
				}
			}
		}
		// Finally update all accounts to desactivate
		if (!accountsToDesactivate.isEmpty()) {
			update(accountsToDesactivate);
		}
	}
}
