global class RBI_DeveloperAlertBatch implements  Database.Batchable<sObject>{
	global String QueryString;
	global set<Id> prjPASMgrId;
	global date todaysDate ;
	public list<Account> accLst;
	public map<String, User> userMap;
	public Map<Id, Account> accMap;
	global RBI_DeveloperAlertBatch(){
		todaysDate = system.Today().addDays(-30);
		QueryString = 'select Name, BillingCity, LastModifiedDate, RecordTypeId, (select Name, Developer__c, Project_Type__c, LastModifiedDate from OnGoingProjects__r ORDER BY LastModifiedDate desc) from Account where LastModifiedDate <=: todaysDate AND (RecordType.Name = \'Developer\')';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(QueryString);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		accLst = scope;
		system.debug('======= ' + accLst);
		accMap = new Map<Id, Account>(accLst);
		set<String> siteCity = new set<String>();
		map<String, User> userlst = new map<String, User>();
		Map<String, list<Account>> mapAccnt = new Map<String, list<Account>>();
		String siteCityString = '';
		String PASEmail;
		list<Account> AccValue;
		list<Account> AccLstinMap;
		for(Account acc : accLst){
			list<List_of_Values__c> lovLst = new list<List_of_Values__c>();
			if(acc.OnGoingProjects__r != null && acc.OnGoingProjects__r.size()>0)
				lovLst = acc.OnGoingProjects__r;
			if(lovLst != null && lovLst.size() >0){
				system.debug('555555555555'+lovLst[0].LastModifiedDate + '  '+todaysDate+ '  '+lovLst[0].Developer__c);
				if(lovLst[0].LastModifiedDate <= System.now() && lovLst[0].LastModifiedDate >= todaysDate){
					accMap.remove(acc.Id);
				}
			}	
			if(acc.BillingCity != null && (siteCity.add(acc.BillingCity)))
				siteCityString += '\'' + acc.BillingCity + '\',';
		}
		system.debug('tttttt ' + accMap);
		if(siteCityString != null && siteCityString != '')
	        siteCityString = siteCityString.substring(0, siteCityString.length()-1); 
		userlst = queryUser(siteCityString);
		system.debug('//////// '+siteCityString);
		
		for(Account acnt : accMap.values()){
			PASEmail = '';
			AccLstinMap = new list<Account>();
			AccValue = new list<Account>();
			if(acnt.BillingCity != null && userMap.containsKey(acnt.BillingCity+'-PAS Manager')){
				PASEmail = userMap.get(acnt.BillingCity+'-PAS Manager').Email;
				system.debug('YYYY '+ PASEmail);
			} 
			if(mapAccnt != null && mapAccnt.size()>0 && mapAccnt.containsKey(PASEmail)){
				AccLstinMap = mapAccnt.get(PASEmail);
				system.debug('9999 '+ AccLstinMap);
			}
			if(AccLstinMap != null && AccLstinMap.size() > 0){
				AccValue.addAll(AccLstinMap);
		 	}
		 	AccValue.add(acnt);
		 	system.debug('1234 '+ AccValue);
		 	mapAccnt.put(PASEmail, AccValue); 
		}
		mapAccnt.remove(''); 
		system.debug('----- ' + mapAccnt);
		EmailPASManager(mapAccnt);
	}    
	
	public map<String, User> queryUser(String siteCity){
        list<User> userList = new list<User>();
        if(siteCity != null && siteCity != ''){	
        	String userQuery = 'select name, Email, UserRole.Name, Covering_Cities__c, City from User';
			userQuery += ' where (Covering_Cities__c INCLUDES (' + siteCity + ')) and (UserRole.Name = \'PAS Manager\')';
			system.debug('********* '+userQuery);
			userList = database.query(userQuery);
        }
        userMap = new map<String, User>();
        for(User us : userList){
        	if(us.Covering_Cities__c != null){
        		list<String> cityList = us.Covering_Cities__c.split(';');
		        for(String strCity : cityList){
		           	userMap.put(strCity+'-'+us.UserRole.Name, us);
		        }
        	}
        }
        system.debug('CITIES ' + userMap); 
        return userMap;
    }
    
    public void EmailPASManager(map<String, list<Account>> acntMap){     
    	prjPASMgrId = new set<Id>();
    	list<Messaging.SingleEmailMessage> emails = new list<Messaging.SingleEmailMessage>();
    	//for(Account acc : acntMap.values()){
    	for(String emailPAS : acntMap.keySet()){
    		list<Account> acLst = acntMap.get(emailPAS);
    		//String[] toAddresses = new String[]{};
    		String body = '';
    		//Creating tabular format for the exception details
    		body = BodyFormat(acLst);
    		system.debug('`````` ' + acLst); 
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    		/*system.debug('{{{{{{ ' + acc.BillingCity);
    		system.debug(';;;;;; ' + userMap);
    		system.debug('...... ' + userMap.containsKey(acc.BillingCity+'-PAS Manager'));
    		if(acc.BillingCity != null && (userMap != null && userMap.size() > 0 && userMap.containsKey(acc.BillingCity+'-PAS Manager'))){
    			toAddresses.add(userMap.get(acc.BillingCity+'-PAS Manager').Email);
    		}else{
    			toAddresses.add(System.label.RBI_DefaultPASMgrEmailId);
    		}*/
    		String[] toAddresses = new String[] {emailPAS};
    			//toAddresses = new String[]{userMap.get(acc.BillingCity+'-PASManager').Email};
    		system.debug('EEEEEE ' + toAddresses);  
    		mail.setToAddresses(toAddresses);
    		mail.setSubject('Developer information have not been updated since from 30 days');
    		//Body of email 
    		mail.setHtmlBody('Hello, <br /><br />Please find below the details of Developer Information that need to be Updated. <br /><br />' + body + '<br /> <br />Thanks & Regards, <br /> RealtyBI Team');
    		//Sending the email
    		/*if (!Test.isRunningTest()) { 
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            	system.debug('mail Sent' + mail);
           	}*/ 
           	emails.add(mail);
    	}
    	if(emails != null && emails.size() > 0){
        	Messaging.sendEmail(emails);
    	}
    	
    	list<Account> AccListWithoutPASMgr = new list<Account>();
    	for(Account ac : accMap.values()){
    		if(prjPASMgrId.add(ac.Id)){
    			AccListWithoutPASMgr.add(ac);
    		}
    	}
    	if(AccListWithoutPASMgr != null && AccListWithoutPASMgr.size()>0){
    		String body = '';
    		//Creating tabular format for the exception details
    		body = BodyFormat(AccListWithoutPASMgr);
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    		String[] toAddresses = new String[] {System.label.RBI_DefaultPASMgrEmailId}; 
    		mail.setToAddresses(toAddresses) ; 
            mail.setSubject('Developer information have not been updated since from 30 days');
            //Body of email 
            mail.setHtmlBody('Hello, <br /><br />Please find below the details of Developer Information that need to be Updated. <br /><br />' + body + '<br /> <br />Thanks & Regards, <br /> RealtyBI Team');  
            //Sending the email  
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('mail Sent');  
    	}  
    }
    
    public String BodyFormat(List<Account> lst){  
       	String str = '' ;  
    	for(Account pj : lst){  
    		prjPASMgrId.add(pj.Id);
        	str += '<tr><td>'+ pj.Name +'</td>'+'<td>'+ pj.BillingCity +'</td>'+'</tr>' ;  
        } 
        str = str.replace('null' , '') ;  
        String finalStr = '' ;
        finalStr = '<table border="1"> <td><b> Developer Name</b> </td> <td><b> Registered City </b></td> '+ str +'</table>' ;    
        return finalStr ;  
   	} 	
	
	global void finish(Database.BatchableContext BC){
		
	}
}