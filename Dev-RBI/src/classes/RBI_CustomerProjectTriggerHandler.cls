public with sharing class RBI_CustomerProjectTriggerHandler {
	public static boolean firstRun = true;
	public ID  CusRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer'].Id;
	public ID RbiRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RBI'].Id;
	public list<Account> Acclist=[Select Id , Weightage_Electrification_Sanitation__c,Weightage_Basement__c,
	                    Weightage_Excavaton_of_Footings__c, Weightage_Finishing__c,
	                    Weightage_RCC_Slab_Casting__c,RecordTypeId,Weightage_Masonary__c from Account WHERE RecordTypeId=:RbiRecType OR RecordTypeId=:CusRecType];
	     
                    
	// Before Insert Trigger
	public void OnBeforeInsert(list<Customer_Projects__c> Cusprojectlist){ 
		if(Cusprojectlist!=null && Cusprojectlist.size()>0){
			for(Customer_Projects__c cusproj : Cusprojectlist){
		    	for(Account Acc : Acclist){
			    	if((cusproj.Weightage_Type__c == 'Realty BI') && (Acc.RecordTypeId==RbiRecType)) {
				    	cusproj.Weightage_Basement__c=Acc.Weightage_Basement__c;
				        cusproj.Weightage_Electrification_Sanitation__c=Acc.Weightage_Electrification_Sanitation__c;
				        cusproj.Weightage_Excavaton_of_Footings__c=Acc.Weightage_Excavaton_of_Footings__c;
				        cusproj.Weightage_Finishing__c=Acc.Weightage_Finishing__c; 
				        cusproj.Weightage_RCC_Slab_Casting__c=Acc.Weightage_RCC_Slab_Casting__c;
				        cusproj.Weightage_Masonary__c=Acc.Weightage_Masonary__c; 
					}
		            else if((cusproj.Weightage_Type__c == 'Customer') && (Acc.RecordTypeId ==CusRecType) && (Acc.Id == cusproj.AccountId__c)) { 
		            	cusproj.Weightage_Basement__c=Acc.Weightage_Basement__c;
				        cusproj.Weightage_Electrification_Sanitation__c=Acc.Weightage_Electrification_Sanitation__c;
				        cusproj.Weightage_Excavaton_of_Footings__c=Acc.Weightage_Excavaton_of_Footings__c;
				        cusproj.Weightage_Finishing__c=Acc.Weightage_Finishing__c; 
				        cusproj.Weightage_RCC_Slab_Casting__c=Acc.Weightage_RCC_Slab_Casting__c;
				        cusproj.Weightage_Masonary__c=Acc.Weightage_Masonary__c;
		            }
		        }
		    }
		}
	}
	//OnBeforeUpdate trigger
	public void OnBeforeUpdate(list<Customer_Projects__c> CusprojectNew, list<Customer_Projects__c> CusprojectOld, Map<Id, Customer_Projects__c> ObjectMap){
		for(Customer_Projects__c cusprj : CusprojectNew){
			if(cusprj.Id == ObjectMap.get(cusprj.Id).Id && ObjectMap.get(cusprj.Id).Weightage_Type__c != cusprj.Weightage_Type__c){
				for(Account Acc1 : Acclist){
			    	if((cusprj.Weightage_Type__c == 'Customer') && (cusprj.AccountId__c==Acc1.Id) && (Acc1.RecordTypeId ==CusRecType) ) { 
				    	cusprj.Weightage_Basement__c=Acc1.Weightage_Basement__c;
				        cusprj.Weightage_Electrification_Sanitation__c=Acc1.Weightage_Electrification_Sanitation__c;
				        cusprj.Weightage_Excavaton_of_Footings__c=Acc1.Weightage_Excavaton_of_Footings__c;
				        cusprj.Weightage_Finishing__c=Acc1.Weightage_Finishing__c; 
				        cusprj.Weightage_RCC_Slab_Casting__c=Acc1.Weightage_RCC_Slab_Casting__c;
				        cusprj.Weightage_Masonary__c=Acc1.Weightage_Masonary__c;
			        }
			        else if((cusprj.Weightage_Type__c == 'Realty BI') && (Acc1.RecordTypeId==RbiRecType)) {
			        	cusprj.Weightage_Basement__c=Acc1.Weightage_Basement__c;
			            cusprj.Weightage_Electrification_Sanitation__c=Acc1.Weightage_Electrification_Sanitation__c;
			            cusprj.Weightage_Excavaton_of_Footings__c=Acc1.Weightage_Excavaton_of_Footings__c;
			            cusprj.Weightage_Finishing__c=Acc1.Weightage_Finishing__c; 
			            cusprj.Weightage_RCC_Slab_Casting__c=Acc1.Weightage_RCC_Slab_Casting__c;
			            cusprj.Weightage_Masonary__c=Acc1.Weightage_Masonary__c;
			        }
		        }
			}
		}
	}
}