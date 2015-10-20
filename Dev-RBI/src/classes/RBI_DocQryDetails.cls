/*
    Type:       Custom Controller
    Purpose:    Used by the Customer in Customer Portal to see the Documents for TSR and DVU Visits records. Also, Customer can see
                the query details for each document. This can be accessed in Customer Portal under My Projects tab - Status subtab and 
                clicking on Visit Name.      

    Used By:   RBI_VisitDetails.page
    ----------------------------------------------------------------------------------
    History:

    25-Apr-2013     Modified        Tugboat Info Solutions Pvt. Ltd

*/
public class RBI_DocQryDetails {
    
    public  list<Query__c>      queryList    {get; set;}
    public  list<Project_Document_Status__c> allQryList {get; set;}
    public Id docId     {get; set;}
    public Visit__c vis{get; set;}
    public boolean disQry {get;set;}
    public ApexPages.StandardController sController;
    public boolean docRecFlag {get;set;} // Determines the field display in Document Section
    
    public RBI_DocQryDetails(ApexPages.StandardController stdCon)
    {
        try{  
            sController = stdCon;
            disQry = false;
            this.vis=(Visit__c)stdCon.getRecord();
            list<Query__c>   queryList = new list<Query__c>();
            if(vis.Visit_Report__c == 'TSR Report' || vis.Visit_Report__c == 'DVU Report')
                docRecFlag = true;
            else
                docRecFlag = false; 
            allQryList = new list<Project_Document_Status__c>();
            allQryList = vis.Project_Document_Status__r;
            if (allQryList != null && allQryList.size() > 0){ 
                docId =  allQryList[0].Id;
                queryList = getqueryList(docId);
            }
        }
        catch(System.Exception e){
            //DO Nothing                  
            
        } 
        
    }
    
    public PageReference selectRow() {
        
        queryList = getqueryList(docId);
        return null;
    }
    
    public Query__c[] getqueryList(String qId){
        
        queryList = new list<Query__c>();
        
        //Runquery to fetch Query records related to a Document
        if (docId!=null){
            queryList   =   [SELECT Id, Query_Initiated_Date__c, Query_Description__c, Query_Resolved_Date__c, Project_Document_Status__c, Project_Document_Status__r.Project_Document__r.Name, Project_Document_Status__r.Project_Document__r.Document_Description__c, Project_Document_Status__r.Project_Document__r.Document_Type__c FROM Query__c Where Project_Document_Status__c=:docId];
        
            if(queryList == null){
                disQry = false;
                return null;
                //ADD IN DEBUG LOG
            }
            else{
                disQry = true;
                return queryList;
                }
        }
        return null;
    }
}