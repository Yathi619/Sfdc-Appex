public with sharing class ProjectTowerExt {

	public Project__c Pro;
	public Tower__c tow;

	public ProjectTowerExt(ApexPages.StandardController std){
		this.Pro=(Project__c)std.getRecord();
		
		
	}
	
	public pagereference addTower(){
		tow=new Tower__c();
		tow.Name='needs to be changed';
		tow.Project__c=Pro.Id;                  
		insert tow;	
		return null;
	}
	/* public pagereference save() //To override the save method
    {
    	
        PageReference pg = new PageReference('/apex/ProjectTowerExtension');
		    pg.getParameters().put('id', 'pro.Id');
		    update Pro;
		    return pg;
		
	} */
}