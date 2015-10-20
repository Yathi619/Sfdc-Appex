public with sharing class myControllerExtension2 {

 public list<Job_Application__c> JobApp {get;set;}
 public Position__c pos;
 public list<Review__c> re {get;set;}
 public String jid {get; set;}

    // The extension constructor initializes the private member
    // variable pos  by using the getRecord method from the standard
    // controller.

    public myControllerExtension2(ApexPages.StandardController stdController) {
        this.pos = (Position__c)stdController.getRecord();
       // system.debug('XXX' +pos);
        JobApp = new list<Job_Application__c>();
        re = new list<Review__c>();
        populateJobApp();
    }

    public void populateJobApp() {
    //  system.debug('AAA' +pos.Id);
        JobApp = [select Id, Name, Status__c,Cover_Letter__c, Candidate__r.Full_Name__c from Job_Application__c where Position__c = : pos.Id];
    //  system.debug('BBB'+ JobApp);
    }

public Pagereference populateReview(){
    re = [select Id, Rating__c,Name from Review__c where Job_Application_Number__c = : jid];
    //system.debug('AAA' + jid);
    return null;
}

}