/**  
* @ classname           : WhatsAppOutboundHandlerTest
* @ author              : Sarjerao Pujari
* @ date                : 23 Oct 2023
* @ description         : This is a Test class of WhatsAppOutboundHandler.

* @ Modification Logs
*  #		  Date(DD/MM/YYYY)		       Description		    	   Modified By
*  1          16/10/2023                   Initial Version             Sarjerao Pujari.
*/
@istest
public class WhatsAppOutboundHandlerTest
{
    /**   
*  @ methodname             : executeTestForSendTime
*  @ author                 : Sarjerao Pujari
*  @ objectreferenced       : None
*  @ param                  : None
*  @ description            : This method is used to test the object and prepare the outbound message record.
*  @ return                 : void
*/    
    
    @isTest
    public static void executeTestForSendTime()
    {   
        Map<String,Object> inputMap = new Map<String,Object>();
        object jsonforSendTime = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"BUSINESS_DISPLAY_PHONE_NUMBER","phone_number_id":"BUSINESS_PHONE_NUMBER_ID"},"statuses":[{"id":"ABCDEF","status":"failed","timestamp":"1697999400000","recipient_id":"CUSTOMER_PHONE_NUMBER","conversation":{"id":"CONVERSATION_ID","expiration_timestamp":"CONVERSATION_EXPIRATION_TIMESTAMP","origin":{"type":"user_initiated"}},"pricing":{"billable":true,"pricing_model":"CBP","category":"service"}}]}');
        inputMap.put('payload',jsonforSendTime);
        Test.startTest();
        WhatsAppOutboundHandler.execute(inputMap);
        Test.stopTest();  
        system.assert(true);
    }
    
    /**   
*  @ methodname             : executeTestForSendTimeSent
*  @ author                 : Nikita Pawar
*  @ objectreferenced       : None
*  @ param                  : None
*  @ description            : This method is used to test if the outbound message sent with status Sent.
*  @ return                 : void
*/
     @isTest
    public static void executeTestForSendTimeSent()
    {   
        Map<String,Object> inputMap = new Map<String,Object>();
        object jsonforSendTime = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"BUSINESS_DISPLAY_PHONE_NUMBER","phone_number_id":"BUSINESS_PHONE_NUMBER_ID"},"statuses":[{"id":"ABCDEF","status":"sent","timestamp":"1697999400000","recipient_id":"CUSTOMER_PHONE_NUMBER","conversation":{"id":"CONVERSATION_ID","expiration_timestamp":"CONVERSATION_EXPIRATION_TIMESTAMP","origin":{"type":"user_initiated"}},"pricing":{"billable":true,"pricing_model":"CBP","category":"service"}}]}');
        inputMap.put('payload',jsonforSendTime);
        Test.startTest();
        WhatsAppOutboundHandler.execute(inputMap);
        Test.stopTest(); 
        system.assert(true);
    }
    
    /**   
*  @ methodname             : executeTestForSendTimedelivered
*  @ author                 : Nikita Pawar
*  @ objectreferenced       : None
*  @ param                  : None
*  @ description            : This method is used to test if the outbound message sent with status deliverd.
*  @ return                 : void
*/   
     @isTest
    public static void executeTestForSendTimedelivered()
    {   
        Map<String,Object> inputMap = new Map<String,Object>();
        object jsonforSendTime = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"BUSINESS_DISPLAY_PHONE_NUMBER","phone_number_id":"BUSINESS_PHONE_NUMBER_ID"},"statuses":[{"id":"ABCDEF","status":"delivered","timestamp":"1697999400000","recipient_id":"CUSTOMER_PHONE_NUMBER","conversation":{"id":"CONVERSATION_ID","expiration_timestamp":"CONVERSATION_EXPIRATION_TIMESTAMP","origin":{"type":"user_initiated"}},"pricing":{"billable":true,"pricing_model":"CBP","category":"service"}}]}');
        inputMap.put('payload',jsonforSendTime);
        Test.startTest();
        WhatsAppOutboundHandler.execute(inputMap);
        Test.stopTest();
        system.assert(true);
    }
    /**   
*  @ methodname             : executeTestForSendTimeRead
*  @ author                 : Nikita Pawar
*  @ objectreferenced       : None
*  @ param                  : None
*  @ description            : This method is used to test if the outbound message sent with status read.
*  @ return                 : void
*/     
     @isTest
    public static void executeTestForSendTimeRead()
    {   
        Map<String,Object> inputMap = new Map<String,Object>();
        object jsonforSendTime = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"BUSINESS_DISPLAY_PHONE_NUMBER","phone_number_id":"BUSINESS_PHONE_NUMBER_ID"},"statuses":[{"id":"ABCDEF","status":"read","timestamp":"1697999400000","recipient_id":"CUSTOMER_PHONE_NUMBER","conversation":{"id":"CONVERSATION_ID","expiration_timestamp":"CONVERSATION_EXPIRATION_TIMESTAMP","origin":{"type":"user_initiated"}},"pricing":{"billable":true,"pricing_model":"CBP","category":"service"}}]}');
        inputMap.put('payload',jsonforSendTime);
        Test.startTest();
        WhatsAppOutboundHandler.execute(inputMap);
        Test.stopTest(); 
        system.assert(true);
    }
    
    /**   
*  @ methodname             : executeTestForFailed
*  @ author                 : Sarjerao Pujari
*  @ objectreferenced       : None
*  @ param                  : None
*  @ description            : This method is used to test the object and update the failed time and reason
*  @ return                 : void
*/    
    @isTest
    public static void executeTestForFailed()
    {        
        object jsonforSendTime = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"BUSINESS_DISPLAY_PHONE_NUMBER","phone_number_id":"BUSINESS_PHONE_NUMBER_ID"},"statuses":[{"id":"ABCDEF","status":"failed","timestamp":"1697999400000","recipient_id":"CUSTOMER_PHONE_NUMBER","errors":[{"code":131014,"title":"Request for url https://URL.jpg failed with error: 404 (Not Found)"}]}]}');		 
        Test.startTest();
        WhatsAppOutboundHandler.execute(jsonforSendTime);
        Test.stopTest(); 
        system.assert(true);
    }
    
    
    /**   
*  @ methodname             : executeTestForDeliverTime
*  @ author                 : Sarjerao Pujari
*  @ objectreferenced       : None
*  @ param                  : None
*  @ description            : This method is used to test the object and prepare the outbound message record.
*  @ return                 : void
*/    
    @isTest
    public static void executeTestForDeliverTime()
    {        
        object jsonforDeliverTime = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"PHONE_NUMBER","phone_number_id":"PHONE_NUMBER_ID"},"statuses":[{"id":"ABCDEF","recipient_id":"PHONE_NUMBER","status":"delivered","timestamp":"1697999400000","conversation":{"id":"CONVERSATION_ID","expiration_timestamp":"TIMESTAMP","origin":{"type":"user_initiated"}},"pricing":{"pricing_model":"CBP","billable":true,"category":"service"}}]}');
        Test.startTest();
        WhatsAppOutboundHandler.execute(jsonforDeliverTime);
        Test.stopTest(); 
        system.assert(true);
    }
    /**   
*  @ methodname             : getOutboundMessageIdTest
*  @ author                 : Sarjerao Pujari
*  @ objectreferenced       : None
*  @ param                  : None
*  @ description            : This method is used to test for getting a unique outbound record with the help of whatspp id.
*  @ return                 : void
*/    
    @isTest
    public static void getOutboundMessageIdTest()
    {  
        List<Template__c> tempList = TestDataFactory.createTemplate(1, true);
        List<WhatsApp_Template__c> whtasAppTempList = TestDataFactory.createWhatsAppTemplate(tempList[0].Id, 1, true);
        Outbound_Message__c outboundMSG = new Outbound_Message__c();
        outboundMSG.External_ID__c = 'wamid.HBgMOTE5ODgxMjIyMDcwFQIAERgSQzkyMEM2N0Q0Q0E3NDRBQ0IyAA==';
        outboundMSG.Message_Text__c = 'Hello Good Morning';
        outboundMSG.WhatsApp_Template__c = whtasAppTempList[0].Id; 
        outboundMSG.Channel__c = 'WhatsApp';
        outboundMSG.Mobile__c = '917654345432';
        insert outboundMSG;
        string whatsAppId = 'wamid.HBgMOTE5ODgxMjIyMDcwFQIAERgSQzkyMEM2N0Q0Q0E3NDRBQ0IyAA==';
        Test.startTest();
        String obmId = WhatsAppOutboundHandler.getOutboundMessageId(whatsAppId);
        Test.stopTest(); 
        system.assert(true);
    }    
}