/**  
* @ classname           : WhatsappWebhookServiceTest
* @ author              : Sarjerao Pujari
* @ date                : 23-10-2023
* @ description         : This is a Test class of WhatsappWebhookService.

* @ Modification Logs
*  #		  Date          		       Description		    	   Modified By
*  1      16-10-2023               Initial Version         Sarjerao Pujari.
*/
@isTest
public with sharing class WhatsappWebhookServiceTest
{

/**    
 	*  @ methodname             : processTest
	*  @ author                 : Sarjerao Pujari
	*  @ objectreferenced       : None
	*  @ param                  : None
	*  @ description            : This method is responsible to test the whatsapp specific payload and invoke the specific service handler class.
	*  @ return                 : void
	*/
    @isTest
	public static void processTest()
    {
        
   		string str = '{"object":"whatsapp_business_account","entry":[{"id":"WHATSAPP_BUSINESS_ACCOUNT_ID","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"PHONE_NUMBER","phone_number_id":"PHONE_NUMBER_ID"},"contacts":[{"profile":{"name":"NAME"},"wa_id":"PHONE_NUMBER"}],"messages":[{"from":"1234567","id":"wamid.ID","timestamp":"1697999400000","text":{"body":"MESSAGE_BODY"},"type":"text"}]},"field":"messages"}]}]}'; 
        User testUser = TestDataFactory.createUser(); 
        PermissionSet ps = [Select Id from PermissionSet where Name='EngageCliq_Admin'];
        PermissionSetAssignment psAssignment = new PermissionSetAssignment();
        psAssignment.AssigneeId = testUser.Id;
        psAssignment.PermissionSetId = ps.Id;
        insert psAssignment;
        
       
        System.runAs(testUser) {
            Test.startTest();
            WhatsappWebhookService.process(str); 
            Test.stoptest();
            List<Inbound_Message__c> inboundList = [select Id,Channel__c from Inbound_Message__c where Channel__c = 'whatsapp'];
            integer listSize = inboundList.size();
            system.assertEquals(1,listSize);
        }
      
    }
    
  /**    
	*  @ methodname             : processTestException
	*  @ author                 : Sarjerao Pujari
	*  @ objectreferenced       : None
	*  @ param                  : None
	*  @ description            : This method is responsible to test the whatsapp specific payload and invoke the specific service handler class.
	*  @ return                 : void
	*/
  @isTest
	public static void processTestException()
  {
   	string str = '{"object":"whatsapp_business_account+"1"","entry":[{"id":"WHATSAPP_BUSINESS_ACCOUNT_ID","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"PHONE_NUMBER","phone_number_id":"PHONE_NUMBER_ID"},"contacts":[{"profile":{"name":"NAME"},"wa_id":"PHONE_NUMBER"}],"messages":[{"from":"1234567","id":"wamid.ID","timestamp":"1697999400000","text":{"body":"MESSAGE_BODY"},"type":"text"}]},"field":"messages"}]}]}';
  	Test.startTest();
		WhatsappWebhookService.process(str);		        
    Test.stoptest();
  
    List<Inbound_Message__c> inboundList = [select Id,Channel__c from Inbound_Message__c where Channel__c = 'whatsapp'];
    integer listSize = inboundList.size();
    system.assertEquals(0,listSize);
  }
}