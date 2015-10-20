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
private class RBI_CustomerPackTrigTestClass {

    static testMethod void CustPackTrigTest() {
        //insert these object record for CustPackTrigTest
        ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
        ID RbiRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RBI'].Id;
        
        list<Account> acc = new list<Account>();
        Account Acnt = new Account(Name = 'TestAccount', BillingStreet = 'TestStreet', BillingCity = 'Hyderabad', BillingState = 'AP', BillingCountry = 'India',
                                    BillingPostalCode = '123456', Phone = '124567', Type='Customer',RecordTypeId = CusRecType );
        acc.add(Acnt);
        insert acc;
        
        list<Project__c> projlist = new list<Project__c>();
        Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
                                         City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
                                         Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
        projlist.add(proj);
        insert projlist;
        
        //Id Accid = System.Label.RBI_AccountId;
        
        list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
        Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id, AccountId__c = acc[0].Id);
        customerProjectlist.add(cp);
        insert customerProjectlist;
        
        list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
        List_of_Values__c lov = new List_of_Values__c(Name='PAS', Entity_Name__c = 'PAS',Entity_Type__c = 'Package',
                                Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
        List_of_Values__c lov1 = new List_of_Values__c(Name='FTR',Entity_Name__c = 'FTR',Entity_Type__c = 'Package',
                                Bank_Name__c = 'HDFC Bank', Completion_Year__c = 2014, Dwelling_Units__c=13, Loan_Amount__c=24000, Dev_Project_Address__c='test unit2');
        List_of_Values__c lov2 = new List_of_Values__c(Name='CRM Report',Key__c='Followup Report',Entity_Name__c = 'CRM Report',Entity_Type__c = 'Package',
                                Bank_Name__c = 'HDFC Bank', Completion_Year__c = 2014, Dwelling_Units__c=13, Loan_Amount__c=24000, Dev_Project_Address__c='test unit2');
        List_of_Values__c lov3 = new List_of_Values__c(Name='PMS',Entity_Name__c = 'PMS',Entity_Type__c = 'Package',
                                Bank_Name__c = 'HDFC Bank', Completion_Year__c = 2014, Dwelling_Units__c=13, Loan_Amount__c=24000, Dev_Project_Address__c='test unit2');                                                                
        lovlist.add(lov);
        lovlist.add(lov1);
        lovlist.add(lov2);
        lovlist.add(lov3);
        insert lovlist;
        
        list<Project_Cust_Packages__c> prjCustPack = new list<Project_Cust_Packages__c>();
        Project_Cust_Packages__c ProjCustomPack = new Project_Cust_Packages__c (List_of_Values__c=lov.id, Customer_Project__c=customerProjectlist[0].Id);
        Project_Cust_Packages__c ProjCustomPack1 = new Project_Cust_Packages__c (List_of_Values__c=lov1.id, Customer_Project__c=customerProjectlist[0].Id);
        Project_Cust_Packages__c ProjCustomPack2 = new Project_Cust_Packages__c (List_of_Values__c=lov2.id, Customer_Project__c=customerProjectlist[0].Id);
        prjCustPack.add(ProjCustomPack);
        prjCustPack.add(ProjCustomPack1);
        prjCustPack.add(ProjCustomPack2);
        //insert prjCustPack;
        
    }
}