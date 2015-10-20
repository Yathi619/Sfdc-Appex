global class RBI_DeveloperAlertScheduler implements Schedulable{
	
	global void execute(SchedulableContext ctx){
		RBI_DeveloperAlertBatch batchApex = new RBI_DeveloperAlertBatch();
		ID batchprocessid = Database.executeBatch(batchApex);
	}
}