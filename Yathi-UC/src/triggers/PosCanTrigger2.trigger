trigger PosCanTrigger2 on Position__c (after update) 
{
	PositionCandidateTriggerHandler2 handler = new PositionCandidateTriggerHandler2();
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		handler.onAfterUpdate(Trigger.New);
		//handler.onAfterUpdate(Trigger.New,Trigger.oldMap);
		//above line of code  to check old values in the list
	}
}