/**
* @author:		 Cyril Lepretre
* @date:		 25/05/2020
* @description:	 Batch that creates reminder tasks depending on business rules (no order and reminder on the account, the create a reminder task)
*
*/

global with sharing class TasksReminderAccountBatch implements Database.Batchable<sObject> {
	global TasksReminderAccountBatch() {
	}

	global Database.QueryLocator start(Database.BatchableContext info) {
		// Query only accounts with no orders (semi join inner selects not allowed with tasks, filter is applied in execute method)
		String query = 'SELECT Id FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext info, List<Account> scope) {
		List<Task> reminderTasksList = [SELECT Id, WhatId FROM Task WHERE Subject = 'Call'];
		List<Task> reminderTasksListToCreate = new List<Task>();
		Set<Id> accountsIdHavingReminderTask = new Set<Id>();
		// Initialization of a Set of Account Ids having reminder Tasks
		for (Task reminderTask : reminderTasksList) {
			accountsIdHavingReminderTask.add(reminderTask.WhatId);
		}
		// Next populate reminderTasksListToCreate with Tasks to create for accounts having no reminder task
		for (Account accountToCheck : scope) {
			if (!accountsIdHavingReminderTask.contains(accountToCheck.Id)) {
				Task reminderTaskToCreate = new Task(	WhatId = accountToCheck.Id, 
														Subject = 'Call', 
														Status = 'Not Started', 
														Priority = 'Normal', 
														IsReminderSet = true,
														ReminderDateTime = DateTime.valueOfGMT(String.valueOf(DateTime.now())) + 5
													);
				reminderTasksListToCreate.add(reminderTaskToCreate);
			}
		}
		if (!reminderTasksListToCreate.isEmpty()) {
			insert(reminderTasksListToCreate);
		}
	}
	
	global void finish(Database.BatchableContext info) {
	}
}
