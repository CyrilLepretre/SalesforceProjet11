global with sharing class TasksReminderAccountScheduler {

	global void execute(SchedulableContext sc) {
		// Query only accounts with no orders (semi join inner selects not allowed with tasks, filter is applied in the batch)
		String query = 'SELECT Id FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)';
		TasksReminderAccountBatch batch = new TasksReminderAccountBatch(query);
		Database.executeBatch(batch);
	}
}
