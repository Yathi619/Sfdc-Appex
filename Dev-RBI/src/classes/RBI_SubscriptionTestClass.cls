@isTest(SeeAllData=true)
private class RBI_SubscriptionTestClass {

    static testMethod void RBI_Subscription() {
    //Insert Customer  Record
        ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
      	list<Account> accnt = new list<Account>();
		Account acc = new Account(Name = 'Testclass Account', Description = 'Test', RecordTypeId = CusRecType, BillingCity = 'Delhi');
		accnt.add(acc);
		insert accnt;
		
    // Insert project Record
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' , Land_Area_in_acres__c = 30.00,
										 City__c ='test',  Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
										 Launch_Date__c = System.today()-3,Site_Address_City__c='Bangalore');
		Project__c proj1 = new Project__c(Project_Name__c='Test1 Class',Status__c='PDS' , Land_Area_in_acres__c = 30.00,
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
										 Launch_Date__c = System.today()-1,Site_Address_City__c = 'Bangalore');								 					 								 
		projlist.add(proj);
		projlist.add(proj1);
		insert projlist;
		
		//retrive Record Type ID Through  Schema.DescribeSObjectResult
		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.RBI_Subscription__c; 
		Map<String,Schema.RecordTypeInfo> SubRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
		Id launchedId = SubRecordTypeInfo .get('Launched').getRecordTypeId();
		
		//Insert  Subscription Record
		list<RBI_Subscription__c> sublist = new list<RBI_Subscription__c>();
		RBI_Subscription__c sub= new RBI_Subscription__c(Start_Date__c=System.today()-3,Customer__c = accnt[0].Id,Launched_Cities__c = 'Bangalore', RecordTypeId = launchedId);
		sublist.add(sub); 
		insert sublist;
		
		//Update Subscription List 
		sublist[0].Start_Date__c = System.today()-1;
		update sublist;
    }
}