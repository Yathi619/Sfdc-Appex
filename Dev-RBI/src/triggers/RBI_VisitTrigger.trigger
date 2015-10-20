trigger RBI_VisitTrigger on Visit__c (after insert, before insert, after update, before update) {
	RBI_VisitTriggerHandler handler = new RBI_VisitTriggerHandler();
    RBI_VisitOwnerChangeTrighandler ownerHandler = new RBI_VisitOwnerChangeTrighandler();
	
    /* After Update */
    if(Trigger.isUpdate && Trigger.isafter){  
    	handler.OnafterUpdate(Trigger.new , Trigger.old, Trigger.oldMap);
    	
    }
    /* Before Update for surveyor or team leader update based on owner change */
    if(Trigger.isUpdate && Trigger.isbefore){  
    	ownerHandler.OnBeforeUpdate(Trigger.new , Trigger.old, Trigger.oldMap);
    }
    
    /* Before Insert for Operation Mgr - Data based on the project sity city */
    if(Trigger.isInsert && Trigger.isbefore){  
    	ownerHandler.OnbeforeInsert(Trigger.new);
    }
}