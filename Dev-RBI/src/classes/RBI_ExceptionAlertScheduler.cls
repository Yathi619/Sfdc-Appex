global class RBI_ExceptionAlertScheduler implements Schedulable{
	global void execute(SchedulableContext ctx){
	    RBI_ExceptionAlertBatch batchApex = new RBI_ExceptionAlertBatch();
        ID batchprocessid = Database.executeBatch(batchApex);
    }
}