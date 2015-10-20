trigger RBI_CustomerProjectTrigger on Customer_Projects__c (before insert, before update) {
	RBI_CustomerProjectTriggerHandler handler= new RBI_CustomerProjectTriggerHandler();
	 if(Trigger.isInsert && Trigger.isbefore){
        handler.OnBeforeInsert(Trigger.new);
      }
   	 /* After Update */
    if(Trigger.isUpdate && Trigger.isbefore){  
        handler.OnBeforeUpdate(Trigger.new , Trigger.old, Trigger.oldMap);
    }   

}