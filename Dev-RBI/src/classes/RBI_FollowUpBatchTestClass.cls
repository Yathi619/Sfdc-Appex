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
@isTest
private class RBI_FollowUpBatchTestClass {

    static testMethod void myUnitTest() {
         //Querying user from org
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        list<UserRole> ur = [select name from UserRole where Name = 'Surveyor'];
        User u = new User(Alias = 'CRMAdmin', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, City = 'Bangalore', userroleid = ur[0].Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='stduser@testorg.com');
        System.runAs(u) {           
        
            list<Project__c> projlist = new list<Project__c>();
            Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PMR' , Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today()-50,
                                             City__c ='test', Site_contact_NameDesg__c = 'Test', Brochure_Zipcode__c = '123456' , Construction_Start_Date__c = System.today()-25,
                                             Site_Address_zipcode__c = '654321' , Launch_Date__c = System.today(),Site_Address_City__c='Bangalore',
                                             construction_Status__c='Underconstruction');
            Project__c proj1 = new Project__c(Project_Name__c='Test Class12',Status__c='PDS' , Land_Area_in_acres__c=30.00, Construction_Start_Date__c = System.today()-25,
                                             City__c ='test', Site_contact_NameDesg__c = 'Test', Brochure_Zipcode__c = '123456' , 
                                             Site_Address_zipcode__c = '654321' , Launch_Date__c = System.today(),Site_Address_City__c='Bangalore',
                                             construction_Status__c='Underconstruction',Site_Visit_Date__c=System.Today()-50);
            Project__c proj2 = new Project__c(Project_Name__c='Test Class2',Status__c='PDS' , Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today()-50,
                                             City__c ='test', Site_contact_NameDesg__c = 'Test', Brochure_Zipcode__c = '123456' , Construction_Start_Date__c = System.today()-25,
                                             Site_Address_zipcode__c = '654321' , Launch_Date__c = System.today(),Site_Address_City__c='Bangalore',
                                             construction_Status__c='Underconstruction');                                
            projlist.add(proj);
            projlist.add(proj1);
            projlist.add(proj2);
            insert projlist;
            
            ID  FollowupType = [SELECT Id FROM RecordType WHERE Name = 'Followup'].Id;
            ID  TowerType = [SELECT Id FROM RecordType WHERE Name = 'Tower'].Id;
            
            list<Visit__c> vstList = new list<Visit__c>();
            Map<Id, Visit__c> mapVis = new Map<Id, Visit__c>();
            Visit__c vst = new Visit__c(Status__c = 'Approved',  Visit_Report__c = 'First Technical Report',Construction__c = 'Underconstruction',
                                        Surveyor__c=u.id,Project__c=projlist[0].id,Closed_Date__c = system.today()-30);
            Visit__c vst1 = new Visit__c(Status__c = 'Approved',  Visit_Report__c = 'First Technical Report',Construction__c = 'Completed',
                                        Surveyor__c=u.id,Project__c=projlist[1].id ,Closed_Date__c=System.today()-20);  
            Visit__c vst2 = new Visit__c(Status__c = 'Positive',  Visit_Report__c = 'DVU Report',Construction__c = 'Completed',
                                        Surveyor__c=u.id,Project__c=projlist[1].id ,Closed_Date__c=System.today());
            Visit__c vst3 = new Visit__c(Status__c = 'Negative',  Visit_Report__c = 'TSR Report',Construction__c = 'Completed',
                                        Surveyor__c=u.id,Project__c=projlist[1].id ,Closed_Date__c=System.today());                             
            Visit__c vst4 = new Visit__c(Status__c = 'Approved',  Visit_Report__c = 'First Technical Report',Construction__c = 'Completed',
                                        Surveyor__c=u.id,RecordTypeId=TowerType,Project__c=projlist[2].id );        
            Visit__c vst5 = new Visit__c(Status__c = 'Approved',  Visit_Report__c = 'DVU Report',Construction__c = 'Completed',
                                        Surveyor__c=u.id,RecordTypeId=TowerType,Project__c=projlist[2].id );                                    
                                                                                        
            vstList.add(vst);
            vstList.add(vst1);
            vstList.add(vst2);
            vstList.add(vst3);
            vstList.add(vst4);
            vstList.add(vst5);
            insert vstList;
            
            list<Tower__c> tw = new list<Tower__c>();
            Tower__c tow = new Tower__c(Name = 'Test Tower', Project__c = projlist[2].Id,Min_Avg_Developer_BSP_per_Sq_Ft__c=12, Launched_Units__c = 80,
                                        Min_Avg_Resale_Price_Per_Sqft__c=20, Max_Avg_Developer_BSP_per_Sq_Ft__c=25, Construction_Start_Date__c = System.today()- 10,
                                        Max_Avg_Resale_Price_Per_Sqft__c=27, Sold_Units__c=16);
            tw.add(tow);
            insert tw;
            
            list<Additional_Charges__c> adnchg = new list<Additional_Charges__c>();
            Additional_Charges__c adcg = new Additional_Charges__c(Charge_Per_Sqft__c = 1000,Project__c=projlist[2].Id, Charge_Type__c = 'PLC', Charge_Detail__c = 'Floor Rise',  
                                        From_Floor__c = '1', To_Floor__c = '20');
            adnchg.add(adcg);
            insert adnchg;
            
            list<Construction_Status__c> ConStat = new list<Construction_Status__c>();
            Construction_Status__c cs = new Construction_Status__c(Basement__c = 'UC', Electrification_and_Sanitation__c = '6', 
                                        Excavation_of_Footings__c = 'N', Finishing__c = '5', Masonary__c = '6', 
                                        RCC_Slab_Casting__c = '7', Visit__c = vst.Id, Tower__c = tow.Id);
            ConStat.add(cs);
            insert ConStat;
            
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
                                                                
            lovlist.add(lov);
            lovlist.add(lov1);
            lovlist.add(lov2);
            lovlist.add(lov3);
            lovlist.add(lov4);
            lovlist.add(lov5);
            lovlist.add(lov6);
            insert lovlist;
            
            list<Infrastructure_Near_Project__c> infraproj = new list<Infrastructure_Near_Project__c>();
            Infrastructure_Near_Project__c infranearproj = new Infrastructure_Near_Project__c(Infrastructure_Near_Project__c = lov.Id, 
                                            Project_Id__c = projlist[2].Id);
            infraproj.add(infranearproj);
            insert infraproj;
            
            list<Payment_Plan__c> paymentlist = new list<Payment_Plan__c>();
            Payment_Plan__c payment = new Payment_Plan__c(Discount__c =20, Project__c=projlist[2].Id, Plan_Type__c = lov1.Id);
            Payment_Plan__c payment1 = new Payment_Plan__c(Discount__c =20,  Plan_Type__c = lov1.Id, Project__c=projlist[0].Id);
            paymentlist.add(payment);
            paymentlist.add(payment1);
            insert paymentlist;
            
            list<Project_Feedback__c> projfeedbacklist = new list<Project_Feedback__c>();
            Project_Feedback__c projfeed = new Project_Feedback__c(List_of_Values_Id__c = lovlist[3].Id, Project__c=projlist[0].Id,Comments__c='xxx');
            Project_Feedback__c projfeed1 = new Project_Feedback__c(List_of_Values_Id__c = lovlist[3].Id, Comments__c='xxx',Project__c=projlist[2].Id);
            projfeedbacklist.add(projfeed);
            projfeedbacklist.add(projfeed1);
            insert projfeedbacklist;
            
            list<Project_Document_Status__c> prjDoc = new list<Project_Document_Status__c>();
            Project_Document_Status__c prjDocStat = new Project_Document_Status__c(Date_of_Approval__c = System.today(), Provided_By_Bank__c = 'Yes',
                                                    Visit__c = vst.Id, Project_Document__c = lov2.Id);
            prjDoc.add(prjDocStat);
            insert prjDoc;  
            
            ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
            ID RbiRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RBI'].Id;
            list<Account> Acclist = new list<Account>();
            Account acc = new Account(Name='Test Class',Weightage_Basement__c=10 ,Weightage_Electrification_Sanitation__c=10.00, Weightage_Excavaton_of_Footings__c = 10,
                                             Weightage_Finishing__c =5, Weightage_Masonary__c = 3,RecordTypeId=RbiRecType,Project_Monitoring_Frequency__c=25);
            Account acc1 = new Account(Name='Test1 Class',Weightage_Basement__c=10 ,Weightage_Electrification_Sanitation__c=5, Weightage_Excavaton_of_Footings__c = 12,
                                             Weightage_Finishing__c =05, Weightage_Masonary__c = 3,RecordTypeId=CusRecType,Project_Monitoring_Frequency__c=30);                              
            Acclist.add(acc);
            Acclist.add(acc1);
            insert Acclist;
            
            list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
            Customer_Projects__c cp1 = new Customer_Projects__c(Project_Id__c = projlist[0].Id,Weightage_Type__c='Customer', AccountId__c =Acclist[1].Id);
            customerProjectlist.add(cp1);
            insert customerProjectlist;
            
            list<Project_Cust_Packages__c> prjCustpkg = new list<Project_Cust_Packages__c>();
            Project_Cust_Packages__c prjCpkg = new Project_Cust_Packages__c(
                                                    Service_Requested_Date__c=System.today(),End_Date__c=system.today() + 365 ,Customer_Project__c=cp1.id,List_of_Values__c = lovlist[6].Id);                           
            prjCustpkg.add(prjCpkg);
            insert prjCustpkg;                      
            
            list<Detail_Price_List__c> detailList = new list<Detail_Price_List__c>();
            Detail_Price_List__c dpl = new Detail_Price_List__c(Tower__c = tow.Id, Project__c=projlist[2].Id, Rate_0__c = 20.0, Rate_1__c = 20.0);
            detailList.add(dpl);
            insert detailList;
            
            //start test
            Test.StartTest();
            RBI_FollowUpBatch batch =  new RBI_FollowUpBatch();
            //batch.QueryString = 'Select Visit_Report__c, Status__c, Visit__c,Project__r.Site_Contact_NameDesg__c,Project__r.construction_Status__c, Project__r.Count_Of_Customers__c,Project__r.Surveyor__c, Project__r.Site_Visit_Date__c, Tower__c, Project__c, Name, Closed_Date__c From Visit__c v where Project__c != \'\' and (Visit_Report__c =\'Followup Report\' or Visit_Report__c =\'First Technical Report\')';
            //batch.start(null);
            system.debug('xxxxxxxxxxxx'+vstList);
            //batch.execute(null, vstList);
            //batch.finish(null);
            /*batch.start(null);
            batch.followUpVisit(projlist[0].Id, vstList[0].Id, projlist[0].Site_Contact_NameDesg__c, vstList[0].Construction__c);
            batch.towerVisit();
            batch.projectQuery(mapVis);*/
            Id JobId = Database.executeBatch(batch);
            list<Visit__c>  vs =[ select id,Project__c,Visit_Report__c from Visit__c  where Project__c = :projlist[0].Id limit 1];
            system.debug('the follow up visit is' +vs);
            /*
            vs.Status__c='Approved';
            vs.Visit_Report__c='First Technical Report';
            update vs;
            system.debug('the follow up visit After is' +vs);
            projfeed1.Visit__c=vs.Id;
            payment1.Visit__c=vs.Id;
            upsert projfeed1;
            upsert payment1;*/
            //System.abortJob(JobId);
            RBI_FollowUpScheduler sco = new RBI_FollowUpScheduler();
            String sch = '0 0 23 * * ?';
            //String sch = (String)system.now();              
            system.schedule('visit Creates', sch, sco);
            
            //stop test
            test.stopTest();
        }   
    }
}