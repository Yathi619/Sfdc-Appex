/*
    Type:       Custom Controller
    Purpose:    Used to add Price list for a Project in Employee Portal.        

    Used By:   RBI_PriceListAdd.page
    ---------------------------------------------------------------
    History:

    05-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_PriceListAdd {
	public String selectedTowers {get; set;}
	public String selectedFromFloor {get; set;}
	public String selectedToFloor {get; set;}
	public decimal pricepersqft{get; set;}
	public Additional_Charges__c Addcharge {get; set;}
	public string Prjid{get; set;}
	public string visitid{get; set;}
	public list<Detail_Price_List__c> DetailPriceList{get;set;}
	public Detail_Price_List__c DetailPrice{get; set;}
	public list<Additional_Charges__c> Addchargelist{get; set;}
	public list<Tower__c> towerRecForDetailunitprc {get;set;}
	public list<Visit__c> towerRecForDetailunitprc1 {get;set;}
	//public  Tower__c tow{get; set;}
	public list<Tower__c>towerlist{get;set;}
	public string visitproj ;
	integer slFromFloor;
	integer slToFloor;
	public Visit__c vis{get;set;}
	Map<Id,Tower__c> Projectmap=new Map<Id,Tower__c>();
	Map<Id,Visit__c> TowerVisitmap= new Map<Id,Visit__c>();
	public decimal MinDevBsp{get; set;}
	public decimal MaxDevBsp{get; set;}
	public RBI_PriceListAdd()
	{
		Prjid=ApexPages.currentPage().getParameters().get('prjid');
		visitid=ApexPages.currentPage().getParameters().get('id');
		system.debug('6666'+visitid);
		system.debug('6666A'+Prjid);
		selectedFromFloor ='';
		selectedToFloor='';
		Addcharge = new Additional_Charges__c();
		DetailPrice= new Detail_Price_List__c();
		gettowerRecords();
		if(visitid!=null && Prjid==null){
			visitQuery();
		}
	}
	public void visitQuery(){
		if(visitid!=null){
			vis=[ Select id,Project__c from Visit__c where id=:visitid];
			visitproj=vis.Project__c;
			system.debug('6666B'+visitproj);
		}
	}
	
	public  List<SelectOption> gettowerRecords(){
		//visitQuery();
 		List<SelectOption> options = new List<SelectOption>();
 		towerRecForDetailunitprc  = new list<Tower__c>();
 		towerRecForDetailunitprc1 = new list<Visit__c>(); 
 		if(Prjid!=null && visitid==null){
			towerRecForDetailunitprc = [select id, Name,Min_Avg_Developer_BSP_per_Sq_Ft__c,Max_Avg_Developer_BSP_per_Sq_Ft__c from Tower__c where Project__c = : Prjid];
			system.debug('77777'+towerRecForDetailunitprc);
			if (towerRecForDetailunitprc.Size() >0){
				for(Tower__c tower:towerRecForDetailunitprc){ 
			     	options.add(new SelectOption(tower.Id,tower.name));
			     	Projectmap.put(tower.Id,tower);
		   		}
	    	}
 		}
 		else{
 			towerRecForDetailunitprc1 = [select id, Tower__c,Tower__r.Name,Min_Avg_Developer_BSP_per_Sqft__c,Max_Avg_Developer_BSP_per_Sqft__c from Visit__c where Visit__c = :visitid ];
 			system.debug('77777A'+towerRecForDetailunitprc1);
 		    if(towerRecForDetailunitprc1.Size() >0){
		    	for(Visit__c vistower:towerRecForDetailunitprc1){ 
			     	options.add(new SelectOption(vistower.Tower__c,vistower.Tower__r.Name));
			     	TowerVisitmap.put(vistower.Tower__c,vistower);
			     	system.debug('rrrrr'+options);
		   		}
	   		}
 		}
		
	    return options;
	}
	public void DetailPriceQuery()
	{   
		DetailPriceList= new list<Detail_Price_List__c>();
		if(Prjid!=null && visitid==null){
			DetailPriceList=[Select id, Tower__c, Project__c From Detail_Price_List__c where  Project__c=:Prjid AND Tower__c = :selectedTowers];
			system.debug('Project Details'+DetailPriceList);
		}
		else{
		    DetailPriceList=[Select id, Tower__c, Project__c From Detail_Price_List__c where  Visit__c=:visitid AND Tower__c = :selectedTowers];
	 		system.debug('Visitdetai'+DetailPriceList);
		}
	}
	public PageReference Save() 
	{ 
		DetailPriceQuery();
		Map<Id,Tower__c> Projectmap=new Map<Id,Tower__c>();
		Schema.Sobjecttype objToken = Schema.getGlobalDescribe().get('Detail_Price_List__c');
		Map<String, SobjectField> fieldMap = objToken.getDescribe().fields.getMap(); 
		selectedFromFloor = Addcharge.From_Floor__c;
		if(selectedFromFloor!=null && selectedFromFloor!=''){
			slFromFloor= Integer.valueof(selectedFromFloor.trim());
		}
		selectedToFloor = Addcharge.To_Floor__c;
		if(selectedToFloor!=null && selectedToFloor!=''){
			slToFloor = Integer.valueof(selectedToFloor.trim());
		}
		if((selectedTowers!='--None--') && (selectedFromFloor!= '')&& (selectedToFloor!= '')){
			if((selectedTowers!='--None--') && (slFromFloor <= slToFloor) ){   
				for(integer i = slFromFloor; i <= slToFloor; i++) {
					if(slFromFloor<=slToFloor){   
						string fid='rate_'+ slFromFloor +'__c'; 
						slFromFloor++;
						String apiName = String.valueOf(fieldMap.get(fid));
						if(apiName == fid && fieldMap.get(fid).getDescribe().Updateable == true){
							if(DetailPriceList!=null && DetailPriceList.size()>0){
								DetailPriceList[0].put(fieldMap.get(fid),pricepersqft);
							}
							else{
		 						 DetailPrice.put(fieldMap.get(fid),pricepersqft);
							}
		             	}	 	
		            }
				}
				if(DetailPriceList!=null && DetailPriceList.size()>0){
					try{
						if(MinDevBsp==null|| MaxDevBsp==null){
							ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'You should Enter Min/Max Developer BSP Of Selected Tower');
						    ApexPages.addMessage(errorMessage);
						}
				    	else if((pricepersqft < MinDevBsp) || (pricepersqft > MaxDevBsp)){
						    //system.debug('111111'+pricepersqft +tow.Min_Avg_Developer_BSP_per_Sq_Ft__c+ tow.Max_Avg_Developer_BSP_per_Sq_Ft__c);
				            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Price captured in Price(Per Sqft) Field should be within the developer BSP range!');
						    ApexPages.addMessage(errorMessage);
						    slFromFloor=null;
						    slToFloor=null;
				    	}else{
				    		 update DetailPriceList;
				    		 system.debug('Update list'+DetailPriceList);
				    		 resetFilters(); 
				    	}
				    		
				    }catch(DMLException ex){
			        		return null;
				    }        			
		        }
		        else{
			       	try{
				    	if(Prjid!=null && visitid==null){
				    		DetailPrice.Tower__c = selectedTowers ;
			   				DetailPrice.Project__c = Prjid;
			   				system.debug('soumya111 '+DetailPrice);
				    	}
				    	else {
				    	     DetailPrice.Tower__c = selectedTowers ;
				    	     DetailPrice.Visit__c=visitid;
				    	     system.debug('soumya222 '+DetailPrice);
				    	}
				    	if(MinDevBsp==null|| MaxDevBsp==null){
							ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'You should Enter Min/Max Developer BSP Of Selected Tower');
						    ApexPages.addMessage(errorMessage);
						}
			   			else if((pricepersqft < MinDevBsp) || (pricepersqft > MaxDevBsp)){
			   				//system.debug('222222'+pricepersqft +tow.Min_Avg_Developer_BSP_per_Sq_Ft__c+ tow.Max_Avg_Developer_BSP_per_Sq_Ft__c);
			   				ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Price captured in Price(Per Sqft) Field should be within the developer BSP range!');
				       		ApexPages.addMessage(errorMessage);
				       		slFromFloor=null;
							slToFloor=null;
			   			}
			   			else{ 
			   				 insert DetailPrice;
							 resetFilters(); 
							 system.debug('Insertlist '+DetailPrice);
			   			}
				   	}
				   	catch(DMLException ex){
				    	return null;
				   	}
				}
		    }
			
		    else if((selectedTowers!='--None--') &&(slFromFloor != null) && (slToFloor!=null)){ 
				if(slFromFloor > slToFloor){
			 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.RBI_PriceListAddFloor));
				}
				slFromFloor=null;
				slToFloor=null;
				return null;
			}
			else if((slFromFloor==null) && (slToFloor!=null)){
			 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select "Tower Name" / "From Floor" / "To Floor".'));
			 	slFromFloor=null;
			 	slToFloor=null;
				return null;     
			}
			else if((slFromFloor!=null) && (slToFloor==null)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select "Tower Name" / "From Floor" / "To Floor".'));
				slFromFloor=null;
		  		slToFloor=null;
		 		return null;
			}	
			else
				 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select "Tower Name" / "From Floor" / "To Floor".'));
				 return null;
			}
		    else if((selectedTowers =='--None--') ||(slFromFloor == null) ||(slToFloor==null)){ 
				 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select "Tower Name" / "From Floor" / "To Floor".'));
			 	 return null;
			}
			    
		return null;
	}
	public PageReference Cancel()
	{	
		if(Prjid!=null && visitid==null){
	 		PageReference pageRef = new PageReference('/'+Prjid);
	 		return pageRef;
	 		
		}
		else{
			PageReference pageRef1 = new PageReference('/'+visitid);
     		return pageRef1;
		}
		
		return null;
		
	}
	public PageReference resetFilters()
	{ 
      	Addcharge = new Additional_Charges__c();
		DetailPrice= new Detail_Price_List__c(); 
		//tow= new Tower__c();
       	pricepersqft = 0.0;
       	selectedTowers='';
       	selectedFromFloor='';
       	selectedToFloor='';
       	slFromFloor=null;
       	slToFloor=null;
        MinDevBsp=null;
    	MaxDevBsp=null;
    	TowerVisitmap=new Map<Id,Visit__c>();
        Projectmap=new Map<Id,Tower__c>(); 
        //towerRecForDetailunitprc=null;
        //towerRecForDetailunitprc1=null;
 		towerRecForDetailunitprc  = new list<Tower__c>();
 		towerRecForDetailunitprc1 = new list<Visit__c>();         
       	return null; 
                         
    } 
    //changes done 23.09.2013
    public PageReference ValidationDevbsp(){
    	//Projectmap= new Map<Id,Tower__c>();
    	if(Prjid!=null && visitid==null){
	    	if(selectedTowers!= null && selectedTowers!= '' && selectedTowers!='--None--'){
	    	  // tow = [Select Min_Avg_Developer_BSP_per_Sq_Ft__c,Max_Avg_Developer_BSP_per_Sq_Ft__c	 from Tower__c where Id=:selectedTowers];
	    	  MinDevBsp = Projectmap.get(selectedTowers).Min_Avg_Developer_BSP_per_Sq_Ft__c;
	    	  MaxDevBsp=Projectmap.get(selectedTowers).Max_Avg_Developer_BSP_per_Sq_Ft__c;
	    	  system.debug('kkkkkkk'+MinDevBsp +MaxDevBsp);
	    	   if(MinDevBsp==null &&  MaxDevBsp==null){
	    	   		MinDevBsp=null;
	    	     	MaxDevBsp=null;
	    	   }
	    	   else if(MinDevBsp==null &&  MaxDevBsp!=null){
	    	   		MinDevBsp=null;
	    	   		MaxDevBsp=Projectmap.get(selectedTowers).Max_Avg_Developer_BSP_per_Sq_Ft__c;
	    	   }
	    	   else if(MinDevBsp!=null && MaxDevBsp==null){
	    	   		MinDevBsp=Projectmap.get(selectedTowers).Min_Avg_Developer_BSP_per_Sq_Ft__c;
	    	   		MaxDevBsp=null;
	    	   }
	    	}
	    	else if(selectedTowers =='--None--'){
	    	  	 MinDevBsp=null;
	    	  	 MaxDevBsp=null;
	    	}
    	}
    	else {
	    	if(selectedTowers!= null && selectedTowers!= '' && selectedTowers!='--None--'){
	    	  // tow = [Select Min_Avg_Developer_BSP_per_Sq_Ft__c,Max_Avg_Developer_BSP_per_Sq_Ft__c	 from Tower__c where Id=:selectedTowers];
	    	  MinDevBsp = TowerVisitmap.get(selectedTowers).Min_Avg_Developer_BSP_per_Sqft__c;
	    	  MaxDevBsp= TowerVisitmap.get(selectedTowers).Max_Avg_Developer_BSP_per_Sqft__c;
	    	  system.debug('vvvvvvvvv'+MinDevBsp +MaxDevBsp);
	    	   if(MinDevBsp==null &&  MaxDevBsp==null){
	    	   	 MinDevBsp=null;
	    	     MaxDevBsp=null;
	    	   }
	    	   else if(MinDevBsp==null &&  MaxDevBsp!=null){
	    	   		MinDevBsp=null;
	    	   		MaxDevBsp=TowerVisitmap.get(selectedTowers).Max_Avg_Developer_BSP_per_Sqft__c;
	    	   }
	    	   else if(MinDevBsp!=null && MaxDevBsp==null){
	    	   		MinDevBsp=TowerVisitmap.get(selectedTowers).Min_Avg_Developer_BSP_per_Sqft__c;
	    	   		MaxDevBsp=null;
	    	   }
	    	}
	    	else if(selectedTowers =='--None--'){
	    	   MinDevBsp=null;
	    	   MaxDevBsp=null;
	    	}
    	}

    	return null;
    }
    //Run test method for Above class
    @IsTest(SeeAllData=true)  
    static  void RBI_PriceListTestClass() {
    	
    	list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Launch_Date__c = System.today(),Brochure_Zipcode__c = '568980', 
										 Site_Address_City__c = 'Bangalore', Site_Address_zipcode__c = '412578');
		projlist.add(proj);
		insert projlist;
		
		list<Tower__c> towerlist = new list<Tower__c>();
		Tower__c twd = new Tower__c(Project__c = projlist[0].Id, Name = 'TowerA',Structure_as_per_Plan__c='13',
									Avg_Resale_Price_per_Sq_Ft__c=250,Min_Avg_Developer_BSP_per_Sq_Ft__c=120, Max_Avg_Developer_BSP_per_Sq_Ft__c=156,Deviation__c='Yes',Planned_Basement_Floors__c=2,Planned_Parking_Floors__c=2,Planned_ResCom_Floors__c=15,Actual_Basement_Floors__c=2, Actual_Parking_Floors__c=3,Actual_ResCom_Floors__c=16  );
		Tower__c twd1 = new Tower__c(Project__c = projlist[0].Id, Name = 'TowerB',Structure_as_per_Plan__c='13',
									Avg_Resale_Price_per_Sq_Ft__c=250,Min_Avg_Developer_BSP_per_Sq_Ft__c=130, Max_Avg_Developer_BSP_per_Sq_Ft__c=190,Deviation__c='Yes',Planned_Basement_Floors__c=2,Planned_Parking_Floors__c=2,Planned_ResCom_Floors__c=15,Actual_Basement_Floors__c=2, Actual_Parking_Floors__c=3,Actual_ResCom_Floors__c=16  );							
		towerlist.add(twd);
		towerlist.add(twd1);
		insert towerlist;
		
		list<Visit__c> vstList = new list<Visit__c>();
	    Visit__c vst1 = new Visit__c(Project__c = projlist[0].Id, Visit_Report__c = 'Followup Report');
	    vstList.add(vst1);
	    insert vstList;
	    
	    list<Visit__c> towervstList = new list<Visit__c>();
	    Visit__c towvst = new Visit__c(Tower__c = towerlist[0].Id, Visit__c=vstList[0].Id,Min_Avg_Developer_BSP_per_Sqft__c=100,Max_Avg_Developer_BSP_per_Sqft__c	=200);
	    towervstList.add(towvst);
	    insert towervstList;
		
		
		list<Additional_Charges__c> Addcrglist = new list<Additional_Charges__c>();
		Additional_Charges__c crg = new Additional_Charges__c(Charge_Type__c='PLC',Charge_Detail__c='Floor Rise',From_Floor__c = '2', To_Floor__c = '15');
		Addcrglist.add(crg);
		insert Addcrglist;
		list<Detail_Price_List__c> Detaillist = new list<Detail_Price_List__c>();
		Detail_Price_List__c detail = new Detail_Price_List__c(Project__c=projlist[0].Id,Tower__c=towerlist[1].Id);
		Detaillist.add(detail);
		insert Detaillist;
		
		//start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_TowerUnitTypeCount which generates the PDF
		PageReference PricelistAdd= Page.RBI_PriceListAddPage;
		System.Test.setCurrentPage(PricelistAdd);
		apexpages.currentpage().getparameters().put('prjid' , projlist[0].Id);
		//apexpages.currentpage().getparameters().put('id' , vstList[0].Id);
		
		//instantiate the class
		RBI_PriceListAdd Addpricelist = new RBI_PriceListAdd(); 
		Addpricelist.Prjid=apexpages.currentpage().getparameters().put('prjid' , projlist[0].Id);
		Addpricelist.gettowerRecords();
		Addpricelist.selectedTowers=towerlist[0].id;
		//Addpricelist.Projectmap.addAll(towerlist);
		Addpricelist.MinDevBsp=towerlist[0].Min_Avg_Developer_BSP_per_Sq_Ft__c;
		Addpricelist.MaxDevBsp=towerlist[0].Min_Avg_Developer_BSP_per_Sq_Ft__c;
		Addpricelist.visitid=null;
		Addpricelist.ValidationDevbsp();
		
		Addpricelist.visitid=apexpages.currentpage().getparameters().put('id' , vstList[0].Id);
		Addpricelist.Prjid=null;
		Addpricelist.visitQuery();
		
		Addpricelist.selectedTowers ='--None--';
		Addpricelist.selectedFromFloor ='';
		Addpricelist.selectedToFloor = '';
		Addpricelist.Save();
		Addpricelist.selectedTowers =towerlist[0].id;
		Addpricelist.slFromFloor=null;
		Addpricelist.slToFloor = 23;
		Addpricelist.Save();
		
		Addpricelist.selectedTowers=towerlist[0].id;
		Addpricelist.selectedFromFloor='7';
		Addpricelist.selectedToFloor= '2';
		Addpricelist.Save();
		
		
		Addpricelist.selectedTowers=towerlist[0].id;
		Addpricelist.Addcharge=crg;
		Addpricelist.selectedFromFloor=Addcrglist[0].From_Floor__c;
		Addpricelist.selectedToFloor= Addcrglist[0].To_Floor__c;
		//Addpricelist.tow=twd;
		Addpricelist.MinDevBsp=100;
		Addpricelist.MaxDevBsp=200;
		Addpricelist.pricepersqft=190;
		Addpricelist.Save();
		
		Addpricelist.selectedTowers=towerlist[0].id;
		Addpricelist.Addcharge=crg;
		Addpricelist.selectedFromFloor=Addcrglist[0].From_Floor__c;
		Addpricelist.selectedToFloor= Addcrglist[0].To_Floor__c;
		Addpricelist.MinDevBsp=100;
		Addpricelist.MaxDevBsp=200;
		//Addpricelist.tow=twd;
		Addpricelist.pricepersqft=90;
		Addpricelist.Save();
		//validation test
		Addpricelist.selectedTowers=towerlist[0].id;
		Addpricelist.Addcharge=crg;
		Addpricelist.selectedFromFloor=Addcrglist[0].From_Floor__c;
		Addpricelist.selectedToFloor= Addcrglist[0].To_Floor__c;
		Addpricelist.MinDevBsp=null;
		Addpricelist.MaxDevBsp=200;
		//Addpricelist.tow=twd;
		Addpricelist.pricepersqft=145;
		Addpricelist.Save();

		Addpricelist.visitid=null;
		Addpricelist.Prjid=apexpages.currentpage().getparameters().put('prjid' , projlist[0].Id);
		Addpricelist.DetailPriceQuery();
		
		Addpricelist.selectedTowers=towerlist[0].id;
		Addpricelist.Addcharge=crg;
		Addpricelist.selectedFromFloor='10';
		Addpricelist.selectedToFloor= '20';
		//Addpricelist.tow=twd;
		Addpricelist.MinDevBsp=20;
		Addpricelist.MaxDevBsp=200;
		Addpricelist.pricepersqft=190;
		Addpricelist.Save();
		
		
		Addpricelist.Cancel();
		Addpricelist.resetFilters();
		
		//Add pricelist in visit
		RBI_PriceListAdd Addpricelist1 = new RBI_PriceListAdd(); 
		Addpricelist1.visitid=apexpages.currentpage().getparameters().put('id' , vstList[0].Id);
		//Addpricelist1.Prjid=null;
		//Addpricelist1.selectedTowers=towervstList[0].Tower__c;
		Addpricelist1.gettowerRecords();
		//Addpricelist1.selectedTowers=towervstList[0].Tower__c;
		//Addpricelist1.MinDevBsp=towervstList[0].Min_Avg_Resale_Price_Per_Sqft__c;
		//Addpricelist1.MaxDevBsp=towervstList[0].Max_Avg_Developer_BSP_per_Sqft__c;
		Addpricelist1.Prjid=null;
		Addpricelist1.ValidationDevbsp();
		Addpricelist1.visitQuery();
		
		Addpricelist1.selectedTowers ='--None--';
		Addpricelist1.selectedFromFloor ='';
		Addpricelist1.selectedToFloor = '';
		Addpricelist1.Save();
		
		Addpricelist1.selectedTowers=towervstList[0].Tower__c;
		Addpricelist1.selectedFromFloor='7';
		Addpricelist1.selectedToFloor= '2';
		Addpricelist1.Save();
		
		Addpricelist1.selectedTowers=towervstList[0].Tower__c;
		Addpricelist1.Addcharge=crg;
		Addpricelist1.selectedFromFloor=Addcrglist[0].From_Floor__c;
		Addpricelist1.selectedToFloor= Addcrglist[0].To_Floor__c;
		//Addpricelist1.tow=twd;
		Addpricelist.MinDevBsp=100;
		Addpricelist.MaxDevBsp=200;
		Addpricelist1.pricepersqft=240;
		Addpricelist1.Save();
		
		Addpricelist1.selectedTowers=towervstList[0].Tower__c;
		Addpricelist1.Addcharge=crg;
		Addpricelist1.selectedFromFloor=Addcrglist[0].From_Floor__c;
		Addpricelist1.selectedToFloor= Addcrglist[0].To_Floor__c;
		//Addpricelist1.tow=twd;
		Addpricelist.MinDevBsp=100;
		Addpricelist.MaxDevBsp=200;
		Addpricelist1.pricepersqft=190;
		Addpricelist1.Save();
		
		
		Addpricelist1.DetailPriceQuery();
		Addpricelist1.selectedTowers=towervstList[0].Tower__c;
		Addpricelist1.DetailPriceList=Detaillist;
		Addpricelist1.selectedFromFloor='18';
		Addpricelist1.selectedToFloor= '23';
		Addpricelist.MinDevBsp=100;
		Addpricelist.MaxDevBsp=200;
		Addpricelist1.pricepersqft=190;
		Addpricelist1.Save();
		
		Addpricelist1.Cancel();
		Addpricelist1.resetFilters();
		
		
		//Stop the Test Class
		System.Test.stopTest();
		
    
    }
   
}