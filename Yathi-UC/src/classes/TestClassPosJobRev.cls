@isTest
private class TestClassPosJobRev {

   static testMethod void myUnitTest() {
   System.Test.startTest();
   Position__c pos=new Position__c();
   
   Job_Application__c ja=new Job_Application__c();
  /* list <Job_Application__c> jalst =new list <Job_Application__c>(); 
   jalst.add(ja); */
   insert ja;
   //created a job application and inserted the record 
   
  /* Position__c pos= new Position__c(Name='Position1',Deadline_Date__c=2,Deadline_Month__c=4.0,Renewal_Date__c=system.today(),Max_Pay__c=400,Min_Pay__c=200, Postal_Code__c = '012345');
   insert pos;  
   
   Candidate__c can=new Candidate__c(Last_Name__c = 'Bhattre', Zip_Postal_Code__c = '123456');
   insert can;
   
   list<Job_Application__c> jLst = new list<Job_Application__c>();
   Job_Application__c ja  = new Job_Application__c(Candidate__c = can.Id);
   Job_Application__c ja1  = new Job_Application__c(Candidate__c = can.Id);
      jLst.add(ja);
      jLst.add(ja1);
        insert jLst; */
   
   
   Pagereference AddPosPg=page.SetPositionJobReview;
   System.Test.setCurrentPage(AddPosPg);
    
   Apexpages.Standardcontroller std=new Apexpages.Standardcontroller(pos);
   SetPositionJobRevExt ext=new SetPositionJobRevExt(std);
     
   ext.populateReview();
   system.Test.stopTest();
    
    
    }
}