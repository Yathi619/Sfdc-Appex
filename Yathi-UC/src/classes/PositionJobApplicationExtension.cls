public with sharing class PositionJobApplicationExtension {

public string posid{get;set;}
public string posname{get;set;}
public boolean display {get;set;}

public Job_Application__c jobid;

public PositionJobApplicationExtension( ApexPages.StandardController std)
{
    
    posid=System.currentPageReference().getParameters().get('poid');
    posname=System.currentPageReference().getParameters().get('poName');
    jobid=(Job_Application__c)std.getRecord();
    system.debug('yathi'+jobid.Id);
    display=false;
}

  public Pagereference save()
  {
    jobid.Position__c='a0028000002O5fk';
    
    insert jobid;
    system.debug('yathi'+jobid.Position__c);
    Pagereference pg=new Pagereference('/' +posid);
    return pg;
  }
  public void cancel()
  {
  	Pagereference pg=new Pagereference('/' +posid);
  
  }
  public Pagereference saveNew()
  {
  	jobid.Position__c=posid;
  	insert jobid;
  	Pagereference pg=new Pagereference('/apex/PosJobController?poid=' + posid +  '&poName='   +posname);
  	pg.setRedirect(true);
  	return pg;
  }
  public void openpopup()
	{
		display=true;
	}
	public void closepopup()
	{
		display=false;
	}
 
}