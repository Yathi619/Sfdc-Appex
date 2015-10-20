/*
    Type:       Custom Controller
    Purpose:    Used to add Construction loan details for a Project.        

    Used By:   RBI_ConstructionLoanDetails.page
    ---------------------------------------------------------------
    History:

    07-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_ConstructionLoanDetails {
	public Account selectedAccount { get; set; }
	public Account[] lstAccount;
    public List_of_Values__c LOV {get;set;}
    public String ProjectId;
    public String LOVId;
   	public ApexPages.StandardController std;
    
    //Constructor
   	public RBI_ConstructionLoanDetails(ApexPages.StandardController stdcontroller) {
     	this.std = stdcontroller;
        this.LOV=(List_of_Values__c)stdcontroller.getRecord();
        ProjectId = System.currentPagereference().getParameters().get('ProjId');
        LOV.Project_Id_Const_Loan__c = ProjectId;
        LOV.Name = 'Construction Loan Details';
        LOV.Entity_Type__c = 'Construction Loan Details';
    }
    
    public pageReference Save(){
    	insert LOV;
    	PageReference Pg = new PageReference('/' + ProjectId);
		return Pg;
    }
    
    public PageReference doCancel(){
		PageReference Pg = new PageReference('/' + ProjectId);
		return Pg;
    }
    public PageReference SaveandNew(){
    	insert LOV;
    	LOV = new List_of_Values__c(Project_Id_Const_Loan__c = ProjectId, Name = 'Construction Loan Details', Entity_Type__c = 'Construction Loan Details');
    	PageReference newPage = New PageReference('/apex/RBI_ConstructionLoanDetails?ProjId='+ProjectId);
    	newPage.setRedirect(true);
    	return newPage;
    }
}