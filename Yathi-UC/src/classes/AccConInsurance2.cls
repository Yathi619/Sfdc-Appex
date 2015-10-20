public with sharing class AccConInsurance2 {

	public string AccName {get;set;}
	public string ConName {get;set;}
	list <Insurance_Policy__c> inslst;
	string querystring;
	
	public list <Insurance_Policy__c> getins()
	{
		return inslst;
	}

	public void AccConSearch()
	{
		if(ConName !='')
		{
			querystring='select id,Name,contact__r.Name,Contact__r.FirstName,contact__r.Account.Name,Contact__r.LastName from Insurance_Policy__c where Contact__r.Name LIKE \'%'+ConName+'%\'';
			inslst=database.query(querystring);
		}
		else if(AccName !='')
		{
			querystring='SELECT contact__r.id,contact__r.accountid,contact__r.name,contact__r.Account.Name,Name,Policy_Amount__c FROM Insurance_Policy__c where contact__r.Account.Name LIKE \'%' +AccName +'%\'';
			inslst=database.query(querystring);
		}
		else if(AccName =='' && ConName =='')
		{
			querystring='SELECT contact__r.id,contact__r.accountid,contact__r.name,contact__r.Account.Name,Name,Policy_Amount__c FROM Insurance_Policy__c where contact__r.Account.Name  LIKE  \'%' +AccName +'%\'';
			inslst=database.query(querystring);
		}
		if(inslst.size()==0)
		{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter A/C Name'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ErrorLabel));
		}
	}
	
}