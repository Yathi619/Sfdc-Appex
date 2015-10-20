@isTest
private class myControllerExtension_Test {

    static testMethod void myUnitTest() {
        
        Position__c po = new Position__c();
        
        System.Test.startTest();
        
        Pagereference pg = page.PosJobApp;
        System.Test.setCurrentPage(pg);
        
        Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(po);
        myControllerExtension test1 = new myControllerExtension(std);
        
        test1.populateJobApp();
        
        System.Test.stopTest();
    }
}