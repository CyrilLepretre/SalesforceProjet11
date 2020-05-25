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
	Test with insert of 1 task per Account, 200 task should be inserted
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
}
