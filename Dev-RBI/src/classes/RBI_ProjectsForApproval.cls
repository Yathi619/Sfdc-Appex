/*
    Type:       Custom Controller
    Purpose:    Used to Approve the Projects created by the Customer from Customer Portal.     

    Used By:   RBI_ProjectForApproval.page
    ----------------------------------------------------------------------------------
    History:

    01-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_ProjectsForApproval {
	// Variable Declaration
	public list<Project__c> WrapperProjList {get; set;}
 	private String first_picklist_option = '- All -'; 
 	transient String QryString;
 	public Project__c Proj;
	public string     ProjId = '';
	public string     Projectname{get; set;}
	public string     Projectcity{get; set;}	
	public boolean    ProjectFlag = false;
	public boolean    ErrorFlag {get; set;}
	public boolean    flag {get; set;}
	public Id SelectedProjId {get;set;}
	private string AcctId     = '';
	public List<String> SerchAlpabet{get;set;}
	public String SearchVar{get;set;}
	List<Project__c> projList;	
	public list<Project__c> Showpro{set;get;}
	public integer sizee{get;set;}

	//Pagination
	public RBI_PageManager objPageManager {get;set;}   
	public Integer pageSize;
	public List<Project__c> Wrapper1prolist{get;set;}
	public List<Project__c> prolist = new List<Project__c>(); 
	public List<Project__c> proDetails;
	
	/* Constructor */
    public RBI_ProjectsForApproval(){
        WrapperProjList = new list<Project__c>();
        Wrapper1prolist= new List<Project__c>(); 
       	ErrorFlag       = false;
        AcctId          = UserUtil.CurrentUser.AccountId; //Logged in user's account id   
        projList 		= new list<Project__c>();
      	//paging variables
		pageSize = 10; 
        objPageManager = new RBI_PageManager(pageSize);               
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;
        	
		SerchAlpabet=new List<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','All'};
					
}
    
    /* Action funtion called on initial load */
	public PageReference InitialLoad(){
		projList 		= new list<Project__c>();		
		projList = [Select Id, Name, Project_Name__c, Developer_Id__c, City__c, Land_Area_in_acres__c, Plot_Area__c, Project_Region__c, Site_Address_City__c, Launch_Date__c, Total_Units__c, Developer_Name__c, Developer_Name_Cust_Provided__c, Developer_Phone_Cust_Provided__c From
					Project__c where To_Be_Approved__c = true AND Project_Rejected__c != true];
        WrapperProjList = new list<Project__c>();  
  		SearchVar='All';
  		Showpro = new list<Project__c>();
  		Showpro.addAll(projList);
  		WrapperProjList.addAll(projList);
  		
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
		for(Project__c p:projList)
		{
			if(SearchVar.equals('All'))
			{
				Showpro.add(p);
			 	WrapperProjList.add(p);
			}					
			else
				if((p.Project_Name__c.startsWith(SearchVar.toLowerCase())||p.Project_Name__c.startsWith(SearchVar)))
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
  	public List<Project__c> getproDetails(){
  	if((WrapperProjList !=null) && (WrapperProjList.size() >0)){ 
      	 if(Wrapper1prolist !=null)	
       		Wrapper1prolist.clear();
        	for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<WrapperProjList.size();i++){
            	Wrapper1prolist.add(WrapperProjList.get(i));

         }

      } 
       return Wrapper1prolist; 
    } 
    
	public void  setproDetails (List<Project__c> proDetails) {
		this.proDetails = proDetails;
	}    
		
	/* Action funtion called on Search */
    public PageReference searchProjects() {
    	WrapperProjList = new List<Project__c>();
    	QryString = 'Select Id, Name, Project_Name__c, Site_Address_City__c, City__c, Land_Area_in_acres__c, Plot_Area__c, Project_Region__c, Launch_Date__c, Total_Units__c, Developer_Name__c, Developer_Id__c, Developer_Name_Cust_Provided__c, Developer_Phone_Cust_Provided__c From Project__c where To_Be_Approved__c=true AND Project_Name__c LIKE \'%'  + Projectname + '%\'';
    	
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
		 	WrapperProjList = new list<Project__c>();
	  		SearchVar='All';
	  		Showpro = new list<Project__c>();
	  		Showpro.addAll(projList);
	  		for(Project__c Serv1: projList) {
	        	WrapperProjList.add(Serv1);
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
    	Proj = new Project__c();
		list<selectOption> pickvalue;          
    	pickvalue = RBI_UtilClass.getPickValues(Proj, 'Site_Address_City__c', first_picklist_option);
        return  pickvalue;
   }
   
    public pageReference detail()
    {
      PageReference pagref = new PageReference('/apex/RBI_ApproveProject?id='+SelectedProjId);
      return pagref;
      
    }
   
}