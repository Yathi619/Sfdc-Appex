public with sharing class PositionEmplWebsiteController {

public string poid {get;set;}
public string poname {get;set;}
public boolean disp {get;set;}

public PositionEmplWebsiteController( Apexpages.Standardcontroller std)
{
	poid=System.currentPageReference().getParameters().get('posid');
	poname=System.currentPageReference().getParameters().get('posname');
	disp=false;
	
}

public void openPopUp()
{
	disp=true;
}
public void closepopup()
{
	disp=false;
}

}