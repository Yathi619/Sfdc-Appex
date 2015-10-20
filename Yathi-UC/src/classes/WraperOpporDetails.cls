public with sharing class WraperOpporDetails {
 
  public list<wrapperclas> opplist {get;set;}
  public list <Opportunity> selectedopportunity=new list<Opportunity>();
  
  public string optid{get;set;}
  

    public void oppDetails()
    {
    	opplist=new list<wrapperclas>();
    	for(Opportunity o : [select id,name,CloseDate,StageName from Opportunity] )
    	opplist.add(new wrapperclas(o));
    }
    
    public void getSelected()
    {
    	selectedopportunity.clear();
        for(wrapperclas wrap :opplist)
        if(wrap.selected==true)
        selectedopportunity.add(wrap.opp);
    	
    }
    public list<Opportunity> getSelectedOpportunity()
    {
    	if(selectedopportunity.size()>0)
    	return selectedopportunity;
    	else
    	return null;
    }
    public void RemoveRecord()
    {
    	for(wrapperclas oppt :opplist)
    	{
    		if(oppt.opp.id==optid)
    		{
    			oppt.selected=false;
    		}
    	}
    	getselected();
    }
    
    
    
	public class wrapperclas
	{
		public Opportunity opp {get;set;}
		public Boolean selected {get;set;}
		
		public wrapperclas( Opportunity o)
		{
			opp=o;
			selected=false;
		}
	}

}