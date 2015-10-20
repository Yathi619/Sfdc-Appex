public with sharing class RBI_QueryExceptionTriggerHandler
 {
	list<Query__c> QueryExplist;
	set<string> visitid;
	set<String> custProjId;
	list<Visit__c> visitlist;
	Map<Id,Query__c> visitmap;
	map<Id,Query__c> visitIdQueryMap;
	map<Id, Query__c> projIdQueryMap;
	set<string>Techheademail;
	string ExceptionId;
	set<Id> projectId;
	set<Id> accountId;
	map<Id, list<Project_Cust_Packages__c>> custPackMap; 
	//map<Id, Project_Cust_Packages__c> custPackMap;
	list<Project_Cust_Packages__c> custPackList;
	list<Contact> primaryContactList; 
	map<Id, Contact> primaryContactMap;
	list<Visit__c> updatevisitlist;
	list<Customer_Projects__c> updateCustProjList; 
	public Static boolean FirstUpdate = true; //Used To avoid recursive call
	
	public void OnBeforeInsert(list<Query__c> QueryExpNew){
		for(Query__c que : QueryExpNew){
			if(que.Record_Type_Name__c == 'Exception' && que.Visit__c != null){
				que.OwnerId = que.Technical_Head_Id__c;
			}
		}
	}
	
	public void OnAfterUpdate(list<Query__c> QueryExpNew, Map<Id, Query__c> ObjectMap)
	{
		if(FirstUpdate){
			FirstUpdate = false;
			updatevisitlist = new list<Visit__c>();
			visitlist = new list<Visit__c>();
			visitmap = new Map<Id,Query__c>();
			QueryExplist = new list<Query__c>();
			visitid = new set<string>();
			custProjId = new set<String>();
			Techheademail = new set<string>();
			visitIdQueryMap = new map<Id, Query__c>();
			projIdQueryMap = new map<Id, Query__c>();
			projectId = new set<Id>();
			accountId = new set<Id>();
			
			for(Query__c qrexp:QueryExpNew){
				if(qrexp.Id == ObjectMap.get(qrexp.Id).Id && ObjectMap.get(qrexp.Id).Exception_Status__c != qrexp.Exception_Status__c){ 
					if(qrexp.Visit__c != null && qrexp.Customer_Project__c == null){
						visitid.add(qrexp.Visit__c);
					}	
					else
					{
						custProjId.add(qrexp.Customer_Project__c);

					}		
				}
			}
			
			system.debug('+++++++'+accountId+' 888 '+custProjId);
			//if(visitid != null && visitid.size() > 0 && custProjId == null)
			if(visitid != null && visitid.size() > 0 && custProjId.size() < 1)
				QueryExplist=[Select id,Exception_Status__c,Visit__c,Visit__r.Project__c,Project_Id__c ,Technical_Head_Id__c,Technical_Head_EmailId__c from Query__c where Visit__c IN : visitid ORDER BY Visit__c]; //Get all the Exception records based on the Visit Ids
			else if(custProjId != null && custProjId.size() > 0)
				QueryExplist=[Select id,Exception_Status__c,Customer_Project__c,Project_Id__c ,Technical_Head_Id__c,Technical_Head_EmailId__c,CustProjAccountId__c from Query__c where Customer_Project__c IN : custProjId ORDER BY Customer_Project__c]; //Get all the Exception records based on the Customer project Ids	
			
			if(visitid != null && visitid.size() > 0 && custProjId.size() < 1){
				//Build a Map of Visit Ids which have at least one exception record with the status as Open. For every Visit record, loop through Exception records with status as Open
				for(Query__c Queryexp : QueryExplist){	   
					if(Queryexp.Exception_Status__c != 'Closed'){  
						visitmap.put(Queryexp.Visit__c,Queryexp); //Build a Visit Map with Visit Ids or Customer Project Ids which need to exculded from updating the Exception flag	
					}else{
						visitIdQueryMap.put(Queryexp.Visit__c,Queryexp);
					}
				}  
				// Loop through the Visit List and check whether the Visit Id is already present in the Map created above. It is not present,
				// it means that the Visit record does not have any Exception records with Status as 'Closed'. Build a list of Visit Records to be updated.
				for(Id vis1:visitid){
					if(visitmap.containsKey(vis1)){
						//Do nothing
					}else{
						Visit__c visit = new Visit__c(Id=vis1, Exception__c = false);
						updatevisitlist.add(visit);
						if(visitIdQueryMap.containsKey(vis1) && vis1 == visitIdQueryMap.get(vis1).Visit__c){
						  	string projId = '';
						   	projId = visitIdQueryMap.get(vis1).Project_Id__c;
						   	projectId.add(projId);
						   	string updvisProjId = visitIdQueryMap.get(vis1).Project_Id__c;
						   	projIdQueryMap.put(updvisProjId,visitIdQueryMap.get(vis1));
						   	system.debug('Hello '+projectId);
						}
				   	}
				}
			}else if(custProjId != null && custProjId.size() > 0){ // This else part is to update the customer project flag when all the child exceptions are closed.
				updateCustProjList = new list<Customer_Projects__c>();
				//Build a Map of Visit Ids which have at least one exception record with the status as Open. For every Visit record, loop through Exception records with status as Open
				for(Query__c Queryexp : QueryExplist){	   
					if(Queryexp.Exception_Status__c != 'Closed'){  
						visitmap.put(Queryexp.Customer_Project__c,Queryexp); //Build a Visit Map with Visit Ids or Customer Project Ids which need to exculded from updating the Exception flag	
					}else{
						visitIdQueryMap.put(Queryexp.Customer_Project__c,Queryexp);
					}
				}  
				accountId = new set<Id>();
				for(Id custId :custProjId){
					if(visitmap.containsKey(custId)){
						//Do nothing
					}else{
						Customer_Projects__c custProj = new Customer_Projects__c(Id=custId, Exception__c = false);
						updateCustProjList.add(custProj);
						if(visitIdQueryMap.containsKey(custId) && custId == visitIdQueryMap.get(custId).Customer_Project__c){
						  	string projId = '';
						   	projId = visitIdQueryMap.get(custId).Project_Id__c;
						   	projectId.add(projId);
						   	//string updvisProjId = visitIdQueryMap.get(custId).Id;
						   	projIdQueryMap.put(custId,visitIdQueryMap.get(custId));
						   	system.debug('Hello '+projectId+' ddddddd '+projIdQueryMap);
						   	
							accountId.add(visitIdQueryMap.get(custId).CustProjAccountId__c);
							system.debug('1212121'+accountId);
						}
				   	}
				}
			}
			try{
				if(updatevisitlist != null && updatevisitlist.size()>0){
					update updatevisitlist;
					QueryCustomerProject();
					system.debug('XXXXXX'+updatevisitlist);
					sendEmail();
						
				}
				if(updateCustProjList != null && updateCustProjList.size()>0){
					update updateCustProjList;
					sendEmailCustPrj();
				}
			}catch(DMLException e){
		    	system.debug(e);
		    }
		}
	}	
	
	/* This method is used for build logic for visit and customer project Exception email */ 
	public void QueryCustomerProject(){
		
       	list<Project_Cust_Packages__c> custPackValue; // used for building custPackMap map
		list<Project_Cust_Packages__c> custPackListinMap; // used for building custPackMap map
		
		custPackList = new list<Project_Cust_Packages__c>();
       	custPackMap = new map<Id, list<Project_Cust_Packages__c>>();
       	//custPackMap = new map<Id, Project_Cust_Packages__c>();
		primaryContactList = new list<Contact>();
       	primaryContactMap = new map<Id, Contact>();
       	system.debug('hhhhhhhhh'+projectId);
		if(projectId != null && projectId.size() > 0 && custProjId.size() < 1){
       		//custPackMap = new map<Id, Project_Cust_Packages__c> ([select Name, LOV_Name__c, List_of_Values__r.Entity_Type__c, Account_Id__c from Project_Cust_Packages__c where Project_Id__c IN : projectId and LOV_Name__c = 'PAS']);
       		custPackList = [select Name, Project_Id__c, LOV_Name__c, List_of_Values__r.Entity_Type__c, Account_Id__c from Project_Cust_Packages__c where Project_Id__c IN : projectId and LOV_Name__c = 'PAS'];
       	}
       	else if(custProjId != null && custProjId.size() > 0){
       		custPackList = [select Name, Project_Id__c, LOV_Name__c, List_of_Values__r.Entity_Type__c, Account_Id__c from Project_Cust_Packages__c where Customer_Project__c IN : custProjId and LOV_Name__c = 'PAS'];
       	}
       	
       	/* Logic to build a map with key and a list (map<Id, list<Project_Cust_Packages__c>> custPackMap)  */
       	for(Project_Cust_Packages__c pcp : custPackList){
       		if(pcp.LOV_Name__c == 'PAS' && pcp.List_of_Values__r.Entity_Type__c == 'Package'){
       			accountId.add(pcp.Account_Id__c);
       			custPackValue = new list<Project_Cust_Packages__c>();
       			custPackListinMap = new list<Project_Cust_Packages__c>();
       			if(pcp.Project_Id__c != null){
       				if(custPackMap != null && custPackMap.size() > 0 && custPackMap.containsKey(pcp.Project_Id__c)){
       					custPackListinMap = custPackMap.get(pcp.Project_Id__c);
       				}
       				if(custPackListinMap != null && custPackListinMap.size() >0){
       					custPackValue.addAll(custPackListinMap);
       				}
       				custPackValue.add(pcp);
       				custPackMap.put(pcp.Project_Id__c,custPackValue);
       			}
       		}
       	}
       	// logic ends here
       	
       	if(accountId != null && accountId.size() > 0){
       		primaryContactList = [select Name, accountId, Primary__c, Email, Group_Email__c from Contact where AccountId IN : accountId and Primary__c = true];
       	}
       	for(Contact con : primaryContactList){
       		if(con.Primary__c == true)
       			primaryContactMap.put(con.AccountId, con);
       	}
       	system.debug('66666666 '+custPackMap);
	}
	
	public void sendEmail(){
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		for(Id projId : projIdQueryMap.keySet()){
			if((projIdQueryMap != null && projIdQueryMap.size() > 0) &&(projIdQueryMap.containsKey(projId) && projId == projIdQueryMap.get(projId).Project_Id__c)){
				list<Project_Cust_Packages__c> custPackLocalList;
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		            String[] toAddresses;
		            toAddresses = new String[] {projIdQueryMap.get(projId).Technical_Head_EmailId__c};
		            if((primaryContactMap != null && primaryContactMap.size() > 0)){
		            	if(custPackMap != null && custPackMap.size() > 0 && custPackMap.containsKey(projId)){
		            		custPackLocalList = custPackMap.get(projId);
		            		if(custPackLocalList != null && custPackLocalList.size() > 0){
		            			boolean firstTimeFlag = true;
		            			for(Project_Cust_Packages__c pcp : custPackLocalList){
		            				if(firstTimeFlag){
		            					mail.setTargetObjectId(primaryContactMap.get(pcp.Account_Id__c).Id);
		            					//Added for Phase 2B on 12.08.2013
		            					if(primaryContactMap.get(pcp.Account_Id__c).Group_Email__c != null)
		            						toAddresses.addAll(primaryContactMap.get(pcp.Account_Id__c).Group_Email__c.split(','));
		            					//Adding Ended	
										firstTimeFlag = false;	            					
		            				}else{
		            					//Added for Phase 2B on 12.08.2013
		        						toAddresses.addAll(primaryContactMap.get(pcp.Account_Id__c).Group_Email__c.split(','));
		        						system.debug('.........'+toAddresses);
		        						
		            					//toAddresses.add(primaryContactMap.get(pcp.Account_Id__c).Email);
		            				}
			            		}	
		            		}
		            	}
		            	else{
			            	mail.setTargetObjectId(system.Label.RBI_DefaultContact);
			            	system.debug('22222222 '+mail);
			            }
		            	system.debug('11111111 '+mail);
		            }else{
		            	mail.setTargetObjectId(system.Label.RBI_DefaultContact);
		            	system.debug('22222222 '+mail);
		            }
		            system.debug('555555555'+projId);
		            mail.setToAddresses(toAddresses);
		            system.debug('========'+toAddresses);
		            mail.saveAsActivity = false;
		            mail.setWhatId(projIdQueryMap.get(projId).Visit__c);
		            mail.setTemplateId(System.label.RBI_Exception_Status_Closed);
		            /*if(visitid != null && visitid.size() > 0 && custProjId.size() < 1){
		            	mail.setWhatId(projIdQueryMap.get(projId).Visit__c);
		            	mail.setTemplateId(System.label.RBI_Exception_Status_Closed);
		            }
		            else if(custProjId != null && custProjId.size() > 0){
		            	mail.setWhatId(projIdQueryMap.get(projId).Customer_Project__c);
		            	mail.setTemplateId(System.label.RBI_Exception_Status_Closed_For_Customer);	
		            }*/
		            
					//system.debug('/////////'+toAddresses+ '1110 '+mail );
					emails.add(mail);
		            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				//}
			}
		}
		system.debug('/////'+emails);
		if(emails != null && emails.size() > 0)
			Messaging.sendEmail(emails);
	}
	//Helper function used to send emails for customer project expection closure
	public void sendEmailCustPrj(){
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		primaryContactList = new list<Contact>();
       	primaryContactMap = new map<Id, Contact>();
		String[] toAddresses;
		Messaging.SingleEmailMessage mail;
		
		if(accountId != null && accountId.size() > 0){
			primaryContactList = [select Name, accountId, Primary__c, Email, Group_Email__c from Contact where AccountId IN : accountId and Primary__c = true];
		}
		
		for(Contact con : primaryContactList){
			if(con.Primary__c == true)
				primaryContactMap.put(con.AccountId, con);
		}
		
		for(Customer_Projects__c cpObj : updateCustProjList){
		toAddresses = new String[] {projIdQueryMap.get(cpObj.Id).Technical_Head_EmailId__c};				
			mail = new Messaging.SingleEmailMessage();
		    if((primaryContactMap != null && primaryContactMap.size() > 0)){
		        mail.setTargetObjectId(primaryContactMap.get(visitIdQueryMap.get(cpObj.Id).CustProjAccountId__c).Id);
		        //Added for Phase 2B on 12.08.2013
		        toAddresses.addAll(primaryContactMap.get(visitIdQueryMap.get(cpObj.Id).CustProjAccountId__c).Group_Email__c.split(','));
		        //Adding Ended
		       	mail.setToAddresses(toAddresses);
		        mail.saveAsActivity = false;
		        mail.setWhatId(cpObj.Id);
		 		mail.setTemplateId(System.label.RBI_Exception_Status_Closed_For_Customer);	
		 		emails.add(mail);		            	
		    }
		}
		if(emails != null && emails.size() > 0)
			Messaging.sendEmail(emails);       	
	}	
}