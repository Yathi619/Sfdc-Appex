global class RBI_AlertScheduler implements Schedulable{
	
    global void execute(SchedulableContext ctx){
		    //String query = 'SELECT id, name FROM strikelronlnfo__c WHERE OwnerId = \'00590000000fFHyAAM\'';
		    RBI_AlertBatch batchApex = new RBI_AlertBatch();
		    ID batchprocessid = Database.executeBatch(batchApex);
	}
}