/*
    Type:       Custom Controller
    Purpose:    Used to generate the TSR, DVU for a Customer from Customer Portal.        

    Used By:   RBI_DVUTSRLoad.page
    ---------------------------------------------------------------
    History:

    26-Apr-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_DVUTSRImageLoad {
	public AWS_S3_Object__c reportimg{get; set;}  
	public boolean norecordsflg {get; set;}// to indicate no dvu tsr images 
	public string qrystring {get; set;}	
	string projid;
	string reportname;
	list <AWS_S3_Object__c> reportimglst;
	public S3.AmazonS3 as3l {get;set;}
	public RBI_DVUTSRImageLoad(){
        projid  	= ApexPages.currentPage().getParameters().get('ProjectId');	
        reportname  = ApexPages.currentPage().getParameters().get('rptName');
        AWS_S3_ExampleController awscontroller = new AWS_S3_ExampleController();
        as3l = awscontroller.as3;
		reportimg = new AWS_S3_Object__c();
		norecordsflg = false;
		reportimglst  = new list <AWS_S3_Object__c>();
		reportimglst = [select id,bucket_name__c,content_type__c, file_name__c, access__c,Project__c,Tower__c,Tower__r.Name,Tower__r.Project__c,Preview_Link__c,imageurl__c, Report_Type__c, Report_Name_Calc__c from AWS_S3_Object__c where Project__c =: projid and Report_Name_Calc__c =:reportname];
		if(reportimglst != null && reportimglst.size()>0){
			reportimg = reportimglst[0];
			qrystring = awscontroller.AWSLogin(reportimglst[0].file_name__c, reportimglst[0].bucket_name__c);
			norecordsflg = false;
		}
		else{
			norecordsflg = true;
		}
	}
	
   @IsTest(SeeAllData=true)  
    static  void RBI_DVUTSRImageLoadTest() {
    	
    	list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Launch_Date__c = System.today(), Brochure_Zipcode__c = '568980', 
										 Site_Address_City__c = 'Bangalore', Site_Address_zipcode__c = '412578');
		projlist.add(proj);
		insert projlist;
		
		list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
		List_of_Values__c lov = new List_of_Values__c(Name='DVU Report', Entity_Name__c='CRM Report',Entity_Type__c='/apex/RBI_DVUTSRImageLoad?ProjectId=',Key__c='DVU Report',Value__c='DVU');
		
		lovlist.add(lov);
		insert lovlist;
		
		list<CRM_Report__c> crmlist = new list<CRM_Report__c>();
		CRM_Report__c cr = new CRM_Report__c(Report_Name__c=lov.Id, Project__c = proj.Id,
										 Status__c ='completed');
		crmlist.add(cr);
		insert crmlist;

		list<AWS_S3_Object__c> Awlist = new list<AWS_S3_Object__c>();
		AWS_S3_Object__c aw = new AWS_S3_Object__c(Bucket_Name__c='testbucket',Content_Type__c='pdf', Project__c = proj.Id, Report_Type__c='DVU',file_name__c='testfile');
		Awlist.add(aw);
		insert Awlist;
		
		//start test class method
       	System.Test.startTest();
       	//Instantiate the RBI_RBI_DVUTSRImageLoad which generates the PDF
		PageReference DVUimageLoad = Page.RBI_DVUTSRImageLoad;
		System.Test.setCurrentPage(DVUimageLoad);
		apexpages.currentpage().getparameters().put('ProjectId' , projlist[0].Id);
		apexpages.currentpage().getparameters().put('rptName' , lov.Name);
		//instantiate the class
		RBI_DVUTSRImageLoad loadImg = new RBI_DVUTSRImageLoad();
   		loadImg.projid = apexpages.currentpage().getparameters().put('ProjectId' , projlist[0].Id);
       	loadImg.reportname = apexpages.currentpage().getparameters().put('rptName' , lov.Name);
     	
     	AWS_S3_ExampleController awscontroller = new AWS_S3_ExampleController();
     	loadImg.qrystring=awscontroller.AWSLogin(Awlist[0].Bucket_Name__c, Awlist[0].file_name__c);
       	
       	//stop the test class
       	System.Test.stopTest();
    }
}