/*
    Type:       Custom Controller
    Purpose:    Used to display the Details of a Project. This can be accessed by clicking on the Project Name field in
                My Projects tab, in Customer Portal.     

    Used By:   RBI_ProjectDetail.page
    ----------------------------------------------------------------------------------
    History:

    25-Apr-2013     Created     Tugboat Info Solutions Pvt. Ltd

*/
public class RBI_ProjectDetail {

    public Account acc{get; set;}
    public list<Account> acclst;
    public Project__c prj{get; set;}
    public ApexPages.StandardController sController;
    public list<CRM_Report__c> rptlist {get;set;}
    public list<Visit__c> visitlist {get;set;}
    public boolean IsPorEnabled {get;set;}
    private string AcctId     = '';
    private string RBIaccnt = '';
    String  prjId;
    public String  custProjId {get;set;}
    public String  FilePath {get;set;}
    public boolean Exceptionflg;
    String  strRemarks;   
    public list<Customer_Projects__c> approvallist {get;set;}
    public string appStatus {get;set;}
    Set<Id> custpackgeset;
    Map<String,Id> packgenameMap;    
    public list<Packageswrapper> WrapperPackageList {get; set;}
    list<List_of_Values__c> LOVreportList;
    public list<Visit__c> projvisitlist {get; set;}
    public boolean displayPopup {get; set;}
    public list<CRM_Report__c> rptPASlist {get;set;}
    public list<CRM_Report__c> rptPMSlist {get;set;}
    public boolean rptPASlistflg {get;set;}
    public boolean rptPMSlistflg {get;set;}
    public list<CRM_Report__c> Visitrptlist {get;set;}
    //Used for setting service requested date and end date
	Map<String,Id> projReportMap;
	Date Contractenddt;
	Date Currentdt;
	public list<Query__c> querylist {get;set;}
	public boolean disQryList {get;set;}
	public boolean caPMSflag {get;set;} // Phase 2C
	public boolean disSavebtn {get;set;} //Phase 2C
	List<Project_Cust_Packages__c> custservdeletelist; // Phase 2C used to delete PMS package on rejection
	Map<Id, Project_Cust_Packages__c> custpackageidsMap;		   
    public RBI_ProjectDetail(ApexPages.StandardController stdCon){
        sController = stdCon;
        this.prj=(Project__c)stdCon.getRecord();
        rptlist   = new list<CRM_Report__c>();
        rptPASlist   = new list<CRM_Report__c>();
        rptPMSlist   = new list<CRM_Report__c>();
        visitlist = new list<Visit__c>();
        strRemarks = '';
        RBIaccnt =  System.Label.RBI_AccountId;
        AcctId  = UserUtil.CurrentUser.AccountId; //Logged in user's account id
        AcctId = (AcctId == null || AcctId == '')?RBIaccnt:AcctId; //set account id to RBI cust record in case it is null
        system.debug('Acc Id'+AcctId);
        IsPorEnabled = UserUtil.CurrentUser.IsPortalEnabled;
        Contractenddt   = UserUtil.CurrentUser.contact.account.Current_Contract_End_Date__c;
		Currentdt	= System.today();
        custpackgeset = new Set<Id>();
        packgenameMap = new Map<String,Id>();
        approvallist = new list<Customer_Projects__c>();
        querylist = new list<Query__c>();
        disQryList = false;
        disSavebtn = false;
        prjId = prj.Id;
        system.debug('Prj id'+prjId); 
        if (Prj.Developer_Id__c != null){
            acc = [Select Id, BillingStreet,BillingState,BillingPostalCode,BillingCity, BillingCountry From Account Where Id = :Prj.Developer_Id__c ];
        }
        
       //To get the report ids from List of value    
        LOVreportList = new list<List_of_Values__c>(); 
        LOVreportList = [SELECT Entity_Name__c,Entity_Type__c,Id, Key__c, Value__c FROM List_of_Values__c where Entity_Name__c = 'CRM Report'];        
        approvallist = [Select Id, Name, Project_Name__c, Project_Id__c,Project_Id__r.Technical_Head__c,Remarks__c, Exception__c, Project_Approval_Status__c, Project_Id__r.City__c, FTR_File_Path__c
         From Customer_Projects__c where AccountId__c = : AcctId and Project_Id__c = :prjId ];
         system.debug('Soumya samal'+approvallist); 
         if(approvallist != null && approvallist.size() > 0){
            appStatus = approvallist[0].Project_Approval_Status__c;
            custProjId = approvallist[0].Id;
            FilePath = approvallist[0].FTR_File_Path__c;
            Exceptionflg = approvallist[0].Exception__c;
            strRemarks = approvallist[0].Remarks__c;
            if (appStatus == 'Approved' || appStatus == 'Reject'){
            	disSavebtn = true;
            }
            
         }
         querylist = [Select Query_Initiated_Date__c, Query_Description__c, Expected_Closure_Date__c, Exception_Status__c, 
         				Customer_Project__c, Closure_Remarks__c, Query_Resolved_Date__c From Query__c Where Customer_Project__c =:custProjId];
         if(querylist != null && querylist.size() > 0){
         	disQryList = true;
         }
         WrapperPackageList = new list<Packageswrapper>();
         WrapperPackageList = this.loadWrapperPackageList();
         rptPASlistflg = false;
         rptPMSlistflg = false;        
         rptlist = this.loadProjReportList();
         if (rptlist != null){
             for (CRM_Report__c r : rptlist) {
                if (r.Report_Name__r.Document_Type__c == 'PAS'){    
                    rptPASlist.add(r);
                    rptPASlistflg = true;
                }   
                if (r.Report_Name__r.Document_Type__c == 'PMS'){
                    rptPMSlist.add(r);
                    rptPMSlistflg = true;
                }
            }
            
            	
        }
        visitlist = this.loadProjVisitList();
    }
    
    //Method tp create an Exception record and send email to PAS Manager and Tech Manager of the Project
    public void CreateExpandSendEmail(){
    	//if (disSavebtn == true){
	    	String RTExcpId = '';
	    	String strOwnr = system.Label.RBI_DefaultPASMgrId;
	    	map<String, Id> RTMap = new map<String, Id>();
	    	String[] strExcpList = new String[]{'Query__c'};
	    	RTMap = RBI_UtilClass.getRecordTypeMap (strExcpList);
	    	RTExcpId = RTMap.get('Exception');
	    	if(approvallist != null && approvallist.size() > 0){
	    		appStatus = approvallist[0].Project_Approval_Status__c;
	    	    custProjId = approvallist[0].Id;
	            Exceptionflg = approvallist[0].Exception__c;
	            strRemarks = approvallist[0].Remarks__c;
	            strOwnr    = (approvallist[0].Project_Id__r == null || approvallist[0].Project_Id__r.Technical_Head__c == null)?strOwnr:(approvallist[0].Project_Id__r.Technical_Head__c);
	    	}
	    	if ((appStatus == 'Approved' || appStatus == 'Hold') && Exceptionflg == true){
	    		Query__c CustProj = new Query__c(Customer_Project__c = custProjId, Query_Description__c = strRemarks, OwnerId=strOwnr, Query_Initiated_Date__c = Currentdt, RecordTypeId = RTExcpId);
	    		Insert CustProj;
	    	}
	    //}
    }
    
    //function to return list of reports based on the services available for the customer
    public list<Visit__c> loadProjVisitList(){
        //projvisitlist = [select Id, Name, Status__c, Start_Date__c, Closed_Date__c, Exception__c, Surveyor__c,Visit_Report__c from Visit__c where Project__c =: prjid];
        //Added for Phase2B on 14/8/2013  For Soumya Document_Received_Date__c
        projvisitlist = [select Id, Name, Status__c, Start_Date__c,Document_Received_Date__c, Closed_Date__c, Exception__c, Surveyor__c,Visit_Report__c from Visit__c where Project__c =: prjid];
        //Soumya changes ends here
        list<Visit__c> returnvisitlist = new list<Visit__c>();
        Map<String,Id> visittypeMap;
        visittypeMap = new  Map<String,Id>();   
        for(List_of_Values__c visitlov: LOVreportList)
        {
            if(packgenameMap.containsKey(visitlov.Value__c))
            {
                visittypeMap.put(visitlov.Key__c,visitlov.Id);
            }       
        }
        for(Visit__c v: projvisitlist)
        {
            if(visittypeMap.containsKey(v.Visit_Report__c)){
                returnvisitlist.add(v);
            }
        }
        return returnvisitlist;
    }
    //function to return list of reports based on the services available for the customer
    public list<CRM_Report__c> loadProjReportList(){
        list<CRM_Report__c> returnrptlist = new list<CRM_Report__c>();
        list<CRM_Report__c> projrptlist = new list<CRM_Report__c>();
        Set<Id> rptIds = new Set<Id>();
        Set<Id> PMSrptIds = new Set<Id>();// for followup visit reports
        Visitrptlist = new list<CRM_Report__c>();
        for(List_of_Values__c Rptlov: LOVreportList)
        {
            if(packgenameMap.containsKey(Rptlov.Value__c))
            {
                rptIds.add(Rptlov.Id);
            }
            else if((Rptlov.Value__c == 'PMSFollowup')&&(packgenameMap.containsKey('PMS'))) // for followup visit reports
            {
                PMSrptIds.add(Rptlov.Id);
            }               
        }
        projrptlist = [select Id, Name, FilePath__c, Which_Report__c, Generate_Report__c, Report_Name__c,Report_Name__r.Name,Report_Name__r.Sort_Order__c, Report_Name__r.Document_Type__c, Status__c,Visit__c,CreatedDate,Report_Name__r.Value__c from CRM_Report__c where Project__c =: prjid ORDER BY Report_Name__r.Sort_Order__c];
		projReportMap = new Map<String,Id>();      
        for(CRM_Report__c Rpt: projrptlist)
        {
            if(!rptIds.add(Rpt.Report_Name__c)){
                returnrptlist.add(Rpt);
            }
            else if(!PMSrptIds.add(Rpt.Report_Name__c)){
                Visitrptlist.add(Rpt);
            }
           projReportMap.put(Rpt.Report_Name__r.Value__c,Rpt.Id);
        }
        return returnrptlist;
    }

    public PageReference savAppStatus(){
        if((approvallist!=null)&&(approvallist.size() > 0)){
			Project_Cust_Packages__c PMScustpackage = new Project_Cust_Packages__c();
			system.debug('caPMSflag'+caPMSflag);    	
    		if(approvallist[0].Project_Approval_Status__c == 'Reject' && packgenameMap!= null && packgenameMap.containsKey('PMS')){  
				caPMSflag = true;
				system.debug('caPMSflag2'+caPMSflag);
				return null;        	
    		}
			else{
            	update approvallist;
            	appStatus = 'Not in Progress';
            	CreateExpandSendEmail();
            	PageReference Pg = Page.RBI_ProjectDetail;
        		pg.getParameters().put('Id',prjId);
        		Pg.setRedirect(true);
        		return Pg;
			}            
		}
		caPMSflag = false;
	   return null;
    }
//Added for phase 2C START            	    
    public PageReference confrmAppStatus(){
		caPMSflag = false;
		Project_Cust_Packages__c PMScustpackage = new Project_Cust_Packages__c();    	
        if((approvallist!=null)&&(approvallist.size() > 0)){
        		update approvallist;
            	custservdeletelist = new List<Project_Cust_Packages__c>();
				if(packgenameMap!= null && packgenameMap.containsKey('PMS') && custpackageidsMap!=null){
					PMScustpackage = custpackageidsMap.get(packgenameMap.get('PMS'));	
					if(PMScustpackage!=null)
					{
						custservdeletelist.add(PMScustpackage);
						Database.Delete(custservdeletelist);
					}
				}	        		
            	appStatus = 'Not in Progress';
            	CreateExpandSendEmail();
            	PageReference Pg = Page.RBI_ProjectDetail;
        		pg.getParameters().put('Id',prjId);
        		Pg.setRedirect(true);
        		return Pg;        	
        } 
        return null;   
    }
    public PageReference cancelAppStatus(){
		caPMSflag = false;
		return null;
    }	    
//Added for phase 2C END

     public list<Packageswrapper> loadWrapperPackageList(){
	     list<Packageswrapper> returnList = new list<Packageswrapper>();
         List<List_of_Values__c> servlist = new List<List_of_Values__c>();
         List<Project_Cust_Packages__c> custservlist;
	         custservlist = new List<Project_Cust_Packages__c>();
             Boolean sflg = false;
             servlist = [SELECT Entity_Name__c,Entity_Type__c,Id,Key__c,Name,Value__c FROM List_of_Values__c WHERE Entity_Type__c = 'Package' order by Value__c ASC];
             custpackageidsMap = new Map<Id, Project_Cust_Packages__c>();
             custservlist = [select Customer_Project__r.Project_Id__r.Id,List_of_Values__r.Name,List_of_Values__c, IsContractInActive__c, Service_Requested_Date__c,End_Date__c from Project_Cust_Packages__c
                             where Customer_Project__r.Project_Id__r.Id=:prjId and Customer_Project__r.AccountId__c=:AcctId and IsContractInActive__c !='Y' order by List_of_Values__r.Value__c ASC];

	         //Used to check if the package is selected for the customer
             packgenameMap = new Map<String,Id>();
             if ((custservlist != null)&&(custservlist.size() > 0)){
    	         for (Project_Cust_Packages__c cpkg : custservlist) {
        	         custpackageidsMap.put(cpkg.List_of_Values__c,cpkg);
                     custpackgeset.add(cpkg.List_of_Values__c);
                     packgenameMap.put(cpkg.List_of_Values__r.Name,cpkg.List_of_Values__c);
                 }
              }
              if ((servlist != null)&&(servlist.size() > 0)){
             	 for (List_of_Values__c sLOV : servlist){
                	 sflg = (custpackageidsMap.containsKey(sLOV.Id))?true:false;
                     Project_Cust_Packages__c projcpdt = (custpackageidsMap.get(sLOV.Id));
                     if(projcpdt!=null)
                    	 returnList.add(new Packageswrapper(sLOV, sflg, sflg, projcpdt.Service_Requested_Date__c, projcpdt.End_Date__c));
                        else
                        returnList.add(new Packageswrapper(sLOV, sflg, sflg, null, null));
                    }
                }
                return returnList;
    }
    
    //action function to save Services
    public PageReference saveServices(){
        list<Project_Cust_Packages__c> CustPackgList;
        CustPackgList = new list<Project_Cust_Packages__c>();
		string mapkey;
		Date actstartdt;
		Customer_Projects__c custProject;
        if((WrapperPackageList!=null)&&(WrapperPackageList.size() > 0)){
            for(Packageswrapper custpackgw: WrapperPackageList) {
                //if it is not existing record, create the customer package record
                if((custpackgeset.add(custpackgw.packgrecord.Id))&&(custpackgw.selectedflg == true))
                {
                	mapkey = '';
                	mapkey = custpackgw.packgrecord.Name;
                	actstartdt = (projReportMap.containsKey(mapkey))?Currentdt:null;
                    CustPackgList.add(new Project_Cust_Packages__c(Customer_Project__c = custProjId, List_of_Values__c = custpackgw.packgrecord.Id, Service_Requested_Date__c=Currentdt, End_Date__c = Contractenddt, Start_Date__c=actstartdt));
                }
            }
            if((CustPackgList!=null)&&(CustPackgList.size()>0))
            {
                Database.insert(CustPackgList);
                WrapperPackageList = new list<Packageswrapper>();
                WrapperPackageList = this.loadWrapperPackageList();
                PageReference Pg = Page.RBI_ProjectDetail;
        		pg.getParameters().put('Id',prjId);
        		Pg.setRedirect(true);
        		return Pg;
            }
        }
     return null;
    }
    //wrapper class to store packages along with the selection
    public class Packageswrapper{
        public List_of_Values__c packgrecord {get; set;}
        public Boolean selectedflg {get; set;}
        public Boolean renderflg {get; set;}
        public Date reqdate {get; set;}
        public Date enddate {get; set;}                
        public Packageswrapper(List_of_Values__c lov, Boolean flg, Boolean rendflg, Date reqdt, Date enddt){
            packgrecord = lov;
            selectedflg = flg;
            renderflg   = rendflg;
            reqdate     = reqdt;
            enddate     = enddt;
       }
   }
   
    public void closePopup() {        
        displayPopup = false;    
    }
         
    public void showPopup() {
        displayPopup = true;    
    }
    

      public PageReference CheckFTR(){
        String checkedProd = Apexpages.currentPage().getParameters().get('checkedProd');
        boolean FTRFlg; 
        boolean PMSFlag = false;
        for(Packageswrapper psw : WrapperPackageList){
            if(psw.packgrecord.Name == 'PAS' && psw.selectedflg == true){
                FTRFlg = true;
            }
            if(psw.packgrecord.Name == 'PAS' && psw.selectedflg == false){
                FTRFlg = false;
            }
            if(psw.packgrecord.Name == 'PMS' && psw.selectedflg == true){
                PMSFlag = true;
            }
            if(psw.packgrecord.Name == 'FTR'){
                if(FTRFlg){
                    psw.selectedflg = true;
                }else if(!FTRFlg && PMSFlag != true){
                        psw.selectedflg = false;
                }  
            }
        }
        return null;
    }
    
    public PageReference doCancel(){
        PageReference Pg = Page.RBI_MyProjects;
        return Pg;
    }
}