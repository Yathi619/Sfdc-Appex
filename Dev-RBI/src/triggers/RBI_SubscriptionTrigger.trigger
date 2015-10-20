trigger RBI_SubscriptionTrigger on RBI_Subscription__c (after insert, after update) {
    RBI_SubscriptionTriggerHandler handler = new RBI_SubscriptionTriggerHandler();
    
    /*After Insert*/
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    
    /* After Update */
    if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.old, Trigger.oldMap);     
    }
}