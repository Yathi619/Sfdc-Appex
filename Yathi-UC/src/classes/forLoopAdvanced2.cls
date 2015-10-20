public with sharing class forLoopAdvanced2 {

public List <Position__c> poslist{get;set;}
public Position__c pos1;
public Position__c pos2;
public Position__c pos3;

public list <position__c> pos =new List<Position__c>();

integer i=0;

public forLoopAdvanced2( Apexpages.Standardcontroller std)
{   
	
	
	poslist=new list<Position__c>();
	
	pos[0]=new Position__c(id='a00280000020Vtc', name='system ananlyst');
	pos[1]=new Position__c(id='a00280000020Vtc', name='system admin');
    pos[2]=new Position__c(id='a00280000020S7p', name='system engineer');
	
	//pos1=new Position__c(id='a00280000020SBM',name='system ananlyst');
	//pos2=new Position__c(id='a00280000020Vtc',name='system admin');
	//pos3=new Position__c(id='a00280000020S7p',name='system engineer');
	
	poslist.addall(pos);
	//poslist.add(pos1);
	//poslist.add(pos2);
	//poslist.add(pos3);
	
	for(Position__c loopPos : poslist )
	{
		
    	system.debug('loopPos'+i +loopPos);
    	i++;
    }

	
     
	}
			

}