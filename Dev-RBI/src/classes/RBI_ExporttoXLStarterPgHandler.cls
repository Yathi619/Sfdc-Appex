public with sharing class RBI_ExporttoXLStarterPgHandler {
	// Variable Declaration
	public list<wrapCheckbox> WrapperProjList {get; set;}
 	private String first_picklist_option = '- All -'; 
 	public Customer_Projects__c Proj;
	public string     ProjId = '';
	public boolean    ProjectFlag = false;
	public boolean    ErrorFlag {get; set;}
	public boolean    flag {get; set;}
	public boolean    sendEmailflag {get; set;}
	public string AcctId     = '';
	string PrjId='';
	public Id SelectedProjId {get;set;}
	public String ProjIdforDownload1 {get; set;}
	
	public List<String> SerchAlpabet{get;set;}
	public String SearchVar{get;set;}
	List<Customer_Projects__c> projList;	
	public list<Customer_Projects__c> Showpro{set;get;}
	public integer sizee{get;set;}

	//Pagination
	public RBI_PageManager objPageManager {get;set;}   
	public Integer pageSize;
	public List<wrapCheckbox> Wrapper1prolist{get;set;}
	public List<Customer_Projects__c> prolist = new List<Customer_Projects__c>(); 
	public List<wrapCheckbox> proDetails = new List<wrapCheckbox>();
	String ProfileName = '';
	
	//For Popup window
	public boolean displayPopup {get; set;}
	
	public Project__c prj;
	public string Projectname{get; set;}
	public string Projectcity{get; set;}
	transient String QryString;
	
	/* Constructor */
    public RBI_ExporttoXLStarterPgHandler(){
        WrapperProjList = new list<wrapCheckbox>();  
        ErrorFlag       = false;
        sendEmailflag   = false;
        
        AcctId          = UserUtil.CurrentUser.AccountId; //Logged in user's account id  
        ProfileName     = UserUtil.CurrentUser.Profile.Name; //logged in user's profile name
        projList 		= new list<Customer_Projects__c>();
		SelectedProjId = null;
        
		//paging variables
		pageSize = 15; 
        objPageManager = new RBI_PageManager(pageSize);               
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;
        Wrapper1prolist= new List<wrapCheckbox>();	
		SerchAlpabet=new List<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','All'};        	           
    }
    
    /* Action funtion called on initial load */
	public PageReference InitialLoad(){
		PageReference pg = Page.RBI_ExportToXLErrorPg;
		projList = [Select Id, Name, Project_Name__c, Project_Id__c, Customer_Name__c,AccountId__c, AccountId__r.Export_Projects__c, Project_Id__r.Name, Project_Id__r.Plot_Area__c, Project_Id__r.Project_Name__c, Project_Id__r.Project_Type__c, Project_Id__r.Developer_Name__c, Project_Id__r.Project_Region__c
					, Project_Id__r.Total_Units__c, Project_Id__r.Launch_Date__c, Project_Id__r.Site_Address_City__c,  Project_Id__r.Site_Address_Actual__c, Project_Id__r.Site_Address_Landmark__c, Project_Id__r.Actual_No_of_Towers__c, Project_Id__r.Land_Area_in_acres__c, Project_Id__r.Planned_Units__c 
					From Customer_Projects__c where 
					AccountId__c = : AcctId AND Project_Id__r.To_Be_Approved__c=false AND Project_Id__r.Status__c = 'PMR' order by createddate desc]; 
        WrapperProjList = new list<wrapCheckbox>();  
  		SearchVar='All';
  		Showpro = new list<Customer_Projects__c>();
  		Showpro.addAll(projList);
		for(Customer_Projects__c proj : Showpro){
			WrapperProjList.add(new wrapCheckbox(proj, false));
		}
		if(WrapperProjList!= null){
			sizee=WrapperProjList.size(); 
			objPageManager.numberOfRows = WrapperProjList.size();
		}	
		if(projList != null && projList.size() > 0 && projList[0].AccountId__r.Export_Projects__c != true){
			pg.setRedirect(true);
			return pg;
		}		
		return null;
	}
	
	/* Action funtion called on click of aphabet order */
	public PageReference display() 
	{
		Showpro.clear();
		/* Logic to maintain the selected project */
		map<Id, wrapCheckbox> selectedProject = new map<Id, wrapCheckbox>();
		for(wrapCheckbox wrap : WrapperProjList){
			if(wrap.emailCust == true){
				selectedProject.put(wrap.custProjrecord.Id,wrap);
			}
		}
		/* End */
		WrapperProjList.clear(); 
		set<Id> projectSetId = new set<Id>();
		if(selectedProject != null && selectedProject.size() > 0) 
			WrapperProjList.addAll(selectedProject.values());
		for(Customer_Projects__c p:projList)
		{			
			if(SearchVar.equals('All') ){
				Showpro.add(p);
				if(selectedProject != null && selectedProject.size() > 0 && selectedProject.containsKey(p.Id)){
			 		continue;
				}
				WrapperProjList.add(new wrapCheckbox(p));
			}					
			else
				if(p.Project_Id__r.Project_Name__c.startsWith(SearchVar.toLowerCase())||p.Project_Id__r.Project_Name__c.startsWith(SearchVar))
				{
					Showpro.add(p);
				   	if(selectedProject != null && selectedProject.size() > 0 && selectedProject.containsKey(p.Id)){
				 		continue;
					}
			 	   	WrapperProjList.add(new wrapCheckbox(p));
				}   
		}
		if(WrapperProjList!= null){
			sizee=WrapperProjList.size(); 
			objPageManager.numberOfRows = WrapperProjList.size();
		}			
		return null;
	}

    // Getter-setter for proDetails used for pagination
  	public List<wrapCheckbox> getproDetails(){
  	
  	if((WrapperProjList !=null) && (WrapperProjList.size() >0)){ 
      	 if(Wrapper1prolist !=null)	
       		Wrapper1prolist.clear();
        	for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<WrapperProjList.size();i++){
            	Wrapper1prolist.add(WrapperProjList.get(i));
         	}
     	} 
    return Wrapper1prolist; 
    } 
    
	public void  setproDetails (List<wrapCheckbox> proDetails) {
		this.proDetails = proDetails;
	}
	
	public PageReference SearchProjects(){
		QryString = 'Select Id, Name, Project_Name__c, Site_Address_City__c, Project_Id__c, Customer_Name__c,AccountId__c, AccountId__r.Export_Projects__c, Project_Id__r.Name, Project_Id__r.Plot_Area__c, Project_Id__r.Project_Name__c, Project_Id__r.Project_Type__c, Project_Id__r.Developer_Name__c, Project_Id__r.Project_Region__c' +
					', Project_Id__r.Total_Units__c, Project_Id__r.Launch_Date__c, Project_Id__r.Site_Address_City__c,  Project_Id__r.Site_Address_Actual__c, Project_Id__r.Site_Address_Landmark__c, Project_Id__r.Actual_No_of_Towers__c, Project_Id__r.Land_Area_in_acres__c, Project_Id__r.Planned_Units__c From Customer_Projects__c where AccountId__c = : AcctId AND Project_Id__r.To_Be_Approved__c=false AND Project_Name__c LIKE \'%'  + Projectname + '%\'';
		system.debug('ABCD ' + QryString);
		if(!Projectcity.equals('- All -')) {
   	    	QryString += ' AND Site_Address_City__c LIKE \'%' + Projectcity + '%\'';
   	    }
   	    system.debug('Coming Into search');
   	    projList = new list<Customer_Projects__c>();
   	    projList = Database.query(QryString);
   	    
   	    /* Logic to maintain the selected project */
		map<Id, wrapCheckbox> selectedProject = new map<Id, wrapCheckbox>();
		for(wrapCheckbox wrap : WrapperProjList){
			if(wrap.emailCust == true){
				selectedProject.put(wrap.custProjrecord.Id,wrap);
			}
		}
		WrapperProjList.clear();
		if(selectedProject != null && selectedProject.size() > 0){
			WrapperProjList = new list<wrapCheckbox>();
			WrapperProjList.addAll(selectedProject.values());
		}
		/* End */
   	    
   	    if(projList == null){
		     
   	 	}else{	  
   	 		
	  		SearchVar = 'All';
	  		Showpro = new list<Customer_Projects__c>();
	  		Showpro.addAll(projList);   	 				
	        for(Customer_Projects__c Serv1: projList) {
	        	if(selectedProject != null && selectedProject.size() > 0 && selectedProject.containsKey(Serv1.Id)){
				 	continue;
				}
    			WrapperProjList.add(new wrapCheckbox(Serv1));
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
		
	public pageReference detail() {
    
	 	PrjId=Apexpages.currentPage().getParameters().get('PrjId');
	 	PageReference pagref;
	 	system.debug('ProfileName'+ProfileName);
	 	if (ProfileName == 'RBI Customer Portal Manager')
	  		pagref = new PageReference('/apex/RBI_ProjectDetail?id='+SelectedProjId);
	  		
	  	if (ProfileName == 'RBI Customer Portal User')
	  		pagref = new PageReference('/apex/RBI_DetailPageforPortalUser?id='+SelectedProjId);
	  		
	  	return pagref;
    }
     
    public PageReference sendMail(){
     	list<wrapCheckbox> selectedProjects = new list<wrapCheckbox>();
     	List<Messaging.Emailfileattachment> attList = new List<Messaging.Emailfileattachment>();
     	Contact primaryContact = new Contact();
     	String[] toAddresses;
     	try{
     		String bigProject = '';
     		system.debug('Coming to sendemail');
	     	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
	     	for(wrapCheckbox wrap : WrapperProjList){
	     		if(wrap.emailCust == true){
	     			system.debug('========'+wrap.custProjrecord.Project_Id__c);
	     			selectedProjects.add(wrap);
	     			PageReference myPdf = Page.RBI_ProjectExport;
					myPdf.getParameters().put('ProjId',wrap.custProjrecord.Project_Id__c);
					Blob b;
					try{
						b = myPdf.getContent();
					}catch(VisualforceException e){
						bigProject +=  '\''+wrap.custProjrecord.Project_Name__c+'\',' ;//Testing
					}
					Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
					attachment.setFileName(wrap.custProjrecord.Project_Name__c);
					attachment.setBody(b);
					attachment.setContentType('application/vnd.ms-excel');                           
					attList.add(attachment);    
	     		}
	     	}
	     	if(bigProject != null && bigProject != ''){
	     		bigProject = bigProject.substring(0, bigProject.length()-1); 
	     		apexpages.addmessage(new apexpages.message(apexpages.severity.Info, 'The size of the project '+bigProject+' exceeds the limit range. Please select other projects and proceed.'));
	     	}
	     	if(attList != null){
	     		email.setFileAttachments(attList);
	     		if(AcctId != null)
	     			primaryContact = [select name, Group_Email__c from Contact where (AccountId = : AcctId) and (Primary__c = true) limit 1];
	     	}
			email.saveAsActivity = false;
			if(selectedProjects != null && selectedProjects.size() > 0){
				email.setWhatId(selectedProjects[0].custProjrecord.Id);
				
			}
		    if(primaryContact != null){
		    	email.setTargetObjectId(primaryContact.Id);
		    }	
		 	email.setTemplateId(System.label.RBI_ProjectImportTemplateId);	
			if(primaryContact != null && primaryContact.Group_Email__c != null)
				toAddresses = primaryContact.Group_Email__c.split(',');
			email.setToAddresses(toAddresses);
			email.setOrgWideEmailAddressId(system.label.RBI_OrgWideEmailAddr);
			if (!Test.isRunningTest()) { 
				Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
			} 
     	}catch(EmailException e){
     		apexpages.addmessage(new apexpages.message(apexpages.severity.error, 'Faliure in sending email!'));
     		showPopup();
     		return null;
     	}catch(Exception e){
     		apexpages.addmessages(e);
     		showPopup();
     		return null;
     	}
     	sendEmailflag = true;
     	showPopup();
		InitialLoad();
     	return null;
	}
	
	/* For openning the popUp window and closing it. */
	public PageReference closePopup() {
		PageReference pg;
		if(sendEmailflag != false){
			pg = Page.RBI_ExporttoXLStarterPg;
			displayPopup = false;
			pg.setRedirect(true);
			return pg;
		}
		displayPopup = false;
		return null; 
    }
 
    public void showPopup() {
		displayPopup = true;
    }
     
    public PageReference downloadProj(){
     	PageReference myPdf = Page.RBI_ProjectExport;
    	string prjid = Apexpages.currentPage().getParameters().get('ProjIdforDownload');
     	string test = ProjIdforDownload1;
     	myPdf.getParameters().put('ProjId',prjid);
     	return myPdf;
    }
     
    public class wrapCheckbox{
		public Customer_Projects__c custProjrecord{get; set;}
		public Boolean emailCust {get; set;}
		public wrapCheckbox(Customer_Projects__c custProj){
			custProjrecord = custProj;
			emailCust = false;
		}
		
		public wrapCheckbox(Customer_Projects__c custProj, Boolean check){
			custProjrecord = custProj;
			emailCust = check;
		}
    }
}