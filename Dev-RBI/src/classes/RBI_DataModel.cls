/**
description   : Used for excel export.
		        Stores the data model for different worksheets data
*/
public class RBI_DataModel{
    public list<model> data{get;set;}
    
    public class Model{
        public string sheetname {get;set;}
        public integer tblsize {get;set;}
        public list<string> headers{get;set;}
        public list<map<string,string>> data{get;set;}
          
        public list<string> prjremheader{get;set;}
        public list<string> prjamntyheader{get;set;}
        public list<string> prjinfraheader{get;set;}
        public list<string> constheader{get;set;}
        //public list<string> prjcsheader{get;set;}
        public list<map<string,string>> prjamntydata{get;set;}
        public list<map<string,string>> prjremdata{get;set;}
        public list<map<string,string>> prjinfradata{get;set;} 
         public list<map<string,string>> constdata{get;set;}  
        //public list<map<string,string>> prjcsdata{get;set;}
        //public list<string> towcsheader{get;set;}
        //public list<map<string,string>> towcsdata{get;set;}        
		//TO be removed                
       /* public list<string> prjheader{get;set;}
        public list<map<string,string>> prjdata{get;set;}        
        public list<string> towrheader{get;set;}
        public list<string> unitheader{get;set;}
        public list<map<string,string>> towrdata{get;set;}        
        public list<map<string,string>> unitdata{get;set;}
       	public list<string> constheader{get;set;}
        public list<map<string,string>> constdata{get;set;}
        */        
    }
}