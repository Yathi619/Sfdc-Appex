trigger JobPositionTrigger on Job_Application__c (after insert) {

JobAppPOsitionTriggerClass handler = new JobAppPOsitionTriggerClass();

 if(Trigger.isAfter && Trigger.isInsert)
 	{
 		handler.onAfterinsert(Trigger.new);
	}
}