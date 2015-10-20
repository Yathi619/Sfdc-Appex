trigger RBI_QueryExceptionTrigger on Query__c (after update, before insert) {
	RBI_QueryExceptionTriggerHandler handler= new  RBI_QueryExceptionTriggerHandler();
	 
	if(Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);       
    }
    
    if(Trigger.isInsert && Trigger.isBefore){
		handler.OnBeforeInsert(Trigger.new);       
    }
}