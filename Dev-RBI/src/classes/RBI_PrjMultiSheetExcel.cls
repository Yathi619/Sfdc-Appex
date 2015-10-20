public without sharing class RBI_PrjMultiSheetExcel {
    public RBI_DataModel dm {get;set;}
    public string inpprojectId;
    string projectId2;    
    public string xmlheader {get;set;}
	public integer rowcount {get;set;}	
    public string endfile{get;set;} 
    list<Project__c> ProjList;  
    list<Project_Feedback__c> ProjremList;
    list<Infrastructure_Near_Project__c> ProjinfraList;        
    list<Construction_Status__c> ConStatList;    
    list<Tower__c> TowList;
	Set <Id> projectId; 
	RBI_DataModel.Model model;   
    public RBI_PrjMultiSheetExcel(){
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';            	
    	inpprojectId = System.currentPagereference().getParameters().get('ProjId');
        dm 				= new RBI_DataModel();
        dm.data 		= new list<RBI_DataModel.Model>();
        ProjList 		= new list<Project__c>();   
        ProjremList 	= new list<Project_Feedback__c>();
        ProjinfraList 	= new list<Infrastructure_Near_Project__c>();
        ConStatList		= new list<Construction_Status__c>();
        system.debug('ProjremList');
		RBI_loadProjectData();
		
    }
    
   private void RBI_loadProjectData(){
   		//map<string,string> rowdata2;
   		String towname = '';
		String unitType = '';
		String noOfUnit;
		String cpparam;
		String builtparam;
		String superbuiltparam;
		//String archname;
		
		map<string,string> rowdata;
		map<string,string> rowdata1;
		map<string,string> rowdata2;
 		ProjList 		  =  [SELECT 
	  							construction_Status__c, TDR_Permitted__c, Site_Address_Landmark__c, Site_Address_City__c,
	  							Project_Type__c,Project_Name__c, Project_LatLong__Longitude__s, Project_LatLong__Latitude__s, 
	  							Plot_Area__c, Name_of_the_Municipal_Corporation__c, Name, License_Registration_Number__c, 
	  							Launch_Date__c, Id, FAR_constructed__c, FAR_Approved_as_per_Plan__c, Developer_Name__c,
	  							Developer_Correspondence_Address__c, Construction_Start_Date__c, Commercial_Area_No_of_shops__c, 
	  							Architect_Name__c, Architect_Contractor_Address__c, Architect_s_Registration_Number__c, Aerobic_Spa__c, Amphitheatre__c, Badminton_Court__c, 
	  							Basketball_Post__c, Children_Play_Area__c, Clubhouse__c, Gymnasium__c, Landscaped_Pathway__c,
	  							Party_Lawn__c, Senior_Citizen_Facilities__c, Sports_Area__c, Swimming_Pool__c, Tennis_Court__c,
	  							//added by legend on 16/10/2013
	  							Site_Address_Line_1__c, Site_Address_Line_2__c, Site_Address_zipcode__c, Site_Address_State__c,
	  							Developer_Bank_AC_No__c,Developer_Bank_Name__c,Project_Locality__c,Site_Visit_Date__c
	  							//ended adding
  							 FROM Project__c 
  							 WHERE
  							Id =:inpprojectId]; 		
 		
        ProjremList		  = [Select Type__c, Remark_Type__c, List_of_Values_Id__r.Name,Id,Comments__c From Project_Feedback__c where Project__c =:inpprojectId];
        //system.debug(LoggingLevel.ERROR,'ProjremList');
        
        ProjinfraList	  = [SELECT Status__c, Project_Id__c, Infrastructure_Near_Project__r.Name,Infrastructure_Nr_Project__c, Distance_From_Project_In_Km__c 
							FROM Infrastructure_Near_Project__c WHERE Project_Id__c =:inpprojectId];    
            
       	model 			  = new RBI_DataModel.Model();	
        model.sheetname   = 'Project';
        model.headers 	  = new list<string>{'Key','Project Id','Name','Address Line 1','Address Line 2','City','State','Zip Code',
        									 'Developer','Developer Address','Developer Bank A/c No.','Developer Bank Name',
        									 'Architect Name','Architect Address','Registration Number',
        									 'Landmark','Name of Muncipal Corporation','Licence Registration No.','Project Type','Project Locality',
        									 'Plot Area','FAR Approved as per Plan','FAR Constructed',
        									 'TDR Approved','Construction Status','Launch Date','Last Visit Date','Construction Start Date','LatLong'};
        model.data 		    = new list<map<string,string>>();
        model.prjremdata    = new list<map<string,string>>();
        model.prjamntydata  = new list<map<string,string>>();
        model.prjinfradata  = new list<map<string,string>>();        
        model.prjremheader  = new list<string>{'Feedback','Comments','Type'};  
        model.prjamntyheader= new list<string>{'Amenity Type','Amenity Status'};         
        model.prjinfraheader= new list<string>{'Facility','Status', 'Distance'};
        for(Project__c p: ProjList){
            rowdata  		= new map<string,string>();
            rowdata.put('Key',p.Id);
            rowdata.put('Project Id',p.Name);            
            rowdata.put('Name',p.Project_Name__c);
            rowdata.put('Address Line 1',p.Site_Address_Line_1__c);//Added by AC
            rowdata.put('Address Line 2',p.Site_Address_Line_2__c);//Added by AC
            rowdata.put('City',p.Site_Address_City__c);
            rowdata.put('State',p.Site_Address_State__c);//Added by AC
            rowdata.put('Zip Code',p.Site_Address_zipcode__c);//Added by AC
            rowdata.put('Developer',p.Developer_Name__c); 
	    	rowdata.put('Developer Address',p.Developer_Correspondence_Address__c);
	    	rowdata.put('Developer Bank A/c No.',p.Developer_Bank_AC_No__c);//Added by AC
	    	rowdata.put('Developer Bank Name',p.Developer_Bank_Name__c);//Added by AC
	    	rowdata.put('Architect Name',p.Architect_Name__c);	    
	    	rowdata.put('Architect Address',p.Architect_Contractor_Address__c);	    
	    	rowdata.put('Registration Number',p.Architect_s_Registration_Number__c);
        	rowdata.put('Landmark',p.Site_Address_Landmark__c);
	    	rowdata.put('Name of Muncipal Corporation',p.Name_of_the_Municipal_Corporation__c);
	    	rowdata.put('Licence Registration No.',p.License_Registration_Number__c);
	    	rowdata.put('Project Type',p.Project_Type__c);
	    	rowdata.put('Project Locality',p.Project_Locality__c);//Added by AC
	    	//rowdata.put('If Mixed, Commercial Area',string.valueOf(p.Commercial_Area_No_of_shops__c));
	    	rowdata.put('Plot Area',string.valueOf(p.Plot_Area__c));
	    	rowdata.put('FAR Approved as per Plan',string.valueOf(p.FAR_Approved_as_per_Plan__c));
	    	rowdata.put('FAR Constructed',string.valueOf(p.FAR_constructed__c));
	    	rowdata.put('TDR Approved',string.valueOf(p.TDR_Permitted__c));
	    	rowdata.put('Construction Status',p.construction_Status__c);
	    	rowdata.put('Launch Date',string.valueOf(p.Launch_Date__c));
	    	rowdata.put('Last Visit Date',string.valueOf(p.Site_Visit_Date__c));
	    	rowdata.put('Construction Start Date',string.valueOf(p.Construction_Start_Date__c));
	    	rowdata.put('LatLong',string.valueOf(p.Project_LatLong__Latitude__s)+string.valueOf(p.Project_LatLong__Longitude__s));
	    	for(string mapkey : rowdata.keySet()){
	    			if(rowdata.get(mapkey) == null || rowdata.get(mapkey) == ''){
	    				//system.debug('AAAAA'+mapkey);
	    				rowdata.put(mapkey,'-');
	    			}
	    			
	    	}
	    	//system.debug('rowdata'+rowdata);
           	model.data.add(rowdata);
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Aerobic Spa','Amenity Status'=>string.valueOf(p.Aerobic_Spa__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Amphitheatre','Amenity Status'=>string.valueOf(p.Amphitheatre__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Badminton Court','Amenity Status'=>string.valueOf(p.Badminton_Court__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Basketball Court','Amenity Status'=>string.valueOf(p.Basketball_Post__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Play Area','Amenity Status'=>string.valueOf(p.Children_Play_Area__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Clubhouse','Amenity Status'=>string.valueOf(p.Clubhouse__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Gymnasium','Amenity Status'=>string.valueOf(p.Gymnasium__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Landscaped Pathway','Amenity Status'=>string.valueOf(p.Landscaped_Pathway__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Party Lawn','Amenity Status'=>string.valueOf(p.Party_Lawn__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Senior Citizen Facilities','Amenity Status'=>string.valueOf(p.Senior_Citizen_Facilities__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Sports Area','Amenity Status'=>string.valueOf(p.Sports_Area__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Swimming Pool','Amenity Status'=>string.valueOf(p.Swimming_Pool__c)});
			model.prjamntydata.add(new Map<string,string>{'Amenity Type'=>'Tennis Court','Amenity Status'=>string.valueOf(p.Tennis_Court__c)});
		}    
	     dm.data.add(model);
	    // model.prjamntydata.add(rowdata2);		
	     
	     //project remarks data
		for(Project_Feedback__c fdbk: ProjremList){
   			rowdata1 = new map<string,string>();
    		rowdata1.put('Feedback',fdbk.List_of_Values_Id__r.Name);
    		rowdata1.put('Comments',fdbk.Comments__c);
    		rowdata1.put('Type',fdbk.Type__c);
	    	for(string mapFkey : rowdata1.keySet()){
	    			if(rowdata1.get(mapFkey) == null || rowdata1.get(mapFkey) == ''){
	    				rowdata1.put(mapFkey,'-');
	    			}
	    			
	    	}    		
    		model.prjremdata.add(rowdata1);
 		}

	    //project infrasructure data
		for(Infrastructure_Near_Project__c prjinfrs: ProjinfraList){
   			rowdata2 = new map<string,string>();
    		rowdata2.put('Facility',prjinfrs.Infrastructure_Near_Project__r.Name);
    		rowdata2.put('Status',prjinfrs.Status__c);
    		rowdata2.put('Distance',prjinfrs.Distance_From_Project_In_Km__c);
	    	for(string mapIkey : rowdata2.keySet()){
	    			if(rowdata2.get(mapIkey) == null || rowdata2.get(mapIkey) == ''){
	    				rowdata2.put(mapIkey,'-');
	    			}
	    			
	    	}    		
    		model.prjinfradata.add(rowdata2);
 		}
 		 		
	    //Tower data	  	
	    	TowList = new list<Tower__c>();
	    	TowList = [SELECT Total_Units__c, Planned_Structure__c,Site_Structure__c, Sold_Units__c, Proposed_Completion_Date__c, Name, 
						Min_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sq_Ft__c, Max_Avg_Resale_Price_Per_Sqft__c,
						Max_Avg_Developer_BSP_per_Sq_Ft__c,Launched_Units__c, Launch_Date__c, Id, Construction_Start_Date__c 
						FROM Tower__c WHERE Project__c =:inpprojectId]; 
	    	//system.debug('TowList'+TowList);
	       	model 			= new RBI_DataModel.Model();	
	        model.sheetname = 'Towers';
	        model.headers 		= new list<string>{'Key','Name','Structure as plan','Structure on the site','Developer BSP','Resale Price','Total Units','Launched Units','Sold Units','Launch Date','Construction Start Date','Proposed Completion Date'};
	        model.constheader 	= new list<string>{'Key','Tower Name','Excavation of Footings','Basement','RCC Slab Casting','Masonary','Electrification and Sanitation','Basement', 'Finishing'};
	        model.data 		= new list<map<string,string>>();
	        model.constdata	= new list<map<string,string>>();
	        for(Tower__c t: TowList){
	            rowdata  		= new map<string,string>();       		
        	    rowdata.put('Key',t.Id);
        	    rowdata.put('Name',t.Name);
        	    rowdata.put('Structure as plan',t.Planned_Structure__c);
        	    rowdata.put('Structure on the site',t.Site_Structure__c);
        	    rowdata.put('Developer BSP',string.valueOf(t.Max_Avg_Developer_BSP_per_Sq_Ft__c)+'-'+string.valueOf(t.Min_Avg_Developer_BSP_per_Sq_Ft__c));
        	    rowdata.put('Resale Price',string.valueOf(t.Max_Avg_Resale_Price_Per_Sqft__c)+'-'+string.valueOf(t.Min_Avg_Resale_Price_Per_Sqft__c));
        	    rowdata.put('Total Units',string.valueOf(t.Total_Units__c));
        	    rowdata.put('Launched Units',string.valueOf(t.Launched_Units__c));
        	    rowdata.put('Sold Units',string.valueOf(t.Sold_Units__c));
        	    rowdata.put('Launch Date',string.valueOf(t.Launch_Date__c));
        	    rowdata.put('Construction Start Date',string.valueOf(t.Construction_Start_Date__c));
        	    rowdata.put('Proposed Completion Date',string.valueOf(t.Proposed_Completion_Date__c));
        	    for(string mapTkey : rowdata.keySet()){
	    			if(rowdata.get(mapTkey) == null || rowdata.get(mapTkey) == ''){
	    				//system.debug('AAAAA'+mapTkey);
	    				rowdata.put(mapTkey,'-');
	    			}
	    			
	    		}
   	            model.data.add(rowdata);
        	}
        	dm.data.add(model);
        	
        //construction status data	
        	if(TowList!= null && TowList.size()>0){
        		ConStatList = 	[SELECT Tower_Name__c, RCC_Slab_Casting__c, Project__c, Name, Masonary__c, Id, Finishing__c,
								Excavation_of_Footings__c, Electrification_and_Sanitation__c, Basement__c FROM Construction_Status__c 
								WHERE Project__c =:inpprojectId];
				//project remarks data
				for(Construction_Status__c cs: ConStatList){
		   			rowdata1 = new map<string,string>();
		    		rowdata1.put('Key',cs.Name);
		    		rowdata1.put('Tower Name',cs.Tower_Name__c);
		    		rowdata1.put('Excavation of Footings',cs.Excavation_of_Footings__c);
		    		rowdata1.put('Basement',cs.Basement__c);		    		
		    		rowdata1.put('RCC Slab Casting',cs.RCC_Slab_Casting__c);
		    		rowdata1.put('Masonary',cs.Masonary__c);
		    		rowdata1.put('Electrification and Sanitation',cs.Electrification_and_Sanitation__c);
		    		rowdata1.put('Finishing',cs.Finishing__c);
		    		//Added by Legend!!
        	    	for(string mapCkey : rowdata1.keySet()){
	    				if(rowdata1.get(mapCkey) == null || rowdata1.get(mapCkey) == ''){
	    					//system.debug('AAAAA'+mapCkey);
	    					rowdata1.put(mapCkey,'-');
	    				}
	    			
	    			}
	    			//Ended adding	    				    				    				    		
		    		model.constdata.add(rowdata1);
		 		}							
        		
        	}
        //Unit Data
	        model = new RBI_DataModel.Model();
	        model.sheetname = 'Units';
	        model.headers = new list<string>{'Name','Type','Carpet Area','Built up Area','Tower Name'};
	        model.data = new list<map<string,string>>();
	  		list<Unit__c> unitList = new list<Unit__c>();
	  		//system.debug(LoggingLevel.DEBUG,'ProjList3');
	  		//system.debug('XXX'+Limits.getHeapSize());
   			//system.debug('YYY'+Limits.getLimitHeapSize());	  		
	        unitList = [Select Id, Unit_Type__c, Tower_Id__c, Name, Carpet_Area_Sq_Ft__c, Built_up_area_Sq_Ft__c,Tower_Id__r.Name From Unit__c where Tower_Id__r.Project__c =:inpprojectId];
   			//system.debug('XXX1'+Limits.getHeapSize());
   			//system.debug('YYY1'+Limits.getLimitHeapSize());	        
	        for(Unit__c u: unitList){
	            rowdata = new map<string,string>();
	            rowdata.put('Name',u.Name);
	            rowdata.put('Type',u.Unit_Type__c);
	            rowdata.put('Carpet Area',string.valueOf(u.Carpet_Area_Sq_Ft__c));                        
	            rowdata.put('Built up Area',string.valueOf(u.Built_up_area_Sq_Ft__c));
	            rowdata.put('Tower Name',u.Tower_Id__r.Name);
	            //Added by Legend!!
        	    for(string mapUkey : rowdata.keySet()){
	    			if(rowdata.get(mapUkey) == null || rowdata.get(mapUkey) == ''){
	    				//system.debug('AAAAA'+mapUkey);
	    				rowdata.put(mapUkey,'-');
	    			}
	    			
	    		}
	    		//Ended adding            
	            model.data.add(rowdata);
	        }        
	        dm.data.add(model);
  		rowcount = unitlist.size()+TowList.size()+2;
	//	system.debug('ProjList2'+dm);
    		
     }   
}