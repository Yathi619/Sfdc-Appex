/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class RBI_CusProjTriggerHandlerTestClass {

    static testMethod void RBI_CusProjTriggerHandler() {
    	ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
	 	ID RbiRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RBI'].Id;
    	list<Account> Acclist = new list<Account>();
		Account acc = new Account(Name='Test Class',Weightage_Basement__c=10 ,Weightage_Electrification_Sanitation__c=3.00, 
									Weightage_Excavaton_of_Footings__c = 9, Weightage_Finishing__c =2, Weightage_Masonary__c = 3,RecordTypeId=RbiRecType);
		Account acc1 = new Account(Name='Test1 Class',Weightage_Basement__c=2 ,Weightage_Electrification_Sanitation__c=1.00, 
									Weightage_Excavaton_of_Footings__c = 2, Weightage_Finishing__c =15, Weightage_Masonary__c = 3,RecordTypeId=CusRecType);								 
		Acclist.add(acc);
		Acclist.add(acc1);
		insert Acclist;
    	
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '412578', Site_Address_zipcode__c = '123456', Launch_Date__c = System.today(),
										 Site_Address_City__c='Bangalore');
		projlist.add(proj);
		insert projlist;
		
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id,Weightage_Type__c='Realty BI', AccountId__c =acc1.Id);
		Customer_Projects__c cp1 = new Customer_Projects__c(Project_Id__c = projlist[0].Id,Weightage_Type__c='Customer', AccountId__c =acc1.Id);
		customerProjectlist.add(cp);
		customerProjectlist.add(cp1);
		insert customerProjectlist;
		
		//test for  Handler OnBeforeUpdate method
		system.Test.startTest();
		cp.Weightage_Type__c ='Customer';
		cp.Weightage_Basement__c = acc1.Weightage_Basement__c;
		cp.Weightage_Electrification_Sanitation__c = acc1.Weightage_Electrification_Sanitation__c;
		cp.Weightage_Excavaton_of_Footings__c = acc1.Weightage_Excavaton_of_Footings__c;
		cp.Weightage_Finishing__c = acc1.Weightage_Finishing__c;
		cp.Weightage_Masonary__c = acc1.Weightage_Masonary__c;
		cp.Weightage_RCC_Slab_Casting__c = acc1.Weightage_RCC_Slab_Casting__c;
		update cp;
		system.assertEquals(cp.Weightage_Finishing__c, 15);
		
		//test for else part
		cp.Weightage_Type__c ='Realty BI';
		cp.Weightage_Basement__c = acc.Weightage_Basement__c;
		cp.Weightage_Electrification_Sanitation__c = acc.Weightage_Electrification_Sanitation__c;
		cp.Weightage_Excavaton_of_Footings__c = acc.Weightage_Excavaton_of_Footings__c;
		cp.Weightage_Finishing__c = acc.Weightage_Finishing__c;
		cp.Weightage_Masonary__c = acc.Weightage_Masonary__c;
		cp.Weightage_RCC_Slab_Casting__c = acc.Weightage_RCC_Slab_Casting__c;
		update cp;
		system.assertEquals(cp.Weightage_Finishing__c, 2);
		system.Test.stopTest();
		
    }
}