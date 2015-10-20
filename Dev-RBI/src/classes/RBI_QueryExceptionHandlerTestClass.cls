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
private class RBI_QueryExceptionHandlerTestClass {

    static testMethod void RBI_QueryExceptionHandler() {
    
    	    // insert project Record
	    	list<Project__c> projlist = new list<Project__c>();
			Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
											 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
											 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
			Project__c proj1 = new Project__c(Project_Name__c='Test1 Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today()-30,
											 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
											 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today(),Technical_Head_Email__c='sss@gmail.com');								 
											 
			projlist.add(proj);
			projlist.add(proj1);
			insert projlist;
			
			list<Visit__c> vstList = new list<Visit__c>();
	    	Visit__c vst = new Visit__c(Status__c = 'Approved', Project__c = projlist[0].Id,  Visit_Report__c = 'First Technical Report', Exception__c = true);
	    	vstList.add(vst);
	    	insert vstList;
	    	
		    ID  QueryType = [SELECT Id FROM RecordType WHERE Name = 'Exception'].Id;
		    list<Query__c> querylist= new list<Query__c>();
		    Query__c query= new Query__c (Exception_Status__c = 'Open', Visit__c = vstList[0].Id, RecordTypeId=QueryType);
		    querylist.add(query);
		    insert querylist;

		    querylist[0].Exception_Status__c = 'Closed';
		    querylist[0].Closure_Remarks__c = 'Hello';
		    RBI_QueryExceptionTriggerHandler qry = new RBI_QueryExceptionTriggerHandler();
		    RBI_QueryExceptionTriggerHandler.FirstUpdate = true; 
		    update querylist;
    }	   
	static testMethod void RBI_QueryExceptionHandler1(){
	    	list<Project__c> projlist1 = new list<Project__c>();
			Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
											 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
											 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
			Project__c proj1 = new Project__c(Project_Name__c='Test1 Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today()-30,
											 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
											 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());								 
											 
			projlist1.add(proj);
			projlist1.add(proj1);
			insert projlist1;
			
			 //insert Account Record with type as Customer
			ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
			
			list<Account> acc = new list<Account>();
	       	Account Acnt = new Account(Name = 'TestAccount', BillingStreet = 'TestStreet', BillingCity = 'Hyderabad', BillingState = 'AP', BillingCountry = 'India',
	       								BillingPostalCode = '123456', Phone = '124567', Type='Customer',RecordTypeId = CusRecType );
	       	acc.add(Acnt);
	       	insert acc;
	       	
	       	list<Contact> conlist= new list<Contact>();
	       	Contact con = new Contact(AccountId = acc[0].Id, lastname = 'lastname',Email='soumya.samal@tugboat.in',Group_Email__c='ss@gmail.com',Primary__c=true);
	       	conlist.add(con);
	       	insert conlist;
	       	
	       	//insert cus project make association to Account and project
	       	list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
			Customer_Projects__c cp = new Customer_Projects__c(Remarks__c = 'Good', Project_Id__c = projlist1[1].Id, AccountId__c = acc[0].Id,Exception__c=true);
			Customer_Projects__c cp1 = new Customer_Projects__c(Remarks__c = 'Good', Project_Id__c = projlist1[1].Id, AccountId__c = acc[0].Id,Exception__c=true);
			customerProjectlist.add(cp);
			customerProjectlist.add(cp1);
			insert customerProjectlist;
			
			//inserting lov record for PAS, FTR 
			list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
	        List_of_Values__c lov = new List_of_Values__c(Name='PAS', Entity_Name__c = 'PAS',Entity_Type__c = 'Package',
	                                Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
	        List_of_Values__c lov1 = new List_of_Values__c(Name='FTR',Entity_Name__c = 'FTR',Entity_Type__c = 'Package',
	                                Bank_Name__c = 'HDFC Bank', Completion_Year__c = 2014, Dwelling_Units__c=13, Loan_Amount__c=24000, Dev_Project_Address__c='test unit2');
	        
	        lovlist.add(lov);
	        lovlist.add(lov1);
	        insert lovlist;
	        
	        list<Project_Cust_Packages__c> prjCustPack = new list<Project_Cust_Packages__c>();
	        Project_Cust_Packages__c ProjCustomPack = new Project_Cust_Packages__c (List_of_Values__c=lovlist[0].id, Customer_Project__c=customerProjectlist[0].Id);
	        Project_Cust_Packages__c ProjCustomPack1 = new Project_Cust_Packages__c (List_of_Values__c=lovlist[1].id, Customer_Project__c=customerProjectlist[0].Id);
	        prjCustPack.add(ProjCustomPack);
	        prjCustPack.add(ProjCustomPack1);
	        insert prjCustPack; 
	         ID  QueryType = [SELECT Id FROM RecordType WHERE Name = 'Exception'].Id;
		    list<Query__c> custquerylist= new list<Query__c>();
		    Query__c query1= new Query__c (Exception_Status__c='Open', Customer_Project__c = customerProjectlist[0].Id ,RecordTypeId = QueryType);
		    custquerylist.add(query1);
		    insert  custquerylist;	
		    
		    custquerylist[0].Exception_Status__c='Closed';
		    custquerylist[0].Closure_Remarks__c = 'Hello';
		    RBI_QueryExceptionTriggerHandler qry1 = new RBI_QueryExceptionTriggerHandler();
		    RBI_QueryExceptionTriggerHandler.FirstUpdate = true; 
	    	update custquerylist;
	    		
	   }
    
}