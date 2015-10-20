trigger RBI_ProjectTrigger on Project__c (before insert, before update,after update, after insert) {
    RBI_ProjectTriggerHandler handler = new RBI_ProjectTriggerHandler();
     /* Before Insert */
    if(Trigger.isInsert && Trigger.isbefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    /* After Insert */
    if(Trigger.isInsert && Trigger.isAfter){
    	list<boolean> createFlag = new list<boolean>();
    	list<String> projectName = new list<String>();
    	list<Id> projId = new list<Id>();
    	list<Id> surveyorId = new list<Id>();
      for(Project__c proj :Trigger.new){
      	boolean createFTRFlag = false;
      	if((proj.Launch_Date__c < system.today()) && (proj.To_Be_Approved__c == false)){
      		createFTRFlag = true;
      	}
      	createFlag.add(createFTRFlag);
      	projectName.add(proj.Name);
      	projId.add(proj.Id);
      	surveyorId.add(proj.Surveyor__c);
      } 
      RBI_ProjectTriggerHandler.OnAfterInsert(projectName, projId, createFlag, surveyorId);
    }     
    /* After Update */
    if(Trigger.isUpdate && Trigger.isbefore){  
        handler.OnBeforeUpdate(Trigger.new , Trigger.old, Trigger.oldMap);
    }
   /* After Update */
    if(Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.new, Trigger.old, Trigger.oldMap);     
    }
}