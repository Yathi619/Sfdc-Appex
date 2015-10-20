public with sharing class myControllerExtension {


 
    private final Position__c pos;
   
    public list<Job_Application__c> JobApp {get;set;}
   
    // The extension constructor initializes the private member
    // variable pos  by using the getRecord method from the standard
    // controller.
   
    public myControllerExtension(ApexPages.StandardController stdController) {
        this.pos = (Position__c)stdController.getRecord();
        JobApp = new list<Job_Application__c>();
         populateJobApp();
    }
 
    public void populateJobApp() {
        JobApp = [select Id, Name, Status__c,Candidate__r.Full_Name__c from Job_Application__c where Position__c = : pos.Id];
    }
}