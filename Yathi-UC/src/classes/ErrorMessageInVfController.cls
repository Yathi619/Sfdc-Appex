public with sharing class ErrorMessageInVfController {
public Account acc {get;set;}

	public ErrorMessageInVfController(ApexPages.StandardController controller)
	{
		acc=new Account();
	}
	public void save()
	{
		if(acc.name=='' || acc.name==null)
		 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter Account name'));
		
		if(acc.AccountNumber=='' || acc.AccountNumber==null)
		Apexpages.addMessage(new Apexpages.Message( Apexpages.Severity.ERROR, 'Please enter Account number' ));
		
		
		if(acc.Phone=='' || acc.Phone==null)
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Warning,'Please enter Phone number'));
		
		if(acc.Site==''|| acc.Site==null)
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'Please enter the Account Site'));
	
		if(acc.Industry=='' || acc.Industry==null)
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Confirm,'Please ente the Account Industry'));
	}
}