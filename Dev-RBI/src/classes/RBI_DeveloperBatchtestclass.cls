@isTest(SeeAllData=true)
private class RBI_DeveloperBatchtestclass {

    static testMethod void DeveloperBatch() {
       ID DevRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Developer'].Id; 
        list<Account> acc = new list<Account>();
        Account Acnt = new Account(Name = 'TestAccount', BillingStreet = 'TestStreet', BillingCity = 'Mumbai', BillingState = 'MR', BillingCountry = 'India',
                                    BillingPostalCode = '123456', Phone = '124567',RecordTypeId = DevRecType);
         Account Acnt1 = new Account(Name = 'TestAccount1', BillingStreet = 'TestStreet', BillingCity = 'Delhi', BillingState = 'Delhi', BillingCountry = 'India',
                           BillingPostalCode = '123456', Phone = '124567',RecordTypeId = DevRecType);                            
        acc.add(Acnt);
        acc.add(Acnt1);
        insert acc;
        
        list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
        List_of_Values__c lov = new List_of_Values__c(Name='Other Projects', Entity_Name__c='Other Projects', Entity_Type__c='Other Projects',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit',Project_Type__c='Completed',Developer__c=acc[0].Id);
		List_of_Values__c lov1 = new List_of_Values__c(Name='Other Projects', Entity_Name__c='Other Projects',Entity_Type__c='Other Projects',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit',Project_Type__c='Ongoing',Developer__c=acc[1].Id);
		lovlist.add(lov);
		lovlist.add(lov1);
		insert lovlist;	
		
		//start test
        Test.StartTest();
        RBI_DeveloperAlertBatch batch = new RBI_DeveloperAlertBatch();
		Id JobId = Database.ExecuteBatch(batch);
		
		RBI_DeveloperAlertScheduler sco = new RBI_DeveloperAlertScheduler();
		String sch = '0 0 23 * * ?';        
		system.schedule('Creating', sch, sco);	
		//stop test	
		test.stopTest();				
        
    }
}