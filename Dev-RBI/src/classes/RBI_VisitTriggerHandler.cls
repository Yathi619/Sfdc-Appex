public without sharing class RBI_VisitTriggerHandler {
    /* This is handler class for RBI_VisitTrigger */
    public list<Project__c> projectlist;
    list<Detail_Price_List__c> folUpDetailPrice;
    map<Id, Visit__c> mapForFolVisit;
    list<Visit__c> folUpTowerVisit;
    list<AWS_S3_Object__c> folUpAWSObjList;
    map<Id, AWS_S3_Object__c> mapForAWSTowProj;
    set<Id> TowerId;
    list<Detail_Price_List__c> detailPricListForProject;
    public list<Project_Feedback__c> projFeedback;
    public list<Project_Feedback__c> PrjFb;
    public Project_Feedback__c updatedfeedbckobj;
    public list<Infrastructure_Near_Project__c> infraProj;
    public list<Infrastructure_Near_Project__c> infNrPrj;
    public Infrastructure_Near_Project__c updtInfrNrPrj;
    public list<Construction_Status__c> ContStat;
    public list<Construction_Status__c> CS;
    public Construction_Status__c updtConStatus;
    public list<Additional_Charges__c> Additionalchrglist;
    public list<Additional_Charges__c> AddnchgList;
    public  Additional_Charges__c upAddCrg;
    public list<Payment_Plan__c> Paymentlist;
    public list<Payment_Plan__c> Paymlist;
    public  Payment_Plan__c upPayment;
    list<Visit__c> vstForAllRelatedList;
    public list<Visit__c> visitstatuslist = new list<Visit__c>();
    public list<Visit__c> finalvisitstatuslist = new list<Visit__c>();
    list<List_of_Values__c> LOVList;
    list<List_of_Values__c> DvuLOVList = new list<List_of_Values__c>();
    list<List_of_Values__c> FtrLOVList = new list<List_of_Values__c>();
    list<List_of_Values__c> TsrLOVList = new list<List_of_Values__c>();
    list<List_of_Values__c> PMSLOVList = new list<List_of_Values__c>(); 
    list<List_of_Values__c> folUpLOVList = new list<List_of_Values__c>();    
    public list<Visit__c> DvuVisit = new list<Visit__c>();
    public list<Visit__c> FtrVisit = new list<Visit__c>();
    public list<Visit__c> folUpVisit = new list<Visit__c>();
    public Boolean uniqSetkey;
    public list<Visit__c> TsrVisit = new list<Visit__c>();
    public map<Id, Visit__c> booleanMapVisit = new map<Id, Visit__c>();
    public Static boolean FirstUpdate = true; //Used To avoid recursive call
    Static boolean PSSStatus = true;
    Static boolean PMRjStatus = true;
    public list<Visit__c> queryedVisList; 
    list<Project__c> updtprojlist; // used to update project visit date   
    set<Id> projectIdSet = new set<Id>();
    set<String> uniquekeyString = new set<String>();
    set<Id> updvisitidset;
    map<Id,Id> PASprojectIdMap;
    map<Id,Id> PMSprojectIdMap;
    map<Id,Id> FTRprojectIdMap;      
    Id projectId = null;
    public list<CRM_Report__c> ReportsforInsert = new list<CRM_Report__c>();
    Map<Id,Project_Cust_Packages__c> CustprojMap;

    public RBI_VisitTriggerHandler(){
        updvisitidset = new set <Id>(); 
        updtprojlist = new list<Project__c>();
        vstForAllRelatedList = new list<Visit__c>();
        LOVList = [SELECT Name,Entity_Name__c,Entity_Type__c,Id, Key__c, Value__c FROM List_of_Values__c where Entity_Name__c = 'CRM Report'];
        PASprojectIdMap = new map<Id,Id>();
        PMSprojectIdMap = new map<Id,Id>();
        FTRprojectIdMap = new map<Id,Id>();
    }
    
    public void OnafterUpdate(list<Visit__c> visitListNew, list<Visit__c> visitListOld, Map<Id, Visit__c> ObjectMap){
        if(FirstUpdate){
            list<Project__c> updateProjectList = new list<Project__c>();
            FirstUpdate = false;
            generateSingleProd(LOVList);
            updtprojlist = new list<Project__c>();
            /* Building the list of DvuVisit, TsrVisit and FtrVisit */
            for(Visit__c visNew : visitListNew){
            	if(visNew.Id ==  ObjectMap.get(visNew.Id).Id && (visNew.Status__c != ObjectMap.get(visNew.Id).Status__c)){
                	projectIdSet.add(visNew.Project__c);
                    projectId = visNew.Project__c;
                    if((visNew.Visit_Report__c == 'DVU Report') && (visNew.Status__c == 'Positive' || visNew.Status__c == 'Negative')){
                    	DvuVisit.add(visNew);
                    }
                    if((visNew.Visit_Report__c == 'TSR Report') && (visNew.Status__c == 'Positive' || visNew.Status__c == 'Negative')){
                        TsrVisit.add(visNew);
                    }
                    if(visNew.Status__c == 'Approved' && visNew.Visit_Report__c == 'First Technical Report'){
                        FtrVisit.add(visNew);
                    }
                    if((visNew.Visit_Report__c == 'DVU Report' ) || (visNew.Visit_Report__c == 'TSR Report')){
                        booleanMapVisit.put(visNew.Id,visNew);
                    }
                    if(visNew.Status__c == 'Approved' && (visNew.Visit_Report__c == 'First Technical Report' || visNew.Visit_Report__c == 'Followup Report')){
                        //Used to set project last visit date
                        updtprojlist.add(new Project__c(Id=visNew.Project__c,Site_Visit_Date__c =system.today()));
                        if(visNew.Visit_Report__c == 'Followup Report'){
                    		updvisitidset.add(visNew.Id);
                            if(visNew.Status__c == 'Approved')
                              	folUpVisit.add(visNew);
                        }
                    }
                }
            }
            if(updtprojlist!=null && updtprojlist.size()>0){
                update updtprojlist;
            }
            //query for project associated to the visit record which is edited.
            projectlist = [select name,Site_Visit_Date__c, Status__c, construction_Status__c, Site_Contact_NameDesg__c,(select name, Project__c,Tower__c, ProjPriceUniqueKey__c from Detail_Price_List__r) from Project__c where Id IN : projectIdSet];
            // function call to update Visit feedback to project
            if(updvisitidset != null && updvisitidset.size()>0){
                QueryVisitRelatedListUpdate(updvisitidset);
            }
            map<String , CRM_Report__c> dupCheckForReport = dupCheck();
            
            /* This is to create record in report object */
            if(DvuVisit != null && DvuVisit.size() > 0){
                for(Visit__c dvuVisit : DvuVisit){
                    for(List_of_Values__c dvuLOV: DvuLOVList){
                        if(dupCheckForReport.containsKey(dvuVisit.Project__c+'-'+dvuLOV.Name) && dupCheckForReport.get(dvuVisit.Project__c+'-'+dvuLOV.Name).Report_Name__r.Name == dvuLOV.name){
                            continue;
                        } 
                        else{
                            if(dvuLOV.Entity_Name__c == 'CRM Report' ){
                                CRM_Report__c CRMRecord = new CRM_Report__c();
                                CRMRecord.Report_Name__c = dvuLOV.Id;
                                CRMRecord.Which_Report__c = dvuLOV.Entity_Type__c;
                                CRMRecord.Status__c = 'Completed';
                                CRMRecord.Project__c = dvuVisit.Project__c;
                                ReportsforInsert.add(CRMRecord);
                                PASprojectIdMap.put(dvuVisit.Project__c,dvuVisit.Project__c);
                            }
                        } 
                    }
                }
            }
            if(TsrVisit != null && TsrVisit.size() > 0){
                for(Visit__c tsrVisit : TsrVisit){
                    for(List_of_Values__c tsrLOV: TsrLOVList){
                        if(dupCheckForReport.containsKey(tsrVisit.Project__c+'-'+tsrLOV.Name) && dupCheckForReport.get(tsrVisit.Project__c+'-'+tsrLOV.Name).Report_Name__r.Name == tsrLOV.Name){
                            continue;
                        }else{
                            if(tsrLOV.Entity_Name__c == 'CRM Report'){
                                CRM_Report__c CRMRecord = new CRM_Report__c();
                                CRMRecord.Report_Name__c = tsrLOV.Id;
                                CRMRecord.Which_Report__c = tsrLOV.Entity_Type__c;
                                CRMRecord.Status__c = 'Completed';
                                CRMRecord.Project__c = tsrVisit.Project__c;
                                ReportsforInsert.add(CRMRecord);
                                PASprojectIdMap.put(tsrVisit.Project__c,tsrVisit.Project__c);
                             }
                        }
                    }
                }
            }
            if(FtrVisit != null && FtrVisit.size() > 0){
                loadPMSMap();
                for(Visit__c ftrVisit : FtrVisit){
                    // To create Unit level, tower level, proj report incase customer has PMS enabled
                    if(CustprojMap.containsKey(ftrVisit.Project__c) ){
                         for(List_of_Values__c pmslst: PMSLOVList){
                            if(dupCheckForReport.containsKey(ftrVisit.Project__c+'-'+pmslst.Name) && dupCheckForReport.get(ftrVisit.Project__c+'-'+pmslst.Name).Report_Name__r.Name == pmslst.Name ){
                                continue;
                            }else{
                                if(pmslst.Entity_Name__c == 'CRM Report'){
                                    CRM_Report__c CRMRecord = new CRM_Report__c();
                                    CRMRecord.Report_Name__c = pmslst.Id;
                                    CRMRecord.Which_Report__c = pmslst.Entity_Type__c;
                                    CRMRecord.Status__c = 'Completed';
                                    CRMRecord.Project__c = ftrVisit.Project__c;
                                    ReportsforInsert.add(CRMRecord);
                                    PMSprojectIdMap.put(ftrVisit.Project__c,ftrVisit.Project__c);
                                }
                            }
                               
                        }                       
                    }
                    //end to create
                    for(List_of_Values__c ftrLOV: FtrLOVList){
                        if(dupCheckForReport.containsKey(ftrVisit.Project__c+'-'+ftrLOV.Name) && dupCheckForReport.get(ftrVisit.Project__c+'-'+ftrLOV.Name).Report_Name__r.Name == ftrLOV.Name){
                            continue;
                        }else{
                            if(ftrLOV.Entity_Name__c == 'CRM Report'){
                                CRM_Report__c CRMRecord = new CRM_Report__c();
                                CRMRecord.Report_Name__c = ftrLOV.Id;
                                CRMRecord.Which_Report__c = ftrLOV.Entity_Type__c;
                                CRMRecord.Status__c = 'Completed';
                                CRMRecord.Project__c = ftrVisit.Project__c;
                                ReportsforInsert.add(CRMRecord);
                                FTRprojectIdMap.put(ftrVisit.Project__c,ftrVisit.Project__c);
                                PASprojectIdMap.put(ftrVisit.Project__c,ftrVisit.Project__c);                                   
                            }
                        }
                    }
                }
            }
            if(folUpVisit != null && folUpVisit.size() > 0){
                for(Visit__c folvis : folUpVisit){
                    for(List_of_Values__c folLOV: folUpLOVList){
                        if(folLOV.Entity_Name__c == 'CRM Report'){
                            CRM_Report__c CRMRecord = new CRM_Report__c();
                            CRMRecord.Report_Name__c = folLOV.Id;
                            CRMRecord.Which_Report__c = folLOV.Entity_Type__c;
                            CRMRecord.Status__c = 'Completed';
                            CRMRecord.Project__c = folvis.Project__c;
                            CRMRecord.Visit__c = folvis.Id;
                            ReportsforInsert.add(CRMRecord);
                        }
                    }
                }
            }
            //function call to update service dates
            updateServiceDates();
            /* This if is to chech the status of visit record of type TSR or DVU is not query as status*/
            queryVisit(); 
            
            /* Logic to update the status of parent record project */ 
            for(Project__c proj : projectlist){ //outer for
                boolean FTRApprFlag = false;
                boolean DVURepFlag = false;
		        boolean TSRRepFlag = false; 
	            boolean TSRDVUQueryFlag = false;
                for(Visit__c vis : queryedVisList){ // inner for loop
                    if(proj.Id == vis.Project__c){
                        if(vis.Visit_Report__c == 'First Technical Report' && vis.Status__c == 'Approved'){
                            FTRApprFlag = true;
                        }
                        if((vis.Visit_Report__c == 'DVU Report') && (vis.Status__c == 'Positive' || vis.Status__c == 'Negative')){
                            DVURepFlag = true;
                        }
                        if((vis.Visit_Report__c == 'TSR Report') && (vis.Status__c == 'Positive' || vis.Status__c == 'Negative')){
                            TSRRepFlag = true;
                        }
                        if((vis.Visit_Report__c == 'DVU Report' || vis.Visit_Report__c == 'TSR Report') && (vis.Status__c == 'Query')){
                            TSRDVUQueryFlag = true;
                        }
                    }
                }
                if((FTRApprFlag == true) &&  (DVURepFlag == false || TSRRepFlag == false) && (TSRDVUQueryFlag == false)){
                    updateProjectList.add(new Project__c(Id = proj.Id, Status__c = 'PSS'));
                }
                else if(FTRApprFlag == true && DVURepFlag == true && TSRRepFlag == true){
                    updateProjectList.add(new Project__c(Id = proj.Id, Status__c = 'PMR'));
                }
                else if(TSRDVUQueryFlag == true){
                    updateProjectList.add(new Project__c(Id = proj.Id, Status__c = 'PQR'));
                }
            }//outer for
            /* End of changing status in project logic */
            try{
                if(ReportsforInsert != null && ReportsforInsert.size() > 0)
                    insert ReportsforInsert;
                if(updateProjectList != null && updateProjectList.size() >0){
                    update updateProjectList;
                }
            }catch(DMLException e){
                system.debug('This exception is from trigger insert'+e);
            }
        }
    }
    
    public map<String, CRM_Report__c> dupCheck(){
        map<String, CRM_Report__c> dupCheckMap = new map<String, CRM_Report__c>();
        for(CRM_Report__c crmReport : [select name, Project__c, Report_Name__c, Report_Name__r.Name from CRM_Report__c where Project__c IN : projectIdSet]){
            dupCheckMap.put(crmReport.Project__c+'-'+crmReport.Report_Name__r.Name, crmReport);
        }
        return dupCheckMap;
    }
    // helper function to update the service actual start date
    private void updateServiceDates(){
        List<Project_Cust_Packages__c> custpkgList  =  new List<Project_Cust_Packages__c>();
        List<Project_Cust_Packages__c> updcustpkgList   =  new List<Project_Cust_Packages__c>();
        Date currentdt = system.today();
        custpkgList = [SELECT Start_Date__c, Project_Id__c, List_of_Values__c, LOV_Name__c, Id, End_Date__c FROM Project_Cust_Packages__c
                   WHERE Customer_Project__r.Project_Id__c IN : projectIdSet AND Start_Date__c = null];
                   
        for(Project_Cust_Packages__c cp : custpkgList){
            if((cp.LOV_Name__c == 'PAS')&&(PASprojectIdMap.containsKey(cp.Project_Id__c))){
                updcustpkgList.add(new Project_Cust_Packages__c(Id=cp.Id,Start_Date__c = currentdt));
            }
            else if((cp.LOV_Name__c == 'FTR')&&(FTRprojectIdMap.containsKey(cp.Project_Id__c))){
                updcustpkgList.add(new Project_Cust_Packages__c(Id=cp.Id,Start_Date__c = currentdt));
            }
            else if((cp.LOV_Name__c == 'PMS')&&(PMSprojectIdMap.containsKey(cp.Project_Id__c))){
                updcustpkgList.add(new Project_Cust_Packages__c(Id=cp.Id,Start_Date__c = currentdt));
            }          
        }
        if((updcustpkgList != null) && (updcustpkgList.size()>0))
        {
            Database.update(updcustpkgList);
        }
    }
    
    public void generateSingleProd(list<List_of_Values__c> lovlist){
        PMSLOVList = new list<List_of_Values__c>();
        for(List_of_Values__c lov : lovlist){
            if(lov.Key__c == 'DVU Report')
                DvuLOVList.add(lov);
            else if(lov.Key__c == 'TSR Report')
                TsrLOVList.add(lov);        
            else if(lov.Key__c == 'First Technical Report')
                FtrLOVList.add(lov);    
            else if(lov.Key__c == 'Followup Report' && lov.Value__c == 'PMS')
                PMSLOVList.add(lov);   
            else if(lov.key__c == 'PMSFollowup' && lov.Value__c == 'PMSFollowup')
                folUpLOVList.add(lov);                          
        }
    }

    /* This method is to query the database with respect to project */
    public void queryVisit(){
        queryedVisList = [Select v.Visit_Report__c,v.Status__c, v.Project__c, v.Project_Name__c, v.ProjecIdVisitType__c, v.Name From Visit__c v where Project__c IN : projectIdSet];
    }

    private void loadPMSMap(){
        CustprojMap = new Map<Id,Project_Cust_Packages__c>();
        List<Project_Cust_Packages__c> custpckg= [Select Customer_Project__r.Project_Id__c,Id,Name From Project_Cust_Packages__c where Customer_Project__r.Project_Id__c IN : projectIdSet AND LOV_Name__c = 'PMS'];
        for(Project_Cust_Packages__c cpk :custpckg){
            if(!(CustprojMap.containsKey(cpk.Customer_Project__r.Project_Id__c)))
                CustprojMap.put(cpk.Customer_Project__r.Project_Id__c, cpk);
        }
    }
    
    public void QueryVisitRelatedListUpdate(Set <Id> updatedIds){
        String StringOFId = '';
        String StringOFIdNew;
        boolean copyQuery = false;
        /* Dynamic query for Detail price list */
        string DetailPricObjectName = 'Detail_Price_List__c';
        string DetailPricChildRelName = 'Detail_Price_List__r';
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Detail_Price_List__c');
        Schema.DescribeSObjectResult typedescription = targetType.getDescribe();
        Map<String, schema.Sobjectfield> resultMap = typedescription.Fields.getMap();
        string detailPriceQuery = 'SELECT ' + string.join(new List<string>(typedescription.Fields.getMap().keySet()), ',') + ' FROM '+ DetailPricChildRelName;
        for(Id folVisId: updatedIds ){
            StringOFId += '\''+folVisId+'\',';
            copyQuery = true;
        }
        if(copyQuery){
            StringOFIdNew = StringOFId.substring(0, StringOFId.length()-1); 
            String Query = 'SELECT Id,Status__c, Construction__c, Site_Contact_NameDesg__c, Project__c,Project__r.Name, Tower__c, (SELECT Access__c,Bucket_Name__c,Content_Type__c,File_Name__c,FollowUp_Visit__c,imageurl__c,Name,OwnerId,Preview_Link__c,Project__c,Report_Name_Calc__c,Report_Type__c,Tower__c,Visit__c, Visit__r.Tower__c FROM FollowUpAWS_S3_Objects__r), (select Actual_Basement_Floors__c, Actual_Parking_Floors__c, Deviation__c, Max_Avg_Developer_BSP_per_Sqft__c, Max_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sqft__c, Actual_ResCom_Floors__c,Tower__c, Min_Avg_Resale_Price_Per_Sqft__c, Launched_Units__c, Sold_Units__c, Proposed_Completion_Date__c from Visits__r ), (SELECT Comments__c, List_of_Values_Id__c,List_of_Values_Id__r.Name, Visit__r.Status__c, Project__c, Visit__c, Visit__r.Project__r.Name, Project_Name__c, ProjFeedUniqueKey__c, Remark_Type__c,Visit_Feedback_Unique_Key__c  from Project_Feedbacks__r), (SELECT Infrastructure_Near_Project__r.Name, Visit__r.Status__c, Status__c, Project_Id__c, Visit__c, Visit__r.Project__c, Distance_From_Project_In_Km__c, Visit__r.Project__r.Name, ProjInfraUniqueKey__c,VstInfraUniqueKey__c from Infrastructure_Near_Project__r), (SELECT Basement__c, Electrification_and_Sanitation__c,Excavation_of_Footings__c, Tower__c, Finishing__c, Masonary__c, Visit__r.Project__r.Name, Visit__c, RCC_Slab_Casting__c,ProjConsStatusUniqueKey__c, Tower_Visit__c, Tower_Visit__r.Tower__c,  Visit__r.Status__c, Tower__r.Project__r.Name,Tower__r.Project__c, Tower__r.Name from Construction_Status__r), (SELECT Project__r.Name, Project__c, Charge_Per_Sqft__c, Charge_Detail__c, Charge_Type__c, From_Floor__c, Visit__c, Input_Guidance__c, Mandatory__c, Description__c, ProjAddnChgUniqueKey__c, Remarks__c, Resale_Value__c,Visit__r.Project__r.Name, Visit__r.Status__c, To_Floor__c from Additional_Charges__r), (SELECT Discount__c,Plan_Type__c,Project__c,Visit__c,ProjectPaymentPlanUniqueKeyUpdate__c,Plan_Type__r.Name, Visit__r.Status__c,Visit__r.Project__r.Name from Payment_Plans__r ORDER BY LastModifiedDate DESC),('+detailPriceQuery+') from Visit__c where Id IN ('+StringOFIdNew+')';
            vstForAllRelatedList = Database.query(Query);
        }
        
        folUpDetailPrice = new list<Detail_Price_List__c>();
        mapForFolVisit = new map<Id, Visit__c>();
        folUpTowerVisit = new list<Visit__c>();
        folUpAWSObjList = new list<AWS_S3_Object__c>();
        if(vstForAllRelatedList != null && vstForAllRelatedList.size() > 0){
            for(Visit__c vstProj :vstForAllRelatedList){
                if(vstProj.Status__c == 'Approved'){
                    mapForFolVisit.put(vstProj.Project__c, vstProj);
                    folUpTowerVisit.addAll(vstProj.Visits__r);
                    folUpDetailPrice.addAll(vstProj.Detail_Price_List__r);
                    folUpAWSObjList.addAll(vstProj.FollowUpAWS_S3_Objects__r);
                    if(folUpTowerVisit != null && folUpTowerVisit.size() > 0){
                        TowerId = new set<Id>();
                    }
                }
            }
        }
        ProjRelatedlistUpdate();
        ProjectInfrastructureNearProjectUpdate();
        ProjectConstructionStatusUpdate();
        ProjectAdditionalChargeUpdate();  
        ProjectPaymentplan(); 
        projTowerUpdate();
        detailPriceUpdate();
        AWSObjUpdate();
    }
    
    /* AWS 3 object update */
    
    public void AWSObjUpdate(){
        list<AWS_S3_Object__c> AWSObjListForUpdate = new list<AWS_S3_Object__c>();
        for(AWS_S3_Object__c awsObj : folUpAWSObjList){
            awsObj.Tower__c = awsObj.Visit__r.Tower__c;
            AWSObjListForUpdate.add(awsObj);
        }
        try{
            if(AWSObjListForUpdate != null && AWSObjListForUpdate.size() > 0)
                upsert AWSObjListForUpdate;
        }catch(DMLException e){
            system.debug(e);
        }
    }
    
    /* Logic to update associated Detail price from tower visits to tower with respect to follow up visit */
    public void detailPriceUpdate(){
        String towId = '';
        uniquekeyString = new set<String>();
        Detail_Price_List__c updateDetailPrice;
        String uniqDetailPrickey;
        list<Detail_Price_List__c> detailPricListForUpdate = new list<Detail_Price_List__c>();
        for(Detail_Price_List__c folUpdelPric: folUpDetailPrice){
            Schema.Sobjecttype objToken = Schema.getGlobalDescribe().get('Detail_Price_List__c');
            Map<String, SobjectField> fieldMap = objToken.getDescribe().fields.getMap();        
            uniqDetailPrickey = '';
            updateDetailPrice = new Detail_Price_List__c();
            for(String fieldName : fieldMap.keySet()) {
                //Check to see if they are not system fields.
                if(fieldMap.get(fieldName).getDescribe().Updateable == true) {      
                    if(fieldName=='Visit__c'){
                        updateDetailPrice.put(fieldName,null);
                    }else if(fieldName=='Project__c'){
                        if(folUpdelPric.Visit__c != null)
                            updateDetailPrice.put(fieldName,folUpdelPric.Project_Id__c);
                    }else if(fieldName =='ProjPriceUniqueKey__c'){
                        if((folUpdelPric.Project_Name__c!= null)&&(folUpdelPric.Tower__c!=null)){
                            towId = folUpdelPric.Tower__c;
                            towId=towId.substring(0,15); 
                            uniqDetailPrickey = folUpdelPric.Project_Name__c + towId;
                            updateDetailPrice.put(fieldName,uniqDetailPrickey);
                        }
                    }else if(fieldName!='OwnerId'){
                        updateDetailPrice.put(fieldName, folUpdelPric.get(fieldName));
                    }   
                }
            }
            if(uniqDetailPrickey != '')
                uniqSetkey = uniquekeyString.add(uniqDetailPrickey);
            if(uniqSetkey == true)
                detailPricListForUpdate.add(updateDetailPrice);
            try{
                if(detailPricListForUpdate != null && detailPricListForUpdate.size() > 0)
                    upsert detailPricListForUpdate ProjPriceUniqueKey__c;
            }catch(DMLException e){
                system.debug(e);
            }
        }
    }
    
    /* Logic to update project and tower list field of a project with respect to follow up visit */
    public void projTowerUpdate(){
        detailPricListForProject = new list<Detail_Price_List__c>();
        list<Project__c> projListForUpdate = new list<Project__c>();
        list<Tower__c> towListForUpdate = new list<Tower__c>();

        // for project details
        String projectId = '';
        if(projectlist != null && projectlist.size() > 0){
            for(Project__c proj : projectlist){
                Project__c pro = new Project__c();
                projectId = proj.Id;
                if(mapForFolVisit.containsKey(projectId)){
                    detailPricListForProject.addAll(proj.Detail_Price_List__r);
                    proj.Site_Contact_NameDesg__c = mapForFolVisit.get(proj.Id).Site_Contact_NameDesg__c;
                    proj.construction_Status__c = mapForFolVisit.get(proj.Id).construction__c;   
                    projListForUpdate.add(proj);
                }
            }
        }

        // for tower details
        if(folUpTowerVisit != null && folUpTowerVisit.size() > 0){
            for(Visit__c folTowvist : folUpTowerVisit){
                Tower__c tow = new Tower__c(Id = folTowvist.Tower__c);
                tow.Actual_Basement_Floors__c = folTowvist.Actual_Basement_Floors__c;
                tow.Actual_Parking_Floors__c = folTowvist.Actual_Parking_Floors__c;
                tow.Actual_ResCom_Floors__c = folTowvist.Actual_ResCom_Floors__c;
                tow.Deviation__c = folTowvist.Deviation__c;
                tow.Max_Avg_Developer_BSP_per_Sq_Ft__c = folTowvist.Max_Avg_Developer_BSP_per_Sqft__c;
                tow.Max_Avg_Resale_Price_Per_Sqft__c = folTowvist.Max_Avg_Resale_Price_Per_Sqft__c;
                tow.Min_Avg_Developer_BSP_per_Sq_Ft__c = folTowvist.Min_Avg_Developer_BSP_per_Sqft__c;
                tow.Min_Avg_Resale_Price_Per_Sqft__c = folTowvist.Min_Avg_Resale_Price_Per_Sqft__c;
                tow.Launched_Units__c = folTowvist.Launched_Units__c;
                tow.Sold_Units__c = folTowvist.Sold_Units__c;
                tow.Proposed_Completion_Date__c = folTowvist.Proposed_Completion_Date__c;
                towListForUpdate.add(tow);
            }
        }
        if(projListForUpdate != null && projListForUpdate.size() > 0)
            upsert projListForUpdate;
            
        if(towListForUpdate != null && towListForUpdate.size() > 0)
            upsert towListForUpdate;    
    }
    
    public void ProjRelatedlistUpdate()
    {   
        PrjFb = new list<Project_Feedback__c>();
        projFeedback = new  list<Project_Feedback__c>();
        string uniqfeedbackkey = '';
        for(Visit__c vstProjFeed  :vstForAllRelatedList){
            projFeedback = vstProjFeed.Project_Feedbacks__r;
            Project_Feedback__c updatedfeedbckobj;
            Schema.Sobjecttype objToken = Schema.getGlobalDescribe().get('Project_Feedback__c');
            Map<String, SobjectField> fieldMap = objToken.getDescribe().fields.getMap();        
            for (Project_Feedback__c projfdback :projFeedback)
            {
                if(projfdback.Visit__r.Status__c == 'Approved')
                {
                    uniqfeedbackkey = '';
                    updatedfeedbckobj = new Project_Feedback__c();
                    for(String fieldName : fieldMap.keySet()) {
                    //Check to see if they are not system fields.
                        if(fieldMap.get(fieldName).getDescribe().Updateable == true) {      
                            if(fieldName=='Visit__c'){
                                updatedfeedbckobj.put(fieldName,null);
                            }
                            else if(fieldName=='Project__c'){
                                if(projfdback.Visit__r != null)
                                    updatedfeedbckobj.put(fieldName,projfdback.Visit__r.Project__c);
                            }
                            else if(fieldName =='ProjFeedUniqueKey__c'){
                                if((projfdback.Visit__r.Project__r!= null)&&(projfdback.List_of_Values_Id__r!=null)){
                                    uniqfeedbackkey = projfdback.Visit__r.Project__r.Name + projfdback.List_of_Values_Id__r.Name;
                                    updatedfeedbckobj.put(fieldName,uniqfeedbackkey);
                                }
                            }
                            else if(fieldName!='OwnerId'){
                                updatedfeedbckobj.put(fieldName, projfdback.get(fieldName));
                            }                               
                        }
                    }
                    if(uniqfeedbackkey != '')
                        uniqSetkey = uniquekeyString.add(uniqfeedbackkey);
                    if(uniqSetkey == true)
                        PrjFb.add(updatedfeedbckobj);
                }
            }
        }
        upsert PrjFb ProjFeedUniqueKey__c;
    }

    public void ProjectInfrastructureNearProjectUpdate()
    {
        string uniqInfrakey;
        uniquekeyString = new set<String>();
        infNrPrj = new list<Infrastructure_Near_Project__c>();
        infraProj = new list<Infrastructure_Near_Project__c>();
        for(Visit__c vstInfrProj : vstForAllRelatedList){
            infraProj = vstInfrProj.Infrastructure_Near_Project__r;
            Infrastructure_Near_Project__c updtInfrNrPrj;
            Schema.Sobjecttype objToken = Schema.getGlobalDescribe().get('Infrastructure_Near_Project__c');
            Map<String, SobjectField> fieldMap = objToken.getDescribe().fields.getMap();        
            for (Infrastructure_Near_Project__c InfPrj :infraProj)
            {
                if(InfPrj.Visit__r.Status__c == 'Approved')
                {
                    uniqInfrakey = '';
                    updtInfrNrPrj = new Infrastructure_Near_Project__c();
                    for(String fieldName : fieldMap.keySet()) {
                    //Check to see if they are not system fields.
                        if(fieldMap.get(fieldName).getDescribe().Updateable == true) {      
                          if(fieldName=='Visit__c'){
                                updtInfrNrPrj.put(fieldName,null);
                           }
                           else if(fieldName=='Project_Id__c'){
                                if(InfPrj.Visit__r != null)
                                    updtInfrNrPrj.put(fieldName,InfPrj.Visit__r.Project__c);
                           }
                           else if(fieldName =='ProjInfraUniqueKey__c'){
                               if((InfPrj.Visit__r.Project__r!= null)&&(InfPrj.Infrastructure_Near_Project__r!=null)){
                                   uniqInfrakey = InfPrj.Visit__r.Project__r.Name + InfPrj.Infrastructure_Near_Project__r.Name;
                                   updtInfrNrPrj.put(fieldName,uniqInfrakey);
                               }
                                
                           }
                           else if(fieldName!='OwnerId'){
                                updtInfrNrPrj.put(fieldName, InfPrj.get(fieldName)); 
                           }                                
                        }
                    }
                    if(uniqInfrakey != null)
                        uniqSetkey = uniquekeyString.add(uniqInfrakey) ;
                    if(uniqSetkey == true)
                        infNrPrj.add(updtInfrNrPrj);
                }
            }
        }
        upsert infNrPrj ProjInfraUniqueKey__c;
    } 

    public void ProjectConstructionStatusUpdate()
    {
        uniquekeyString = new set<String>();
        string towId;
        String uniqConstStakey;
        CS = new list<Construction_Status__c>();
        ContStat = new list<Construction_Status__c>();
        for(Visit__c CoStus : vstForAllRelatedList){
            ContStat = CoStus.Construction_Status__r;
            
            Construction_Status__c updtConStatus;
            Schema.Sobjecttype objToken = Schema.getGlobalDescribe().get('Construction_Status__c');
            Map<String, SobjectField> fieldMap = objToken.getDescribe().fields.getMap();        
            for (Construction_Status__c ConStatProj :ContStat)
            {
                uniqConstStakey = '';
                if(ConStatProj.Visit__r.Status__c == 'Approved')
                {
                    updtConStatus = new Construction_Status__c();
                    for(String fieldName : fieldMap.keySet()) {
                    //Check to see if they are not system fields.
                        if(fieldMap.get(fieldName).getDescribe().Updateable == true) {      
                          if(fieldName=='Visit__c'){
                                updtConStatus.put(fieldName,null);
                           }
                           else if(fieldName=='Project__c'){
                                if(CoStus.Project__r.Name != null)
                                    updtConStatus.put(fieldName,CoStus.Project__c);
                                    
                           }
                           else if(fieldName =='ProjConsStatusUniqueKey__c'){
                               if((CoStus.Project__c!= null)&&(ConStatProj.Tower_Visit__r!=null)){
                                   towId = ConStatProj.Tower_Visit__r.Tower__c;
                                   string tempid = ConStatProj.Tower__c;
                                   towId=towId.substring(0,15); 
                                   uniqConstStakey = CoStus.Project__r.Name + towId;  
                                   updtConStatus.put(fieldName,uniqConstStakey);
                               }
                           }
                           else if((fieldName =='Tower__c') && (ConStatProj.Tower_Visit__r!=null)&&(ConStatProj.Tower_Visit__r.Tower__c!=null)){  
                                updtConStatus.put(fieldName,ConStatProj.Tower_Visit__r.Tower__c);
                           }      
                           else if(fieldName!='OwnerId' && fieldName != 'Tower_Visit__c'){
                                updtConStatus.put(fieldName, ConStatProj.get(fieldName)); 
                           }  
                                                
                        }
                    }
                    if(uniqConstStakey != '')
                        uniqSetkey = uniquekeyString.add(uniqConstStakey) ;
                    if(uniqSetkey == true)
                        CS.add(updtConStatus);
                }
            }
        }
        try{
            if(CS != null && CS.size() >0)
                upsert CS ProjConsStatusUniqueKey__c;
        }catch(DMLException e){
            system.debug(e);
        }
    }
    public void ProjectAdditionalChargeUpdate()
    {
        String uniqAddCharkey;
        uniqSetkey = false;
        uniquekeyString = new set<String>();
        AddnchgList = new list<Additional_Charges__c>();
        Additionalchrglist = new list<Additional_Charges__c>();
        for(Visit__c vstac : vstForAllRelatedList){
            Additionalchrglist = vstac.Additional_Charges__r;
            Additional_Charges__c upAddCrg;
            Schema.Sobjecttype objToken = Schema.getGlobalDescribe().get('Additional_Charges__c');
            Map<String, SobjectField> fieldMap = objToken.getDescribe().fields.getMap();
            for(Additional_Charges__c adnChg : Additionalchrglist){
                uniqAddCharkey = '';
                if(adnChg.Visit__r.Status__c == 'Approved'){
                	upAddCrg = new Additional_Charges__c();
                    for(String fieldName : fieldMap.keySet()) {
                        //Check to see if they are not system fields.
                        if(fieldMap.get(fieldName).getDescribe().Updateable == true) {      
                            if(fieldName=='Visit__c'){
                                upAddCrg.put(fieldName,null);
                            }
                            else if(fieldName=='Project__c'){
                            	if(adnChg.Visit__r.Project__c != null)
                                    upAddCrg.put(fieldName,adnChg.Visit__r.Project__c);
                            }
                            else if(fieldName =='ProjAddnChgUniqueKey__c'){
                            	if((adnChg.Visit__r.Project__r!= null)&&(adnChg.Charge_Type__c =='PLC')&&(adnChg.Charge_Detail__c =='Floor Rise')
                                	&&((adnChg.From_Floor__c!=null)&&(adnChg.To_Floor__c!=null))){
                                    uniqAddCharkey = adnChg.Visit__r.Project__r.Name + adnChg.Charge_Type__c + adnChg.Charge_Detail__c + adnChg.From_Floor__c + adnChg.To_Floor__c;
                                    upAddCrg.put(fieldName,uniqAddCharkey);
                                }
	                            else{
	                                if((adnChg.Visit__r.Project__r!= null)&&(adnChg.Charge_Detail__c!=null)){
	                                    uniqAddCharkey = adnChg.Visit__r.Project__r.Name + adnChg.Charge_Type__c + adnChg.Charge_Detail__c;
	                                    upAddCrg.put(fieldName,uniqAddCharkey);                                 
	                                }
	                                else{
	                                    uniqAddCharkey = adnChg.Visit__r.Project__r.Name + adnChg.Charge_Type__c;
	                                    upAddCrg.put(fieldName,uniqAddCharkey);                                 
	                                }  
	                            }
	                        }
	                        else if(fieldName!='OwnerId'){
	                        	upAddCrg.put(fieldName, adnChg.get(fieldName)); 
	                        } 
                        }
                    }
                    if(uniqAddCharkey != '')
                        uniqSetkey = uniquekeyString.add(uniqAddCharkey) ;
                    if(uniqSetkey == true)
                        AddnchgList.add(upAddCrg);
                }       
            }
        }
        try{
	        upsert AddnchgList ProjAddnChgUniqueKey__c;
        }catch(DMLException e){
            system.debug(e);
        }
    } 
    public void ProjectPaymentplan(){
        String uniqPayPlanCharkey;
        uniquekeyString = new set<String>();
        Paymlist = new list<Payment_Plan__c>();
        Paymentlist = new list<Payment_Plan__c>();
        for(Visit__c vspayment : vstForAllRelatedList){
            Paymentlist = vspayment.Payment_Plans__r;
            Payment_Plan__c upPayment;
            Schema.Sobjecttype objToken = Schema.getGlobalDescribe().get('Payment_Plan__c');
            Map<String, SobjectField> fieldMap = objToken.getDescribe().fields.getMap();
            for(Payment_Plan__c adpmt : Paymentlist){
            	uniqPayPlanCharkey = '';
                if(adpmt.Visit__r.Status__c == 'Approved'){
	                upPayment = new Payment_Plan__c();
                    for(String fieldName : fieldMap.keySet()){
                        //Check to see if they are not system fields.
                        if(fieldMap.get(fieldName).getDescribe().Updateable == true){
                            if(fieldName=='Visit__c'){
                                upPayment.put(fieldName,null);
                            }
                            else if(fieldName=='Project__c'){
                            	if(adpmt.Visit__r.Project__c != null)
                                    upPayment.put(fieldName,adpmt.Visit__r.Project__c);
                            }
                            else if(fieldName =='ProjectPaymentPlanUniqueKeyUpdate__c'){
                            	if((adpmt.Visit__r.Project__r.Name!= null)&&(adpmt.Plan_Type__r!=null)){
                                    uniqPayPlanCharkey = adpmt.Visit__r.Project__r.Name + adpmt.Plan_Type__r.Name; 
                                    upPayment.put(fieldName,uniqPayPlanCharkey);
                                 }
                            }
                            else if(fieldName!='OwnerId'){
                                upPayment.put(fieldName, adpmt.get(fieldName));
                            }
                        }
                    }
                	if(uniqPayPlanCharkey != '')     
                    	uniqSetkey = uniquekeyString.add(uniqPayPlanCharkey) ;
                	if(uniqSetkey == true)
                    	Paymlist.add(upPayment); 
                }
            }
        }
        upsert Paymlist ProjectPaymentPlanUniqueKeyUpdate__c;
    }
}