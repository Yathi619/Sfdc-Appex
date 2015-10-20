/*
    Type:       Custom Controller Extension 
    Purpose:    Used to preview aws s3 image file in emp application
    Used By:    s3Preview.page
    ---------------------------------------------------------------
    History:

    26-Apr-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_s3PreviewExtn {
	
	public ApexPages.StandardController sController;	
	AWS_S3_Object__c s3obj;	
	public String qrystring {get; set;}
	
	public RBI_s3PreviewExtn(ApexPages.StandardController stdCon){
		sController = stdCon;
		this.s3obj=(AWS_S3_Object__c)stdCon.getRecord();
		AWS_S3_ExampleController awscontroller = new AWS_S3_ExampleController();
		qrystring = '';
		qrystring = awscontroller.AWSLogin(s3obj.file_name__c, s3obj.bucket_name__c);
	}
}