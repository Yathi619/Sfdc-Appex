public with sharing class VFComparisonController {
 public List<account> listOfAccounts{get;set;}
  public String name {get;set;}
        
  public PageReference getAccountsByName(){
   listOfAccounts=[select id, name from Account where Name = :name];
   return null;
  } 
}