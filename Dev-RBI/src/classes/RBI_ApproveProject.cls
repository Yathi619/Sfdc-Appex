/*
    Type:       Custom Controller
    Purpose:    Used to approve the projects created by customers (through Customer Portal).         

    Used By:   RBI_ApproveProject.page
    ---------------------------------------------------------------
    History:

    07-May-2013     Created     Tugboat Info Solutions Pvt. Ltd

*/
public class RBI_ApproveProject {

    public Account acc{get; set;}
    public list<Account> acclst;
    public Project__c prj{get; set;}
    public ApexPages.StandardController sController;
    private string AcctId     = '';
    String  prjId;
    String  custProjId;
    list<Visit__c> VisitList;
    Id ProjRecTypeId;
    //Added for Phase2B on 13/8/2013
    public boolean displayPopup {get; set;}
	//public Account objAcc {get; set;}
	//Ends
    public RBI_ApproveProject(ApexPages.StandardController stdCon)
    {
        sController = stdCon;
        this.prj=(Project__c)stdCon.getRecord();
        AcctId  = UserUtil.CurrentUser.AccountId; //Logged in user's account id
        prjId = prj.Id;
        VisitList = new list<Visit__c>();
        
    }
    
    public PageReference AprovPrj(){
        prj.To_Be_Approved__c = false;
        prj.Project_Rejected__c = false;
        update prj;
        system.debug('xxxxxx'+prj);
        if((prj.Launch_Date__c < system.today()) && (prj.To_Be_Approved__c == false)){
            ProjRecTypeId = [select Id,name from RecordType where name='Project' and SObjectType='Visit__c' limit 1].Id;
            Visit__c visit = new Visit__c();
            visit.RecordTypeId = ProjRecTypeId;
            visit.Project__c = prj.Id;
            visit.Visit_Report__c = 'First Technical Report';
            if(prj.Surveyor__c != null){
                visit.Surveyor__c = prj.Surveyor__c;
                visit.OwnerId = prj.Surveyor__c;
            }
            visit.Start_Date__c = system.today();    
            VisitList.add(visit);
                   
        }
        try{
            insert VisitList;
            sendEmail();
        }catch(DMLException e){
            system.debug(e);
        }
        PageReference Pg = Page.RBI_ProjectsForApproval;
        return Pg;
    }
   //Added for Phase2B on 13/8/2013
   public PageReference RejectPrj(){
        
        prj.Project_Rejected__c = true;
        try{
        	update prj;
        	system.debug('xxxxxx'+prj+' yyy '+AcctId);
        	sendEmail();
        }catch(DMLException e){
        	system.debug(e);
        	return null;
        }
        PageReference Pg = Page.RBI_ProjectsForApproval;
        displayPopup = false;
        return Pg;
   }
   // 
    public PageReference doCancel(){
        PageReference Pg = Page.RBI_ProjectsForApproval;
        return Pg;
    }
    
    //Added for Phase2B on 14/8/2013
    public void sendEmail(){
    	User custPrimContact = new User();
    	if(prj.ownerId != null || prj.ownerId != '')
    		custPrimContact = [select Name,ContactId,Contact.Group_Email__c from User where Id = : prj.ownerId];
    	if(custPrimContact != null){	
	    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = custPrimContact.Contact.Group_Email__c.split(',');
	        mail.setToAddresses(toAddresses);
	        if(prj.Project_Rejected__c == false)
	        	mail.setTemplateId(System.label.RBI_TempIdForCustProjectApproved);
	        else
	        	mail.setTemplateId(System.label.RBI_TempIdForCustProjectRejected);	
	        mail.setTargetObjectId(custPrimContact.ContactId);
	        mail.setWhatId(prj.Id);
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}
    }
    
    public void closePopup()
	{
		displayPopup = false;
	}
	public void showPopup()
	{
		displayPopup = true;
	}
    //End of Phase2B on 14/8/2013
    
}