trigger CandidateTrigger on Candidate__c (after insert) 
{

	CandidateTriggerHandler handler=new CandidateTriggerHandler();

	if(Trigger.isAfter && Trigger.isInsert)
	{
    	handler.onafterinsert(Trigger.new);
	}

}