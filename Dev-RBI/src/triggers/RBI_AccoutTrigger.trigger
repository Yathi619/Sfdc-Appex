trigger RBI_AccoutTrigger on Account (before insert, before update) {
	
	RBI_AccountTriggerHandler handler = new RBI_AccountTriggerHandler();
	/* Before Insert */
    if(Trigger.isInsert && Trigger.isbefore){
        handler.OnBeforeInsert(Trigger.new);
    }
	/* Before Update */
    if(Trigger.isUpdate && Trigger.isbefore){  
        handler.OnBeforeUpdate(Trigger.new , Trigger.old, Trigger.oldMap);
    }
}