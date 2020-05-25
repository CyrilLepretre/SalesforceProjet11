/**
* @author:		 Cyril Lepretre
* @date:		 25/05/2020
* @description:		Test OrderTrigger use cases
* #TestReady
*
*/

@istest
private with sharing class OrderTrigger_Test {
	@testSetup
	static void init() {
		// Insert of 2 accounts
		Account accountWithOneOrder = new Account(Name = 'With One'/*, Active__c = True*/);
		Account accountWithTwoOrders = new Account(Name = 'With Two'/*, Active__c = True*/);
		insert new Account[]{accountWithOneOrder, accountWithTwoOrders};
		// Insert of 2 contracts, one for each account
		Contract ctr1 = new Contract(	AccountId = accountWithOneOrder.Id,
										ContractTerm = 1,
										StartDate = date.today(),
										Status = 'Draft');
		Contract ctr2 = new Contract(	AccountId = accountWithTwoOrders.Id,
										ContractTerm = 2,
										StartDate = date.today(),
										Status = 'Draft');
		insert new Contract[]{ctr1, ctr2};
		// Then activate contracts
		ctr1.Status = 'Activated';
		ctr2.Status = 'Activated';
		update ctr1;
		update ctr2;
		// Insert of 1 order for 'With One' Account, and 2 orders for 'With Two' Account
		Order orderWithOne1 = new Order(AccountId = accountWithOneOrder.Id, Status = 'Draft', Description = 'toDeleteAccount1', EffectiveDate = date.today());
		Order orderWithTwo1 = new Order(AccountId = accountWithTwoOrders.Id, Status = 'Draft', Description = 'toDeleteAccount2', EffectiveDate = date.today());
		Order orderWithTwo2 = new Order(AccountId = accountWithTwoOrders.Id, Status = 'Draft', Description = 'notToDeleteAccount2', EffectiveDate = date.today());
		insert new Order[]{orderWithOne1, orderWithTwo1, orderWithTwo2};
	}

	/*
	Test with 1 account having 1 order, when deleting the order
	*/
	@isTest
	static void givenOneAccountWithOneOrder_WhenDeleteOrder_ThenUpdateAccountActiveToFalse(){
		Account ac = [SELECT Id, Active__c FROM Account WHERE Name = 'With One'];
		System.assertEquals(True, ac.Active__c,'The Active__c field should be True because the account has an order');
		Test.startTest();
		Order orderToDelete = [SELECT Id FROM Order WHERE AccountId =: ac.Id];
		delete(orderToDelete);
		Account acAfterUpdate = [SELECT Id, Active__c FROM Account WHERE Name = 'With One'];
		Test.stopTest();
		System.assertEquals(False, acAfterUpdate.Active__c,'The Active__c field should be False because the account has no order anymore');
	}

	/*
	Test with 1 account having 2 orders, when deleting only 1 order
	*/
	@isTest
	static void givenOneAccountWithTwoOrders_WhenDeleteOnlyOne_ThenNoUpdateAccountActive(){
		Account ac = [SELECT Id, Active__c FROM Account WHERE Name = 'With Two'];
		System.assertEquals(True, ac.Active__c,'The Active__c field should be True because the account has an order');
		Test.startTest();
		List<Order> ordersList = [SELECT Id FROM Order WHERE AccountId =: ac.Id];
		System.assertEquals(2, ordersList.size(),'The account should have 2 orders');
		delete(ordersList.get(0)); // Delete only the first order of the list
		Account acAfterUpdate = [SELECT Id, Active__c FROM Account WHERE Name = 'With Two'];
		Test.stopTest();
		System.assertEquals(True, acAfterUpdate.Active__c,'The Active__c field should be True because the account has one order remaining');
	}

	/*
	Test with 1 account having 2 orders, when deleting all orders
	*/
	@isTest
	static void givenOneAccountWithTwoOrders_WhenDeleteTwoOrders_ThenUpdateAccountActiveToFalse(){
		Account ac = [SELECT Id, Active__c FROM Account WHERE Name = 'With Two'];
		System.assertEquals(True, ac.Active__c,'The Active__c field should be True because the account has an order');
		Test.startTest();
		List<Order> ordersList = [SELECT Id FROM Order WHERE AccountId =: ac.Id];
		System.assertEquals(2, ordersList.size(),'The account should have 2 orders');
		delete(ordersList); // Delete all the orders of the account
		Account acAfterUpdate = [SELECT Id, Active__c FROM Account WHERE Name = 'With Two'];
		Test.stopTest();
		System.assertEquals(False, acAfterUpdate.Active__c,'The Active__c field should be Falase because the account has no orders anymore');
	}
}
