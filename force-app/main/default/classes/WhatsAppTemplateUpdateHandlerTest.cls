/**  
* @ classname           : WhatsAppTemplateUpdateHandlerTest
* @ author              : Sarjerao Pujari
* @ date                : 16-10-2023
* @ description         : This is a Test class of WhatsAppTemplateUpdateHandler.

* @ Modification Logs
*  #		  Date		              Description		    	   Modified By
*  1      16-10-2023            Initial Version        Sarjerao Pujari.
*/
@isTest
public class WhatsAppTemplateUpdateHandlerTest
{
    
    /**   
*  @ methodname             : testData
*  @ author                 : Sarjerao Pujari
*  @ objectreferenced       : WhatsApp_Template__c
*  @ param                  : None
*  @ description            : This method is used to prepare the test data to be used in .
*  @ return                 : void
*/
    @testSetup
    public static void testData()
    {
        List<Template__c> templateList = TestDataFactory.createTemplate(1, true);
        List<WhatsApp_Template__c> temList = TestDataFactory.createWhatsAppTemplate(templateList[0].Id, 1, false);
        List<WhatsApp_Template__c> updatedWhatsAppTempList = new List<WhatsApp_Template__c>();
        for(WhatsApp_Template__c wt : temList){
            wt.Template_Type__c = 'Business Initiative';
            wt.JSON_Payload__c = '{"messaging_product": "whatsapp","recipient_type":"individual","to":"919765394670","type":"template","template":{"name":"test_bot","language":{"code": "en_US"}}}';
            updatedWhatsAppTempList.add(wt);
        }
        insert updatedWhatsAppTempList;
    }
    
    /**   
*  @ methodname             : executeTestForApproved
*  @ author                 : Sarjerao Pujari
*  @ objectreferenced       : None
*  @ param                  : None
*  @ description            : This method is used to Test the whatsapp template status according to payload received as a Approved.
*  @ return                 : void
*/
    @isTest
    public static void executeTestForApproved()
    {	
        Map<String,Object> inputMap = new Map<String,Object>();
        object str = JSON.deserializeUntyped('{"event":"APPROVED","message_template_id":"temId","message_template_name":"<TEMPLATE_NAME>","message_template_language":"<LANGUAGE_AND_LOCALE_CODE>","reason":"NONE"}');
        inputMap.put('payload',str);
        Test.startTest();
        WhatsAppTemplateUpdateHandler.execute(inputMap);
        Test.stopTest();
        List<WhatsApp_Template__c> wTemList = [select Id,status__c from WhatsApp_Template__c];
        system.assertNotEquals(Null,wTemList);
    }
    
    /**   
*  @ methodname             : executeTestForRejected
*  @ author                 : Sarjerao Pujari
*  @ objectreferenced       : None
*  @ param                  : None
*  @ description            : This method is used to Test the whatsapp template status according to payload received as a Rejected.
*  @ return                 : void
*/
    @isTest
    public static void executeTestForRejected()
    {
        object str2 = JSON.deserializeUntyped('{"event":"REJECTED","message_template_id":"temId","message_template_name":"<TEMPLATE_NAME>","message_template_language":"<LANGUAGE_AND_LOCALE_CODE>","reason":"NONE"}');
        Test.startTest();
        WhatsAppTemplateUpdateHandler.execute(str2);       
        Test.stopTest();
        List<WhatsApp_Template__c> wTemList = [select Id,status__c from WhatsApp_Template__c];
        System.assertNotEquals('draft',wTemList[0].status__c );
    }
}