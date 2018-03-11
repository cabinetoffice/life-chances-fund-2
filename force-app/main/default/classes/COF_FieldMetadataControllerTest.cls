/* _______________________________________________________________________________________________________________
   Name:		COF_FieldMetadataControllerTest.cls
   Description: Test Class for COF_FieldMetadataController
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Mar 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class COF_FieldMetadataControllerTest { 
		
    @isTest static void testit() {
		
        PageReference pageRef = Page.COF_RetrieveFieldMetadata;
        Test.setCurrentPage(pageRef);     
        
		Test.startTest();
		ApexPages.StandardController stdcon = new ApexPages.StandardController(new SIB_Field_Metadata__c());
		COF_FieldMetadataController con1 = new COF_FieldMetadataController(stdcon);
		con1.retrieveMetadata();
		con1.viewMetadata();     	
     	Test.stopTest(); 
     	
     	List<SIB_Field_Metadata__c> mdList = [
     		SELECT Name, Object_Name__c, Field_Key__c, Description__c, Help_Text__c, Relationship_Name__c
     		FROM SIB_Field_Metadata__c
     	];
     	
     	// test data included in controller class
     	system.assertEquals(con1.objectNameList.size(),mdList.size());
     	system.assertEquals('Application__c',mdList[0].Object_Name__c);
     	system.assertEquals('Test__r',mdList[0].Relationship_Name__c);

    }  
    
    
}