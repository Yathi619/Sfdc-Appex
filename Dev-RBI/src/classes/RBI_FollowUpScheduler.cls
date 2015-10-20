global class RBI_FollowUpScheduler implements Schedulable{

global void execute(SchedulableContext ctx){
            //String query = 'SELECT id, name FROM strikelronlnfo__c WHERE OwnerId = \'00590000000fFHyAAM\'';
            RBI_FollowUpBatch batchApex = new RBI_FollowUpBatch();
            ID batchprocessid = Database.executeBatch(batchApex);
    }
}