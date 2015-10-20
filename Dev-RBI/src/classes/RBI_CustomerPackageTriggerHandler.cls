public without sharing class RBI_CustomerPackageTriggerHandler {
    
    /* This is handler class for RBI_CustomerPackageTrigger */
    
    public list<Project_Cust_Packages__c> PASCustPack = new list<Project_Cust_Packages__c>();
    public list<Project_Cust_Packages__c> FTRCustPack = new list<Project_Cust_Packages__c>();
    public list<Project_Cust_Packages__c> PMSCustPack = new list<Project_Cust_Packages__c>();
    public list<Visit__c> VisitList = new list<Visit__c>();
    public list<CRM_Report__c> CRMReportList = new list<CRM_Report__c>();
    list<List_of_Values__c> PasLOVList = new list<List_of_Values__c>();
    list<List_of_Values__c> PmsLovList = new list<List_of_Values__c>();
    list<List_of_Values__c> FtrLOVList = new list<List_of_Values__c>();
    list<List_of_Values__c> LOVList;
    list<CRM_Report__c> ReportForInsert = new list<CRM_Report__c>();
    Id ProjRecTypeId;
    boolean TSRFlag = false;
    boolean DVUFlag = false;
    boolean FTRFlag = false;
    boolean PMSFlag = false;
    Set<Id> projidset;
    Map<Id,Project_Cust_Packages__c> CustprojMap; 
    map<String,CRM_Report__c> CRMReportMap;
    map<String , Visit__c> mapForDupCheck;
    public list<CRM_Report__c> ReportsforInsert;       
    public RBI_CustomerPackageTriggerHandler(){
        LOVList = [SELECT Entity_Name__c,Entity_Type__c,Key__c,Name, Id FROM List_of_Values__c];
        ProjRecTypeId = [select Id,name from RecordType where name='Project' and SObjectType='Visit__c' limit 1].Id;
    }
    
    /* This method will handle the call from trigger after insert of Customer Package */
    public void OnAfterInsert(list<Project_Cust_Packages__c> custpackageList){
        
        Id ProjId = null;
        Id projIdkey = null;
        set<String> projVisitType = new set<String>(); 
        projidset = new Set<Id>();
        for(Project_Cust_Packages__c pcp:custpackageList ){
            ProjId = pcp.Project_Id__c;
            projidset.add(ProjId);
            projVisitType.add(ProjId+'-TSR Report');
            projVisitType.add(ProjId+'-DVU Report');
            projVisitType.add(ProjId+'-First Technical Report');
            
        }
        system.debug('projVisitType '+projVisitType);
        checkVisitRec(projVisitType); //This call will build the map for dups check
        loadFTRMap();  
        queryForCRMReports();
        system.debug('CustprojMap'+CustprojMap);      
        for(Project_Cust_Packages__c pcp:custpackageList ){
            projId = pcp.Project_Id__c;
            system.debug('map2'+mapForDupCheck.get(projId+'-TSR Report'));
            system.debug('CRMReportMap '+CRMReportMap);
            system.debug('CustprojMap '+CustprojMap);
            system.debug('mapForDupCheck '+mapForDupCheck);
            system.debug('pcp.LOV_Name__c '+pcp.LOV_Name__c);

            if(pcp.LOV_Name__c=='PAS' ){
                PASCustPack.add(pcp);
                
            }else if(pcp.LOV_Name__c=='FTR' && !(mapForDupCheck.containsKey(projId+'-First Technical Report')) && (mapForDupCheck.get(projId+'-First Technical Report') == null)){
                FTRCustPack.add(pcp);
                system.debug('xxxxxx'+FTRCustPack);
            }
            
            //else if(pcp.LOV_Name__c=='PMS' && ((!CRMReportMap.containsKey(projId+)) && (CustprojMap.containsKey(projId))&&(mapForDupCheck.containsKey(ProjId+'-First Technical Report')))){
            else if(pcp.LOV_Name__c=='PMS' && (CustprojMap.containsKey(projId))&&(mapForDupCheck.containsKey(ProjId+'-First Technical Report'))){
                if(mapForDupCheck.get(ProjId+'-First Technical Report').Status__c == 'Approved'){
                    PMSCustPack.add(pcp);
                    projVisitType.add(ProjId+' PMS Report');
                }
            }
            //system.debug('map4 '+mapForDupCheck.get(ProjId+'-First Technical Report').Status__c);
            //system.debug('projVisitType '+projVisitType);
            //system.debug('PASCustPack-- '+pc  p.Customer_Project__c+'level2 '+pcp.Project_Id__c);
        }   
       
        if(LOVList != null && LOVList.size() > 0){
            generateSingleProd(LOVList);
            system.debug('FtrLOVList '+FtrLOVList);
            system.debug('PasLOVList '+PasLOVList);
            system.debug('PASCustPack '+PASCustPack);
            
            //FtrLOVList = generateSingleProd(LOVList, 'FTR');
            //if(custpackageList.LOV_Name__c == 'PAS'){
            
                if(PasLOVList != null && PasLOVList.size() > 0){
                    for(List_of_Values__c LOV : PasLOVList){
                        for(Project_Cust_Packages__c pcp : PASCustPack){
                        		projIdkey = pcp.Project_Id__c;
                                system.debug('PASCustPack '+mapForDupCheck.containsKey(projIdkey+'-'+LOV.Key__c));
                                system.debug('pcp.Customer_Project__r.Project_Id__c '+projIdkey+'-'+LOV.Key__c);
                                if(LOV.Entity_Type__c == 'Service Visit' && !(mapForDupCheck.containsKey(projIdkey+'-'+LOV.Key__c))){
                                    
                                    Visit__c visit = new Visit__c();
                                    //visit. = system.today();
                                    visit.RecordTypeId = ProjRecTypeId;
                                    visit.Project__c = pcp.Project_Id__c;
                                    visit.Visit_Report__c = LOV.Key__c;
                                    visit.ProjecIdVisitType__c = visit.Project__c+'-'+visit.Visit_Report__c;
                                    //visit.Status__c = 'In Progress';//Checking
                                    system.debug('visit.ProjecIdVisitType__c '+visit.ProjecIdVisitType__c);
                                    /*if(pcp.Team_Leader__c != null){
                                        visit.Team_Leader__c = pcp.Team_Leader__c;
                                        visit.OwnerId = pcp.Team_Leader__c;
                                        //visit.Surveyor__c = pcp.Surveyor_Id__c;
                                    }*/
                                    //Added code for 2nd Phase on 05.08.2013
                                    /*
                                    if(pcp.Technical_Head__c != null){
                                        visit.Technical_Head__c = pcp.Operation_Mgr_Data__c; // changed based on phase 2b on 30.08.2013
                                        visit.OwnerId = pcp.Operation_Mgr_Data__c;
                                    }*/
                                    //Adding End on 05.08.2013
                                    visit.Start_Date__c = system.today();    
                                    VisitList.add(visit);
                                    mapForDupCheck.put(projIdkey+'-'+LOV.Key__c,visit);
                                    system.debug('going in pas'); 
                                }   
        
                        }       
                    }
                    /* This is for adding Team Manager
                    for(Visit__c vis : VisitList){
                         
                    }*/
                }
            
            //}
            //if(custpackageList.LOV_Name__c == 'FTR'){
                if(FtrLOVList != null && FtrLOVList.size() > 0){
                    for(List_of_Values__c LOV : FtrLOVList){
                        for(Project_Cust_Packages__c fcp : FTRCustPack){
                        	projIdkey = fcp.Project_Id__c;
                            system.debug('PASCustPack '+fcp.Project_Id__c);
                            system.debug('pcp.Customer_Project__r.Project_Id__c '+fcp.Customer_Project__r.Project_Id__c);
                            if(LOV.Entity_Type__c == 'Service Visit' && !(mapForDupCheck.containsKey(projIdkey+'-'+LOV.Key__c))){
                                Visit__c visit = new Visit__c();
                                visit.RecordTypeId = ProjRecTypeId;
                                //visit. = system.today();
                                visit.Project__c = fcp.Project_Id__c;
                                visit.Visit_Report__c = LOV.Key__c;
                                visit.ProjecIdVisitType__c = visit.Project__c+'-'+visit.Visit_Report__c;
                                system.debug('visit.ProjecIdVisitType__c '+visit.ProjecIdVisitType__c);
                                if(fcp.Surveyor_Id__c != null){
                                    visit.OwnerId = fcp.Surveyor_Id__c;
                                    visit.Surveyor__c = fcp.Surveyor_Id__c;
                                }
                                visit.Start_Date__c = system.today();
                                //visit.OwnerId = fcp.Surveyor_Id__c;
                                VisitList.add(visit);
                                mapForDupCheck.put(projIdkey+'-'+LOV.Key__c,visit);
                                system.debug('going in ftr'+VisitList);
                            }   
                        }       
                    }
                }
                if(PMSCustPack != null && PMSCustPack.size() >0){
                    ReportsforInsert = new List<CRM_Report__c>();
                    for(List_of_Values__c LOV : PmsLovList){
                        for(Project_Cust_Packages__c pmscp : PMSCustPack){
                                system.debug('CRMReportMapinPMS'+CRMReportMap);
                                system.debug('CRMReportMapinPMS'+pmscp);
                            if(!(CRMReportMap.containsKey(pmscp.Project_Name__c+'-'+LOV.Name))){
                                system.debug('Insideloop');
                                CRM_Report__c CRMRecord = new CRM_Report__c();
                                CRMRecord.Report_Name__c = LOV.Id;
                                CRMRecord.Which_Report__c = LOV.Entity_Type__c;
                                CRMRecord.Status__c = 'Completed';
                                CRMRecord.Project__c = pmscp.Project_Id__c;
                                ReportsforInsert.add(CRMRecord);  
                            }
                                
                        }
                        
                    }
                    system.debug('ReportsforInsert'+ReportsforInsert);
                }
            //}
        }
        
       // try{
            system.debug('VisitList1'+VisitList);
            if(VisitList != null && VisitList.size() > 0){
                //system.debug('VisitList2 '+VisitList);
                Database.Insert(VisitList, false);
                //insert VisitList;
                
            }
            if(ReportsforInsert != null && ReportsforInsert.size() > 0){
                system.debug('ReportsforInsert '+ReportsforInsert);
                insert ReportsforInsert;
                
            }            
            /*
            if(CRMReportList != null && CRMReportList.size() > 0)
                insert CRMReportList;
            */    
        /*}
        catch(DmlException e){
            system.debug(e);
        }*/ 
    }
    public void generateSingleProd(list<List_of_Values__c> lovlist){
        
        for(List_of_Values__c lov : lovlist){
            if(lov.Entity_Name__c == 'PAS')
                PasLOVList.add(lov);
            else if(lov.Entity_Name__c == 'FTR')
                FtrLOVList.add(lov);    
            else if(lov.Entity_Name__c == 'CRM Report' && lov.Key__c == 'Followup Report')
                PmsLovList.add(lov);    
        }
    }
    /* This method is to check whether that project is already having visit records or not */
    
    
    public void checkVisitRec(set<String> projVisitType){
        mapForDupCheck = new map<String, Visit__c>();
        string ProjIdReport = '';
        list<Visit__c> visitListCheck = [select name, Visit_Report__c, Project__c,Status__c from Visit__c where ProjecIdVisitType__c IN : projVisitType];
        system.debug('visitListCheck '+visitListCheck);
        for(Visit__c vis : visitListCheck){
            ProjIdReport = vis.Project__c+'-'+vis.Visit_Report__c;
            mapForDupCheck.put(ProjIdReport, vis);              
        }
    }
    
    list<CRM_Report__c> crmList;
    /* query for CRM Report based on project */
    public void queryForCRMReports(){
        CRMReportMap = new map<String,CRM_Report__c>();
        crmList = [select name, Report_Name__c,Report_Name__r.Name, Project__c, Project__r.Id, Generate_Report__c, Project__r.Name from CRM_Report__c where Project__c IN : projidset];
        for(CRM_Report__c crmrep : crmList){
            if((crmrep.Report_Name__r.Name == 'Project Report')||(crmrep.Report_Name__r.Name == 'Unit Report')||(crmrep.Report_Name__r.Name == 'Tower Report')){
        //  if(crmrep.Generate_Report__c == 'PMS'){
                CRMReportMap.put(crmrep.Project__r.Name+'-'+crmrep.Report_Name__r.name,crmrep);
                //break;
            }
        }
    }
       private void loadFTRMap(){
        CustprojMap = new Map<Id,Project_Cust_Packages__c>();
        List<Project_Cust_Packages__c> custpckg= [Select Customer_Project__r.Project_Id__c,Id,Name From Project_Cust_Packages__c where Customer_Project__r.Project_Id__c IN : projidset AND LOV_Name__c = 'PMS'];
        system.debug('AA'+custpckg+'CC'+projidset);
        for(Project_Cust_Packages__c cpk :custpckg){
            if(!(CustprojMap.containsKey(cpk.Customer_Project__r.Project_Id__c)))
                CustprojMap.put(cpk.Customer_Project__r.Project_Id__c, cpk);
        }
        system.debug('BB'+CustprojMap);
    }
}