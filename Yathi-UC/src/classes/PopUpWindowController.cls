public with sharing class PopUpWindowController {
	
	public boolean display {get;set;}
	
	PopUpWindowController( ApexPages.Standardcontroller std)
	{
		display=false;
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