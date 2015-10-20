/*
    Type:       Custom Controller
    Purpose:    Used to add Infrastructure Near for a Project in Employee Portal.         

    Used By:   RBI_AddInfraNearProject.page
    ---------------------------------------------------------------
    History:

    02-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_AddInfraNearProject {
	
	public boolean visitInfraDupError;
	public list<servicewrapper> WrapperListofval {get; set;} 
    public Infrastructure_Near_Project__c recInfra;
    public List_of_Values__c reclistofval;
    public list<Infrastructure_Near_Project__c> infralist;
    public string ProjectId;
    public string ProjectName {get;set;}
    public string VisitId;
    public string VisitName;
    
    public RBI_AddInfraNearProject(){
    	ProjectId = System.currentPagereference().getParameters().get('ProjId');
    	ProjectName = System.currentPagereference().getParameters().get('ProjName');
    	//Added for Phase 2C on 13.09.2013
    	VisitId = System.currentPageReference().getParameters().get('VstId');
    	VisitName = System.currentPageReference().getParameters().get('VstName');
    	visitInfraDupError = false;
    	//Adding End
    	WrapperListofval = new list<servicewrapper>();
    }
    
    public list<servicewrapper> getListofValues(){
    	WrapperListofval = new list<servicewrapper>();
    	for(List_of_Values__c reclistofval:[Select Id, Name, Entity_Name__c, Entity_Type__c, Key__c, Value__c From List_of_Values__c where Entity_Name__c = 'Infrastructure Near Project Site']){
        	WrapperListofval.add(new servicewrapper(reclistofval));
        }
        return WrapperListofval;
    }
    
    public PageReference dosave(){
        infralist = new list<Infrastructure_Near_Project__c>();	  
        for(servicewrapper servwrapper: WrapperListofval) {
            if(servwrapper.selected == true) {
            	//Added for Phase 2C on 13.09.2013
            	if(ProjectId !=null){
					infralist.add(new Infrastructure_Near_Project__c(Project_Id__c = ProjectId, Infrastructure_Near_Project__c = servwrapper.listofval.Id));
            	}else if(VisitId !=null){
            		infralist.add(new Infrastructure_Near_Project__c(Visit__c = VisitId, Infrastructure_Near_Project__c = servwrapper.listofval.Id));
            	}
            	//Adding End                      
            }
        }
        try{
	       	if (infralist !=null && ProjectId !=null){//Added for Phase 2C on 13.09.2013
	        	Database.Insert(infralist);
	        	PageReference Pg = new PageReference('/' + ProjectId);
	    		return Pg;
	    		//Added for Phase 2C on 13.09.2013
	        }else if(infralist !=null && VisitId !=null){
	        	visitInfraDupError = false;
	        	hasDuplicates(infralist);
	        	for(Infrastructure_Near_Project__c inf : infralist){
	        		if(visitInfraDupError){
		        		return null;
	        		}
	        	}
	        	Database.Insert(infralist);
	        	PageReference Pg1 = new PageReference('/' + VisitId);
	    		return Pg1;
	    		//Adding End
	        }
        }catch(DMLException ex){
        	ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Infrastructure already exists!');
        	ApexPages.addMessage(errorMessage);
        	return null;
        }      
        return null;
    }
    
    public PageReference doCancel(){
    	//Added for Phase 2C on 13.09.2013
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
    
    public void hasDuplicates(Infrastructure_Near_Project__c[] reclistofval){
    	Map <String,servicewrapper> infraMap = new Map<String, servicewrapper> ();
    	system.debug('//// ' + reclistofval);
        for (servicewrapper wrapLov: WrapperListofval) {
        	if(wrapLov.selected == true){
                String lovName     = (wrapLov.listofval.Name==null)?'':wrapLov.listofval.Name.toLowerCase();
                String vstNum     = (VisitName==null)?'':VisitName.toLowerCase();
                String ukey = lovName + vstNum;
                system.debug('----- ' + ukey + ' 111 ' + lovName + ' 222 ' + vstNum);
                if (infraMap.containsKey(ukey)) {
                    wrapLov.listofval.addError('An Infrastructure with the same Name already exists in the system');
                    visitInfraDupError = true;
                }
                else infraMap.put(ukey,wrapLov);
        	}
        }
        if (!infraMap.isEmpty()){  
	    	for(Infrastructure_Near_Project__c[] infraCheck:[select Id, VstInfraUniqueKey__c, Infrastructure_Near_Project__r.Name from Infrastructure_Near_Project__c where VstInfraUniqueKey__c IN :infraMap.keySet()]) {
	        	for(Infrastructure_Near_Project__c inf : infraCheck) {
	            	String currentId = inf.Id;
	                //if there's a dupe and this isn't the current record, then add the error.
	                if(infraMap.containsKey(inf.VstInfraUniqueKey__c) && (currentId != infraMap.get(inf.VstInfraUniqueKey__c).listofval.Id)) {
	                	infraMap.get(inf.VstInfraUniqueKey__c).listofval.addError('Duplicate record with the same infrastructure found in salesforce(Name: ' + inf.Infrastructure_Near_Project__r.Name + ')');
	                	visitInfraDupError = true;
	                }
	            }
	       	}
    	}
    }
}