public with sharing class UniColStuExtension {

public string colId {get;set;}
public list <Student__c> studnt {get;set;}

public UniColStuExtension( ApexPages.Standardcontroller strdcon)
{
	studnt=new list<Student__c>();
 
}
public void populateStudent()
{
	studnt=[select Name,Address__c,College__c,Date_Of_Birth__c,Fees__c from Student__c where College__c=: colId];
	System.debug('AAA' + colId);
	
}

}