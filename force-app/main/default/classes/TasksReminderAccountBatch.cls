global with sharing class TasksReminderAccountBatch implements Database.Batchable<sObject> {
	global String query;

	// Constructor with initialization of the query to get first Account list filtered
	global TasksReminderAccountBatch(String query) {
		this.query = query;
	}

	global Database.QueryLocator start(Database.BatchableContext info) {
		// Query passed as paramater of the constructor is used
		return Database.getQueryLocator(this.query);
	}

	global void execute(Database.BatchableContext info, List<Account> scope) {
		List<Task> reminderTasksList = [SELECT Id, WhoId FROM Task WHERE Subject = 'Call'];
		List<Task> reminderTasksListToCreate = new List<Task>();
		Set<Id> accountsIdHavingReminderTask = new Set<Id>();
		// Initialization of a Set of Account Ids having reminder Tasks
		for (Task reminderTask : reminderTasksList) {
			accountsIdHavingReminderTask.add(reminderTask.WhoId);
		}
		// Next populate reminderTasksListToCreate with Tasks to create for accounts having no reminder task
		for (Account accountToCheck : scope) {
			if (!accountsIdHavingReminderTask.contains(accountToCheck.Id)) {
				Task reminderTaskToCreate = new Task(	WhoId = accountToCheck.Id, 
														Subject = 'Call', 
														Status = 'Not Started', 
														Priority = 'Normal', 
														IsReminderSet = true,
														ReminderDateTime = System.now() + 5
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
