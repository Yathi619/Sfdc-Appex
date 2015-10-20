public with sharing class DisplayCandidatesUsingWrapper 
{

    public PageReference getselected() {
        return null;
    }


    public list <Canwrap> canlist {get;set;}
    public list<Candidate__c> SelectedCandidates=new list<Candidate__c>();
    
        
    public void DisplayCandidates()
    {
        canlist=new list<Canwrap>();
       
        for(Candidate__c c :[select id,Name,Full_Name__c from Candidate__c])
        canlist .add(new Canwrap(c));
    }
    
    public class Canwrap
    {
        public Boolean selected {get;set;}
        public Candidate__c can {get;set;}
        
        public Canwrap(Candidate__c c)
        {
            can=c;
            selected=false;
        }
        
        
    }

}