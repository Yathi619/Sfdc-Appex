/*
    Type:       Custom Controller
    Purpose:    Used to create Constrcution Status for a Tower in the Employee application.        

    Used By:   RBI_CreateConstructionStatus.page
    ---------------------------------------------------------------
    History:

    25-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_CreateConstructionStage {
	
   	public Id selectedTower {get;set;}
   	public List<SelectOption> TowerOptions {get; set;}
   	public list<Tower__c> TowerList;
   	public Tower__c TowerRec   {get;set;}
   	public Construction_Status__c ConStatus {get;set;}
   	public string ProjectId;
   	public string ProjectName {get;set;}
   	boolean notUpdatedConStatus;
   	String relatedOf = '';
   	String forCheck = '';
   	String keyPrefix = '';
   	String visitKeyPrefix = '';
   	String keyPrefixForConsrStatus = '';
   	public ApexPages.StandardController sController;
   	
   	public RBI_CreateConstructionStage(ApexPages.StandardController stdCon){
   		sController = stdCon;
		this.ConStatus=(Construction_Status__c)stdCon.getRecord();
		system.debug('1111111111'+ConStatus);
       	ProjectId = System.currentPagereference().getParameters().get('ProjId');
       	ProjectName = System.currentPagereference().getParameters().get('ProjName');
       	relatedOf = System.currentPagereference().getParameters().get('retURL');
       	system.debug('Project Id '+ProjectId);
       	if(ProjectId == null || ProjectId == ''){
       		Schema.DescribeSObjectResult r = Tower__c.sObjectType.getDescribe();
			keyPrefix = r.getKeyPrefix();
			Schema.DescribeSObjectResult v = Visit__c.sObjectType.getDescribe();
			visitKeyPrefix = v.getKeyPrefix();
			forCheck = relatedOf.substring(1, relatedOf.length()-12); 
			if((forCheck != null && forCheck != '') && (keyPrefix != null && keyPrefix != '') && forCheck != keyPrefix)
       			ProjectId = ConStatus.Project__c;
			system.debug('ssssssss'+forCheck+' xx '+keyPrefix+' '+ProjectId);
	       	
       	}
       	
       	TowerOptions = new List<SelectOption>() ;
        list<Tower__c>   TowerList = new list<Tower__c>();
        //goToStandard();
        notUpdatedConStatus = false;
        getTowers();
	}
	
	public pageReference goToStandard(){
		system.debug('yyyy'+forCheck+'-'+keyPrefix+'-'+visitKeyPrefix);    	
    	if((forCheck != null && forCheck != '') && (keyPrefix != null && keyPrefix != '')){
    		if((visitKeyPrefix != null && visitKeyPrefix != '') && (keyPrefix != null && keyPrefix != '') && (ProjectId == null || forCheck == visitKeyPrefix || forCheck == keyPrefix)){
    			Schema.DescribeSObjectResult conStatus = Construction_Status__c.sObjectType.getDescribe();
				keyPrefixForConsrStatus = conStatus.getKeyPrefix();
				Pagereference newpage = new Pagereference ('/'+keyPrefixForConsrStatus+'/e?retURL='+relatedOf);
				system.debug('INIF'+newpage); 
				newpage.setRedirect(true);			
	    		return newpage;
    		}
		}
		return null;
	}
	
    public void getTowers(){
	    TowerList = [select Name, Project__c, Project__r.Name from Tower__c where Project__c = : ProjectId];
	    if((ProjectName == null || ProjectName == '') && (forCheck != keyPrefix) && (keyPrefix != keyPrefixForConsrStatus)){
	    	if((visitKeyPrefix != null && visitKeyPrefix != '') && (keyPrefix != null && keyPrefix != '') && forCheck == visitKeyPrefix){
	    		
	    	}else if(TowerList != null && TowerList.size() > 0){
	    		ProjectName = TowerList[0].Project__r.Name;
	    		selectedTower = ConStatus.Tower__c;
	    	}	
	    }
	    system.debug('TowerList'+TowerList);
		if (TowerList != null && TowerList.Size() >0){
			for(Tower__c towRec:TowerList){
				
		     	TowerOptions.add(new SelectOption(towRec.Id,towRec.Name));
			}
		}
	}
	
	public void CommonMethod(){
		ConStatus.Project__c = ProjectId;
		ConStatus.Tower__c = selectedTower;
		system.debug ('Con Stat Record'+ConStatus);
		try{
			upsert ConStatus;
		}catch(DMLException e){
			 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.RBI_Generic_Duplicate_ErrorMsg)); 
			 //system.debug('Duplicates are not allowed'+ApexPages.Message); 
			 notUpdatedConStatus = true;
		}

	}
	
	public pageReference doSave(){
		CommonMethod();
		if(!notUpdatedConStatus){
			PageReference Pg = new PageReference('/' + ProjectId);
			return Pg;
		}
		return null;
	}
	
	public pageReference doSaveandNew(){
		
		CommonMethod();
		ConStatus = new Construction_Status__c();
		//PageReference Pg = new PageReference('/apex/RBI_CreateConstructionStatus?ProjId?'+ProjectId +'&ProjName='+ProjectName);
		PageReference Pg = ApexPages.currentPage();
		pg.getParameters().put('ProjId',ProjectId);
		pg.getParameters().put('ProjName',ProjectName);
		Pg.setRedirect(true);
		//sController = new ApexPages.standardController(ConStatus);        
        //return sController.view();
		return Pg;
		
	}
	public PageReference doCancel(){
		PageReference Pg = new PageReference('/' + ProjectId);
		return Pg;
    }

}