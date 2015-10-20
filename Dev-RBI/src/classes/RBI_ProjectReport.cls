public class RBI_ProjectReport {
    public list<RecordType> Reclist;
    public list<Tower__c> towList {get;set;}
    public list<Visit__c> visitlist {get;set;}
    public String projName{get; set;}
    public String projAddress{get; set;}
    public String DevName{get; set;}
    public String DevAddress{get; set;}
    public String Constatus{get; set;}
    public String visitIdFromURL = '';
    public ApexPages.StandardController std;
    
    public void RBI_ProjectReport (ApexPages.StandardController stdcontroller)
    {
     stdcontroller=std;
      QueryVisit();
      visitIdFromURL = ApexPages.currentPage().getParameters().get('Id');
    }
    
    public void QueryVisit()
    {
        
        visitlist= new list<Visit__c>();
        Reclist =[Select SobjectType, Name, DeveloperName From RecordType where SobjectType ='Visit__c' AND DeveloperName='Followup'];
        visitlist=[Select  Tower__c, Surveyor__c, Status__c, Start_Date__c, Sold_Units__c, RecordTypeId, Project__c, Project__r.id,Project__r.Contact_Person__r.Name, Project__r.Developer_Address__c,Project__r.License_Registration_Number__c,Project__r.Name_of_the_Municipal_Corporation__c,Project__r.Plot_Area__c,Project__r.construction_Status__c,Project__r.Construction_Start_Date__c, Project_Name__c, Project_Address__c,   Min_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sqft__c, Max_Avg_Resale_Price_Per_Sqft__c, Max_Avg_Developer_BSP_per_Sqft__c, Legal_Agency__c, Launched_Units__c,Id, Developer_Name__c ,Construction__c  From Visit__c where id=:visitIdFromURL AND RecordTypeId=:Reclist[0].Id ];
        system.debug('the visitlist'+visitlist);
        projName=visitlist[0].Project_Name__c;
        projAddress=visitlist[0].Project_Address__c;
        DevName= visitlist[0].Developer_Name__c;
        DevAddress=visitlist[0].Project__r.Developer_Address__c;
        
        
        
        
    }

}