public with sharing class RBI_DTRLoad {

	public string ProjectId {get;set;}
	public string ProjectName {get;set;}
	public boolean disframe {get;set;}
	public string  FTRpath {get;set;}
	string filename;
	string custprojectid;
	string bucketname;
	boolean execptionflg;
	Customer_Projects__c updcustproj;

	public RBI_DTRLoad(){
		execptionflg = false;
        ProjectId = ApexPages.currentPage().getParameters().get('Id');
        ProjectName = ApexPages.currentPage().getParameters().get('Name');
        custprojectid = ApexPages.currentPage().getParameters().get('custProjectId');
        filename = ApexPages.currentPage().getParameters().get('path');
        bucketname =System.Label.RBI_FTRBucket;
        string ftrvstexternalid = ProjectId+'-First Technical Report';
        list<Visit__c> vstLst = new list<Visit__c>(); 
       	vstLst =[select Id, name, Exception__c from Visit__c where ProjecIdVisitType__c=:ftrvstexternalid ];
       	if(vstLst!=null && vstLst.size()>0)
       	{
       		execptionflg = vstLst[0].Exception__c;
       	}
        if((filename!=null) && (filename!='') && (execptionflg != true))
		{
			
        	AWS_S3_ExampleController awscontroller = new AWS_S3_ExampleController();
        	FTRpath = awscontroller.AWSLogin(filename, bucketname);
		}
	}
	
	public PageReference gotoReport(){
	try{  		
			if(execptionflg == true){
				PageReference pg = new PageReference('/apex/RBI_Detail_Technical_Report_PDF?Id='+ProjectId);
				return pg;				
			}
			else{
				if (filename == null || filename == '' ){
					disframe = false;
					bucketname =System.Label.RBI_FTRBucket;
					string s3path     =System.Label.RBI_S3Link;
					string fileaccess = 'private';
					PageReference myPdf = Page.RBI_Detail_Technical_Report_PDF;
					myPdf.getParameters().put('Id', ProjectId);
					Blob b;
					b = myPdf.getContent();
					string inpfilename = custprojectid+'-'+ProjectName +'-DTR.pdf';
					//call function to upload the FTR in s3
					AWS_S3_ExampleController awscls = new AWS_S3_ExampleController();
					awscls.uploadFilesystemDoc(bucketname,inpfilename,b,fileaccess);
					//after upload  update the path on customer package
					s3path = s3path+'/'+bucketname+'/'+inpfilename;
					if(custprojectid != null && custprojectid !='')
					{
						updcustproj = new Customer_Projects__c(Id = custprojectid,FTR_File_Path__c=inpfilename);
						Database.update(updcustproj);
					}		
					PageReference pg = new PageReference('/apex/RBI_Detail_Technical_Report_PDF?Id='+ProjectId);
					return pg;
				}else{
					disframe = true;
					return null;
				}
			}
		}catch(Exception ex){
    		System.debug('EXCEPTION: ' + ex);			
		}		
		return null;
	}
	
	@IsTest(SeeAllData=true)  
	static void DTRLoadTest() {
		
		string bktname = System.Label.RBI_FTRBucket;
		string s3pth = System.Label.RBI_S3Link;
		string pth;
		ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
		list<Account> acc = new list<Account>();
        Account Acnt = new Account(Name = 'TestLastName',RecordTypeId=CusRecType);
        acc.add(Acnt);
        insert acc;
		
		list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '568980', Site_Address_zipcode__c = '412578', 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
		
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id, AccountId__c = acc[0].Id,Weightage_Basement__c=3,
									Weightage_Electrification_Sanitation__c=3,Weightage_Excavaton_of_Footings__c=1,Weightage_Finishing__c=5,
									Weightage_Masonary__c=6,Weightage_RCC_Slab_Casting__c=4, FTR_File_Path__c = 'Test Path');
		customerProjectlist.add(cp);
		insert customerProjectlist;
		
		//start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_DTRLoadPage
		PageReference dtrLoad = Page.RBI_DTRLoadPage;
		System.Test.setCurrentPage(dtrLoad);
		
		//Instantiate the class which is used in the page above
		apexpages.currentpage().getparameters().put('projectId' , projlist[0].Id);
		apexpages.currentpage().getparameters().put('ProjectName' , projlist[0].Project_Name__c);
		apexpages.currentpage().getparameters().put('custprojectid' , customerProjectlist[0].Id);
		pth = apexpages.currentpage().getparameters().put('FTRpath' , customerProjectlist[0].FTR_File_Path__c);
		RBI_DTRLoad rbiDtr = new RBI_DTRLoad();
		
		rbiDtr.FTRpath = null;
		rbiDtr.disframe = false;
		rbiDtr.gotoReport();
		
		AWS_S3_ExampleController awscon = new AWS_S3_ExampleController();
		rbiDtr.FTRpath = awscon.AWSLogin(customerProjectlist[0].FTR_File_Path__c, bktname);
		rbiDtr.FTRpath =  customerProjectlist[0].FTR_File_Path__c;
		rbiDtr.disframe = true;
		PageReference deTechPDF = Page.RBI_Detail_Technical_Report_PDF;
		System.Test.setCurrentPage(deTechPDF);
		rbiDtr.gotoReport();
		
		//Stop the Test Class
		System.Test.stopTest();
	}
}