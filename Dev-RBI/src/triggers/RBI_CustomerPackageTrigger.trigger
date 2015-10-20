trigger RBI_CustomerPackageTrigger on Project_Cust_Packages__c (after insert) {
	RBI_CustomerPackageTriggerHandler handler = new RBI_CustomerPackageTriggerHandler();
	 /* After Insert */
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
}