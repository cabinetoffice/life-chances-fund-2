@isTest
private class SIB_TemplateControllerTest {
	
	@isTest static void test_method_one() {
        PageReference pageRef = Page.Questions;
        Test.setCurrentPage(pageRef);     
		SIB_TemplateController controller = new SIB_TemplateController();
		System.assertEquals(controller.footerLinks.size(),[
			SELECT COUNT()
			FROM Footer_Link__mdt
			WHERE Active__c = true
		]);
	}
	
}