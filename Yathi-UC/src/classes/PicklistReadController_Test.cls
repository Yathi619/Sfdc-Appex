@isTest
private class PicklistReadController_Test {

    static testMethod void myUnitTest() {
     Position__c po=new Position__c(); 
      
     System.Test.startTest();
     Pagereference pg=page.PickListReadRightController;
     System.Test.setCurrentPage(pg);
     
     Apexpages.Standardcontroller std=new Apexpages.Standardcontroller(po);
     
     PicklistReadController tes=new PicklistReadController(std);
     
     tes.showtextbox();
     tes.showtextbox1();
     tes.pick.Resident__c='Yes';
     tes.showtextbox();
    
        
        
    }
}