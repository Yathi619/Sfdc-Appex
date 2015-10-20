/*
    Type:       Custom Controller
    Purpose:    Used to generate the Project Snapshot Report for a Customer from Customer Portal.        

    Used By:   RBI_GenerateProjectSnapshotReport.page
    ---------------------------------------------------------------
    History:

    26-Apr-2013     Created     Tugboat Info Solutions Pvt. Ltd

*/
public class RBI_ProjectSnapshot {
    public Contact con{get; set;}
    public list<Contact> conlst{get;set;} 
    public Project__c prj{get; set;}
    public list<Project__c> projlist{get;set;}
    public list<List_of_Values__c> Quantlist{get;set;}
    public list<List_of_Values__c> lovlist{get;set;}
    public list<List_of_Values__c> lvongoinglist{get;set;}
    public list<List_of_Values__c> lvcomplete{get;set;}
    public Id projid;
    public ApexPages.StandardController sController;
    public Visit__c visit {get; set;}
    public Visit__c visittsr {get; set;}
    public list<Visit__c> visitlist{get;set;}
    public list<Visit__c> tsrlist{get;set;}
    public list<Visit__c> dvulist{get;set;}
    public list<Customer_Projects__c> customerlist{get;set;}
    public string dateStr {get; set;}
    public boolean IsPorEnabled {get;set;}    
    private string RBIaccnt = '';
    public string AcctName {get;set;}
    private string AcctId     = '';
    
    public RBI_ProjectSnapshot(ApexPages.StandardController stdCon)
    {
        sController = stdCon;
        projid=ApexPages.currentPage().getParameters().get('id');
        showDevAccContact(); 
        showlovproject();
        showvisit();
        projlist = new list <Project__c>();
        RBIaccnt =  System.Label.RBI_AccountId;
        AcctId = UserUtil.CurrentUser.AccountId; //Logged in user's account id
        AcctId = (AcctId == null || AcctId == '')?RBIaccnt:AcctId; //set account id to RBI cust record in case it is null
        IsPorEnabled = UserUtil.CurrentUser.IsPortalEnabled;
		AcctName = UserUtil.CurrentUser.contact.account.Name;
        //customerlist=[Select Customer_Name__c,Project_Id__c from Customer_Projects__c where Project_Id__c=:projid ORDER by LastModifiedDate DESC];
    }
    public void showDevAccContact(){
        projlist=[Select id, Developer_Id__c From Project__c where id=:projid ];
        if (projlist[0].Developer_Id__c != null)
        	conlst = [select Id, Name ,Age__c, Details_of_Experience__c, Qualifications__c,AccountId from Contact where AccountId =:projlist[0].Developer_Id__c];
    
    }
    
    public void showlovproject(){
        //Quantlist=[Select Total_BUA__c, Project_Type__c, Loan_Amount__c, Land_Area_in_Acres__c, Id,Project_Id_Const_Loan__c, Dwelling_Units__c, Dev_Project_Name__c, Completion_Year__c, Bank_Name__c From List_of_Values__c  where Developer__c=:projlist[0].Developer_Id__c]; 
        Quantlist=[Select Total_BUA__c, Project_Type__c, Loan_Amount__c, Land_Area_in_Acres__c, Id,Project_Id_Const_Loan__c, Dwelling_Units__c, Dev_Project_Name__c, Completion_Year__c, Bank_Name__c From List_of_Values__c  where Project_Id_Const_Loan__c =: projid];
        lvongoinglist= new list<List_of_Values__c>();
        lvcomplete = new list<List_of_Values__c>();
        lovlist=[Select Total_BUA__c, Project_Type__c,Dev_Project_Address__c, Loan_Amount__c, Land_Area_in_Acres__c, Id, Dwelling_Units__c, Dev_Project_Name__c, Completion_Year__c, Bank_Name__c,Customer__r.Name From List_of_Values__c where Developer__c=:projlist[0].Developer_Id__c]; 
        for(List_of_Values__c lv :lovlist){
            if(lv.Project_Type__c == 'Ongoing')
            { 
                lvongoinglist.add(lv);
            }
            else if(lv.Project_Type__c == 'Completed')
            { 
                lvcomplete.add(lv);
            }   
        }
        
    }
    public void showvisit(){
        DateTime d = system.Today() ;
        dateStr =  d.format('dd/MM/yyyy') ; 
            
        visit=new Visit__c ();
        visittsr = new Visit__c ();
        visitlist = new list<Visit__c>();
        tsrlist = new list<Visit__c>();
        dvulist = new list<Visit__c>();
        
        visitlist=[Select Status__c, LastModifiedDate, Legal_Agency__r.Name,Project__c, Visit_Report__c From Visit__c  where Project__c=:projid ORDER by LastModifiedDate DESC]; 
        for(Visit__c vis :visitlist){
            if(vis.Visit_Report__c == 'TSR Report')
            { 
                tsrlist.add(vis);
                visittsr = tsrlist[0];
            }
            else if(vis.Visit_Report__c == 'DVU Report') 
            { 
                dvulist.add(vis);
                visit=dvulist[0];
            }   
            
        }
         
    }
}