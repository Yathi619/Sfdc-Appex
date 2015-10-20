/*
    Type:       Custom Controller
    Purpose:    Used to display Upcoming projects on the Customer Portal Home Page. Associating of the Customer to a Project and 
    			adding the services selected by the Customer is also done through this class.         

    Used By:   RBI_UpcomingLaunchedProjects.page
    ---------------------------------------------------------------
    History:

    02-Apr-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_Projects {

	// Variable Declaration
	public boolean addflg {get; set;}
	public list<projectservwrapper> WrapperProjList {get; set;}
	public string     accBackground {get; set;} //Added for Phase 2B on 23.08.2013
    public string     accRemarks{get; set;}     //Added for Phase 2B on 23.08.2013
 	private String first_picklist_option = '- All -'; 
 	transient String QryString;
 	public Project__c ProjDates {get; set;}
	public Project__c Proj;
	public string     ProjId = '';
	public string     Projectname{get; set;}
	public string     Projectcity{get; set;}	
	public boolean    ProjectFlag = false;
	public boolean    ErrorFlag {get; set;}
	public boolean    flag {get; set;}
	private string 	  AcctId     = '';

	private date      Contractenddt;
	private date      Currentdt;
	
	Id FTRId;
    Id PASId;
    Id PMSId;
	Set<Id> SelectedProjIdsSet = new Set<Id>();
	public List<String> SerchAlpabet{get;set;}
	public String SearchVar{get;set;}
	List<Project__c> projList;	
	public list<Project__c> Showpro{set;get;}
	public integer sizee{get;set;}

	//Pagination
	public RBI_PageManager objPageManager {get;set;}   
	public Integer pageSize;
	public List<projectservwrapper> Wrapper1prolist{get;set;}
	public List<Project__c> prolist = new List<Project__c>(); 
	public List<projectservwrapper> proDetails;
	
	public list <Selectoption> servicesOptions {get; set;} //services pick list
	private Map<Id,Id> CustprojMap;
	Set<Id> projectidsset; 
	//for Popup
        public list<List_of_Values__c> allprojlist{get;set;}
		public list<List_of_Values__c> lvongoinglist{get;set;}
		public list<List_of_Values__c> lvcomplete{get;set;}
		public ID devId {get; set;}
		//Added for Phase 2B on 12.08.2013
		public String StPrjNam{get; set;}
		public String StAddln1{get; set;}
		public String StAddln2{get; set;}
		public String StAddSta{get; set;}
		public String StAddCty{get; set;}
		public String PrjLat{get; set;}
		public String PrjLon{get; set;}
		public boolean displayPopupforPrjMap {get; set;}
		//Adding End
		public boolean displayPopup {get; set;} 
     // 
     //for checking existing reports
     private Map<String,Id> projReportMap;
	 private Map<Id,string> lovmap;
	 static List<List_of_Values__c> servlist;
	 List<List_of_Values__c> servreflist;	 			      
	/* Constructor */
    public RBI_Projects(){
        WrapperProjList = new list<projectservwrapper>(); 
        displayPopup = false; 
        ErrorFlag       = false;
        AcctId          = UserUtil.CurrentUser.AccountId; //Logged in user's account id

		Contractenddt   = UserUtil.CurrentUser.contact.account.Current_Contract_End_Date__c;
		Currentdt		= System.today(); 
		projList 		= new list<Project__c>();
        ProjDates 		= new Project__c();

        projectidsset 	= new set<id>();
        addflg 			= false;
		//paging variables
		pageSize = 15; 
        objPageManager = new RBI_PageManager(pageSize);               
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;
        Wrapper1prolist= new List<projectservwrapper>();	
		SerchAlpabet=new List<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','All'};
        //used for select options of Service PAS,PMS...
        servlist     = new List<List_of_Values__c>();
        servreflist  = new List<List_of_Values__c>();
        servreflist = [SELECT Entity_Name__c,Entity_Type__c,Id,Key__c,Name,Value__c FROM List_of_Values__c WHERE Entity_Type__c = 'Package' order by Value__c];
        servlist.addall(servreflist);
		FTRPASIdGenerate();
}
    
    /* Action funtion called on initial load */
	public PageReference InitialLoad(){
		SelectedProjIdsSet.clear();
        projList 		= new list<Project__c>();
        //Modified the Query for Phase 2B on 12.08.2013		
		projList = [Select Id, Name, Project_Type__c, Project_Name__c, Site_Address_Line_1__c, Site_Address_Line_2__c, Site_Address_State__c,Developer_Id__c, 
					City__c, Plot_Area__c, Approx_No_of_Units__c, Project_Category__c, Land_Area_in_acres__c, Project_Region__c, Project_LatLong__Latitude__s, Project_LatLong__Longitude__s,
					Site_Address_City__c, Launch_Date__c, Total_Units__c, Developer_Name__c, Developer_Id__r.Remarks_market_Feedback__c,Developer_Id__r.General_Background_of_promoters__c From Project__c where To_Be_Approved__c = false 
					AND Launch_Date__c > TODAY];
        WrapperProjList = new list<projectservwrapper>();  
  		SearchVar='All';
  		Showpro = new list<Project__c>();
  		Showpro.addAll(projList);
  		//Used to check if the projecting is already existing for the customer
        projectidsset = new set<id>();  		
  		for (Project__c o : projList) {
        	projectidsset.add( o.id );
    	}
  		CustprojMap 	= new Map<Id,Id>();		 
		CustprojMap = buildCustprojMap(projectidsset,AcctId);
		for(Project__c proj : Showpro){
			if ((SelectedProjIdsSet.add(proj.Id))&&(!CustprojMap.containsKey(proj.Id))){
			 		WrapperProjList.add(new projectservwrapper(proj));
	
			 }//end if
		}//end for
		system.debug('BBBBB'+WrapperProjList);
		if(WrapperProjList!= null){
			sizee=WrapperProjList.size(); 
			objPageManager.numberOfRows = WrapperProjList.size();
		}	
		
		return null;
	}    
	
	/* Action funtion called on click of aphabet order */
	public PageReference display() 
	{
		Showpro.clear();
		WrapperProjList.clear();
		//Added on 17/8/2013 to fix the defect
		servlist = new List<List_of_Values__c>();
        servlist.addall(servreflist);		
        //servlist = [SELECT Entity_Name__c,Entity_Type__c,Id,Key__c,Name,Value__c FROM List_of_Values__c WHERE Entity_Type__c = 'Package' order by Value__c];
		FTRPASIdGenerate();
		//Ended adding
		for(Project__c p:projList)
		{
			if((SearchVar.equals('All'))&&(!CustprojMap.containsKey(p.Id)))
			{
				Showpro.add(p);
			 	WrapperProjList.add(new projectservwrapper(p));
			}					
			else
				if((p.Project_Name__c.startsWith(SearchVar.toLowerCase())||p.Project_Name__c.startsWith(SearchVar))&&(!CustprojMap.containsKey(p.Id)))
				{
				   Showpro.add(p);
				   WrapperProjList.add(new projectservwrapper(p));
				   system.debug('AAAAAA'+WrapperProjList);
				   system.debug('CCCCCC'+servlist);					   
				   
				}   
		   
		}
		if(WrapperProjList!= null){
			sizee=WrapperProjList.size(); 
			objPageManager.numberOfRows = WrapperProjList.size();
		}			
		return null;
	}
	
    // Getter-setter for proDetails used for pagination
  	public List<projectservwrapper> getproDetails(){
  	if((WrapperProjList !=null) && (WrapperProjList.size() >0)){ 
      	 if(Wrapper1prolist !=null)	
       		Wrapper1prolist.clear();
        	for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<WrapperProjList.size();i++){
            	Wrapper1prolist.add(WrapperProjList.get(i));

         }

      } 
       return Wrapper1prolist; 
    } 
    
	public void  setproDetails (List<projectservwrapper> proDetails) {
		this.proDetails = proDetails;
	}    
		
	/* Action funtion called on Search */
    public PageReference searchProjects() {
    	WrapperProjList = new List<projectservwrapper>();
    	QryString = 'Select Id, Name, Project_Type__c, Project_Name__c, Site_Address_Line_1__c, Site_Address_Line_2__c, Site_Address_State__c, Site_Address_City__c, City__c, Plot_Area__c, Approx_No_of_Units__c, Project_Category__c, Land_Area_in_acres__c, Project_Region__c, Launch_Date__c, Total_Units__c, Developer_Name__c, Developer_Id__c,Developer_Id__r.Remarks_market_Feedback__c,Developer_Id__r.General_Background_of_promoters__c, Project_LatLong__Latitude__s, Project_LatLong__Longitude__s From Project__c where Launch_Date__c > TODAY AND To_Be_Approved__c=false AND Project_Name__c LIKE \'%'  + Projectname + '%\'';
    	
    	if(!Projectcity.equals('- All -')) {
   	    	QryString += ' AND Site_Address_City__c LIKE \'%' + Projectcity + '%\'';
   	    }
  		projList 		= new list<Project__c>();
        projList 		= Database.query(QryString);  		
   	 	if(projList == null){
		      ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'No results found');
	              ApexPages.addMessage(errorMessage);   	 		
   	 		
   	 	}
   	 	else{
   		servlist = new List<List_of_Values__c>();
        servlist.addall(servreflist);   		
   		//servlist = [SELECT Entity_Name__c,Entity_Type__c,Id,Key__c,Name,Value__c FROM List_of_Values__c WHERE Entity_Type__c = 'Package' order by Value__c];   	 		  
	 	WrapperProjList = new list<projectservwrapper>();
  		SearchVar='All';
  		Showpro = new list<Project__c>();
  		Showpro.addAll(projList);   	 				
  		//Used to check if the projecting is already existing for the customer  		
        projectidsset = new set<id>();  		
  		for (Project__c o : projList) {
        	projectidsset.add( o.id );
    	} 
    	CustprojMap = new Map<Id,Id>(); 
		CustprojMap = buildCustprojMap(projectidsset,AcctId);  	    
        for(Project__c Serv1: projList) {
        		if (!CustprojMap.containsKey(Serv1.Id)){
   	    			WrapperProjList.add(new projectservwrapper(Serv1));
        		}
   	    }
		if(WrapperProjList!= null){
			sizee=WrapperProjList.size(); 
			objPageManager.numberOfRows = WrapperProjList.size();
		}	   	    

    }
          	return null;
    }
    
    /*This method is refered from RBI_UtilClass to fetch the City values*/
    public List<selectOption> getCity() {
    	//Proj=projList[0];
    	Proj = new Project__c();
		list<selectOption> pickvalue;          
    	pickvalue = RBI_UtilClass.getPickValues(Proj, 'Site_Address_City__c', first_picklist_option);
        return  pickvalue;
   }
   
    /* Wrapper class with project object, services and selection flag*/
    public class projectservwrapper{
    	public Project__c projrecord {get; set;} 
    	public Boolean    selected   {get; set;}
	
    	/*Flags to capture customer services */
    	public Boolean    PASFlg     {get; set;}
    	public Boolean    PMSFlg     {get; set;}
    	public Boolean    PMSwFTRFlg {get; set;}
    	    	    	    	
		public list <Selectoption> servoptwrap {get; set;} //services pick list
		public list<Id> selectedids {get; set;}
		public projectservwrapper(Project__c s){
        	projrecord = s;
        	selected   = false;
        	PASFlg     = false;
        	PMSFlg     = false;
        	PMSwFTRFlg = false;
        	servoptwrap = new List<SelectOption>();
    		setServoptions(servoptwrap);  
    		selectedids = new list<Id>();   	
    	}
    	
	}
	
	    /* Wrapper class with project Id, account id, package id*/
  		private class projCustPackgwrapper{
  			string wprojId = '';
  			string wPackgId = '';
		
		   projCustPackgwrapper(string projId, string PackgId){
        	wprojId      =  projId;
        	wPackgId     =  PackgId;
  	   	}
    	
	}  
 
     //Set ServicesList from LOV master
	  static void setServoptions(List<SelectOption> optn){
 	        if ((servlist != null)&&(servlist.size() > 0)){
	            for (List_of_Values__c sLOV : servlist){
	                optn.add(new SelectOption(sLOV.Id, sLOV.Name));
	            } 
	        } 
		}   
     
   // Action function for add button     
  public PageReference savelist() {
  		loadprojReportMap(); // function call to load the projects and existing reports map
		list<Customer_Projects__c> objCustProjlst = new list<Customer_Projects__c>();
		list<Project_Cust_Packages__c> CustPackgList;
		CustPackgList = new list<Project_Cust_Packages__c>(); 
		list <projCustPackgwrapper> CustPackgwrapList = new list<projCustPackgwrapper>();
		list<Project_Cust_Packages__c> insCustPackgList;
		insCustPackgList = new list<Project_Cust_Packages__c>(); 	
		String cpProjid = '';
		list<Id> insselectedids;
		list<Customer_Projects__c> custprojListqry;
		
		for(projectservwrapper projwrapper: WrapperProjList) {
			insselectedids = new list<Id>();
			insselectedids = projwrapper.selectedids;
			if((insselectedids != null)&&(insselectedids.size()>0)){
				for(Id cpid: insselectedids){
					CustPackgwrapList.add(new projCustPackgwrapper(projwrapper.projrecord.Id, cpid));
				 }
					objCustProjlst.add(new Customer_Projects__c(Project_Id__c = projwrapper.projrecord.Id, AccountId__c = AcctId));
			 }
	     }
	       try{        
	        if(objCustProjlst != null){
	        Database.insert(objCustProjlst);
	   		custprojListqry = [Select Id, Name, Project_Name__c, Project_Id__c, Customer_Name__c,AccountId__c From Customer_Projects__c where AccountId__c = : AcctId order by Project_Id__c];
		
	 		if(CustPackgwrapList != null){
	 				string mapkey = '';
	 				date actstartdt;
	        		for(projCustPackgwrapper cpwrap:CustPackgwrapList){
	        			for(Customer_Projects__c cpqry:custprojListqry)
	        			{
	        			   if(cpqry.Project_Id__c == cpwrap.wprojId)
	        			   {	
	        			   		mapkey = '';
	        			   		mapkey = cpqry.Project_Id__c+(string)lovmap.get(cpwrap.wPackgId);
	        			   		actstartdt = (projReportMap.containsKey(mapkey))?Currentdt:null;
	        			   		insCustPackgList.add(new Project_Cust_Packages__c(Customer_Project__c = cpqry.Id, List_of_Values__c = cpwrap.wPackgId, End_Date__c = Contractenddt,Service_Requested_Date__c=Currentdt,Start_Date__c=actstartdt));
  			   		        	break;					
	        			   }
	        			}
	        		}
	        		Database.insert(insCustPackgList); 
	         	        		
	        	}
	
	        }
	        	//return null;
			PageReference myProjectPage = Page.RBI_MyProjects;
		    return myProjectPage;
	 	}
		catch(System.DmlException e){
			    ApexPages.addMessages(e);                    
				return null; 
		}
	/*	}else{
  		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the atleast one Service before clicking on Add button'));
  	}*/
  	return null;
	

}
	//Used to build customer projects map used for building projects list which are not associated to the customer
	static  Map<Id,Id> buildCustprojMap(Set<Id> projidset,string Accid){
		Map<Id,Id> retCustprojMap = new Map<Id,Id>(); 
		List<Customer_Projects__c> custprojList = [Select Id, Name, Project_Name__c, Project_Id__c,   Customer_Name__c, AccountId__c, Project_Id__r.Project_Name__c,Project_Id__r.City__c, Project_Id__r.Launch_Date__c, Project_Id__r.Total_Units__c, Project_Id__r.Approx_No_of_Units__c, Project_Id__r.Developer_Name__c
							  From Customer_Projects__c where AccountId__c = : Accid and Project_Id__c in : projidset];
		for(Customer_Projects__c cpobj: custprojList)
		{
			retCustprojMap.put(cpobj.Project_Id__c, cpobj.Id);
		}
		return retCustprojMap;
	}
	
	//for Pop-up

	public void QryDevProfile(){
				
		displayPopup = true; 
		allprojlist = new list<List_of_Values__c>();
		//Modified query for Phase 2B on 13.08.2013
		allprojlist = [Select Total_BUA__c, Project_Type__c, Dev_Project_Address__c, Loan_Amount__c, Land_Area_in_Acres__c, Id,Project_Id_Const_Loan__c, Dwelling_Units__c, Dev_Project_Name__c, Completion_Year__c, Bank_Name__c,Developer__r.General_Background_of_promoters__c,Developer__r.Remarks_market_Feedback__c From List_of_Values__c  where Developer__c=:devId];
		if (allprojlist.size() != null) {
			lvongoinglist= new list<List_of_Values__c>();
		 	lvcomplete = new list<List_of_Values__c>();
		 
	    	for(List_of_Values__c lv :allprojlist){
	    		if(lv.Project_Type__c == 'Ongoing') { 
	    			lvongoinglist.add(lv);
	    		
	    		}
	    		else if(lv.Project_Type__c == 'Completed') {
	    			lvcomplete.add(lv);
	    		 
	    		}	
	    	
	   	   	}
		}
		
		
	}
	public void closePopup() {        
        displayPopup = false;    
    }
         
    public void showPopup() {        
        displayPopup = true;    
    }
    
    //Added for Phase 2B on 12.08.2013
    public void closePopupforPrjMap() {        
        displayPopupforPrjMap = false;    
    }
         
    public void showPopupforPrjMap() { 
        displayPopupforPrjMap = true;    
    }
    //Adding End
    
    /* This method is used to set the FTR, PAS and PMS Ids */
   	public void FTRPASIdGenerate(){
   		lovmap = new Map<Id,String>();
        if ((servlist != null)&&(servlist.size() > 0)){                 
        	for (List_of_Values__c sLOV : servlist){
            	if(sLOV.name == 'PAS')
                	PASId = sLOV.Id;
                if(sLOV.name == 'FTR')  
                	FTRId = sLOV.Id;
                if(sLOV.name == 'PMS')
                	PMSId = sLOV.Id;
                lovmap.put(sLOV.Id,sLOV.name);    
       		}
     	}  
 	}        
    
    public PageReference CheckFTR(){
	    Id projectId = Apexpages.currentPage().getParameters().get('idParam');
	    Id selectedValue = Apexpages.currentPage().getParameters().get('selectedValue');
	    String checkedProd = Apexpages.currentPage().getParameters().get('checkedProd');
	   // FTRPASIdGenerate();
	    /*if(checkedProd == 'true')
    		Prodcounter++;
    	if(checkedProd == 'false')
    		Prodcounter--;
	    */
	    if(checkedProd == 'True' && selectedValue == PASId){
	        for(projectservwrapper psw : WrapperProjList){
	            if(psw.projrecord.id == projectId){
	                psw.selectedids.add(FTRId);
	                break;
	            }
	        }
	    } 
	    else if(checkedProd == 'false' && selectedValue == PASId){
	    
	        for(projectservwrapper psw : WrapperProjList){
	            list<Id> listWithoutFTRId = new list<Id>();
	            if(psw.projrecord.id == projectId){
                     for(Id selId : psw.selectedids){
	                    if(selId == FTRId){
	                        //DO NOTHING
	                    }
	                    else{
	                        listWithoutFTRId.add(selId);
	                        
	                    }
	                }
	                psw.selectedids.clear();
	            	psw.selectedids.addAll(listWithoutFTRId);
	            	break;
	            }
	            
	        }
	    }
	    return null;
	}

	/* Helper function which is used to build map of project+service with respect to reports.This map is used to set
	service start date*/	
	private void loadprojReportMap(){
		projReportMap =	new Map<String,Id>();
		list<CRM_Report__c> projrptlist = new list<CRM_Report__c>();
		projrptlist = [SELECT Id, Name, FilePath__c, Which_Report__c, Generate_Report__c, Report_Name__c,Report_Name__r.Value__c,Project__c FROM CRM_Report__c 
			       WHERE Project__c IN : projectidsset];
		for(CRM_Report__c rep : projrptlist){
			if(!projReportMap.containsKey(rep.Project__c+rep.Report_Name__r.Value__c))
				projReportMap.put(rep.Project__c+rep.Report_Name__r.Value__c,rep.Id);
		}		
	}
}