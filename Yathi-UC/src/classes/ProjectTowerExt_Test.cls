@isTest(SeeAllData=true)
private class ProjectTowerExt_Test {

    static testMethod void myUnitTest() {
     
     project__c pro=new project__c();
      pro.Projects_Name__c='testing'; 
     
     pro.Launch_Date__c= system.today();
     pro.Plot_Area_in_Acres__c=5;

     insert pro;
    
     
     
     
      system.Test.startTest();
      Pagereference pg=page.ProjectTowerExtension;
      System.test.setCurrentPage(pg);
      
      Apexpages.Standardcontroller std=new Apexpages.Standardcontroller(pro);
      
      ProjectTowerExt pttst = new ProjectTowerExt(std);
      
      pttst.addTower();
     /* pttst.Pro.Projects_Name__c = 'Yathi1';
      pttst.Pro.Planned_No_Of_Towers__c = 5; */
      pttst.save();
      system.Test.stopTest();
      
      
      
      
    }
}