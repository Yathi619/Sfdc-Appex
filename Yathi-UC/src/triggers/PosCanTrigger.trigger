trigger PosCanTrigger on Job_Application__c (after insert) {

	PositionCandidateTriggerHandler handler=new PositionCandidateTriggerHandler();
	if(Trigger.isAfter && Trigger.isInsert)
	{
		handler.onAfterInsert( Trigger.new);
	}


}