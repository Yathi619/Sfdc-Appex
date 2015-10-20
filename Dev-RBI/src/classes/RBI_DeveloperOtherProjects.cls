/*
    Type:       Custom Controller
    Purpose:    Used to display the Ongoing and Completed projects of a developer in Customer Portal as a pop-up         

    Used By:   RBI_OtherOnGoingCompletedProjects.page
    ----------------------------------------------------------------------------------
    History:

    24-Apr-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_DeveloperOtherProjects {

	public Account selectedAccount { get; set; }
	public Account[] lstAccount;
    public List_of_Values__c LOV {get;set;}
    public String AccountId;
    public String LOVId;
   
    public ApexPages.StandardController std;
    
   	public RBI_DeveloperOtherProjects(ApexPages.StandardController stdcontroller) {
     	this.std = stdcontroller;
        this.LOV=(List_of_Values__c)stdcontroller.getRecord();
        AccountId = System.currentPagereference().getParameters().get('AccId');
        LOV.Developer__c = AccountId;
        LOV.Name = 'Other Projects';
        LOV.Entity_Type__c = 'Other Projects';
        
    }
    
    public pageReference Save(){
    	
    	/*if(LOV.Project_Type__c == 'Ongoing')
        	LOV.Name = 'Ongoing Projects';
       	if(LOV.Project_Type__c == 'Completed')*/
        	LOV.Name = 'Other Projects';
        	LOV.Entity_Type__c = 'Other Projects'; 	
        	
        insert LOV;
    	PageReference Pg = new PageReference('/' + AccountId);
		return Pg;
    }
    
    public PageReference doCancel(){
		PageReference Pg = new PageReference('/' + AccountId);
		return Pg;
    }
    public PageReference SaveandNew(){
    	insert LOV;
    	LOV = new List_of_Values__c(Developer__c = AccountId, Name = 'Other Projects', Entity_Type__c = 'Other Projects');
    	PageReference newPage = New PageReference('/apex/RBI_OtherOngoingCompletedProjects?AccId='+AccountId);
    	newPage.setRedirect(true);
    	return newPage;
    }
}