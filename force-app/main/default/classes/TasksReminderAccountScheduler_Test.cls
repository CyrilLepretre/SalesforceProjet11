/**
* @author:		 Cyril Lepretre
* @date:		 26/05/2020
* @description:		Test TasksReminderAccountScheduler use cases
* #TestReady
*
*/

@istest
private with sharing class TasksReminderAccountScheduler_Test {
	@testSetup
	static void init() {
		List<Account> accounts = new List<Account>();
		// Insert 200 accounts
		for (Integer i=0;i<200;i++) {
			accounts.add(new Account(name = 'AccountBatch '+i));
		}
		insert accounts;
	}

	/*
	Test with insert of 1 task per Account, 200 tasks should be inserted
	*/
	@isTest
	static void given200accountsWithoutOrderAndTask_WhenCreateReminderTasksByBatch_ThenInsert200tasks(){
		Test.startTest();
		SchedulableContext sc = null;
		TasksReminderAccountScheduler scheduler = new TasksReminderAccountScheduler();
		scheduler.execute(sc);
		Test.stopTest();
		List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'AccountBatch%'];
		Set<Id> accountsId = new Set<Id>();
		for (Account accountToCheck : accounts) {
			accountsId.add(accountToCheck.Id);
		}
		List<Task> tasksCreated = [SELECT Id FROM Task WHERE WhatId IN :accountsId];
		System.assertEquals(200, tasksCreated.size(),'There should be 200 reminder tasks created');
	}

	/*
	Test with insert of 1 task per Account while 10 accounts have already a reminder task, 190 tasks should be inserted so 200 tasks finally
	*/
	@isTest
	static void given190accountsWithoutOrderAndTaskAnd10WithTask_WhenCreateReminderTasksByBatch_ThenInsert190tasksSo200TasksGlobally(){
		List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'AccountBatch%'];
		Set<Id> accountsId = new Set<Id>();
		for (Account accountToCheck : accounts) {
			accountsId.add(accountToCheck.Id);
		}
		List <Task> tasksAlreadyExistingBeforeBatch = new List<Task>();
		// Insert 1 reminder task on 10 accounts to verify that no reminder tasks will be created for them
		for (Integer i=0; i<10; i++) {
			Task reminderTaskToCreate = new Task(	WhatId = accounts[i].Id, 
														Subject = 'Call', 
														Status = 'Not Started', 
														Priority = 'Normal', 
														IsReminderSet = true,
														ReminderDateTime = DateTime.valueOfGMT(String.valueOf(DateTime.now())) + 5
													);
			tasksAlreadyExistingBeforeBatch.add(reminderTaskToCreate);
		}
		insert(tasksAlreadyExistingBeforeBatch);
		List<Task> tasksAlredyExisting = [SELECT Id FROM Task WHERE WhatId IN :accountsId];
		System.assertEquals(10, tasksAlredyExisting.size(),'There should be 10 reminder tasks already existing');

		Test.startTest();
		SchedulableContext sc = null;
		TasksReminderAccountScheduler scheduler = new TasksReminderAccountScheduler();
		scheduler.execute(sc);
		Test.stopTest();
		List<Task> tasksGlobally = [SELECT Id FROM Task WHERE WhatId IN :accountsId];
		System.assertEquals(200, tasksGlobally.size(),'There should be 190 reminder tasks created, 200 tasks globally');
	}

	/*
	Test with insert of 1 task per Account while 1 account has already an Order, 199 tasks should be inserted so 199 tasks finally
	*/
	@isTest
	static void given199accountsWithoutOrderAndTaskAnd1WithOrder_WhenCreateReminderTasksByBatch_ThenInsert199tasksSo199TasksGlobally(){
		List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'AccountBatch%'];
		Set<Id> accountsId = new Set<Id>();
		for (Account accountToCheck : accounts) {
			accountsId.add(accountToCheck.Id);
		}
		// Insert a contract for 1 account
		Contract ctr1 = new Contract(	AccountId = accounts[0].Id,
										ContractTerm = 1,
										StartDate = date.today(),
										Status = 'Draft');
		insert ctr1;
		// Insert of 1 order for 1 accout
		Order order = new Order(AccountId = accounts[0].Id, Status = 'Draft', Description = 'Account with 1 order', EffectiveDate = date.today());
		insert order;

		Test.startTest();
		SchedulableContext sc = null;
		TasksReminderAccountScheduler scheduler = new TasksReminderAccountScheduler();
		scheduler.execute(sc);
		Test.stopTest();
		List<Task> tasksGlobally = [SELECT Id FROM Task WHERE WhatId IN :accountsId];
		System.assertEquals(199, tasksGlobally.size(),'There should be only 199 reminder tasks created, 199 tasks globally');
	}
}
