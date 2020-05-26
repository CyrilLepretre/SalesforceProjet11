/**
* @author:		 Cyril Lepretre
* @date:		 25/05/2020
* @description:	 Scheduler for the batch which creates reminder tasks
*
*/

global with sharing class TasksReminderAccountScheduler {

	global void execute(SchedulableContext sc) {
		TasksReminderAccountBatch batch = new TasksReminderAccountBatch();
		// Limit batch size to 200, could be updated in the future depending on monitoring results
		Database.executeBatch(batch, 200);
	}
}
