public with sharing class RBI_SubscriptionTriggerHandler {
	
	Map<Id, Date> custIdDateMap;
	Map<Id, String> custIdCityMap;
	Set<String> LaunchedCities;
	boolean callFutureFlag;
	public Id launchedId;
	
	public RBI_SubscriptionTriggerHandler(){
		launchedId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Launched'].Id;
		custIdDateMap = new Map<Id, Date>();
		LaunchedCities = new Set<String>();
		custIdCityMap = new Map<Id, String>();
		callFutureFlag = false;
	}
	
	public void OnAfterInsert(list<RBI_Subscription__c> subscription){
		for(RBI_Subscription__c sub : subscription){
			if(sub.Start_Date__c != null && sub.Launched_Cities__c != null && sub.RecordTypeId == launchedId){
				list<String> cityList = sub.Launched_Cities__c.split(';');
				LaunchedCities.addAll(cityList);
				custIdDateMap.put(sub.Customer__c, sub.Start_Date__c);
				custIdCityMap.put(sub.Customer__c, sub.Launched_Cities__c);
				callFutureFlag = true;
			}
		}
		if(callFutureFlag){
			futureHandler(custIdDateMap, custIdCityMap, LaunchedCities);
		}
	}
	
	public void OnAfterUpdate(list<RBI_Subscription__c> newSubscrip, list<RBI_Subscription__c> oldSubscrip, Map<Id, RBI_Subscription__c> oldsubmap){
		for(RBI_Subscription__c subsc : newSubscrip){
			if((subsc.Id == oldsubmap.get(subsc.Id).Id && oldsubmap.get(subsc.Id).Start_Date__c != subsc.Start_Date__c) || (subsc.Id == oldsubmap.get(subsc.Id).Id && oldsubmap.get(subsc.Id).Launched_Cities__c != subsc.Launched_Cities__c)){
				if((subsc.RecordTypeId == launchedId)){
					list<String> cityList = subsc.Launched_Cities__c.split(';');
					LaunchedCities.addAll(cityList);
					custIdDateMap.put(subsc.Customer__c, subsc.Start_Date__c);
					custIdCityMap.put(subsc.Customer__c, subsc.Launched_Cities__c);
					callFutureFlag = true;
				}
			}
		}
		if(callFutureFlag){
			futureHandler(custIdDateMap, custIdCityMap, LaunchedCities);
		}
	}
	
	@future (callout=true)
	public static void futureHandler(Map<Id, Date> mapDt, Map<Id, String> mapStrCity, set<String> cityLaunched){
		list<Customer_Projects__c> cusProjlist = new list<Customer_Projects__c>();
		Map<String, Customer_Projects__c> mapDuplicateCusProj = new Map<String, Customer_Projects__c>();
		list<Customer_Projects__c> CusProjinsert = new list<Customer_Projects__c>();
		list<Customer_Projects__c> CusProjExandNew = new list<Customer_Projects__c>();
		
		list<Project_Cust_Packages__c> custPkginsert = new list<Project_Cust_Packages__c>(); 
		Map<String, Project_Cust_Packages__c> mapPrjCustPkgDup = new map<String, Project_Cust_Packages__c>();
		list<Project_Cust_Packages__c> custPkgList = new list<Project_Cust_Packages__c>();
		
		Map<String, List_of_Values__c> lovmap = new Map<String, List_of_Values__c>(); 
		list<List_of_Values__c> lovList = new list<List_of_Values__c>();
		set<Id> projId = new set<Id>();
		set<Id> custId = new set<Id>();
		set<Id> cusPrjId = new set<Id>();
		list<Project__c> projectlist = new list<Project__c>();
		map<Id, Account> customerMap;
		
		// This will contains all the customer
	    if(mapStrCity != null && mapStrCity.size() > 0){
	    	customerMap = new map<Id, Account>([select name, Current_Contract_End_Date__c from Account where Id IN : mapStrCity.keySet()]);
	    	system.debug('1111111111'+customerMap);
	    }
		
		/*Query for the Project Object*/
		projectlist = [select Name, Launch_Date__c, Site_Address_City__c, Project_Name__c from Project__c where Site_Address_City__c IN: cityLaunched 
						AND (Launch_Date__c >= :mapDt.values() AND Launch_Date__c <= :system.today())];
		for(Project__c prj : projectlist){
			projId.add(prj.Id);
		}
		custId.addAll(mapStrCity.keySet());
		
		/*Query for the Customer Projects Object*/
		cusProjlist = [select Id, AccountId__c, Project_Id__c from Customer_Projects__c where Project_Id__c = :projId and AccountId__c = :custId];
		for(Customer_Projects__c csProj : cusProjlist){
			String prjId = csProj.Project_Id__c;
			String cusId = csProj.AccountId__c;
			cusPrjId.add(csProj.Id);
			mapDuplicateCusProj.put(prjId + '-' + cusId, csProj);
		}
		for(String cspId : custId){
			if(projectlist != null && projectlist.size()>0){
				for(Project__c prj : projectlist){
					system.debug('1111111 ' + cspId + '...... ' + prj.Project_Name__c);
					if(mapDuplicateCusProj.containsKey(prj.Id + '-' + cspId)){
						CusProjExandNew.add(mapDuplicateCusProj.get(prj.Id + '-' + cspId));
					}else{
						CusProjinsert.add(new Customer_Projects__c(Project_Id__c = prj.Id, AccountId__c = cspId));
					}
				}
			}
		}
		try{
			if(CusProjinsert != null && CusProjinsert.size() > 0){
				insert CusProjinsert;
				CusProjExandNew.addAll(CusProjinsert);
			}
		}catch(DMLException ex){
			system.debug(ex);
		}
		/*Query for List of Values Object */
		lovList = [Select Name, Entity_Name__c, Entity_Type__c from List_of_Values__c where Entity_Type__c = 'Package' AND Name IN('PAS', 'FTR')];
		for(List_of_Values__c lv : lovList){
			if(lv.Entity_Type__c == 'Package'){
				lovmap.put(lv.Name, lv);
			}
		}
		/*Query for Customer Package Object*/
		custPkgList = [select Name, Customer_Project__c, List_of_Values__c,List_of_Values__r.Name from Project_Cust_Packages__c where Customer_Project__c = : cusPrjId];
		for(Project_Cust_Packages__c csPkg : custPkgList){
			if(csPkg.List_of_Values__r.Name == 'PAS')
				mapPrjCustPkgDup.put(csPkg.Customer_Project__c + '-PAS', csPkg);
			else if(csPkg.List_of_Values__r.Name == 'FTR')
				mapPrjCustPkgDup.put(csPkg.Customer_Project__c + '-FTR', csPkg);
		}
		for(Customer_Projects__c custProj : CusProjExandNew){
			system.debug('////////'+custProj);
			if(!mapPrjCustPkgDup.containsKey(custProj.Id + '-PAS')){
				if(lovmap != null && lovmap.size() > 0 && lovmap.containsKey('PAS') && (customerMap != null && customerMap.size() > 0 && customerMap.containsKey(custProj.AccountId__c)))
					custPkginsert.add(new Project_Cust_Packages__c(Customer_Project__c = custProj.Id, List_of_Values__c = lovmap.get('PAS').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(custProj.AccountId__c).Current_Contract_End_Date__c));
			}
			if(!mapPrjCustPkgDup.containsKey(custProj.Id + '-FTR')){
				if(lovmap != null && lovmap.size() > 0 && lovmap.containsKey('FTR') && (customerMap != null && customerMap.size() > 0 && customerMap.containsKey(custProj.AccountId__c)))
					custPkginsert.add(new Project_Cust_Packages__c(Customer_Project__c = custProj.Id, List_of_Values__c = lovmap.get('FTR').Id, Service_Requested_Date__c = System.today(), End_Date__c = customerMap.get(custProj.AccountId__c).Current_Contract_End_Date__c));
			}
		}
		try{
			if(custPkginsert != null && custPkginsert.size() > 0)
				insert custPkginsert;
		}catch(DMLException ex){
			system.debug(ex);
		}
	}
}