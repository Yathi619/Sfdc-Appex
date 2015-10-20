/*
    Type:       Custom Controller
    Purpose:    Used to add Feedback/Remarks for a Project in Employee Portal.         

    Used By:   RBI_AddProjectFeedback.page
    ---------------------------------------------------------------
    History:

    06-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_AddProjectFeedback {
	
	public boolean visitFeedDupError;
	public list<servicewrapper> WrapperListofval {get; set;} 
    public Project_Feedback__c recfeedback;
    public List_of_Values__c reclistofval;
    public list<Project_Feedback__c> feedbacklist;
    public string ProjectId;
    public string ProjectName {get;set;}
    public string VisitId;
    public string VisitName;
    
    public RBI_AddProjectFeedback(){
    	ProjectId = System.currentPagereference().getParameters().get('ProjId');
    	ProjectName = System.currentPagereference().getParameters().get('ProjName');
    	//Added for Phase 2C on 16.09.2013
    	VisitId = System.currentPageReference().getParameters().get('VstId');
    	VisitName = System.currentPageReference().getParameters().get('VstName');
    	visitFeedDupError = false;
    	//Adding End
    	WrapperListofval = new list<servicewrapper>();
    	
    }
    
    public list<servicewrapper> getListofValues(){
    	WrapperListofval = new list<servicewrapper>();
        	for(List_of_Values__c reclistofval:[Select Id, Name, Entity_Name__c, Entity_Type__c, Key__c, Value__c From List_of_Values__c where Entity_Name__c = 'Remark' OR Entity_Name__c = 'Statutory Approval' ORDER BY Entity_Name__c]){
            	WrapperListofval.add(new servicewrapper(reclistofval));
      
            }
      
        return WrapperListofval;
    }
    
    public PageReference dosave(){
       
        feedbacklist = new list<Project_Feedback__c>();	  
        for(servicewrapper servwrapper: WrapperListofval) {
            if(servwrapper.selected == true) {
            	//Added for Phase 2C on 16.09.2013
            	if(ProjectId !=null){
					feedbacklist.add(new Project_Feedback__c(Project__c=ProjectId, Comments__c='Need to enter', List_of_Values_Id__c=servwrapper.listofval.Id));
            	}else if(VisitId !=null){
					feedbacklist.add(new Project_Feedback__c(Visit__c=VisitId, Comments__c='Need to enter', List_of_Values_Id__c=servwrapper.listofval.Id));
				}
				//Adding End                      
            }
        }
        try{
	       	if(feedbacklist !=null && ProjectId !=null){//Added for Phase 2C on 16.09.2013
	        	Database.Insert(feedbacklist);
	        	PageReference Pg = new PageReference('/' + ProjectId);
	    		return Pg;
	    		//Added for Phase 2C on 16.09.2013
	        }else if(feedbacklist !=null && VisitId !=null){
	        	visitFeedDupError = false;
	        	hasDuplicates(feedbacklist);
	        	for(Project_Feedback__c fdbck : feedbacklist){
	        		if(visitFeedDupError){
		        		return null;
	        		}
	        	}
	        	
	        	Database.Insert(feedbacklist);
	        	PageReference Pg1 = new PageReference('/' + VisitId);
	    		return Pg1;
	    		//Adding End
	        }
        }catch(DMLException ex){
        	ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Feedback already exists!');
        	ApexPages.addMessage(errorMessage);
        	return null;
        }      
        return null;
    }
    
    public PageReference doCancel(){
		//Added for Phase 2C on 16.09.2013
    	if(ProjectId !=null){
			PageReference Pg = new PageReference('/' + ProjectId);
			return Pg;
    	}else{
    		PageReference Pg1 = new PageReference('/' + VisitId);
			return Pg1;
			//Adding End
    	}
    }
    
    public class servicewrapper{
        public List_of_Values__c listofval {get; set;} 
        public Boolean selected {get; set;}
        
        public servicewrapper(List_of_Values__c lov){
            listofval = lov;
            selected= false;
        }
    }
    
    public void hasDuplicates(Project_Feedback__c[] reclistofval){
    	Map <String,servicewrapper> feedMap = new Map<String, servicewrapper> ();
    	system.debug('//// ' + reclistofval);
        for (servicewrapper wrapLov: WrapperListofval) {
        	if(wrapLov.selected == true){
                String lovName     = (wrapLov.listofval.Name==null)?'':wrapLov.listofval.Name.toLowerCase();
                String vstNum     = (VisitName==null)?'':VisitName.toLowerCase();
                String ukey = lovName + vstNum;
                system.debug('----- ' + ukey + ' 111 ' + lovName + ' 222 ' + vstNum);
                if (feedMap.containsKey(ukey)) {
                    wrapLov.listofval.addError('An Feedback with the same Name already exists in the system');
                    visitFeedDupError = true;
                }
                else feedMap.put(ukey,wrapLov);
        	}
        }
        if (!feedMap.isEmpty()){  
	    	for(Project_Feedback__c[] feedCheck:[select Id, Visit_Feedback_Unique_Key__c, List_of_Values_Id__r.Name from Project_Feedback__c where Visit_Feedback_Unique_Key__c IN :feedMap.keySet()]) {
	        	for(Project_Feedback__c fd : feedCheck) {
	            	String currentId = fd.Id;
	                //if there's a dupe and this isn't the current record, then add the error.
	                if(feedMap.containsKey(fd.Visit_Feedback_Unique_Key__c) && (currentId != feedMap.get(fd.Visit_Feedback_Unique_Key__c).listofval.Id)) {
	                	feedMap.get(fd.Visit_Feedback_Unique_Key__c).listofval.addError('Duplicate record with the same feedback found in salesforce(Name: ' + fd.List_of_Values_Id__r.Name + ')');
	                	visitFeedDupError = true;
	                }
	            }
	       	}
    	}
    }
}