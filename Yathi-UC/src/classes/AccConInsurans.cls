public with sharing class AccConInsurans {

//public string AccName {get;set;}
public string ConName {get;set;}
public list <Insurance_Policy__c> ins {get;set;}

//string query;
set <string> conid=new set<string>();
//set <string> accid=new set<string>();

list <Contact> con=new list<Contact>();
//list <Account> acc=new list<Account>();
//list <Insurance_Policy__c> ins1=new list<Insurance_Policy__c>();

//list <Contact> con1=new list<Contact>();

public list<Insurance_Policy__c> getins()
{
    return ins;
}


public void searchAccount()
{
        ins = new list<Insurance_Policy__c>();
        if(ConName != null)
        {
            list<Contact> con =new list<Contact>([select id from Contact where LastName like :ConName ]);
            for(Contact c : con)
            {
                conid.add(c.Id);
            }
            ins=[SELECT Id,Name, Contact__r.FirstName,Contact__r.LastName,Policy_Amount__c FROM Insurance_Policy__c where Contact__c = :conid];
        }   
        
       
        else{
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Please enter a value to search');
            ApexPages.addMessage(errorMessage);  
            }
}   
    
}