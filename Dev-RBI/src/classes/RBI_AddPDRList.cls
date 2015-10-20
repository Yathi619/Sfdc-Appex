/*
    Type:       Custom Controller
    Purpose:    Used to add PDR List for a Visit Record (TSR and DVU Visit) in Employee Portal.         

    Used By:   RBI_AddPDRList.page
    ---------------------------------------------------------------
    History:

    06-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_AddPDRList {
	public list<servicewrapper> WrapperListofval {get; set;} 
    public Project_Document_Status__c recprojdoc;
    public List_of_Values__c reclistofval;
    public list<Project_Document_Status__c> documentlist;
    public string ProjectId;
    public string VisitId;
    public string ProjectName {get;set;}
    
    public RBI_AddPDRList(){
    	ProjectId = System.currentPagereference().getParameters().get('ProjId');
    	VisitId = System.currentPagereference().getParameters().get('VisId');
    	WrapperListofval = new list<servicewrapper>();
    	
    }
    
    public list<servicewrapper> getListofValues(){
    	WrapperListofval = new list<servicewrapper>();
        	for(List_of_Values__c reclistofval:[Select Id, Name, Entity_Name__c, Entity_Type__c, Document_Type__c, Document_Description__c, Key__c, Value__c From List_of_Values__c where Entity_Type__c = 'Document' ORDER BY Key__c]){
            	WrapperListofval.add(new servicewrapper(reclistofval));
      
            }
      
        return WrapperListofval;
    }
    
    public PageReference dosave(){
       
        documentlist = new list<Project_Document_Status__c>();	  
        for(servicewrapper servwrapper: WrapperListofval) {
            if(servwrapper.selected == true) {
            
				documentlist.add(new Project_Document_Status__c(Visit__c=VisitId, Project_Document__c=servwrapper.listofval.Id));                      
            }
        }
       	if (documentlist !=null){
        	Database.Insert(documentlist);
        	PageReference Pg = new PageReference('/' + VisitId);
    		return Pg;
        }      
        return null;
    }
    
    public PageReference doCancel(){
		PageReference Pg = new PageReference('/' + VisitId);
		return Pg;
    }
    
    public class servicewrapper{
        public List_of_Values__c listofval {get; set;} 
        public Boolean selected {get; set;}
        
        public servicewrapper(List_of_Values__c lov){
            listofval = lov;
            selected= false;
        }
    }
}