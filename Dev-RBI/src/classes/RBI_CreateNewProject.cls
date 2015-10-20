/*
    Type:       Custom Controller
    Purpose:    Used to Create New projects by a Customer on the Customer Portal Home Page.         

    Used By:   RBI_CreateNewProject.page
    ---------------------------------------------------------------
    History:

    12-Apr-2013     Created     Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_CreateNewProject {

    public Account acc{get; set;}
    public list<Account> acclst;
    public Project__c prj{get; set;}
    public ApexPages.StandardController sController;
    public list<CRM_Report__c> rptlist {get;set;}
    public string AcctId     = '';
    public list<Customer_Projects__c> approvallist {get;set;}
    public string appStatus {get;set;}  
    String  prjId;
    
    public RBI_CreateNewProject(ApexPages.StandardController stdCon){
        sController = stdCon;
        this.prj=(Project__c)stdCon.getRecord();
        AcctId  = UserUtil.CurrentUser.AccountId; //Logged in user's account id     
        prjId = prj.Id;
    }
    
    public pageReference AddValue() {
        acclst = new list<Account>();
        acc = new Account();
        acclst = [select BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Phone from Account where Id =:prj.Developer_Id__c];
        acc = acclst[0];
        return null;
    }
    
    public pagereference save(){
    
        prj.To_Be_Approved__c = true;
        try{
	        insert prj;
	        list<Customer_Projects__c> objCustProjlst = new list<Customer_Projects__c>();
	        objCustProjlst.add(new Customer_Projects__c(Project_Id__c = prj.Id, AccountId__c = AcctId));
	        if(objCustProjlst != null)
	            Database.insert(objCustProjlst);
        }catch(DMLException e){
        	ApexPages.addMessages(e);
            return null;
        }
        PageReference myProjectPage = Page.RBI_MyProjects;
        return myProjectPage;
    }
    
    public PageReference doCancel(){
        PageReference Pg = Page.RBI_MyProjects;
        return Pg;
    }
    
}