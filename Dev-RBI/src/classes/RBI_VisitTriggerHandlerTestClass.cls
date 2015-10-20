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
private class RBI_VisitTriggerHandlerTestClass {

    static testMethod void RBI_VisitTriggerHandler() {
    	
    	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    	
    	list<UserRole> ur = [select name from UserRole where Name = 'Surveyor' OR Name = 'PAS Manager'];
    	Id usId1 = null;
		Id usId2 = null;
		for(UserRole u : ur){
			if(u.Name == 'Surveyor')
				usId1 = u.Id;
			else if(u.Name == 'PAS Manager')
				usId2 = u.Id;
		}   
    	
    	User userlist = new User(Alias = 'CRMAdmin', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
      					LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, City = 'Bangalore', userroleid = usId1, 
      					TimeZoneSidKey='America/Los_Angeles', UserName='stduser@testorg.com');
      	insert userlist;
      	
      	User userlist1 = new User(Alias = 'CRMAdmin', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
      					LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, City = 'Bangalore', userroleid = usId1, 
      					TimeZoneSidKey='America/Los_Angeles', UserName='stduse1r@testorg.com');
    	insert userlist1;
    	
    	System.runAs(userlist) {
    	
	    	list<Project__c> projlist = new list<Project__c>();
			Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today()-60,
											 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
											 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
			Project__c proj1 = new Project__c(Project_Name__c='Test1 Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today()-30,
											 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
											 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());								 
											 
			projlist.add(proj);
			projlist.add(proj1);
			insert projlist;
			
	    	list<Tower__c> tw = new list<Tower__c>();
	    	Tower__c tow = new Tower__c(Name = 'Test Tower', Project__c = projlist[0].Id,Min_Avg_Developer_BSP_per_Sq_Ft__c=12, Launched_Units__c = 90, 
	    								Min_Avg_Resale_Price_Per_Sqft__c=20,Max_Avg_Developer_BSP_per_Sq_Ft__c=25,
	    								Max_Avg_Resale_Price_Per_Sqft__c=27, Sold_Units__c=16);
	    	tw.add(tow);
	    	insert tw;
	    	ID  visitType = [SELECT Id FROM RecordType WHERE  DeveloperName = 'Followup'].Id;
	    	list<Visit__c> vstList = new list<Visit__c>();
	    	
	    	Visit__c vst1 = new Visit__c(Project__c = projlist[0].Id,  Visit_Report__c = 'Followup Report');
	    	
	    	Visit__c vst2 = new Visit__c(Project__c = projlist[0].Id,  Visit_Report__c = 'DVU Report');
	    	//insert vst1;
	    	Visit__c vst3 = new Visit__c(Status__c = 'Pending', Project__c = projlist[0].Id,  Visit_Report__c = 'TSR Report', RecordTypeId = visitType);
	    	Visit__c vst4 = new Visit__c(Status__c = 'Pending', Project__c = projlist[0].Id,  Visit_Report__c = 'First Technical Report',RecordTypeId = visitType);
	    	Visit__c vst5 = new Visit__c(Status__c = 'Forwarded', Project__c = projlist[1].Id,  Visit_Report__c = 'First Technical Report',RecordTypeId = visitType);
	    	vstList.add(vst1);
	    	vstList.add(vst2); 
	    	vstList.add(vst3); 
	    	vstList.add(vst4); 
	    	vstList.add(vst5);
	    	insert vstList;
	    	Visit__c towVis = new Visit__c(Visit_Report__c = 'Followup Report',Tower__c = tow.Id, Visit__c = vstList[0].Id, Project__c = projlist[0].Id);
	    	insert towVis;
	    	
	    	list<Additional_Charges__c> adnchg = new list<Additional_Charges__c>();
	    	Additional_Charges__c adcg = new Additional_Charges__c(Visit__c= vstList[0].Id, Charge_Per_Sqft__c = 1000, Charge_Type__c = 'PLC', Charge_Detail__c = 'Floor Rise',  
	    								From_Floor__c = '1', To_Floor__c = '20');
	  					
	    	adnchg.add(adcg);
	    	insert adnchg;
	    	
	    	list<Construction_Status__c> ConStat = new list<Construction_Status__c>();
	    	Construction_Status__c cs = new Construction_Status__c(Basement__c = 'UC', Electrification_and_Sanitation__c = '6', 
	    								Excavation_of_Footings__c = 'N', Finishing__c = '5', Masonary__c = '6',  
	    								RCC_Slab_Casting__c = '7', Visit__c = vstList[0].Id, Tower_Visit__c=towVis.Id);
	    	ConStat.add(cs);
	    	insert ConStat;
	    	
	    	list<Detail_Price_List__c> detailList = new list<Detail_Price_List__c>();
	    	Detail_Price_List__c dpl = new Detail_Price_List__c(Tower__c = tow.Id, Visit__c = vstList[0].Id, Rate_0__c = 20.0, Rate_1__c = 20.0);
	    	detailList.add(dpl);
	    	insert detailList;
	    	
	    	list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
			List_of_Values__c lov = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Infrastructure Near Project Site', Entity_Type__c='Public Convenience',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
			List_of_Values__c lov1 = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Payment Plan',Entity_Type__c='Payment Plan',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
			List_of_Values__c lov2 = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Document',Entity_Type__c='Document',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
			List_of_Values__c lov3 = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Remark',Entity_Type__c='Remark',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
			List_of_Values__c lov4 = new List_of_Values__c(Name='FTR', Entity_Name__c='Package',Entity_Type__c='Package',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit');	
			List_of_Values__c lov5 = new List_of_Values__c(Name='PAS', Entity_Name__c='Package',Entity_Type__c='Package',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit1');
									
			List_of_Values__c lov6 = new List_of_Values__c(Name='PMS', Entity_Name__c='Package',Entity_Type__c='Package',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit3');
			List_of_Values__c lov7 = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Remark',Entity_Type__c='Remark',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
									Loan_Amount__c=25000, Dev_Project_Address__c='test unit');						
			lovlist.add(lov);
			lovlist.add(lov1);
			lovlist.add(lov2);
			lovlist.add(lov3);
			lovlist.add(lov4);
			lovlist.add(lov5);
			lovlist.add(lov6);
			lovlist.add(lov7);
			insert lovlist;
			
			list<Infrastructure_Near_Project__c> infraproj = new list<Infrastructure_Near_Project__c>();
			Infrastructure_Near_Project__c infranearproj = new Infrastructure_Near_Project__c(Infrastructure_Near_Project__c = lov.Id, 
											Visit__c = vstList[0].Id);							
			infraproj.add(infranearproj);
			insert infraproj;
			
			infraproj[0].Infrastructure_Near_Project__c=lov.id;
			infraproj[0].Visit__c =vstList[1].Id;
			update  infraproj;
			
			list<Payment_Plan__c> paymentlist = new list<Payment_Plan__c>();
			Payment_Plan__c payment = new Payment_Plan__c(Discount__c =21, Plan_Type__c = lov1.Id,Visit__c = vstList[0].Id);
			paymentlist.add(payment);
			insert paymentlist;
			
			list<Project_Feedback__c> projfeedbacklist = new list<Project_Feedback__c>();
			Project_Feedback__c projfeed = new Project_Feedback__c(List_of_Values_Id__c = lov3.Id,Visit__c = vstList[0].Id, Comments__c='xxx');
			projfeedbacklist.add(projfeed);
			insert projfeedbacklist;
			
			projfeedbacklist[0].List_of_Values_Id__c=lov7.id;
			projfeedbacklist[0].Visit__c =vstList[1].Id;
			update  projfeedbacklist;
	    	
	    	//start test class method
	       	//System.Test.startTest();
	       	RBI_VisitTriggerHandler VisitTrigger= new  RBI_VisitTriggerHandler();
	       	
	       	RBI_VisitTriggerHandler.FirstUpdate = true; 
	       	list<Visit__c>  vs =[ select id, Team_Leader__c, Surveyor__c, ownerId, RecordType.Name,Status__c, Project__c,Visit_Report__c from Visit__c  where Project__c = :projlist[0].Id];
	       	system.debug('yyyyyyyyyyyyyyyy'+vs+' 111 '+vs[1].RecordType.Name);
	       	list<Visit__c> visList = new list<Visit__c>();
	       	//for(Visit__c v : vs){
	       	for(Visit__c v : vstList){
	       		if(v.Visit_Report__c == 'Followup Report'){
	       			v.Status__c='Approved';
	       		}
	       		if(v.Visit_Report__c == 'DVU Report'){
	       			v.Status__c='Positive';
	       			//v.OwnerId = userlist[0].Id;
	       		}
	       		if(v.Visit_Report__c == 'TSR Report'){
	       			v.Status__c='Negative'; 
	       			//v.OwnerId = userlist[1].Id;
	       		}	
	       		if(v.Visit_Report__c == 'First Technical Report'){
	       			if(v.Status__c == 'Forwarded')
	       				v.Status__c='Approved';
	       		}	
	       		visList.add(v);
	       		//break;
	       	}
	        update visList;
	        
	        RBI_VisitOwnerChangeTrighandler visit = new RBI_VisitOwnerChangeTrighandler();
	        RBI_VisitOwnerChangeTrighandler.FirstUpdate = true; 
	        list<Visit__c> visListOwnerChange = new list<Visit__c>();
	        for(Visit__c v : vstList){
	        	if(v.Visit_Report__c == 'DVU Report'){
	        		v.OwnerId = userlist1.Id;
	        		visListOwnerChange.add(v);
	        	}
	        	if(v.Visit_Report__c == 'First Technical Report'){
	        		v.OwnerId = userlist1.Id;
	        		visListOwnerChange.add(v);
	        	}
	        }
	        update visListOwnerChange;
	        system.debug('121212'+visList);
	       	//RBI_VisitTriggerHandler VisitTrigger= new  RBI_VisitTriggerHandler();
	       	//VisitTrigger.OnAfterInsert(vstList);
	       	
	       	
	        //System.assertEquals(vst2.Status__c ,'Approved');
	        /*set<id> updatedIds = new  set<id> ();
	        updatedIds.add(vst2.Project__c);
	       	VisitTrigger.QueryVisitRelatedListUpdate(updatedIds);
	      	VisitTrigger.AWSObjUpdate();
	       	VisitTrigger.detailPriceUpdate();
	       	VisitTrigger.projTowerUpdate();
	        VisitTrigger.ProjRelatedlistUpdate();
	      	VisitTrigger.ProjectInfrastructureNearProjectUpdate();
	      	VisitTrigger.ProjectConstructionStatusUpdate();
	      	VisitTrigger.ProjectAdditionalChargeUpdate();
	        VisitTrigger.ProjectPaymentplan();*/
	        
	        //Stop Test class
	        //System.Test.stopTest();
	    }
    }
}