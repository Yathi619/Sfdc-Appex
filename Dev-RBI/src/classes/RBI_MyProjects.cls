/*
    Type:       Custom Controller
    Purpose:    Used to display projects belonging to a Customer on the Customer Portal Home Page.         

    Used By:   RBI_MyProjects.page
    ---------------------------------------------------------------
    History:

    06-Apr-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_MyProjects {
	// Variable Declaration
	public list<Customer_Projects__c> WrapperProjList {get; set;}
 	private String first_picklist_option = '- All -'; 
 	public Customer_Projects__c Proj;
	public string     ProjId = '';
	public boolean    ProjectFlag = false;
	public boolean    ErrorFlag {get; set;}
	public boolean    flag {get; set;}
	string AcctId     = '';
	string PrjId='';
	public Id SelectedProjId {get;set;}
	
	public List<String> SerchAlpabet{get;set;}
	public String SearchVar{get;set;}
	List<Customer_Projects__c> projList;	
	public list<Customer_Projects__c> Showpro{set;get;}
	public integer sizee{get;set;}

	//Pagination
	public RBI_PageManager objPageManager {get;set;}   
	public Integer pageSize;
	public List<Customer_Projects__c> Wrapper1prolist{get;set;}
	public List<Customer_Projects__c> prolist = new List<Customer_Projects__c>(); 
	public List<Customer_Projects__c> proDetails;
	String ProfileName = '';
	
	//Search for Projects added on 20.08.2013
	public Project__c prj;
	public string Projectname{get; set;}
	public string Projectcity{get; set;}
	transient String QryString;
	//Adding End
	
	/* Constructor */
    public RBI_MyProjects(){
        WrapperProjList = new list<Customer_Projects__c>();  
        ErrorFlag       = false;
        AcctId          = UserUtil.CurrentUser.AccountId; //Logged in user's account id  
        ProfileName     = UserUtil.CurrentUser.Profile.Name; //logged in user's profile name
        projList 		= new list<Customer_Projects__c>();
		SelectedProjId = null;
        
		//paging variables
		pageSize = 15; 
        objPageManager = new RBI_PageManager(pageSize);               
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;
        Wrapper1prolist= new List<Customer_Projects__c>();	
		SerchAlpabet=new List<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','All'};        	           
    }
    
    /* Action funtion called on initial load */
	public PageReference InitialLoad(){
		projList = [Select Id, Name, Project_Name__c, Project_Id__c, Customer_Name__c,AccountId__c, Project_Id__r.Name, Project_Id__r.Plot_Area__c, Project_Id__r.Project_Name__c, Project_Id__r.Project_Type__c, Project_Id__r.Developer_Name__c, Project_Id__r.Project_Region__c
					, Project_Id__r.Total_Units__c, Project_Id__r.Launch_Date__c, Project_Id__r.Site_Address_City__c,  Project_Id__r.Site_Address_Actual__c, Project_Id__r.Site_Address_Landmark__c, Project_Id__r.Actual_No_of_Towers__c, Project_Id__r.Land_Area_in_acres__c, Project_Id__r.Planned_Units__c From Customer_Projects__c where AccountId__c = : AcctId AND Project_Id__r.To_Be_Approved__c=false order by createddate desc]; 
        WrapperProjList = new list<Customer_Projects__c>();  
  		SearchVar='All';
  		Showpro = new list<Customer_Projects__c>();
  		Showpro.addAll(projList);
		for(Customer_Projects__c proj : Showpro){
			WrapperProjList.add(proj);
		}
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
		for(Customer_Projects__c p:projList)
		{
			if(SearchVar.equals('All')){
				Showpro.add(p);
			 	WrapperProjList.add(p);
			}					
			else
				if(p.Project_Id__r.Project_Name__c.startsWith(SearchVar.toLowerCase())||p.Project_Id__r.Project_Name__c.startsWith(SearchVar))
				{
				   Showpro.add(p);
			 	   WrapperProjList.add(p);					   
				}   
		   
		}
		if(WrapperProjList!= null){
			sizee=WrapperProjList.size(); 
			objPageManager.numberOfRows = WrapperProjList.size();
		}			
		return null;
	}

    // Getter-setter for proDetails used for pagination
  	public List<Customer_Projects__c> getproDetails(){
  	if((WrapperProjList !=null) && (WrapperProjList.size() >0)){ 
      	 if(Wrapper1prolist !=null)	
       		Wrapper1prolist.clear();
        	for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<WrapperProjList.size();i++){
            	Wrapper1prolist.add(WrapperProjList.get(i));

         }
     } 
     return Wrapper1prolist; 
    } 
    
	public void  setproDetails (List<Customer_Projects__c> proDetails) {
		this.proDetails = proDetails;
	}
	
	//Added on 20.08.2013
	public PageReference SearchProjects(){
		QryString = 'Select Id, Name, Project_Name__c, Site_Address_City__c, Project_Id__c, Customer_Name__c,AccountId__c, Project_Id__r.Name, Project_Id__r.Plot_Area__c, Project_Id__r.Project_Name__c, Project_Id__r.Project_Type__c, Project_Id__r.Developer_Name__c, Project_Id__r.Project_Region__c' +
					', Project_Id__r.Total_Units__c, Project_Id__r.Launch_Date__c, Project_Id__r.Site_Address_City__c,  Project_Id__r.Site_Address_Actual__c, Project_Id__r.Site_Address_Landmark__c, Project_Id__r.Actual_No_of_Towers__c, Project_Id__r.Land_Area_in_acres__c, Project_Id__r.Planned_Units__c From Customer_Projects__c where AccountId__c = : AcctId AND Project_Id__r.To_Be_Approved__c=false AND Project_Name__c LIKE \'%'  + Projectname + '%\'';
		system.debug('ABCD ' + QryString);
		if(!Projectcity.equals('- All -')) {
   	    	QryString += ' AND Site_Address_City__c LIKE \'%' + Projectcity + '%\'';
   	    }
   	    
   	    projList = new list<Customer_Projects__c>();
   	    projList = Database.query(QryString);
   	    system.debug('WXYZ ' + projList);
   	    if(projList == null){
		      ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'No results found');
	              ApexPages.addMessage(errorMessage);   	 		
   	 		
   	 	}else{	  
   	 		WrapperProjList = new list<Customer_Projects__c>();
	  		SearchVar = 'All';
	  		Showpro = new list<Customer_Projects__c>();
	  		Showpro.addAll(projList);   	 				
	        for(Customer_Projects__c Serv1: projList) {
    			WrapperProjList.add(Serv1);
	        }
	   	}
		if(WrapperProjList!= null){
			sizee=WrapperProjList.size(); 
			objPageManager.numberOfRows = WrapperProjList.size();
		}
   	 	return null; 
	}
	
	/*This method is refered from RBI_UtilClass to fetch the City values*/
    public List<selectOption> getCity() {
    	prj = new Project__c();
		list<selectOption> pickvalue;          
    	pickvalue = RBI_UtilClass.getPickValues(prj, 'Site_Address_City__c', first_picklist_option);
        return  pickvalue;  
   	}
	//Adding End        
		
	 public pageReference detail() {
    
	 	PrjId=Apexpages.currentPage().getParameters().get('PrjId');
	 	PageReference pagref;
	 	system.debug('ProfileName'+ProfileName);
	 	if ((ProfileName == 'RBI Customer Portal Manager') || (ProfileName == 'RBI Demo Customer Portal Mgr'))
	  		pagref = new PageReference('/apex/RBI_ProjectDetail?id='+SelectedProjId);
	  		
	  	if (ProfileName == 'RBI Customer Portal User')
	  		pagref = new PageReference('/apex/RBI_DetailPageforPortalUser?id='+SelectedProjId);
	  		
	  	return pagref;
     }
}