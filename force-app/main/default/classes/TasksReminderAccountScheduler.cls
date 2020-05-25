global with sharing class TasksReminderAccountScheduler {

	global void execute(SchedulableContext sc) {
		TasksReminderAccountBatch batch = new TasksReminderAccountBatch();
		// Limit batch size to 100 for governor limits
		Database.executeBatch(batch, 100);
	}
}
