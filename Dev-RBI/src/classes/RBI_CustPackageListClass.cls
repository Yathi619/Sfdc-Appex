/*
    Type:       Custom Controller
    Purpose:    Used to display the Packages/Services associated with the Customer, in Employee application          

    Used By:   RBI_CustPackageListPage.page
    ---------------------------------------------------------------
    History:

    18-Apr-2013          Created		Tugboat Info Solutions Pvt.Ltd

*/
public with sharing class RBI_CustPackageListClass {
	public list<Project_Cust_Packages__c> liParents{get; set;}
    public string projectId ='';
    public RBI_CustPackageListClass(ApexPages.standardController std){
        projectId=Apexpages.currentPage().getParameters().get('id');
        liParents = [select Customer_Project__r.Project_Id__r.Id,List_of_Values__c,List_Pricing__c
                             from Project_Cust_Packages__c where Customer_Project__r.Project_Id__r.Id=:projectId];
       }

}