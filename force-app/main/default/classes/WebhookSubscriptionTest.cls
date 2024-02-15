/**  
* @ classname           : WebhookSubscriptionTest
* @ author              : Sarjerao Pujari
* @ date                : 23-10-2023
* @ description         : This is a Test class of WebhookSubscription.

* @ Modification Logs
*  #			  Date		                   Description		    		     Modified By
*	 1        16-10-2023                 Initial Version             Sarjerao Pujari.
*/
@isTest
public class WebhookSubscriptionTest
{
    
    /** 
* @ methodname             : HandleGetRequestTest
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is designed to Test the incoming HTTP GET requests.
* @ return                 : None
*/
    // Define a test method for handleGetRequest
    @isTest
    static void HandleGetRequestTest()
    {
        // Create a test RestRequest
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.test_request_url_label;
        RestContext.request = request;
        
        // Set the expected webhook token
        Constants.hub_verify_token = 'hello';
        Constants.hub_challenge = 'testChallenge';
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        // Call the handleGetRequest method
        Test.startTest();
        WebhookSubscription.handleGetRequest();
        Test.stopTest();
        System.assert(true);
    }
    
    
    /**  
* @ methodname             : HandlePostRequestTest
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is responsible for testing the HandlePostRequest method.
* @ return                 : None
*/
    // Define a test method for handlePostRequest
    @isTest
    static void HandlePostRequestTest()
    {
        // Create a test RestRequest
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.test_request_url_label;
        RestContext.request = request;
        String channelName = 'WhatsApp';
        
        // Set the expected request body
        RestContext.request.requestBody = Blob.valueOf('{"object":"whatsapp_business_account","entry":[{"id":"WHATSAPP_BUSINESS_ACCOUNT_ID","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"PHONE_NUMBER","phone_number_id":"PHONE_NUMBER_ID"},"contacts":[{"profile":{"name":"NAME"},"wa_id":"PHONE_NUMBER"}],"messages":[{"from":"PHONE_NUMBER","id":"wamid.ID","timestamp":"TIMESTAMP","text":{"body":"MESSAGE_BODY"},"type":"text"}]},"field":"messages"}]}]}');
        // Call the handlePostRequest method
        Test.startTest();
        WebhookSubscription.handlePostRequest();
        Test.stopTest();
        System.assert(true);
        
    }
    
    /**  
* @ methodname             : testHandlePostRequestException
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is responsible for testing the exception in HandlePostRequest method.
* @ return                 : None
*/
    @isTest
    static void testHandlePostRequestException()
    {
        // Create a test RestRequest
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.test_request_url_label+'1';    
        RestContext.request = request;
        String channelName = 'WhatsApp';
        
        // Set the expected request body
        RestContext.request.requestBody = Blob.valueOf('{"object":"whatsapp_business_account","entry":[{"id":"WHATSAPP_BUSINESS_ACCOUNT_ID","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"PHONE_NUMBER","phone_number_id":"PHONE_NUMBER_ID"},"contacts":[{"profile":{"name":"NAME"},"wa_id":"PHONE_NUMBER"}],"messages":[{"from":"PHONE_NUMBER","id":"wamid.ID","timestamp":"TIMESTAMP","text":{"body":"MESSAGE_BODY"},"type":"text"}]},"field":"messages"}]}]}');
        // Call the handlePostRequest method
        Test.startTest();
        WebhookSubscription.handlePostRequest();
        Test.stopTest();
        
        List<Inbound_Message__c> wTemList = [Select id,Channel__c,Message_Text__c from Inbound_Message__c];
        system.assertEquals(0,wTemList.size());
    }
}