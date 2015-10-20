public with sharing class StringArrayTest {
	
	//The Apex class must be called 'StringArrayTest' and be in the public scope.
	
	public static list<String> generateStringArray(Integer n){
		
	//The number of returned strings is specified by the integer parameter to the 'generateStringArray' method.
   //The Apex class must have a public static method called 'generateStringArray'. 
	
	//The 'generateStringArray' method must return an array (or list) of strings
	list <string> lst=new list<string>();
		
	for(Integer i=0;i<n;i++){
		string a = 'Test '+i;
		lst.add(a);
	}
		return lst;
	}
}