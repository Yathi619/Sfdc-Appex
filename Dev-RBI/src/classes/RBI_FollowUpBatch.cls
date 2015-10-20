global class RBI_FollowUpBatch implements  Database.Batchable<sObject>{
	global String QueryString;
	
	list<Visit__c> visitRecForInsert; // This list variable is for followup visit record which is to be inserted. 
	list<Visit__c> towerVisitForInsert;
	list<Construction_Status__c> constStatuslistForInsert;
	list<Detail_Price_List__c> detailPricelistForInsert;
	list<Infrastructure_Near_Project__c> InfraNearProjectlistForInsert;
	list<Project_Feedback__c> FeedbacklistForInsert;
	list<Additional_Charges__c> additChargeslistForInsert;
	list<Payment_Plan__c> paymentPlanslistForInsert;
	list<Project__c> projectWithChildRecLst;
	list<RecordType> recList; // Used to get the record type of visit record type
	list<Visit__c> visitListForCopy = new list<Visit__c>(); // for copying the related list of a project.
	list<Tower__c> towerlist = new list<Tower__c>();
	list<Construction_Status__c> constStatuslist = new list<Construction_Status__c>();
	list<Detail_Price_List__c> detailPricelist = new list<Detail_Price_List__c>();
	list<Infrastructure_Near_Project__c> InfraNearProjectlist = new list<Infrastructure_Near_Project__c>();
	list<Project_Feedback__c> Feedbacklist = new list<Project_Feedback__c>();
	list<Additional_Charges__c> additChargeslist = new list<Additional_Charges__c>();
	list<Payment_Plan__c> paymentPlanslist = new list<Payment_Plan__c>();
	       
	Id FollowUpRecTypeId = null;
	Id TowerRecTypeId = null;
	global RBI_FollowUpBatch(){
		QueryString = 'Select Visit_Report__c, Status__c, Visit__c,Project__r.Site_Contact_NameDesg__c,Project__r.construction_Status__c, Project__r.Count_Of_Customers__c,Project__r.Surveyor__c, Project__r.Site_Visit_Date__c, Tower__c, Project__c, Name, Closed_Date__c From Visit__c v where Project__c != \'\' and (Visit_Report__c =\'Followup Report\' or Visit_Report__c =\'First Technical Report\')';
		recList = [SELECT Name, SobjectType FROM RecordType where SobjectType ='Visit__c'];
		visitRecForInsert = new list<Visit__c>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){  
		return Database.getQueryLocator(QueryString);
	}
    
    public map<Id, Visit__c> dupsCheck(list<Visit__c> vislist){
    	map<Id, Visit__c> DupCheckMap = new map<Id, Visit__c>(); 
    	for(Visit__c vis : vislist){ // this for loop is for building the logic of dupcheckmap variable.
			if(vis.Visit_Report__c == 'Followup Report')
				DupCheckMap.put(vis.Project__c, vis);
    	}
		return DupcheckMap;
    }
    
    public void followUpVisit(String ProjId, String ProjSurveyor, String siteContName, String conStatus){
    	Visit__c visitRec = new Visit__c();
		visitRec.Visit_Report__c = 'FollowUp Report';
		visitRec.RecordTypeId = FollowUpRecTypeId;
		visitRec.Project__c = ProjId;
		visitRec.Status__c = 'Pending';
		visitRec.Construction__c = conStatus;
		visitRec.Site_contact_NameDesg__c = siteContName;
		if(ProjSurveyor != null)
			visitRec.Surveyor__c = ProjSurveyor;
			visitRec.OwnerId = ProjSurveyor;
			visitRecForInsert.add(visitRec);
			visitListForCopy.add(visitRec);
    	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		map<Id, Project_Cust_Packages__c> projFollowUpKeySet = new map<Id, Project_Cust_Packages__c>();
		map<Id, Visit__c> DupCheckMap; // This map is for duplicate check for follow up visit record.
		map<Id, Visit__c> mapForFTRDate = new map<Id, Visit__c>();
		map<Id, Visit__c> mapforTower = new map<Id, Visit__c>();
		list<Visit__c> visitList = new list<Visit__c>();
		list<Visit__c> followUpvisitList = new list<Visit__c>();
		list<Project_Cust_Packages__c> UpdCustomerPakageList = new list<Project_Cust_Packages__c>();
		boolean withCustFlag = false;
		Integer visitOffSet = Integer.valueOf(system.label.RBI_VisitOffSet);
		//Date todaysDatePlusVisitOffSet = system.today() + visitOffSet;
		
		for(RecordType rec : recList){
			if(rec.name == 'Followup')
				FollowUpRecTypeId = rec.Id;
			if(rec.name == 'Tower')
				TowerRecTypeId = rec.Id;
		}
		
		for(sObject vis : scope){
			Visit__c visRec = (Visit__c)vis;
				if(visRec.Status__c == 'Approved' && visRec.Visit_Report__c == 'First Technical Report'){
					mapForFTRDate.put(visRec.Project__c, visRec);
					visitList.add(visRec);
				}	
				if(visRec.Visit_Report__c == 'Followup Report')	
					followUpvisitList.add(visRec);
		}
		
		DupCheckMap = new map<Id, Visit__c>(); 
		DupCheckMap = dupsCheck(followUpvisitList);
		for(Visit__c vis : visitList){
            //system.debug('xxxxxxxxxxxx'+vis.Project__r.Site_Visit_Date__c+' --- '+todaysDatePlusVisitOffSet+ '  ' +visitOffSet);
			if(mapForFTRDate.containsKey(vis.Project__c)){
				if(vis.Project__r.Count_Of_Customers__c == 0){
					Integer PMSDefaultFreq = Integer.valueOf(system.label.RBI_PMSDefaultFrequency);
					if((system.today() == vis.Project__r.Site_Visit_Date__c + (PMSDefaultFreq - visitOffSet)) && !DupCheckMap.containsKey(vis.Project__c)){
						followUpVisit(vis.Project__c, vis.Project__r.Surveyor__c, vis.Project__r.Site_Contact_NameDesg__c, vis.Project__r.construction_Status__c);
					}
				}	
				else{
					withCustFlag = true;// The logic in this else part is done below since it is inside for loop
				} 	
			}
		}
		if(withCustFlag){
			integer LowFreqCycle;
			Date CalcfollowupVisitdt;
			Integer projMonitorFreq;
			set<Id> dupCheckSetId = new set<Id>();
			set<Id> ProjId = new Set<Id>();
			list<Project_Cust_Packages__c> projectCustPackList = [Select CalcfollowupVisitdt__c, LastFollowupDate__c, Project_Monitoring_Frequency__c, Project_City__c, Name, List_of_Values__c, LOV_Name__c, Customer_Project__c,  Customer_Project__r.Project_Id__c,Customer_Project__r.Project_Id__r.Surveyor__c, Customer_Project__r.Project_Id__r.Site_Visit_Date__c, Customer_Project__r.Project_Id__r.construction_Status__c, Customer_Project__r.Project_Id__r.Site_Contact_NameDesg__c, List_of_Values__r.Name From Project_Cust_Packages__c where List_of_Values__r.Name = 'PMS' and IsContractInActive__c = 'N' order by Project_Monitoring_Frequency__c, Customer_Project__r.Project_Id__c];
			system.debug('@@@@@@'+projectCustPackList);
            for(Project_Cust_Packages__c pcp : projectCustPackList){
            	if(mapForFTRDate.containsKey(pcp.Customer_Project__r.Project_Id__c)){
            		CalcfollowupVisitdt = null;
            		projMonitorFreq = null;
	            	if(pcp.LastFollowupDate__c != null){
		            	CalcfollowupVisitdt = pcp.CalcfollowupVisitdt__c;
		            }
			        else if(pcp.LastFollowupDate__c == null && mapForFTRDate.get(pcp.Customer_Project__r.Project_Id__c).Closed_Date__c != null){
			          	if(mapForFTRDate.get(pcp.Customer_Project__r.Project_Id__c).Closed_Date__c >= pcp.CalcfollowupVisitdt__c){
			           		CalcfollowupVisitdt = mapForFTRDate.get(pcp.Customer_Project__r.Project_Id__c).Closed_Date__c;
			           	}else{
			           		CalcfollowupVisitdt = pcp.CalcfollowupVisitdt__c;
			           	} 
			        }	
			        system.debug('/////////////'+CalcfollowupVisitdt+ ' '+projMonitorFreq+ ' '+visitOffSet);
	            		system.debug('************'+pcp);
	            	if(pcp.Project_Monitoring_Frequency__c != null)		
	            		projMonitorFreq =(Integer) pcp.Project_Monitoring_Frequency__c - visitOffSet;	
	            	if(CalcfollowupVisitdt != null && projMonitorFreq != null){
						if(system.today() == CalcfollowupVisitdt + projMonitorFreq){ // logic for creating follow up visit record
							if(!projFollowUpKeySet.containsKey(pcp.Customer_Project__r.Project_Id__c)){
								followUpVisit(pcp.Customer_Project__r.Project_Id__c, pcp.Customer_Project__r.Project_Id__r.Surveyor__c, pcp.Customer_Project__r.Project_Id__r.Site_Contact_NameDesg__c, pcp.Customer_Project__r.Project_Id__r.construction_Status__c);
				                       
				                //ADD TO update list and Map
				                projFollowUpKeySet.put(pcp.Customer_Project__r.Project_Id__c, pcp);
				                if(dupCheckSetId.add(pcp.Id))
				                	UpdCustomerPakageList.add(new Project_Cust_Packages__c(Id = pcp.Id, LastFollowupDate__c = CalcfollowupVisitdt + projMonitorFreq));
							}else{
								if(dupCheckSetId.add(pcp.Id))
									UpdCustomerPakageList.add(new Project_Cust_Packages__c(Id = pcp.Id, LastFollowupDate__c = CalcfollowupVisitdt + projMonitorFreq));
							}
	            		}
	            	}
            	}
            }
            if((projFollowUpKeySet != null)&&(projFollowUpKeySet.Size()>0)){
            	for(Project_Cust_Packages__c pcp : projectCustPackList){
            		if(mapForFTRDate.containsKey(pcp.Customer_Project__r.Project_Id__c)){
            			CalcfollowupVisitdt = null;
		            	projMonitorFreq = null;
		            	LowFreqCycle = null;
		            	if(pcp.LastFollowupDate__c != null){
		            		CalcfollowupVisitdt = pcp.CalcfollowupVisitdt__c;
		            	}
			            else if(pcp.LastFollowupDate__c == null && mapForFTRDate.get(pcp.Customer_Project__r.Project_Id__c).Closed_Date__c != null){
			            	if(mapForFTRDate.get(pcp.Customer_Project__r.Project_Id__c).Closed_Date__c >= pcp.CalcfollowupVisitdt__c){
			            		CalcfollowupVisitdt = mapForFTRDate.get(pcp.Customer_Project__r.Project_Id__c).Closed_Date__c;
			            	}else{
			            		CalcfollowupVisitdt = pcp.CalcfollowupVisitdt__c;
			            	}
			            }	
			            if(pcp.Project_Monitoring_Frequency__c != null)		
			            	projMonitorFreq =(Integer) pcp.Project_Monitoring_Frequency__c - visitOffSet;	
			            if(system.Label.RBI_LowestFrequencyCycle != null)
	            			LowFreqCycle = Integer.valueOf(system.Label.RBI_LowestFrequencyCycle);
		            	if(projFollowUpKeySet.containsKey(pcp.Customer_Project__r.Project_Id__c) && CalcfollowupVisitdt != null && projMonitorFreq != null){ //check for falling inside the frequency.
		            		if(dupCheckSetId.add(pcp.Id) && (CalcfollowupVisitdt + projMonitorFreq <= system.today() + LowFreqCycle)){
		            			UpdCustomerPakageList.add(new Project_Cust_Packages__c(Id = pcp.Id, LastFollowupDate__c = CalcfollowupVisitdt + projMonitorFreq));
		            		}
		            	}
            		}
	            }
            }
        }
		
		try{
			if(visitRecForInsert != null && visitRecForInsert.size() > 0){
				insert visitRecForInsert;
				projectQuery(DupCheckMap);
				towerVisit();
			}
			if(UpdCustomerPakageList != null && UpdCustomerPakageList.size() > 0) // updating Customer Package
				update UpdCustomerPakageList;
			if(towerVisitForInsert != null && towerVisitForInsert.size() > 0){
				insert towerVisitForInsert;
					
				/* Logic for relating construction status and towervisit */
				for(Visit__c towervisit : towerVisitForInsert){
					mapforTower.put(towervisit.Tower__c, towervisit);				
				}
			}
				
			if(constStatuslistForInsert != null && constStatuslistForInsert.size() > 0){
				for(Construction_Status__c constStatus : constStatuslistForInsert){
					if(mapforTower.containsKey(constStatus.Tower__c)){
						constStatus.Tower_Visit__c = mapforTower.get(constStatus.Tower__c).Id;
						constStatus.Tower__c = null;
					}
				}
				insert constStatuslistForInsert;
			}
			if(detailPricelistForInsert != null && detailPricelistForInsert.size() > 0)
				insert detailPricelistForInsert;
			if(InfraNearProjectlistForInsert != null && InfraNearProjectlistForInsert.size() > 0)
				insert InfraNearProjectlistForInsert;
			if(FeedbacklistForInsert != null && FeedbacklistForInsert.size() > 0)
				insert FeedbacklistForInsert;
			if(additChargeslistForInsert != null && additChargeslistForInsert.size() > 0)
				insert additChargeslistForInsert;
			if(paymentPlanslistForInsert != null && paymentPlanslistForInsert.size() > 0)
				insert paymentPlanslistForInsert;	
		}catch(DMLException e){
			system.debug(e);
		}
	}
	
	public void towerVisit(){
		map<Id, Visit__c> mapforFollowupVisitRec = new  map<Id, Visit__c>();	
		towerVisitForInsert = new list<Visit__c>();	
		Visit__c visitRec;
		/* This logic is for bulk data of follow up visit */
		for(Visit__c vis : visitRecForInsert){
			mapforFollowupVisitRec.put(vis.Project__c, vis);
		}
		
		/* For tower Visit record */
		for(Tower__c tow : towerlist){
			if(mapforFollowupVisitRec.containsKey(tow.Project__c)){
				VisitRec = new Visit__c();
				VisitRec.RecordTypeId = TowerRecTypeId;
				VisitRec.Tower__c = tow.Id;
				VisitRec.Visit__c = mapforFollowupVisitRec.get(tow.Project__c).Id;
				VisitRec.Actual_Basement_Floors__c = tow.Actual_Basement_Floors__c;  
				VisitRec.Actual_Parking_Floors__c = tow.Actual_Parking_Floors__c;
				VisitRec.Actual_ResCom_Floors__c = tow.Actual_ResCom_Floors__c;
				VisitRec.Deviation__c = tow.Deviation__c;
				VisitRec.Max_Avg_Developer_BSP_per_Sqft__c =tow.Max_Avg_Developer_BSP_per_Sq_Ft__c; 
				VisitRec.Max_Avg_Resale_Price_Per_Sqft__c = tow.Max_Avg_Resale_Price_Per_Sqft__c;
				VisitRec.Min_Avg_Developer_BSP_per_Sqft__c = tow.Min_Avg_Developer_BSP_per_Sq_Ft__c;
				VisitRec.Min_Avg_Resale_Price_Per_Sqft__c = tow.Min_Avg_Resale_Price_Per_Sqft__c;
				VisitRec.Launched_Units__c = tow.Launched_Units__c;
				VisitRec.Sold_Units__c = tow.Sold_Units__c;
				VisitRec.Proposed_Completion_Date__c = tow.Proposed_Completion_Date__c;
				VisitRec.OwnerId = mapforFollowupVisitRec.get(tow.Project__c).OwnerId;
				towerVisitForInsert.add(VisitRec);	
			}
		}		
		/* For Construction Status */
		constStatuslistForInsert = new list<Construction_Status__c>();
		set<Id> towerSetId = new set<Id>();
		for(Construction_Status__c conStat : constStatuslist){
			if(towerSetId.add(conStat.Tower__c)){
				if(mapforFollowupVisitRec.containsKey(conStat.Project__c))	
					conStat.Visit__c = mapforFollowupVisitRec.get(conStat.Project__c).Id;
					conStat.Project__c = null;
					conStat.ProjConsStatusUniqueKey__c = null;
					Construction_Status__c cons = conStat.clone(false, true);
					constStatuslistForInsert.add(cons);
			}
		}
		/* For Detail Price List */
		detailPricelistForInsert = new list<Detail_Price_List__c>();
		for(Detail_Price_List__c detPrice : detailPricelist){
			if(mapforFollowupVisitRec.containsKey(detPrice.Project__c))	
				detPrice.Visit__c = mapforFollowupVisitRec.get(detPrice.Project__c).Id;
				detPrice.Project__c = null;
				detPrice.ProjPriceUniqueKey__c = null;
				Detail_Price_List__c dpl = detPrice.clone(false, true);
				detailPricelistForInsert.add(dpl);
		}
		/* For Infrastructure Near Project */
		InfraNearProjectlistForInsert = new list<Infrastructure_Near_Project__c>();
		for(Infrastructure_Near_Project__c infNearProj : InfraNearProjectlist){
			if(mapforFollowupVisitRec.containsKey(infNearProj.Project_Id__c))	
				infNearProj.Visit__c = mapforFollowupVisitRec.get(infNearProj.Project_Id__c).Id;
				infNearProj.Project_Id__c = null;
				infNearProj.ProjInfraUniqueKey__c = null;
				Infrastructure_Near_Project__c inp = infNearProj.clone(false, true);
				InfraNearProjectlistForInsert.add(inp);
		}
		/* For Project Feedback */
		FeedbacklistForInsert = new list<Project_Feedback__c>();
		for(Project_Feedback__c feedback : Feedbacklist){
			if(mapforFollowupVisitRec.containsKey(feedback.Project__c))	
				feedback.Visit__c = mapforFollowupVisitRec.get(feedback.Project__c).Id;
				feedback.Project__c = null;
				feedback.ProjFeedUniqueKey__c = null;
				Project_Feedback__c pf = feedback.clone(false, true);
				FeedbacklistForInsert.add(pf);
		}
		/* For Additional Charges */
		additChargeslistForInsert = new list<Additional_Charges__c>();
		for(Additional_Charges__c addCharges : additChargeslist){
			if(mapforFollowupVisitRec.containsKey(addCharges.Project__c))	
				addCharges.Visit__c = mapforFollowupVisitRec.get(addCharges.Project__c).Id;
				addCharges.Project__c = null;
				addCharges.ProjAddnChgUniqueKey__c = null;
				Additional_Charges__c ac = addCharges.clone(false, true);
				additChargeslistForInsert.add(ac);
		}
		
		/* For Payment Plans */
		paymentPlanslistForInsert = new list<Payment_Plan__c>();
		for(Payment_Plan__c paymentPlan : paymentPlanslist){
			if(mapforFollowupVisitRec.containsKey(paymentPlan.Project__c))	
				paymentPlan.Visit__c = mapforFollowupVisitRec.get(paymentPlan.Project__c).Id;
				paymentPlan.Project__c = null;
				paymentPlan.ProjectPaymentPlanUniqueKeyUpdate__c = null;
				Payment_Plan__c pp = paymentPlan.clone(false, true);
				paymentPlanslistForInsert.add(pp);
		}
	}
		
	public void projectQuery(map<Id, Visit__c> mapDupCheck){
		string StringOFId ='';
		string fullQuery = '';
		string StringOFIdNew = '';
		boolean copyQuery = false;
		list<Project__c> records = new list<Project__c>();
		Schema.SObjectType targetType;
		Schema.DescribeSObjectResult typedescription;
		Map<String, schema.Sobjectfield> resultMap;
		
		/* For Tower Subquery */ 
		string TowerObjectName = 'Tower__c';
		string TowerChildRelName = 'Towers__r';
		targetType = Schema.getGlobalDescribe().get('Tower__c');
		typedescription = targetType.getDescribe();
		resultMap = typedescription.Fields.getMap();
		string towerQuery = 'SELECT ' + string.join(new List<string>(typedescription.Fields.getMap().keySet()), ',') + ' FROM '+ TowerChildRelName ;
		targetType = null;
		typedescription = null;
		resultMap =null;
		
		/* For Construction Status Subquery */ 
		string constStatusObjectName = 'Construction_Status__c';
		string constStatusChildRelName = 'Construction_Status__r';
		targetType = Schema.getGlobalDescribe().get('Construction_Status__c');
		typedescription = targetType.getDescribe();
		resultMap = typedescription.Fields.getMap();
		string constStatusQuery = 'SELECT ' + string.join(new List<string>(typedescription.Fields.getMap().keySet()), ',') + ' FROM '+ constStatusChildRelName;
		targetType = null;
		typedescription = null;
		resultMap =null;
		
		/* For Detail Price Subquery */ 
		string detailPriceObjectName = 'Detail_Price_List__c';
		string detailPriceChildRelName = 'Detail_Price_List__r';
		targetType = Schema.getGlobalDescribe().get('Detail_Price_List__c');
		typedescription = targetType.getDescribe();
		resultMap = typedescription.Fields.getMap();
		string detailPriceQuery = 'SELECT ' + string.join(new List<string>(typedescription.Fields.getMap().keySet()), ',') + ' FROM '+ detailPriceChildRelName ;
		targetType = null;
		typedescription = null;
		resultMap =null;
		
		/* For Infrastructure Near Project Subquery */ 
		string InfraNearProjectObjectName = 'Infrastructure_Near_Project__c';
		string InfraNearProjectChildRelName = 'Infrastructure_Near_Project__r';
		targetType = Schema.getGlobalDescribe().get('Infrastructure_Near_Project__c');
		typedescription = targetType.getDescribe();
		resultMap = typedescription.Fields.getMap();
		string InfraNearProjQuery = 'SELECT ' + string.join(new List<string>(typedescription.Fields.getMap().keySet()), ',') + ' FROM '+ InfraNearProjectChildRelName ;
		targetType = null;
		typedescription = null;
		resultMap =null;
				
		/* For Remark(Feedback) Subquery */ 
		string FeedbackObjectName = 'Project_Feedback__c';
		string FeedbackChildRelName = 'Project_Feedbacks__r';
		targetType = Schema.getGlobalDescribe().get('Project_Feedback__c');
		typedescription = targetType.getDescribe();
		resultMap = typedescription.Fields.getMap();
		string remarkQuery = 'SELECT ' + string.join(new List<string>(typedescription.Fields.getMap().keySet()), ',') + ' FROM '+ FeedbackChildRelName ;
		targetType = null;
		typedescription = null;
		resultMap =null;
		
		/* For Additional Charges Subquery */ 
		string additChargesObjectName = 'Additional_Charges__c';
		string additChargesChildRelName = 'Additional_Charges__r';
		targetType = Schema.getGlobalDescribe().get('Additional_Charges__c');
		typedescription = targetType.getDescribe();
		resultMap = typedescription.Fields.getMap();
		string AddChargesQuery = 'SELECT ' + string.join(new List<string>(typedescription.Fields.getMap().keySet()), ',') + ' FROM '+ additChargesChildRelName ;
		targetType = null;
		typedescription = null;
		resultMap =null;
		
		
		/* For Payment Plan Subquery*/ 
		string paymentPlanObjectName = 'Payment_Plan__c';
		string paymentPlanChildRelName = 'Payment_Plans__r';
		targetType = Schema.getGlobalDescribe().get('Payment_Plan__c');
		typedescription = targetType.getDescribe();
		resultMap = typedescription.Fields.getMap();
		string paymentPlanQuery = 'SELECT ' + string.join(new List<string>(typedescription.Fields.getMap().keySet()), ',') + ' FROM '+ paymentPlanChildRelName ;
		
		for(Visit__c vis : visitListForCopy){
			StringOFId += '\''+vis.Project__c+'\',';
			copyQuery = true;
		}
		if(copyQuery){
			StringOFIdNew = StringOFId.substring(0, StringOFId.length()-1); 
			fullQuery = 'SELECT Name,('+towerQuery+'),('+constStatusQuery+' order by LastModifiedDate,Tower__c ),('+detailPriceQuery+'),('+InfraNearProjQuery+'),('+remarkQuery+'),('+AddChargesQuery+ '),('+paymentPlanQuery+') FROM Project__c where Id IN ('+StringOFIdNew+')';
			records = Database.query(fullQuery);
			system.debug('---------'+records);
		}
		
		/* This part is to copy the project child records in to a seperate list */
		for(Project__c pr :records){
			if(pr.Towers__r != null && pr.Towers__r.size() > 0)
    			towerlist.addAll(pr.Towers__r);
    		if(pr.Construction_Status__r != null && pr.Construction_Status__r.size() > 0)	
    			constStatuslist.addAll(pr.Construction_Status__r);
    		if(pr.Detail_Price_List__r != null && pr.Detail_Price_List__r.size() > 0)	
    			detailPricelist.addAll(pr.Detail_Price_List__r);
    		if(pr.Infrastructure_Near_Project__r != null && pr.Infrastructure_Near_Project__r.size() > 0)	
    			InfraNearProjectlist.addAll(pr.Infrastructure_Near_Project__r);
    		if(pr.Project_Feedbacks__r != null && pr.Project_Feedbacks__r.size() > 0)	
    			Feedbacklist.addAll(pr.Project_Feedbacks__r);
    		if(pr.Additional_Charges__r != null && pr.Additional_Charges__r.size() > 0)	
    			additChargeslist.addAll(pr.Additional_Charges__r);	
    		if(pr.Payment_Plans__r != null && pr.Payment_Plans__r.size() > 0)	
    			paymentPlanslist.addAll(pr.Payment_Plans__r);				
		}
		/* ---- End ---- */
	}
   
	global void finish(Database.BatchableContext BC){

	}
}