public with sharing class RBI_UtilClass {
     public static List<selectOption> getPickValues(Sobject object_name, String field_name, String first_val) 
     {
      /*new list for holding all of the picklist options*/
      List<selectOption> options = new List<selectOption>();
      /*if there is a first value being provided*/ 
      if (first_val != null) { 
         /*add the first option*/
         options.add(new selectOption(first_val, first_val)); 
      }
      /*grab the sobject that was passed*/
      Schema.sObjectType sobject_type = object_name.getSObjectType();
      /*describe the sobject*/ 
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
      /*get a map of fields for the passed sobject*/ 
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
      /*grab the list of picklist values for the passed field on the sobject*/ 
      List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues();
      /*for all values in the picklist list*/ 
      for (Schema.PicklistEntry a : pick_list_values) {
         /*add the value and label to our final list*/   
         options.add(new selectOption(a.getLabel(), a.getValue())); 
      }
      /*return the List*/
      return options; 
   }
   /*given a list of SObjects, return a set of ids*/
    public static Set<Id> setOfIdFromListOfSObject ( List<SObject> oList ) {
        Set<Id> Ids = new Set<Id> {};
        for (SObject o : oList) {
            Ids.add( o.id );
        }
        return Ids;
    }
   /*Used to calculate construction status based on wieghtage and total towers*/
    public static Double calculateconststatus(Construction_Status__c objConststat, Customer_Projects__c objwieghts, Integer totalfloors, Integer totalrescommfloors) {
        Double totalconststatus = 0.0;
        Decimal  eoftval = 0,// for Excavaton of Footings
                baseval = 0; // for Basement
        Decimal rrcslabval      = 0.0,//for RCC Slab Casting
                masonaryval     = 0.0,//for Masonary 
                elecval         = 0.0, //for Electrification and Sanitation
                finishingval    = 0.0; // for finishing
                
         if(objConststat.Basement__c == 'UC'){
            baseval = 0.50;
        }else if(objConststat.Basement__c == 'C'){
            baseval = 1.0;
        }else{
            baseval = 0.0;
        }
        
        if(objConststat.Excavation_of_Footings__c == 'UC'){
            eoftval = 0.5;
        }else if(objConststat.Excavation_of_Footings__c == 'C'){
            eoftval = 1.0;
        }else{
            eoftval = 0.0;
        }   
        rrcslabval   = (objConststat.RCC_Slab_Casting__c == null)?0:Double.valueof((objConststat.RCC_Slab_Casting__c).trim());
        masonaryval  = (objConststat.Masonary__c==null)?0:Double.valueof((objConststat.Masonary__c).trim());
        if(totalfloors == 0){
        	rrcslabval = 0;
        	masonaryval = 0;
        } else{       
        	rrcslabval   = (rrcslabval.divide(totalfloors, 2, System.RoundingMode.HALF_UP));
        	masonaryval  = (masonaryval.divide(totalfloors, 2, System.RoundingMode.HALF_UP));
        }
        elecval      = (objConststat.Electrification_and_Sanitation__c == null)?0:Double.valueof((objConststat.Electrification_and_Sanitation__c).trim());
        finishingval = (objConststat.Finishing__c == null)?0:Double.valueof((objConststat.Finishing__c).trim());
		if(totalrescommfloors == 0){
			elecval 	 = 0;
			finishingval = 0;
		}else{                
        	elecval      = (elecval.divide(totalrescommfloors, 2, System.RoundingMode.HALF_UP));
        	finishingval = (finishingval.divide(totalrescommfloors, 2, System.RoundingMode.HALF_UP));                 
		}
        totalconststatus = (baseval*(objwieghts.Weightage_Basement__c))+(eoftval*(objwieghts.Weightage_Excavaton_of_Footings__c));
        totalconststatus += (rrcslabval*(objwieghts.Weightage_RCC_Slab_Casting__c))+(masonaryval*(objwieghts.Weightage_Masonary__c));
        totalconststatus += (elecval*(objwieghts.Weightage_Electrification_Sanitation__c))+(finishingval*(objwieghts.Weightage_Finishing__c));
		system.debug('totalconststatus3 +'+totalconststatus);        
        return totalconststatus;    
        }  
 
    /*Used to calculate construction status, optimistic estimate, pessimistic estimate for unit report based on wieghtage and total towers*/
    public static String calcconststatus_unit(Construction_Status__c objConststat, Customer_Projects__c objwieghts, Integer totalfloors, Integer totalrescommfloors) {
        String retvalue = '';
        Double totalconststatus = 0.0;
        Decimal Minestimate		= 0.0;        
        Decimal Maxestimate      = 0.0;        
        Decimal  eoftval = 0,// for Excavaton of Footings
                baseval = 0; // for Basement
        Decimal rrcslabval      = 0.0,//for RCC Slab Casting
                masonaryval     = 0.0,//for Masonary 
                elecval         = 0.0, //for Electrification and Sanitation
                finishingval    = 0.0; // for finishing
		//Used for calculating Min max estimates                
		Decimal eoftvalmin= 0.0,
				eoftvalmax= 0.0,
				rrcslabvalmin= 0.0,
				rrcslabvalmax= 0.0,
				basevalmin= 0.0,
				basevalmax= 0.0,
				masonaryvalmin= 0.0,
				masonaryvalmax= 0.0,
				elecvalmin= 0.0,
				elecvalmax= 0.0,
				finshngvalmin= 0.0,
				finshngvalmax= 0.0;                 
                
         if(objConststat.Basement__c == 'UC'){
            baseval = 0.50;
        }else if(objConststat.Basement__c == 'C'){
            baseval = 1.0;
        }else{
            baseval = 0.0;
        }
        
        if(objConststat.Excavation_of_Footings__c == 'UC'){
            eoftval = 0.5;
        }else if(objConststat.Excavation_of_Footings__c == 'C'){
            eoftval = 1.0;
        }else{
            eoftval = 0.0;
        }   
        rrcslabval   = (objConststat.RCC_Slab_Casting__c == null)?0:Double.valueof((objConststat.RCC_Slab_Casting__c).trim());
        masonaryval  = (objConststat.Masonary__c==null)?0:Double.valueof((objConststat.Masonary__c).trim());
        if(totalfloors == 0){
        	rrcslabval = 0;
        	masonaryval = 0;
        }
        else{
        rrcslabval   = (rrcslabval.divide(totalfloors, 2, System.RoundingMode.HALF_UP));
        masonaryval  = (masonaryval.divide(totalfloors, 2, System.RoundingMode.HALF_UP));
        }
        elecval      = (objConststat.Electrification_and_Sanitation__c == null)?0:Double.valueof((objConststat.Electrification_and_Sanitation__c).trim());
        finishingval = (objConststat.Finishing__c == null)?0:Double.valueof((objConststat.Finishing__c).trim());
		if(totalrescommfloors==0){
			elecval		= 0;
			finishingval = 0;
		}   
		else{             
        	elecval      = (elecval.divide(totalrescommfloors, 2, System.RoundingMode.HALF_UP));
        	finishingval = (finishingval.divide(totalrescommfloors, 2, System.RoundingMode.HALF_UP));                 
		}
        totalconststatus = (baseval*(objwieghts.Weightage_Basement__c))+(eoftval*(objwieghts.Weightage_Excavaton_of_Footings__c));
        totalconststatus += (rrcslabval*(objwieghts.Weightage_RCC_Slab_Casting__c))+(masonaryval*(objwieghts.Weightage_Masonary__c));
        totalconststatus += (elecval*(objwieghts.Weightage_Electrification_Sanitation__c))+(finishingval*(objwieghts.Weightage_Finishing__c));
		system.debug('totalconststatus3 +'+totalconststatus);
		eoftvalmin      = objConststat.Excavation_Min_Calc__c;
		eoftvalmax      = objConststat.Excavation_Max_Calc__c;
		basevalmin   	= objConststat.Basement_Construction_Min_Calc__c;
		basevalmax   	= objConststat.Basement_Construction_Max_Calc__c;
		rrcslabvalmin   = objConststat.RCC_Structure_Min_Calc__c;
		rrcslabvalmax   = objConststat.RCC_Structure_Max_Calc__c;
		masonaryvalmin  = objConststat.Masonary_Work_Min_Calc__c;
		masonaryvalmax  = objConststat.Masonary_Work_Max_Calc__c;
		elecvalmin   	= objConststat.Electrification_Sanitation_Min__c;
		elecvalmax   	= objConststat.Electrification_Sanitation_Max__c;		
		finshngvalmin   = objConststat.Finishing_Min_Calc__c;
		finshngvalmax   = objConststat.Finishing_Max_Calc__c;
		//Min estimate calculation
		Minestimate = (1-eoftval)*eoftvalmin+(1-baseval)*basevalmin+(1-rrcslabval)*rrcslabvalmin;
		Minestimate += (1-masonaryval)*masonaryvalmin+(1-elecval)*elecvalmin+(1-finishingval)*finshngvalmin;
		Minestimate = Minestimate.setscale(0,System.RoundingMode.DOWN);

		
		//Max estimate calculation		
		Maxestimate = (1-eoftval)*eoftvalmax+(1-baseval)*basevalmax+(1-rrcslabval)*rrcslabvalmax;
		Maxestimate += (1-masonaryval)*masonaryvalmax+(1-elecval)*elecvalmax+(1-finishingval)*finshngvalmax;
		Maxestimate = Maxestimate.setscale(0,System.RoundingMode.UP);
		system.debug('Maxestimate 3'+Maxestimate);				        
				
		retvalue = String.valueOf(totalconststatus)+','+String.valueOf(Minestimate)+','+String.valueOf(Maxestimate);
		system.debug('retvalue'+retvalue);        
        return retvalue;    
        }
	
	public static map<String, Id> getRecordTypeMap (String[] objNames) {
    //This method returns the RecordType map for the obj name specified. It can be for a single object or multiple objects
    // Pass the string as a String List eg. String[] objNames = new String[]{'Account','Contact'};
    
       map<String, Id> RTMap = new Map<String, Id>();
       for (RecordType RT : [Select Id, Name From RecordType where SobjectType IN :objNames AND IsActive = true]) {
            RTMap.put(RT.Name, RT.Id);
       }
       return RTMap;
  }
    
}