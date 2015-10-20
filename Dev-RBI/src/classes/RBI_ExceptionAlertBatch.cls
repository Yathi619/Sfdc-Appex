global class RBI_ExceptionAlertBatch implements  Database.Batchable<sObject>{
	
	global String QueryString; 
	global Date todayDate;
	list<Query__c> exceptionList;
	
	global RBI_ExceptionAlertBatch(){
		todayDate = system.today();
		QueryString = 'select Name,Expected_Closure_Date__c,Query_Resolved_Date__c,Visit__c,Visit__r.Name,Visit__r.Project__r.Name,Technical_Head_EmailId__c,PAS_Manager_Email__c,Team_Leader_Email__c, Closure_Remarks__c,Expected_Closure_Email_Date__c, Query_Description__c, Query_Initiated_Date__c,Exception_Status__c, Other_Remarks__c,Customer_Project__c,Customer_Project__r.Project_Name__c,Customer_Project__r.Name,Visit__r.Project__r.Project_Name__c from Query__c  where Exception_Status__c != \'Closed\' and Expected_Closure_Email_Date__c = : todayDate order by Visit__c' ;
		exceptionList = new list<Query__c>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){  
		return Database.getQueryLocator(QueryString);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		String PASTechEmailId;
		exceptionList = scope;
		system.debug('xxxxxxxxxx'+exceptionList);
		map<String, list<Query__c>> exceptionMap = new map<String, list<Query__c>>() ;
		list<Query__c> excepValue;
		list<Query__c> excepListinMap;
		for(Query__c excep : exceptionList){
			excepValue = new list<Query__c> ();
			PASTechEmailId = '';
			excepListinMap = new list<Query__c> ();
			if((excep.Team_Leader_Email__c != null && excep.Team_Leader_Email__c != '') && (excep.Technical_Head_EmailId__c != null && excep.Technical_Head_EmailId__c != '')){
				PASTechEmailId = excep.Team_Leader_Email__c+','+excep.Technical_Head_EmailId__c;
				system.debug('yyyyyyyyyyyyyy'+PASTechEmailId);
				if(exceptionMap != null && exceptionMap .size() > 0 && exceptionMap .containsKey(PASTechEmailId)){
					excepListinMap = exceptionMap.get(PASTechEmailId);
					system.debug('33333 ' + excepListinMap);
				}
				if(excepListinMap != null && excepListinMap.size() > 0){
					excepValue.addAll(excepListinMap);
		 		}
				excepValue.add(excep);
				exceptionMap .put(PASTechEmailId, excepValue);
				system.debug('111111111111'+exceptionMap);
				system.debug('2222222 ' + exceptionMap.get(PASTechEmailId));
			}
		}
 		if(exceptionMap != null && exceptionMap.size() > 0){
 			EmailSurveyor(exceptionMap);
 		}
	}	
	public void EmailSurveyor(map<String, list<Query__c>> excepMap){
        system.debug('212121'+excepMap);
        for(String PASTechEmail : excepMap.keySet()){
        	list<Query__c> exceptionRec = excepMap.get(PASTechEmail);
    		String body = '' ;  
            //Creating tabular format for the exception details  
            body = BodyFormat(exceptionRec) ;  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ; 
            String[] toAddresses = PASTechEmail.split(',');
            //String[] toAddresses = new String[] {PASTechEmail} ;  
            mail.setToAddresses(toAddresses) ; 
            mail.setSubject('Exception records which are expected to close tomorrow');
            //Body of email 
            mail.setHtmlBody('Hello, <br /><br />Please find below the details of Exceptions that are expected to close tommorow. <br /><br />' + body + '<br /> <br />Thanks & Regards, <br /> RealtyBI Team');  
            //Sending the email 
            if (!Test.isRunningTest()) { 
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            	system.debug('mail Sent' + mail);
           	}
        }
    }
    
    public String BodyFormat(List<Query__c> lst){  
       	String str = '' ;  
       	
    	for(Query__c qry : lst){  
			Date myDate = date.newinstance(qry.Expected_Closure_Date__c.year(), qry.Expected_Closure_Date__c.month(), qry.Expected_Closure_Date__c.day());
            String d = String.valueOf(myDate);
            if(qry.Visit__c != null)
        		str += '<tr><td>'+ qry.Name +'</td>'+'<td>'+ qry.Query_Description__c +'</td>'+'<td>'+ d +'</td>'+'<td>'+ qry.Visit__r.Name +'</td>'+'<td>'+ qry.Visit__r.Project__r.Project_Name__c +'</td>'+'</tr>' ;  
            else
                str += '<tr><td>'+ qry.Name +'</td>'+'<td>'+ qry.Query_Description__c +'</td>'+'<td>'+ d +'</td>'+'<td>'+ qry.Customer_Project__r.Name +'</td>'+'<td>'+ qry.Customer_Project__r.Project_Name__c +'</td>'+'</tr>' ;  
        }  
        str = str.replace('null' , '') ;  
        String finalStr = '' ;  
        finalStr = '<table border="1"> <td><b> Exception Id </b> </td> <td><b> Description </b> </td> <td><b> Exception Closure Date </b></td> <td><b> Related To </b></td> <td><b> Project Name </b></td> '+ str +'</table>' ;    
        return finalStr ;  
   	}  
	
	global void finish(Database.BatchableContext BC){

	}

}