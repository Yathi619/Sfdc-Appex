/*
    Type:       Custom Controller
    Purpose:    Used for approval of the projects under My Tasks tab, in Customer Portal         

    Used By:   RBI_MyTasks.page
    ----------------------------------------------------------------------------------
    History:

    01-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_MyTasks {

	// Variable Declaration
	string mapkey;	
	public list<Customer_Projects__c> WrapperProjList {get; set;}
 	private String first_picklist_option = '- All -'; 
 	transient String QryString;
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
	Set <Id> custprojids;
	Map<String, String> custpackageidsMap;	
	/* Constructor */
    public RBI_MyTasks(){
    	custprojids = new Set<Id>();
        WrapperProjList = new list<Customer_Projects__c>();  
        ErrorFlag       = false;
        AcctId          = UserUtil.CurrentUser.AccountId; //Logged in user's account id   
        projList 		= new list<Customer_Projects__c>();
		SelectedProjId = null;
        
		//paging variables
		pageSize = 10; 
        objPageManager = new RBI_PageManager(pageSize);               
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;
        Wrapper1prolist= new List<Customer_Projects__c>();	
		SerchAlpabet=new List<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','All'};
		LoadCustPackagesMap();        	           
    }
    
    /* Action funtion called on initial load */
	public PageReference InitialLoad(){
		projList = [Select Id, Name, Project_Name__c, Project_Id__c, Project_Approval_Status__c, Customer_Name__c,AccountId__c, Project_Id__r.Name, Project_Id__r.Project_Name__c, Project_Id__r.Project_Type__c, Project_Id__r.Developer_Name__c, Project_Id__r.Project_Region__c
					, Project_Id__r.Total_Units__c, Project_Id__r.Launch_Date__c, Project_Id__r.Status__c, Project_Id__r.Site_Address_City__c,  Project_Id__r.Site_Address_Actual__c, Project_Id__r.Site_Address_Landmark__c, Project_Id__r.Actual_No_of_Towers__c, Project_Id__r.Land_Area_in_acres__c, Project_Id__r.Planned_Units__c 
					From Customer_Projects__c where AccountId__c = : AcctId AND
					Project_Id__r.Status__c = 'PMR' AND
					(Project_Approval_Status__c = 'In Progress' OR Project_Approval_Status__c = 'Hold')
					order by Project_Id__c]; 
		if (projlist != null) {
	        WrapperProjList = new list<Customer_Projects__c>();  
	  		SearchVar='All';
	  		Showpro = new list<Customer_Projects__c>();
	  		Showpro.addAll(projList);
	  		//Used to check if the Customer is having PAS service
	        custprojids = new set<id>();  		
	  		for (Customer_Projects__c o : projList) {
	        	custprojids.add( o.id );
	    	}	  		
	  		LoadCustPackagesMap(); 
			for(Customer_Projects__c proj : Showpro){
				mapkey = proj.Name+'-PAS';
				if(custpackageidsMap.containsKey(mapkey)){		
					WrapperProjList.add(proj);
				}	
			}
			if(WrapperProjList!= null){
				sizee=WrapperProjList.size(); 
				objPageManager.numberOfRows = WrapperProjList.size();
			}
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
			mapkey = p.Name+'-PAS';
			if((SearchVar.equals('All'))&&(custpackageidsMap.containsKey(mapkey))){
				Showpro.add(p);
			 	WrapperProjList.add(p);
			}					
			else
				if((p.Project_Id__r.Project_Name__c.startsWith(SearchVar.toLowerCase())||p.Project_Id__r.Project_Name__c.startsWith(SearchVar))&&(custpackageidsMap.containsKey(mapkey)))
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
		
	 public pageReference detail(){
      PrjId=Apexpages.currentPage().getParameters().get('PrjId');
      PageReference pagref = new PageReference('/apex/RBI_ProjectDetail?id='+SelectedProjId);
      return pagref;
      
    }
    // Helper function to load customer package map.USed to check PAS service
    private void LoadCustPackagesMap(){
		custpackageidsMap = new Map<String, String>();
		List <Project_Cust_Packages__c> custservlist;
                custservlist = [select Customer_Project__r.Name,Name,Customer_Project__r.Project_Id__r.Id,
                		List_of_Values__r.Name,IsContractInActive__c from Project_Cust_Packages__c
                		where Customer_Project__c IN :custprojids AND IsContractInActive__c !='Y' 
                		order by List_of_Values__r.Value__c ASC];
                		
				 for (Project_Cust_Packages__c cpkg : custservlist) {
                            custpackageidsMap.put(cpkg.Customer_Project__r.Name+'-'+cpkg.List_of_Values__r.Name,cpkg.Id);
                 }      	
    }

}