global with sharing class AngularDemoController {

    // hardcode an account id for demo purposes
   // static String posId = 'a00280000020S7p';
   

	static string posId;

    global AngularDemoController(){
    
        posId = ApexPages.currentPage().getParameters().get('posId');
   
   
   
}
    global static String getAccount() {
        return JSON.serialize([select id,name
            from Position__c where id = :posId][0]);
    }    

    global static String getContacts() {
        return JSON.serialize([select id,name
            from Job_Application__c where Position__c = :posId]);
    }

}