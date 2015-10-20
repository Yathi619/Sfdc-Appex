/*
    Type:       Custom Controller
    Purpose:    Used by the Customer in Customer Portal to select the towers for generation of Tower Report PDF.
                Customer can select min of 1 and max of 10 towers for a project. This can be accessed in Customer Portal
                under My Projects tab - Reports subtab and clicking on Generate report link.         

    Used By:   RBI_ProjectTowers.page
    ---------------------------------------------------------------
    History:

    19-Apr-2013     Created     Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_ProjectTowersClass {
    Id[] selectedTowers= new Id[]{};
    public ApexPages.StandardController std;
    Id projectId = null;
    
    public RBI_ProjectTowersClass(ApexPages.StandardController stdcontroller){
        projectId = stdcontroller.getId();
    }
    
    public Id[] getSelectedTowers() {
        return selectedTowers;
        
    }
    
    public void setSelectedTowers(Id[] selectedTowers) {
        this.selectedTowers= selectedTowers;
    } 
    
    public List<SelectOption> gettowerRecords(){
        List<SelectOption> options = new List<SelectOption>();
        list<Tower__c> towerRecords = [select name from Tower__c where Project__c = : projectId]; 
        if (towerRecords.Size() >0){
            for(Tower__c tower:towerRecords){
                options.add(new SelectOption(tower.Id,tower.name));
            }
       } 
       return options;
    }
    /* This method will Generate TowerReport in PDF */
    public pageReference generatePDF(){
        
        if(selectedTowers != null && selectedTowers.size() > 0){
            if(selectedTowers.size() < 11){
                PageReference pg = new PageReference('/apex/RBI_GenerateTowerReportPDF?TowerList='+selectedTowers);
                return pg;
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.RBI_TowerSelectErrMes));
        }
        if(selectedTowers.size() < 11){
            if(selectedTowers.size() > 0){
                PageReference pg = new PageReference('/apex/RBI_GenerateTowerReportPDF?TowerList='+selectedTowers);
                return pg;
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.RBI_MaxTowerSelErrMes));
        }
        return null;
    }
    
    //Test method for the class above
    
     @IsTest(SeeAllData=true)  static  void Towerpage() {
        //create record for following object and make association between them
        list<Project__c> projlist = new list<Project__c>();
        Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
                                         City__c ='test',Brochure_Zipcode__c = '568980', Site_Address_zipcode__c = '412578', 
                                         Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
        projlist.add(proj);
        insert projlist;
        
        list<Tower__c> towerlist = new list<Tower__c>();
        Tower__c twd = new Tower__c(Project__c = projlist[0].Id, Name = 'TowerA',Structure_as_per_Plan__c='13',
                                    Avg_Resale_Price_per_Sq_Ft__c=250,Deviation__c='Yes',Planned_Basement_Floors__c=2,Planned_Parking_Floors__c=2,Planned_ResCom_Floors__c=15,Actual_Basement_Floors__c=2, Actual_Parking_Floors__c=3,Actual_ResCom_Floors__c=16  );
        towerlist.add(twd);
        insert towerlist;
        
        //start test class method
        PageReference towerpage = Page.RBI_ProjectTowersPage;
        
        //Instantiate the controller
        ApexPages.StandardController stdCon = new ApexPages.StandardController(proj);
        RBI_ProjectTowersClass tow= new RBI_ProjectTowersClass(stdCon);
        System.Test.startTest();
        //test the RBI_Project Tower class Method
        tow.projectId=projlist[0].Id;
        tow.gettowerRecords();
        tow.getSelectedTowers();
        tow.setSelectedTowers(tow.SelectedTowers);
        tow.generatePDF();
        
        //Stop Test Class
        System.Test.stopTest();
    
     }
}