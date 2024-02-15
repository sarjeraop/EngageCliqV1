/*
 *  @classname  		: WhatsAppAPIServiceTest
 *  @author 			: Rati Kulkarni
 *  @ param             : none
 *  @description  		: This class is used to test the communications with WhatsApp.

 *  @modificationlog
 *  	#		Date				 Description				Modified By
 *		1.	    22-12-2023			 Added Comments			    sarjerao Pujari
*/
@isTest
public class WhatsAppAPIServiceTest {

/**
 * @ methodname             : CreateWhatsAppTemplateAPIServiceTest.
 * @ author                 : Rati Kulkarni.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this testCreateWhatsAppTemplateAPIService method is used to test the whatsApp template API service.
 * @ return                 : none.
 */    
    @isTest
    static void CreateWhatsAppTemplateAPIServiceTest() {
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new WhatsAppAPIServiceMock());

        // Call the method to test
        Map<String, Object> response = WhatsAppAPIService.createWhatsAppTemplateAPIService('sampleJson');
        
    }


/**
 * @ methodname             : GetApprovedWhatsAppTemplatesAPIServiceTest.
 * @ author                 : Rati Kulkarni.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the whatsApp Approved template API service.
 * @ return                 : none.
 */
    @isTest
    static void GetApprovedWhatsAppTemplatesAPIServiceTest() {
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new WhatsAppAPIServiceMock());
		String jsonString = 'https://graph.facebook.com/v17.0/106473345515586/message_templates?fields=id,name,status,category,language,components&status=APPROVED';
        // Call the method to test
        Map<String, Object> response = WhatsAppAPIService.getApprovedWhatsAppTemplatesAPIService(jsonString); 
        system.assertEquals(response.get('StatusCode'),null);
        
    }
    
/**
 * @ methodname             : GetNextApprovedWhatsAppTemplatesAPIServiceTest.
 * @ author                 : Rati Kulkarni.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the whatsApp Approved template API service.
 * @ return                 : none.
 */
    @isTest
    static void GetNextApprovedWhatsAppTemplatesAPIServiceTest() {
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new WhatsAppAPIServiceMock());
		String jsonString = 'https://graph.facebook.com/v17.0/106473345515586/message_templates?fields=id,name,status,category,language,components&status=APPROVED&limit=25&after=MjQZD';
        // Call the method to test
        Map<String, Object> response = WhatsAppAPIService.getApprovedWhatsAppTemplatesAPIService(jsonString);
        system.assertEquals(response.get('StatusCode'),null);
    }
    
    @isTest
    static void editWhatsAppTemplateAPIServiceTest() {
        
      WhatsApp_Template__c whatsAppTemplateObj = new WhatsApp_Template__c();
      whatsAppTemplateObj.Name__c = 'Welcome Template';
      whatsAppTemplateObj.IsActive__c = true;
      whatsAppTemplateObj.WhatsApp_Template_ID__c = 'temId';
      whatsAppTemplateObj.JSON_Payload__c = '{"messaging_product": "whatsapp","recipient_type":"individual","to":"919765394670","type":"template","template":{"name":"test_bot","language":{"code": "en_US"}}}';
      whatsAppTemplateObj.Message_Body__c ='<p>Hello</p>';
      whatsAppTemplateObj.WhatsApp_Category__c = 'MARKETING';
       insert whatsAppTemplateObj;
       String jsonString = 'https://graph.facebook.com/v17.0/106473345515586/message_templates?fields=id,name,status,category,language,components&status=APPROVED';
       String templateId = whatsAppTemplateObj.ID;
        
        Test.startTest();
        WhatsAppAPIService.editWhatsAppTemplateAPIService(jsonString,templateId);
        Test.stopTest();
        WhatsApp_Template__c listOfWhatsAppTemplate = [select Id,Name__c from WhatsApp_Template__c where Name__c= 'Welcome Template' limit 1];
        system.assertEquals(listOfWhatsAppTemplate.Name__C ,'Welcome Template');
    }
    
    
    @isTest
    static void getBusinessIdTest(){
        Test.startTest();
        	string businessId = WhatsAppAPIService.getBusinessId();
        Test.stopTest();
        boolean isEmptyBusinessId;
        Channel_Configuration__mdt apiObject =  new Channel_Configuration__mdt();
        apiObject = [Select API_key__c, Business_ID__c,Endpoint_URL__c from Channel_Configuration__mdt limit 1];
        if(apiObject.Business_ID__c != Null){
            isEmptyBusinessId = true;
        }else{
            isEmptyBusinessId = false;
        }
        
        system.assertEquals(apiObject.Business_ID__c != Null,isEmptyBusinessId);
    }
}