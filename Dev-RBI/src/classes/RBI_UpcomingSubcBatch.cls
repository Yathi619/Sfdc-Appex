global class RBI_UpcomingSubcBatch implements  Database.Batchable<sObject>{
	global String QueryString; 
	global date todaysDate ;
	list<Project__c> projlst;
	map<Id,Project__c> UpcomingProjmap;
	map<Id,Project__c> LaunchedProjmap;
	set<Id> projId;
	map<Id, Account> customerMap;
    set<Id> custProjId;
	map<Id,RBI_Subscription__c> upcomingSubscriptionMap;
	map<Id,RBI_Subscription__c> allSubscriptionMap;
	map<Id,RBI_Subscription__c> lauchedSubscriptionMap;
    map<Id,RBI_Subscription__c> custIdSubsMap;
    map<String, Customer_Projects__c> custProjIdMapForDups;
    map<String, Customer_Projects__c> launchCustProjIdMapForDups;
    map<String, Project_Cust_Packages__c> custpackMapForDups;
    map<String, Project_Cust_Packages__c> launchedCustpackMapForDups;
    map<String, List_of_Values__c> listOfValuesMap;
    list<Customer_Projects__c> custProjList = new list<Customer_Projects__c>();
    list<Project_Cust_Packages__c> custPackList = new list<Project_Cust_Packages__c>();
    map<String, Customer_Projects__c> custProjForInsert;
    map<String, Project_Cust_Packages__c> custPackForInsert;
	global RBI_UpcomingSubcBatch(){
        custProjId = new set<Id>(); 
        todaysDate = system.today();
		//QueryString = 'select Name, Site_Address_City__c from Project__c where ((To_Be_Approved__c = false and Project_Rejected__c = false) and (Launch_Date__c >= TODAY))' ;
		QueryString = 'select Name, Site_Address_City__c, Project_Name__c, CreatedDate, Launch_Date__c from Project__c where ((To_Be_Approved__c = false AND Project_Rejected__c = false) AND ((Launch_Date__c >= TODAY) OR CreatedDate = TODAY))' ;
	}
	global Database.QueryLocator start(Database.BatchableContext BC){  
		return Database.getQueryLocator(QueryString);
	}
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		projlst = scope; 
		UpcomingProjmap = new map<Id, Project__c>();// holds all upcoming projects and which is approved for customers.
		LaunchedProjmap = new map<Id, Project__c>();// holds all Lauched projects and which is approved for customers.
		custProjIdMapForDups = new map<String, Customer_Projects__c>();
        launchCustProjIdMapForDups = new map<String, Customer_Projects__c>();
		for(Project__c proj : projlst){
			if(proj.Launch_Date__c > system.today()){
				UpcomingProjmap.put(proj.Id, proj);
				system.debug('888888888'+proj);
			}
			
			/* logic for launched project created today which comes under start date of the subcription object */
			//Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
			else if(proj.Launch_Date__c <= system.today() && date.newinstance(proj.CreatedDate.year(), proj.CreatedDate.month(), proj.CreatedDate.day()) == system.today()){
				LaunchedProjmap.put(proj.Id, proj);
				system.debug('777777777'+proj);
			}
			system.debug('99999999'+proj.Launch_Date__c +' ' +date.newinstance(proj.CreatedDate.year(), proj.CreatedDate.month(), proj.CreatedDate.day())+''+system.today());
		}
		custIdSubsMap = new map<Id, RBI_Subscription__c>();
		system.debug('aaaaaaaa'+LaunchedProjmap);
		//allSubscriptionMap = new map<Id, RBI_Subscription__c> ([select Name, RecordType.Name, Start_Date__c, Launched_Cities__c, Customer__c, Upcoming_Cities__c, Type__c from RBI_Subscription__c where Type__c = 'Upcoming']);
		allSubscriptionMap = new map<Id, RBI_Subscription__c> ([select Name, RecordType.Name, Start_Date__c, Launched_Cities__c, Customer__c, Upcoming_Cities__c from RBI_Subscription__c]);
		if(allSubscriptionMap != null && allSubscriptionMap.size() > 0){
			upcomingSubscriptionMap = new map<Id, RBI_Subscription__c>();
			lauchedSubscriptionMap = new map<Id, RBI_Subscription__c>();
		}
		for(RBI_Subscription__c sub : allSubscriptionMap.values()){
			if(sub.RecordType.Name == 'Upcoming'){
				upcomingSubscriptionMap.put(sub.Id, sub);
				system.debug('&&&&&&&'+sub);
			}else if(sub.RecordType.Name == 'Launched' && sub.Launched_Cities__c != null && sub.Start_Date__c != null){
				lauchedSubscriptionMap.put(sub.Id, sub);
				system.debug('******'+sub);
			}
	    	custIdSubsMap.put(sub.Customer__c, sub);
	    }
		system.debug('44444444'+lauchedSubscriptionMap);
	    // This will contains all the customer
	    if(custIdSubsMap != null && custIdSubsMap.size() > 0){
	    	customerMap = new map<Id, Account>([select name, Current_Contract_End_Date__c from Account where Id IN : custIdSubsMap.keySet()]);
	    	system.debug('1111111111'+customerMap);
	    }

	    system.debug('///////'+upcomingSubscriptionMap);
	    system.debug('///////'+lauchedSubscriptionMap);
	    if((upcomingSubscriptionMap != null && upcomingSubscriptionMap.size() > 0 ) || (lauchedSubscriptionMap != null && lauchedSubscriptionMap.size() > 0 ) ){
	    	// List creation for both the cases
	    	list<List_of_Values__c> lovList = [Select name, Entity_Type__c from List_of_Values__c where Entity_Type__c = 'Package'];
        	listOfValuesMap = new map<String, List_of_Values__c>();
        	for(List_of_Values__c lov : lovList){
        		if(lov.Entity_Type__c=='Package'){
        			listOfValuesMap.put(lov.Name, lov);
        		}
        	}
        	// query for customer project dups check in customer project
        	//(UpcomingProjmap != null && UpcomingProjmap.size > 0)?projId.addAll(UpcomingProjmap.keySet()):'';
        	if((UpcomingProjmap != null && UpcomingProjmap.size() > 0) || (LaunchedProjmap != null && LaunchedProjmap.size() > 0)){
        		projId = new set<Id>();
        		if(UpcomingProjmap != null && UpcomingProjmap.size() > 0)
        			projId.addAll(UpcomingProjmap.keySet());
        		if(LaunchedProjmap != null && LaunchedProjmap.size() > 0)	
        			projId.addAll(LaunchedProjmap.keySet());
        	}
        	if(custIdSubsMap != null && custIdSubsMap.size() > 0){
	        	custProjList = [select name, Project_Id__c,Project_Id__r.CreatedDate, Project_Id__r.Launch_Date__c, AccountId__c from Customer_Projects__c where AccountId__c = : custIdSubsMap.keySet() and Project_Id__c = :projId];
	        	if(custProjList != null && custProjList.size() > 0){
	        		custProjIdMapForDups = new map<String, Customer_Projects__c>();
        			launchCustProjIdMapForDups = new map<String, Customer_Projects__c>();
	        	}
        	}
	        
	        for(Customer_Projects__c custProj : custProjList){
	            String projId = custProj.Project_Id__c;
	            String accId = custProj.AccountId__c;
	            if(custProj.Project_Id__r.Launch_Date__c > system.today()){
	            	custProjIdMapForDups.put(projId+'-'+accId, custProj);
	            }
	            
	            else if(date.newinstance(custProj.Project_Id__r.CreatedDate.year(), custProj.Project_Id__r.CreatedDate.month(), custProj.Project_Id__r.CreatedDate.day()) == system.today() &&  custProj.Project_Id__r.Launch_Date__c <= system.today()){
	            	launchCustProjIdMapForDups.put(projId+'-'+accId, custProj);
	            }
	            custProjId.add(custProj.Id);
	        }
	        // query for customer package dups check for that customer package
	        if(custProjId != null && custProjId.size() > 0){
	        	
	        	custPackList = [select name, List_of_Values__c,List_of_Values__r.Name,Customer_Project__c, Customer_Project__r.Project_Id__r.Launch_Date__c, Customer_Project__r.Project_Id__r.CreatedDate  from Project_Cust_Packages__c where Customer_Project__c = : custProjId];
	        	if(custPackList != null && custPackList.size() > 0){
	        		custpackMapForDups = new map<String, Project_Cust_Packages__c>();
	        		launchedCustpackMapForDups = new map<String, Project_Cust_Packages__c>();
	        	}
	        
	        
		        for(Project_Cust_Packages__c custPack : custPackList){
		        	if(custPack.Customer_Project__r.Project_Id__r.Launch_Date__c > system.today()){
			            if(custPack.List_of_Values__r.Name == 'PAS')
			                custpackMapForDups.put(custPack.Customer_Project__c+'-PAS',custPack);
			            else if(custPack.List_of_Values__r.Name == 'FTR')   
			            	custpackMapForDups.put(custPack.Customer_Project__c+'-FTR',custPack);
		        	}    	
		        	
		        	else if(date.newinstance(custPack.Customer_Project__r.Project_Id__r.CreatedDate.year(), custPack.Customer_Project__r.Project_Id__r.CreatedDate.month(), custPack.Customer_Project__r.Project_Id__r.CreatedDate.day()) == system.today() && custPack.Customer_Project__r.Project_Id__r.Launch_Date__c <= system.today()){
		        		if(custPack.List_of_Values__r.Name == 'PAS')
			                launchedCustpackMapForDups.put(custPack.Customer_Project__c+'-PAS',custPack);
			            else if(custPack.List_of_Values__r.Name == 'FTR')   
			            	launchedCustpackMapForDups.put(custPack.Customer_Project__c+'-FTR',custPack);
		        	}
		        }
	    	}    
	        custProjForInsert = new map<String, Customer_Projects__c>();
        	custPackForInsert = new map<String, Project_Cust_Packages__c>();
        	
	    }
		
		
		/* Logic for upcoming projects */ 
		if(upcomingSubscriptionMap != null && upcomingSubscriptionMap.size() > 0  && !upcomingSubscriptionMap.isEmpty()){
			//custProjForInsert = new map<String, Customer_Projects__c>();
        	//custPackForInsert = new map<String, Project_Cust_Packages__c>();
	        // association the pas service to customer 
	        for(Project__c proj : UpcomingProjmap.values()){
	        	for(RBI_Subscription__c subc : upcomingSubscriptionMap.values()){
	        		system.debug('121212'+subc);
	        		list<String> subCitiesList = new list<String>();
	        		if(subc.Upcoming_Cities__c != null)
	        			subCitiesList = subc.Upcoming_Cities__c.split(';');
	        		String projId = proj.Id;
	            	String accId = subc.Customer__c;
	        		for(String city : subCitiesList){
	        			// if there is no customer project
	        			//if(city == proj.Site_Address_City__c && custProjIdMapForDups != null && custProjIdMapForDups.size() > 0 && !custProjIdMapForDups.containsKey(projId+'-'+accId) && !custProjForInsert.containsKey(projId+'-'+accId)){
	        			if(city == proj.Site_Address_City__c && !custProjIdMapForDups.containsKey(projId+'-'+accId) && !custProjForInsert.containsKey(projId+'-'+accId)){
	        				custProjForInsert.put(projId+'-'+accId, new Customer_Projects__c(AccountId__c = accId, Project_Id__c = projId));
	        				if(customerMap != null && customerMap.size() > 0 && customerMap.containsKey(accId)){
	        					custPackForInsert.put(projId+'-'+accId+'-PAS', new Project_Cust_Packages__c(List_of_Values__c = listOfValuesMap.get('PAS').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(accId).Current_Contract_End_Date__c));
	        					custPackForInsert.put(projId+'-'+accId+'-FTR', new Project_Cust_Packages__c(List_of_Values__c = listOfValuesMap.get('FTR').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(accId).Current_Contract_End_Date__c));
	        				}
	        			}
	        			// if there is customer project, then check for PAS service
	        			else if(city == proj.Site_Address_City__c && custProjIdMapForDups != null && custProjIdMapForDups.size() > 0 && custProjIdMapForDups.containsKey(projId+'-'+accId) && !custProjForInsert.containsKey(projId+'-'+accId)){
	        				if(customerMap != null && customerMap.size() > 0 && customerMap.containsKey(accId)){
		        				if(custpackMapForDups != null && custpackMapForDups.size() > 0 && !custpackMapForDups.containsKey(custProjIdMapForDups.get(projId+'-'+accId).Id+'-PAS')){
		        					custPackForInsert.put(projId+'-'+accId+'-PAS', new Project_Cust_Packages__c(List_of_Values__c = listOfValuesMap.get('PAS').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(accId).Current_Contract_End_Date__c, Customer_Project__c = custProjIdMapForDups.get(projId+'-'+accId).Id));
		        				}
		        				if(custpackMapForDups != null && custpackMapForDups.size() > 0 && !custpackMapForDups.containsKey(custProjIdMapForDups.get(projId+'-'+accId).Id+'-FTR')){
		        					custPackForInsert.put(projId+'-'+accId+'-FTR', new Project_Cust_Packages__c(List_of_Values__c = listOfValuesMap.get('FTR').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(accId).Current_Contract_End_Date__c, Customer_Project__c = custProjIdMapForDups.get(projId+'-'+accId).Id));
		        				}
	        				}
	        			}
	        		}
	        	}
	        }
		}
		/* End of upcoming projects */
		system.debug('aaaaaaaa'+LaunchedProjmap);
		system.debug('aaaaaaaa1111111'+launchCustProjIdMapForDups);
		system.debug('**********'+launchedCustpackMapForDups);
		/* Logic for Launched projects created today */ 
		if(lauchedSubscriptionMap != null && lauchedSubscriptionMap.size() > 0  && !lauchedSubscriptionMap.isEmpty()){
			//custProjForInsert = new map<String, Customer_Projects__c>();
        	//custPackForInsert = new map<String, Project_Cust_Packages__c>();
        	system.debug('333333'+LaunchedProjmap);
	        // association the pas service to customer 
	        for(Project__c proj : LaunchedProjmap.values()){
	        	for(RBI_Subscription__c subc : lauchedSubscriptionMap.values()){
	        		system.debug('222222'+subc);
	        		system.debug('@@@@@@@@'+subc.Start_Date__c +'  '+ proj.Launch_Date__c+proj.Project_Name__c + system.today());
	        		if(subc.Start_Date__c <= proj.Launch_Date__c && proj.Launch_Date__c <= system.today()){
		        		list<String> subCitiesList = new list<String>();
		        		if(subc.Launched_Cities__c != null)
		        			subCitiesList = subc.Launched_Cities__c.split(';');
		        		String projId = proj.Id;
		            	String accId = subc.Customer__c;
		        		for(String city : subCitiesList){
		        			// if there is no customer project
		        			if(city == proj.Site_Address_City__c && !launchCustProjIdMapForDups.containsKey(projId+'-'+accId) && !custProjForInsert.containsKey(projId+'-'+accId)){
		        				custProjForInsert.put(projId+'-'+accId, new Customer_Projects__c(AccountId__c = accId, Project_Id__c = projId));
		        				if(customerMap != null && customerMap.size() > 0 && customerMap.containsKey(accId)){
		        					custPackForInsert.put(projId+'-'+accId+'-PAS', new Project_Cust_Packages__c(List_of_Values__c = listOfValuesMap.get('PAS').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(accId).Current_Contract_End_Date__c));
		        					custPackForInsert.put(projId+'-'+accId+'-FTR', new Project_Cust_Packages__c(List_of_Values__c = listOfValuesMap.get('FTR').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(accId).Current_Contract_End_Date__c));
		        				}
		        				
		        			}
		        			// if there is customer project, then check for PAS service
		        			else if(city == proj.Site_Address_City__c && launchCustProjIdMapForDups != null && launchCustProjIdMapForDups.size() > 0 && launchCustProjIdMapForDups.containsKey(projId+'-'+accId) && !custProjForInsert.containsKey(projId+'-'+accId)){
		        				if(customerMap != null && customerMap.size() > 0 && customerMap.containsKey(accId)){
			        				if(custpackMapForDups != null && custpackMapForDups.size() > 0 && !launchedCustpackMapForDups.containsKey(launchCustProjIdMapForDups.get(projId+'-'+accId).Id+'-PAS')){
			        					custPackForInsert.put(projId+'-'+accId+'-PAS', new Project_Cust_Packages__c(List_of_Values__c = listOfValuesMap.get('PAS').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(accId).Current_Contract_End_Date__c, Customer_Project__c = launchCustProjIdMapForDups.get(projId+'-'+accId).Id));
			        				}
			        				if(custpackMapForDups != null && custpackMapForDups.size() > 0 && !launchedCustpackMapForDups.containsKey(launchCustProjIdMapForDups.get(projId+'-'+accId).Id+'-FTR')){
			        					custPackForInsert.put(projId+'-'+accId+'-FTR', new Project_Cust_Packages__c(List_of_Values__c = listOfValuesMap.get('FTR').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(accId).Current_Contract_End_Date__c, Customer_Project__c = launchCustProjIdMapForDups.get(projId+'-'+accId).Id));
			        				}
		        				}
		        			}
		        		}
	        		}
	        	}
	        }
		}
		system.debug('5555555555'+lauchedSubscriptionMap);
		system.debug('5555555555'+upcomingSubscriptionMap);
		/* End of Launched projects created today */
		if((upcomingSubscriptionMap != null && upcomingSubscriptionMap.size() > 0  && !upcomingSubscriptionMap.isEmpty()) || (lauchedSubscriptionMap != null && lauchedSubscriptionMap.size() > 0  && !lauchedSubscriptionMap.isEmpty())){
			try{
	        	if(custProjForInsert != null && custProjForInsert.size() > 0){
	        		insert custProjForInsert.Values();
	        	}
	        	for(Customer_Projects__c custProj : custProjForInsert.Values()){
	        		String projId = custProj.Project_Id__c;
	            	String accId = custProj.AccountId__c;
	            	if(custPackForInsert != null && custPackForInsert.size() > 0 && custPackForInsert.containsKey(projId+'-'+accId+'-PAS')){
	            		custPackForInsert.get(projId+'-'+accId+'-PAS').Customer_Project__c = custProj.Id;
	            	}
	            	if(custPackForInsert != null && custPackForInsert.size() > 0 && custPackForInsert.containsKey(projId+'-'+accId+'-FTR')){
	            		custPackForInsert.get(projId+'-'+accId+'-FTR').Customer_Project__c = custProj.Id;
	            	}
	            	system.debug('+++++++'+custPackForInsert);
	        	}
	        	if(custPackForInsert != null && custPackForInsert.size() > 0){
	        		insert custPackForInsert.values();
	        	}
	        	
	        }catch(DMLException e){
	        	system.debug(e);
	        }
		}
	}
	global void finish(Database.BatchableContext BC){
		
	}
}