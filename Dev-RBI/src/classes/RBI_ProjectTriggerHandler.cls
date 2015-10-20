public without sharing class RBI_ProjectTriggerHandler {
    /* This is handler class for RBI_ProjectTrigger */
    public static boolean firstRun = true;
    public  list<User> userListEmail;
    Static list<Visit__c> VisitList = new list<Visit__c>(); 
    Static Id ProjRecTypeId = [select Id,name from RecordType where name='Project' and SObjectType='Visit__c' limit 1].Id;
    
    public void OnBeforeInsert(list<Project__c> project){
        //function call to check duplicate project records
        hasDuplicates(project);
        map<String, User> userlst = new map<String, User>();
        set<String> siteCity = new set<String>();
        String siteCityString = '';
        for(Project__c proj : project){
        	//Added for Phase2B on 16/8/2013
        	if((proj.Document_Received_date__c!=null) && (proj.Document_Received_by__c==null)){
        		proj.Document_Received_by__c = UserInfo.getUserId();
        	}
        	// End of Phase2B on 16/8/2013
            if(proj.Site_Address_City__c != null && (siteCity.add(proj.Site_Address_City__c)))
                //siteCity.add(proj.Site_Address_City__c); 
                siteCityString += '\''+proj.Site_Address_City__c+'\',';
        }
        if(siteCityString != null && siteCityString != '')
        	siteCityString = siteCityString.substring(0, siteCityString.length()-1); 
        system.debug('xxxxxxxxxxx'+siteCityString);
        userlst = queryUser(siteCityString);
        for(Project__c proj : project){
        	boolean userFlag = false;
            String surveyorKey = proj.Site_Address_City__c+'-Surveyor';
            //String pasManagerKey = proj.Site_Address_City__c+'-PAS Manager';
            String TechnicalHeadKey = proj.Site_Address_City__c+'-Technical Head';// Created for 2nd Phase 31.07.2013
            String zonalHeadKey = proj.Site_Address_City__c+'-Zonal Head';// Created for 2nd Phase 05.08.2013
            if(proj.Site_Address_City__c != null){
	            if(userlst.containsKey(surveyorKey) && userlst.get(surveyorKey).UserRole.Name == 'Surveyor'){
                	proj.Surveyor__c = userlst.get(surveyorKey).Id;
                }else{
                  	proj.Surveyor__c = system.Label.RBI_DefaultPASMgrId; 
                } 
                /*if(userlst.containsKey(pasManagerKey) && userlst.get(pasManagerKey).UserRole.Name == 'PAS Manager'){
                	proj.Team_Leader__c = proj.OwnerId;
                }
                else{
                 	proj.Team_Leader__c = system.Label.RBI_DefaultPASMgrId;
                }*/
                //Added for 2nd Phase 05.08.2013 
                system.debug('44444'+userlst);
                if(((proj.To_Be_Approved__c == true) || (proj.RBI_Created_By_Batch_Job__c == true)) && userlst.containsKey(zonalHeadKey) && userlst.get(zonalHeadKey).UserRole.Name == 'Zonal Head'){
                	proj.Team_Leader__c = userlst.get(zonalHeadKey).Id;
                	system.debug('5555555'+userlst.get(zonalHeadKey)+'      '+proj.Team_Leader__c);
                }
                else if((proj.To_Be_Approved__c == false) && (proj.RBI_Created_By_Batch_Job__c == false)){
                	proj.Team_Leader__c = proj.OwnerId;
                }
                else{
                 	proj.Team_Leader__c = system.Label.RBI_DefaultPASMgrId;
                }
                //ends
                //Added for 2nd Phase 31.07.2013 
                if(userlst.containsKey(TechnicalHeadKey) && userlst.get(TechnicalHeadKey).UserRole.Name == 'Technical Head'){
                	proj.Technical_Head__c = userlst.get(TechnicalHeadKey).Id;
                }
                else{
                 	proj.Technical_Head__c = system.Label.RBI_DefaultPASMgrId;
                }
                //Adding ended
            }
        }
    }
    
    public void OnBeforeUpdate(list<Project__c> projectNew, list<Project__c> projectOld, Map<Id, Project__c> ObjectMap){
        map<String, User> userlst = new map<String, User>();
        set<String> siteCity = new set<String>();
        String siteCityString = '';
        list<Project__c> projectListforUpdate = new list<Project__c>();
        boolean updateflag = false;
        for(Project__c projNew : projectNew){
        	//Added for Phase2B on 16/8/2013
        	if((projNew.Id == ObjectMap.get(projNew.Id).Id)&&(ObjectMap.get(projNew.Id).Document_Received_date__c == null)&&(projNew.Document_Received_date__c!=null) && (projNew.Document_Received_by__c==null)){
        		projNew.Document_Received_by__c = UserInfo.getUserId();
        	}
        	//End of Phase2B on 16/8/2013
            if(projNew.Id == ObjectMap.get(projNew.Id).Id && ObjectMap.get(projNew.Id).Site_Address_City__c != projNew.Site_Address_City__c){
                projectListforUpdate.add(projNew);
                if(projNew.Site_Address_City__c != null && (siteCity.add(projNew.Site_Address_City__c)))
                    siteCityString += '\''+projNew.Site_Address_City__c+'\',';
                updateflag = true;
            }
            else if(projNew.Id == ObjectMap.get(projNew.Id).Id && ObjectMap.get(projNew.Id).Project_Name__c != projNew.Project_Name__c){
                projectListforUpdate.add(projNew);
                updateflag = true;
            } 
            else if(projNew.Id == ObjectMap.get(projNew.Id).Id && ObjectMap.get(projNew.Id).Developer_Id__c != projNew.Developer_Id__c){
                projectListforUpdate.add(projNew);
                updateflag = true;
            }                                
        }
        if(updateflag){
	        //function call to check duplicate project records
	        if(projectListforUpdate!=null && projectListforUpdate.size()>0){
	            hasDuplicates(projectListforUpdate);
	        }
	        if(siteCityString != null && siteCityString != '')
	        	siteCityString = siteCityString.substring(0, siteCityString.length()-1); 
	        userlst = queryUser(siteCityString);
	        
	        for(Project__c proj : projectNew){
	            boolean userFlag = false;
	            boolean modifyFlag1 = false;
	            boolean modifyFlag2 = false;
	            String surveyorKey = proj.Site_Address_City__c+'-Surveyor';
	            //String pasManagerKey = proj.Site_Address_City__c+'-PAS Manager';
	            String TechnicalHeadKey = proj.Site_Address_City__c+'-Technical Head';// Created for 2nd Phase 31.07.2013
	            if(proj.Site_Address_City__c != null && ObjectMap.get(proj.Id).Site_Address_City__c != proj.Site_Address_City__c){
					//if(userlst.containsKey(surveyorKey) && userlst.get(surveyorKey).UserRole != null && proj.Site_Address_City__c == userlst.get(surveyorKey).City && userlst.get(surveyorKey).UserRole.Name == 'Surveyor'){
					if(userlst.containsKey(surveyorKey) && userlst.get(surveyorKey).UserRole != null && userlst.get(surveyorKey).UserRole.Name == 'Surveyor'){
			            proj.Surveyor__c = userlst.get(surveyorKey).Id;
		                system.debug('11111'+proj.Surveyor__c);
		            }
		            else{
		               	proj.Surveyor__c = system.Label.RBI_DefaultPASMgrId;
		            }
		            /*
		            if(userlst.containsKey(pasManagerKey) && userlst.get(pasManagerKey).UserRole != null && proj.Site_Address_City__c == userlst.get(pasManagerKey).City && userlst.get(pasManagerKey).UserRole.Name == 'PAS Manager'){
	    	            proj.Team_Leader__c = proj.OwnerId;
	                    system.debug('1111122'+proj.Team_Leader__c);
	                }
	                else{
	                   	proj.Team_Leader__c = system.Label.RBI_DefaultPASMgrId; 
	                }
	                */
	                // Added for 2nd Phase 31.07.2013
		            if(userlst.containsKey(TechnicalHeadKey) && userlst.get(TechnicalHeadKey).UserRole != null && userlst.get(TechnicalHeadKey).UserRole.Name == 'Technical Head'){
	    	            proj.Technical_Head__c = userlst.get(TechnicalHeadKey).Id;
	                }
	                else{
	                   	proj.Technical_Head__c = system.Label.RBI_DefaultPASMgrId; 
	                }
	                //Adding end
	            }
	        }
        }
    }
    
    /* This method is used from beforeInsert and beforeUpdate */
    
    public map<String, User> queryUser(String siteCity){
        //list<User> userList = [select name, UserRole.Name, Covering_Cities__c, City from User where City IN : siteCity];
        list<User> userList = new list<User>();
        system.debug('qqqqqqqqqq'+siteCity);
        //if((siteCity != null && siteCity != '') || (devCity != null && devCity != '')){
        if(siteCity != null && siteCity != ''){	
        	String userQuery = 'select name, UserRole.Name, Covering_Cities__c, City from User';
			//userQuery += ' where (City IN ('+siteCity+') OR Covering_Cities__c INCLUDES (' + siteCity + ')) and UserRole.Name = \'Surveyor\'';
			//userQuery += ' where (Covering_Cities__c INCLUDES (' + siteCity + ')) and UserRole.Name = \'Surveyor\'';Zonal Head
			//Added for 2nd Phase 31.07.2013
			userQuery += ' where (Covering_Cities__c INCLUDES (' + siteCity + ')) and (UserRole.Name = \'Surveyor\' OR UserRole.Name = \'Technical Head\' OR UserRole.Name = \'Zonal Head\' OR UserRole.Name = \'Operation Mgr - Data\')';
			//Adding ended
			system.debug('++++++++'+userQuery);
			userList = database.query(userQuery);
        }
        system.debug('yyyyyyyyyyy'+userList);
        map<String, User> userMap = new map<String, User>();
        for(User us : userList){
        	if(us.Covering_Cities__c != null){
        		list<String> cityList = us.Covering_Cities__c.split(';');
		        for(String strCity : cityList){
		           	userMap.put(strCity+'-'+us.UserRole.Name, us);
		        }
        	}
        } 
        system.debug('asdf'+userMap);
        return userMap;
    }
    /* This method is used from afterinsert to create project bucket on project creation*/
    /* Creating FTR Visit record when a project is created with the launch date before today */
        
        @future (callout=true)
        public static void OnAfterInsert(list<String> projectName, list<Id> projId, list<boolean> createFTR, list<Id> surveyorId){
            /*if (!Test.isRunningTest()) 
            {
                string bucketname = projectName;
                AWS_S3_ExampleController awscls;
                awscls =  new AWS_S3_ExampleController();
                if((bucketname != null) && (bucketname != '')){
                    awscls.createS3Bucket(bucketname);
                }
            }*/
            for(integer i = 0; i < projectName.size(); i++){
                if(createFTR[i]){
                    Visit__c visit = new Visit__c();
                    visit.RecordTypeId = ProjRecTypeId;
                    visit.Project__c = projId[i];
                    visit.Visit_Report__c = 'First Technical Report';
                    if(surveyorId[i] != null){
                        visit.Surveyor__c = surveyorId[i];
                        visit.OwnerId = surveyorId[i];
                    }
                    visit.Start_Date__c = system.today();    
                    VisitList.add(visit);
                }
            }
            
            try{
                insert VisitList;
            }catch(DMLException e){
                system.debug(e);
            }
         }

// This method acts as a uniqueness checker for the Project
    private  void hasDuplicates(Project__c[] projects){
        //Define a map for unique Projects
        Map <String,Project__c> projMap = new Map<String, Project__c> ();
        for (Project__c projinst: projects) {
            String Name     = (projinst.Project_Name__c==null)?'':projinst.Project_Name__c.toLowerCase();
            String city     = (projinst.Site_Address_City__c==null)?'':projinst.Site_Address_City__c.toLowerCase();
            String devname  = (projinst.Developer_Name__c==null)?'':projinst.Developer_Name__c.toLowerCase();
            String ukey = Name + city+devname;
            if (projMap.containsKey(ukey)) {
                projinst.addError('Project with this Name already exists in the system!');
            }
            else
                projMap.put(ukey,projinst);
        }

        //Check DB for dupes
        if (!projMap.isEmpty()){
            for(Project__c[] ProjCheck:[select Id, Unique_Key__c from Project__c where Unique_Key__c IN :projMap.keySet()]) {
                for(Project__c projr:ProjCheck) {
                    String currentProjectId = projr.Id;
                    if(projMap.containsKey(projr.Unique_Key__c) && (currentProjectId != projMap.get(projr.Unique_Key__c).Id)) {
                        //projMap.get(projr.Unique_Key__c).addError('Duplicate Project Name, City and Developer Name found in salesforce(id: ' + projr.id + ')');
                        projMap.get(projr.Unique_Key__c).addError('Project Name already exists for the selected City / Developer!');
                    }
                }
            }
        }
    }
    
    /* If an Project status is changed to PMR then this method will send Email to corresponding customer  */
    public void OnAfterUpdate(list<Project__c> projectNew, list<Project__c> projectOld, Map<Id, Project__c> ObjectMap){
        if (firstRun){
        	List<Messaging.SingleEmailMessage> emails;
            list<Customer_Projects__c> custProject = new list<Customer_Projects__c>();
            set<Id> projSetId = new set<Id>();
            set<Id> custProjSetId = new set<Id>();
            list<Contact> con = new list<Contact>();
            map<Id, wrapEmailProject> projWrap = new map<Id, wrapEmailProject>();
            map<Id, Project__c> projectMap = new map<Id, Project__c>();
            boolean PMRChangeFlag = false;
            //firstRun = false;
            system.debug('9999999'+projectNew[0].Status__c);
            for(Project__c projNew : projectNew){
                if(projNew.Id == ObjectMap.get(projNew.Id).Id && ObjectMap.get(projNew.Id).Status__c != projNew.Status__c && projNew.Status__c == 'PMR'){
                    projSetId.add(projNew.Id);
                    projectMap.put(projNew.Id, projNew);
                    PMRChangeFlag = true;
                    firstRun = false;
                }
            }
            if(PMRChangeFlag){
            	emails = new List<Messaging.SingleEmailMessage>();
                PMRChangeFlag = false;
                if(projSetId != null)
                    custProject = [select AccountId__c, Project_Id__c, Project_Id__r.Name, Project_Id__r.Project_Name__c, Project_Name__c from Customer_Projects__c where Project_Id__c IN : projSetId];
                for(Customer_Projects__c cusProj : custProject){
                    if(projectMap.containsKey(cusProj.Project_Id__c)){
                        //projWrap.put(cusProj.Id, new wrapEmailProject(cusProj));
                        custProjSetId.add(cusProj.AccountId__c);
                    }
                }   
                if(custProjSetId != null && custProjSetId.size() > 0)
                    con = [select name, Email, AccountId, Group_Email__c from Contact where AccountId IN : custProjSetId and Primary__c = true];
                for(Customer_Projects__c cusProj : custProject){ 
                    for(Contact c : con){ // Inner for loop
                        if(c.AccountId == cusProj.AccountId__c){
                        	String[] toAddresses;
                            Customer_Projects__c custProjRec = new Customer_Projects__c();
                            //custProjRec = projWrap.get(cusProj.Id).custProjrecord;
                            //projWrap.put(cusProj.Id, new wrapEmailProject(custProjRec, cusProj.Customer_User_Email__c));
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(c.Group_Email__c != null){
                            	toAddresses = c.Group_Email__c.split(',');
                            	mail.setToAddresses(toAddresses);
                            }
                            mail.setTemplateId(System.label.RBI_TemplateIdForPRMStatusChange);
                            mail.setTargetObjectId(c.Id);
                            mail.setWhatId(cusProj.Project_Id__c);
                            //mail.saveAsActivity = false;
                            system.debug('/////////'+toAddresses+ '1110 '+mail );
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                            emails.add(mail);
                        }
                    }// end of inner for loop   
                }   
                if(emails != null && emails.size() > 0)
                	Messaging.sendEmail(emails);
            }
        }
    }
    public class wrapEmailProject{
        public Customer_Projects__c custProjrecord;
        public String emailId;
        public wrapEmailProject(Customer_Projects__c custproj){
            custProjrecord = custproj;
        }
        public wrapEmailProject(Customer_Projects__c custproj, String conEmail){
            custProjrecord = custproj;
            emailId = conEmail;
        }
    }
}