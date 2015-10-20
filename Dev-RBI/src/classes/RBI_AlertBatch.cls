global class RBI_AlertBatch implements  Database.Batchable<sObject>{
	global String QueryString; 
	global set<Id> prjPASMgrId;
	list<Project__c> projlst;
	public list<User> userlst;
	public list<Visit__c> Visitlst;
    global list<Visit__c> VisitList;
	public set<String> siteCity;
	global set<Id> ProjId;
	public map<String, list<Project__c>> projWrap ;
	public map<String,Visit__c> visitDupCheckMap;
	public list<AsyncApexJob> job;
	list<String> PASManagerEmailId = new list<String>();
	list<Project__c> EmailProject;
    Id ProjRecTypeId;
	map<Id,User> mapOfProject;
    list<List_of_Values__c> LOVList;
	
	global RBI_AlertBatch(){
		QueryString = 'select Site_Address_City__c,Team_Lead_Email__c,PAS_Manager_Name__c, Launch_Date__c,Team_Leader__c, Surveyor__c, Launched_Flag__c, Name, OwnerId, Owner.Name, Project_Name__c from Project__c where Launched_Flag__c =\'false\' order by Team_Leader__c' ;
        siteCity = new set<String>();
        VisitList = new list<Visit__c>();
        ProjId = new set<Id>();
        projlst = new list<Project__c>();
        EmailProject = new list<Project__c>();
        projWrap = new map<String, list<Project__c>>();
        userlst = new list<User>();
	}
	global Database.QueryLocator start(Database.BatchableContext BC){  
		list<Visit__c> VisitListForEmail = new list<Visit__c>();
		map<String, list<Project__c>> projWrapForEmail ;
		return Database.getQueryLocator(QueryString);
	}
    
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
	 	projlst = scope;
	 	
        for(Project__c proj : projlst){
        	if(proj.Site_Address_City__c != null)
	 			siteCity.add(proj.Site_Address_City__c);
	 		if(proj.Launch_Date__c == system.today()){
	 			ProjId.add(proj.Id);
	 		system.debug('Manjunath ' + proj.Team_Lead_Email__c + 'Soumya ' + proj.Team_Leader__c +'  xxx  '+proj.Id);	
	 		}
	 	}
 		Visitlst = [select name, Project__c, Visit_Report__c from Visit__c where Project__c IN : ProjId];
		checkVisitRec();
    	list<Visit__c> visitForInsert = new list<Visit__c>();
		mapOfProject = new map<Id,User>();
		if(siteCity != null && siteCity.size() > 0)
		userlst = [select Name, City, Email from User where City IN : siteCity and UserRole.Name = 'PAS Manager'];
		boolean cityFlag;
		list<Project__c> projListLocal;
		set<String> PASMgrEmail = new set<String>();
        //if(userlst != null && userlst.size() > 0){
            //for(User us : userlst){
            	cityFlag = false;
            	projListLocal = new list<Project__c>();
                for(Project__c proj : projlst){ // Inner For Loop 
                	String ProjectId = proj.Id+'-First Technical Report';
                	system.debug('1111111'+proj.Team_Leader__c+' Boss '+proj.Team_Lead_Email__c);
                    //if(us.City == proj.Site_Address_City__c){
                        if(proj.Launch_Date__c == system.today()+2){
                            //projListLocal.add(proj);
                            //EmailProject.add(proj);
                            //PASManagerEmailId.add(us.Email);
                            projListLocal = new list<Project__c>();
                            list<Project__c> projListinMap = new list<Project__c>();
                            if(projWrap != null && projWrap.size() > 0 && projWrap.containsKey(proj.Team_Lead_Email__c)){
                            	projListinMap = projWrap.get(proj.Team_Lead_Email__c);
                            }
                            if(projListinMap != null && projListinMap.size() > 0){
                            	projListLocal.addAll(projListinMap);
                            }
                            projListLocal.add(proj);
                            projWrap.put(proj.Team_Lead_Email__c, projListLocal);
                        }
                        /*else if(proj.Launch_Date__c == system.today() && visitDupCheckMap.get(ProjectId) == null){
                            mapOfProject.put(proj.Id,us);
                        }*/
                    //}
                }// End of Inner For loop
                /*
                if(cityFlag){
                	projWrap.put(us.Id, new wrapEmailProject(projListLocal, us));
                	cityFlag = false;
                }*/
            //} 
            system.debug('22222222'+projWrap);
        //}
        //if(mapOfProject != null && mapOfProject.size() > 0){
			LOVList = [SELECT Entity_Name__c,Entity_Type__c,Key__c, Id FROM List_of_Values__c];	
            ProjRecTypeId = [select Id,name from RecordType where name='Project' and SObjectType='Visit__c' limit 1].Id;
        //}    
        if(LOVList != null && LOVList.size() > 0 && projlst != null && projlst.size() > 0){
            for(Project__c proj : projlst){
            	String ProjectId = proj.Id+'-First Technical Report';
                if(!(visitDupCheckMap.containsKey(ProjectId)) && (proj.Launch_Date__c == system.today() && visitDupCheckMap.get(ProjectId) == null)){
                    User userRec = new User();
                    userRec = mapOfProject.get(proj.Id);
                    for(List_of_Values__c lov : lovlist){
                    	// As per Phase 2B changes, this code has been commented. 
                        /*
                        if(lov.Entity_Name__c == 'PAS' && LOV.Entity_Type__c == 'Service Visit'){
                            Visit__c visit = new Visit__c();
                            visit.RecordTypeId = ProjRecTypeId;
                            visit.Project__c = proj.Id;
                            visit.Visit_Report__c = lov.Key__c;
                            visit.ProjecIdVisitType__c = visit.Project__c+'-'+visit.Visit_Report__c;
                            if(proj.Team_Leader__c != null){
                                visit.Team_Leader__c = proj.Team_Leader__c;
                            }
                            if(userRec != null)
                            	visit.OwnerId = proj.Team_Leader__c;
                            else
                            	visit.OwnerId = system.Label.RBI_DefaultPASMgrId;	
                            visit.Start_Date__c = system.today();    
                            VisitList.add(visit);
                        }else if(lov.Entity_Name__c == 'FTR' && lov.Entity_Type__c == 'Service Visit'){
                        */
                        if(lov.Entity_Name__c == 'FTR' && lov.Entity_Type__c == 'Service Visit'){
                           	Visit__c visit = new Visit__c();
                           	visit.RecordTypeId = ProjRecTypeId;
                           	visit.Project__c = proj.Id;
                           	visit.Visit_Report__c = lov.Key__c;
                           	visit.ProjecIdVisitType__c = visit.Project__c+'-'+visit.Visit_Report__c;
                        	if(proj.Surveyor__c != null){
                            	visit.Surveyor__c = proj.Surveyor__c;
                        	}
                        	if(userRec != null)
                        		visit.OwnerId = proj.Surveyor__c;
                        	else
                            	visit.OwnerId = system.Label.RBI_DefaultPASMgrId;		
                        	visit.Start_Date__c = system.today();    
                        	VisitList.add(visit);
                   		}
                    }    
                }
            }
        }
        try{
        	if(VisitList != null && VisitList.size() > 0)
        		insert VisitList;
        		EmailSurveyor();
        }catch(DmlException e){
        	system.debug('Error while inserting visit records from Batch jobs '+e);
        }
        system.debug('xxxxxxxx'+prjPASMgrId);
	}
    
    public void EmailSurveyor(){
        system.debug('212121'+projWrap);
        prjPASMgrId = new set<Id>();
        system.debug('bbbbbbbbbbbbb'+userlst);
        for(String PASEmail : projWrap.keySet()){
        	list<Project__c> projectRec = projWrap.get(PASEmail);
    		String body = '' ;  
            //Creating tabular format for the case details  
            body = BodyFormat(projectRec) ;  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ; 
            String[] toAddresses = new String[] {PASEmail} ;  
            mail.setToAddresses(toAddresses) ; 
            mail.setSubject('Projects going to be launched');
            //Body of email 
            mail.setHtmlBody('Dear ' + projectRec[0].PAS_Manager_Name__c + ', <br /><br />Please find below the details of Projects that are going to be launched after 2 days. <br /><br />' + body + '<br /> <br />Thanks & Regards, <br /> RealtyBI Team');  
            //Sending the email 
            if (!Test.isRunningTest()) { 
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            	system.debug('mail Sent');
           	}
        }
    	/*for(User userRec : userlst){
    		if(projWrap != null && projWrap.size() > 0 && projWrap.containsKey(userRec.Id)){
    			list<Project__c> projectRec = projWrap.get(userRec.Id).projrecord;
    			String body = '' ;  
              	//Creating tabular format for the case details  
              	body = BodyFormat(projectRec) ;  
              	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ; 
              	String[] toAddresses = new String[] {userRec.Email} ;  
              	mail.setToAddresses(toAddresses) ; 
              	mail.setSubject('Projects going to be launched');
              	//Body of email 
                mail.setHtmlBody('Dear ' + userRec.Name + ', <br /><br />Please find below the details of Projects that are going to be launched after 2 days. <br /><br />' + body + '<br /> <br />Thanks & Regards, <br /> RealtyBI Team');  
                //Sending the email  
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                system.debug('mail Sent');
    		}
    	}
        list<Project__c> ProjListWithourPASMgr = new list<Project__c>();
        for(Project__c Pro : projlst){
            
            if(prjPASMgrId.add(Pro.Id) && (Pro.Launch_Date__c == system.today()+2)){
                ProjListWithourPASMgr.add(Pro);
            }
        }
        if(ProjListWithourPASMgr != null && ProjListWithourPASMgr.size() > 0){
            String body = '' ;  
            //Creating tabular format for the case details  
            body = BodyFormat(ProjListWithourPASMgr) ;  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ; 
            String[] toAddresses = new String[] {system.Label.RBI_DefaultPASMgrEmailId} ;  
            mail.setToAddresses(toAddresses) ; 
            mail.setSubject('Projects going to be launched');
            //Body of email 
            mail.setHtmlBody('Dear ' + system.Label.RBI_DefaultPASMrgName + ', <br /><br />Please find below the details of Projects that are going to be launched after 2 days. <br /><br />' + body + '<br /> <br />Thanks & Regards, <br /> RealtyBI Team');  
            //Sending the email  
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('mail Sent');
        }*/
    }
    
    public String BodyFormat(List<Project__c> lst){  
       	String str = '' ;  
       	
    	for(Project__c pj : lst){  
    		prjPASMgrId.add(pj.Id);
        	str += '<tr><td>'+ pj.Name +'</td>'+'<td>'+ pj.Project_Name__c +'</td>'+'<td>'+ pj.Owner.Name +'</td>'+'</tr>' ;  
        }  
        str = str.replace('null' , '') ;  
        String finalStr = '' ;  
        system.debug('121212'+prjPASMgrId);
        finalStr = '<table border="1"> <td><b> Project Number</b> </td> <td><b> Project Name </b></td> <td><b> Owner </b></td> '+ str +'</table>' ;    
        return finalStr ;  
   	}  
    
	global void finish(Database.BatchableContext BC){
		// Get the ID of the AsyncApexJob representing this batch job
   		// from Database.BatchableContext.
   		// Query the AsyncApexJob object to retrieve the current job's information.
   		/*AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email  FROM AsyncApexJob WHERE Id = :BC.getJobId()];
   		// Send an email to the Apex job's submitter notifying of job completion.
   		Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
   		String[] toAddresses = new String[] {job.CreatedBy.Email};
   		mail.setToAddresses(toAddresses);
   		mail.setSubject('Batch Compeletion Report ' + job.Status);
   		mail.setPlainTextBody('The batch Apex job Processed ' + job.TotalJobItems + ' batches with ' + job.NumberOfErrors + ' failures. ');
   		Messaging.sendEmail(new Messaging.Singleemailmessage[]{	mail });*/
	}
	
	public void checkVisitRec(){
		String ProjIdReport = '';
		visitDupCheckMap = new map<String,Visit__c>();
		for(Visit__c vis : Visitlst){
        	ProjIdReport = vis.Project__c+'-'+vis.Visit_Report__c;
			visitDupCheckMap.put(ProjIdReport, vis);    			
    	}
	}
	/*public class wrapEmailProject{
		public list<Project__c> projrecord;
		public User userRec;
		public wrapEmailProject(list<Project__c> proj, User usRec){
			projrecord = proj;
			userRec = usRec;
		}
	}*/
}