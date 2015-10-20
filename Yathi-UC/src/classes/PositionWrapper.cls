public with sharing class PositionWrapper {
	public list <WrapperPosition> wrapposlst{get;set;}
	public list <Position__c> poslst{get;set;}
	public string posid {get;set;}
//public Id posid{get;set;}


//public list <WrapperPosition> getPos() replaced by the below code
public pagereference DisposList()
{
wrapposlst=new list<WrapperPosition>();
for(Position__c p :[select Id,name,Max_Pay__c from Position__c])
wrapposlst.add(new WrapperPosition(p));
return null;
//return wrapposlst;  -- replaced by the above code segment as the return type is Pagereference
}

//Add Selected is just a list of Positions ..no inputchceckbox
public void AddSelected()
{
	poslst=new list<Position__c>();
	//looping through wrapperposition list and dropping the selected (WrapperPosition is object type) position record to the poslist variable
	for(WrapperPosition wp :wrapposlst)
	{
		if(wp.selected==true)
		{
			poslst.add(wp.po);
			//p has position record of type wrapper and po is of type Position__c...so adding record to poslst
			system.Debug('DDD'+poslst);
		}
	}
	
}
   //Here we need to unselect the wrapper position list that gets reflected in the position list
	public void RemoveRec()
	{
		for(WrapperPosition wr :wrapposlst)
		{
			if(wr.po.Id==posid)
			{
				wr.Selected=false;
				
			}
		}
		AddSelected();
	}

	public class WrapperPosition
	{
		public Position__c po{get;set;}
		public Boolean Selected{get;set;}
	
		public WrapperPosition(Position__c p)
		{
			po=p;
			Selected=false;
		}
	}

}