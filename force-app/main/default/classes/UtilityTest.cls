/*
*  @classname  		: UtilityTest
*  @author 			: Sarjerao Pujari
*  @ param             : none
*  @description  		: UtilityTest class is used to test all the comman method of utility class.

*  @modificationlog
*  	#		Date				 Description				Modified By
*		1.	    22-12-2023			 Added Comments			    sarjerao Pujari
*/
@isTest
public class UtilityTest {
    
    /**
* @ methodname             : createTestData.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : Account,Contact,Template__c,WhatsApp_Template__c,Send_Configuration__c.
* @ param                  : none.
* @ description            : this createTestData method is used to create a data for testing.
* @ return                 : none.
*/
    @TestSetup
    public static void createTestData(){
        List<Account> getAccounts = TestDataFactory.getAccounts(5, true);
        List<Contact> getContacts = TestDataFactory.getAccountContacts(10, getAccounts[0].Id, true);
        List<Template__c> getTemplate = TestDataFactory.createTemplate(10, true);
        List<WhatsApp_Template__c> getWhatsAppTemplate = TestDataFactory.createWhatsAppTemplate(getTemplate[0].Id, 1, true);
        List<Send_Configuration__c> sbcList = TestDataFactory.createSBCRecords(1,'Contact');
    }
    
    /**
* @ methodname             : replaceMessageWhatsAppTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method used to Test the replaced message to whatsApp supported formate(bold, italic and strike).
* @ return                 : none.
*/
    @isTest
    public static void replaceMessageWhatsAppTest(){
        
        String msgBody = '<strong>Hello Good Morning</strong>';
        Test.startTest();
        String ChangeBody = Utility.replaceMessageWhatsApp(msgBody);
        Test.stopTest();
        
        System.assertEquals('*Hello Good Morning*', changeBody, 'Message replacement failed');
    }
    
    /**
* @ methodname             : createOutboundMessagesAndConversationsTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : Contact,Outbound_Message__c,WhatsApp_Template__c.
* @ param                  : none.
* @ description            : This method Test the outbound record and conversation to Dataservice classs to create record.
* @ return                 : none.
*/
    @isTest
    public static void createOutboundMessagesAndConversationsTest(){
        Id whatsAppTemplateObj = [Select Id, Name__c From WhatsApp_Template__c Limit 1].Id;
        string objAPIName = 'Contact';
        List<Contact> contactObjList = [Select Id, Name, AssistantPhone From Contact];
        List<Outbound_Message__c> outboundMsgList = new List<Outbound_Message__c>();
        Outbound_Message__c outBoundObj = new Outbound_Message__c();
        outBoundObj.Channel__c = 'WhatsApp';
        outBoundObj.Message_Text__c = 'Hello ... Good Morning';
        outBoundObj.Mobile__c = '917083702342';
        outBoundObj.SentTime__c = system.now();
        outBoundObj.WhatsApp_Template__c = whatsAppTemplateObj;
        outBoundObj.Source_Record_Id__c = contactObjList[0].Id;
        outBoundObj.Media__c = '917756805014';
        outboundMsgList.add(outBoundObj);
        List<String> recordIds = new List<String>();
        recordIds.add(contactObjList[0].Id);
        Map<String, Object> mapChannelRequest = new Map<String, Object>();
        
        mapChannelRequest.put('records', contactObjList);
        mapChannelRequest.put('recordIds', recordIds);
        mapChannelRequest.put('objectAPIName', 'Contact');
        mapChannelRequest.put('mobileFieldAPIName', 'AssistantPhone');
        mapChannelRequest.put('nameFieldAPIName', 'Name');
        mapChannelRequest.put('templateId', whatsAppTemplateObj);
        mapChannelRequest.put('messageText', 'Hello Good Morning');
        
        Test.setMock(HttpCalloutMock.class, new UtilityMock());
        WhatsAppServiceHandler handler = new WhatsAppServiceHandler();
        
        Test.startTest();
        ApexResultSet result =  WhatsAppService.process(mapChannelRequest);
        Utility.createOutboundMessagesAndConversations(outboundMsgList,objAPIName);
        Test.stopTest();
        
        System.assertNotEquals(null, outBoundObj.Id, 'Outbound message creation failed');
        System.assertEquals(true, result.isSuccess);
        
    }
    
    /**
* @ methodname             : getMergedMessageTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : Contact,Template__c.
* @ param                  : none.
* @ description            : This method is used to test the updated SF fields by values.
* @ return                 : none.
*/
    @isTest
    public static void getMergedMessageTest(){
        List<Contact> conList = [Select Id, Name From Contact Limit 10];
        String unmergedMessage = '<strong> Good Morning';
        String objectAPIName = 'Contact';
        String templateId = [Select Id, Name From Template__c Limit 1].Id;
        
        Test.startTest();
        Map<String,Object> getMergedMessageResult = Utility.getMergedMessage(conList, unmergedMessage, objectAPIName, templateId);
        Test.stopTest();
        System.assertNotEquals(null, getMergedMessageResult, 'Merged message retrieval failed');
    }
    
    
        /**
* @ methodname             : getMergedMessageBoleanTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : Contact,Template__c.
* @ param                  : none.
* @ description            : This method is used to test if we get merged messages.
* @ return                 : none.
*/
    @isTest
    public static void getMergedMessageBoleanTest(){
        List<Contact> conList = [Select Id, Name From Contact Limit 10];
        String unmergedMessage = '<strong> Good Morning';
        String objectAPIName = 'Contact';
        String templateId = [Select Id, Name From Template__c Limit 1].Id;
        
        Test.startTest();
        Map<String,Object> getMergedMessageResult = Utility.getMergedMessage(conList, unmergedMessage, objectAPIName, templateId,true);
        Test.stopTest();
        System.assertNotEquals(null, getMergedMessageResult, 'Merged message retrieval failed');
    }
    
    
    
    /**
* @ methodname             : getTemplateTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : Template__c.
* @ param                  : none.
* @ description            : This method is used to test if it returns list of template records.
* @ return                 : none.
*/
    @isTest
    public static void getTemplateTest(){
        
        Test.startTest();
        List<Template__c>  tempList = Utility.getTemplate();
        Test.stopTest();
        System.assertNotEquals(null, tempList, 'Template list retrieval failed');
    }
    
    
    /**
* @ methodname             : getTemplateFromTemplateIdTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : WhatsApp_Template__c.
* @ param                  : none.
* @ description            : This method Test the WhatsApp_Template__c object for specified template Id.
* @ return                 : none.
*/
    @isTest
    public static void getTemplateFromTemplateIdTest(){
        
        String whatsApptemplateId = [Select Id, Name From WhatsApp_Template__c Limit 1].Id;
        Test.startTest();
        WhatsApp_Template__c getWhatsAppTemplate = Utility.getTemplateFromTemplateId(whatsApptemplateId);
        Test.stopTest();
        System.assertNotEquals(null, getWhatsAppTemplate);
    }
    
    /**
* @ methodname             : getAllChannelsMapTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Test the active channel records in the form of map.
* @ return                 : none.
*/
    @isTest
    static void getAllChannelsMapTest() {
        Test.startTest();
        Object channelMtdtObj = Utility.getAllChannelsMap();
        Test.stopTest();
        System.assertNotEquals(null, channelMtdtObj);
    }
    
    /**
* @ methodname             : getAllWebhookConfigurationsTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Test the all webhook configurations.
* @ return                 : none.
*/
    @isTest
    static void getAllWebhookConfigurationsTest() {
        Test.startTest();
        Object getWeebhookResult = Utility.getAllWebhookConfigurations('WhatsApp');
        Test.stopTest();
        System.assertNotEquals(null, getWeebhookResult);
    }
    
    
    /**
* @ methodname             : approvedWhatsAppTemplateTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Test the Approved whatsApp Templates.
* @ return                 : none.
*/
    @isTest
    static void approvedWhatsAppTemplateTest() {
        Test.startTest();
        List< WhatsApp_Template__c>  getWeebhookResult = Utility.approvedWhatsAppTemplate(false,'Contact');
        Test.stopTest();
        System.assertNotEquals(null, getWeebhookResult);
    }
    
    
    /**
* @ methodname             : approvedWhatsAppTemplateBolleanFalseTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : WhatsApp_Template__c.
* @ param                  : none.
* @ description            : This method Test the Approved whatsApp Templates.
* @ return                 : none.
*/
    @isTest
    static void approvedWhatsAppTemplateBolleanFalseTest() {
        Test.startTest();
        List< WhatsApp_Template__c>  getWeebhookResult = Utility.approvedWhatsAppTemplate(true,'Lead');
        Test.stopTest();
        System.assertNotEquals(null, getWeebhookResult);
    }
    
    
    /**
* @ methodname             : getQuickTextListTest.
* @ author                 : Nikita Powar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Test QuickText List.
* @ return                 : none.
*/
    @isTest
    static void getQuickTextListTest() {
        Test.startTest();
        List<QuickText>  getQuickTextResult = Utility.getQuickTextList();
        Test.stopTest();
        System.assertNotEquals(null, getQuickTextResult);
    }
    
    /**
* @ methodname             : getAllSendButtonConfigsTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Test List of sendConfiguration.
* @ return                 : none.
*/
    @isTest
    public static void getAllSendButtonConfigsTest(){
        
        Test.startTest();
        Map<string,Send_Configuration__c>  getButtonConfigResult = Utility.getAllSendButtonConfigs('Contact');
        Test.stopTest();
        System.assertNotEquals(null, getButtonConfigResult);
        
    }
    
    
    /**
* @ methodname             : getAllActiveApprovedTemplatesNullTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : WhatsApp_Template__c.
* @ param                  : none.
* @ description            : This method Test the all active approved templates.
* @ return                 : none.
*/
    @isTest
    public static void getAllActiveApprovedTemplatesNullTest(){
        
        Test.startTest();
        List<WhatsApp_Template__c>  getAllActiveAppTemp = Utility.approvedWhatsAppTemplate(false,'Contact');
        Test.stopTest();
        System.assertNotEquals(null, getAllActiveAppTemp);
    }
    
    
    /**
* @ methodname             : getSessionIdTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Tests the session ID.
* @ return                 : none.
*/
    @isTest
    public static void getSessionIdTest(){
        
        Test.startTest();
        Object sessionId = Utility.getSessionId();
        Test.stopTest();
        System.assertNotEquals(null, sessionId);
    }
    
    /**
* @ methodname             : getAllActiveApprovedTemplatesTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : WhatsApp_Template__c.
* @ param                  : none.
* @ description            : This method Test List of Approved Templates.
* @ return                 : none.
*/
    @isTest
    public static void getAllActiveApprovedTemplatesTest(){
        
        Test.startTest();
        Map<string,WhatsApp_Template__c> getAllActiveAppTemp = Utility.getAllActiveApprovedTemplates('Contact', 'WhatsApp');
        Test.stopTest();
        System.assertNotEquals(null, getAllActiveAppTemp);
    }
    
    
    /**
* @ methodname             : getExistingSBCsTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Tests Existing sendConfiguration.
* @ return                 : none.
*/
    @isTest
    public static void getExistingSBCsTest(){
        
        Test.startTest();
        ApexResultSet getSBC = Utility.getExistingSBCs();
        Test.stopTest();
        List<String> sbcSourceString = new List<String>();
        sbcSourceString.add('Contact');
        system.assertEquals(sbcSourceString, getSBC.data);
    }
    
    /**
* @ methodname             : getLatestAPIVersionTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Test Latest API Version.
* @ return                 : none.
*/
    @isTest
    public static void getLatestAPIVersionTest(){
        
        Test.startTest();
        String gwtAPIVersion = Utility.getLatestAPIVersion();
        Test.stopTest();
        System.assertNotEquals(null, gwtAPIVersion);
    }
    
    /**
* @ methodname             : getAllObjectsTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Test List of all Object.
* @ return                 : none.
*/
    @isTest
    public static void getAllObjectsTest(){
        
        Test.startTest();
        Map<String,String> getAllObjectResult = Utility.getAllObjects();
        Test.stopTest();
        System.assertNotEquals(null, getAllObjectResult);
    }
    
    
    /**
* @ methodname             : testGetJsonFromStaticResource.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Test JSON from static resources.
* @ return                 : none.
*/
    @isTest
    static void testGetJsonFromStaticResource() {
        Test.startTest();
        String result = Utility.getJsonFromStaticResource('WhatsAppBITemplateJSON');
        Test.stopTest();
        System.assertNotEquals(null, result);
        
    }
    
    /**
* @ methodname             : sbcRecordFinderTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : None.
* @ param                  : none.
* @ description            : This method Test JSON from static resources.
* @ return                 : none.
*/
    @isTest
    static void sbcRecordFinderTest() {
       List<Send_Configuration__c> scRec = TestDataFactory.createSBCRecords(1, 'Account');
        Test.startTest();
        Send_Configuration__c configRec = Utility.sbcRecordFinder('Account');
        Test.stopTest();
        system.assertNotEquals(Null, configRec);
        
        
    }
    
    /**
* @ methodname             : createWebhookLogTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : none.
* @ param                  : none.
* @ description            : This method Test if webhook log is getting generated.
* @ return                 : none.
*/
    @isTest
    static void createWebhookLogTest() {
        string channel = 'WhatsApp';
        string payload = '{"messaging_product":"whatsapp","metadata":{"display_phone_number":"BUSINESS_DISPLAY_PHONE_NUMBER","phone_number_id":"BUSINESS_PHONE_NUMBER_ID"},"statuses":[{"id":"ABCDEF","status":"sent","timestamp":"1697999400000","recipient_id":"CUSTOMER_PHONE_NUMBER","conversation":{"id":"CONVERSATION_ID","expiration_timestamp":"CONVERSATION_EXPIRATION_TIMESTAMP","origin":{"type":"user_initiated"}},"pricing":{"billable":true,"pricing_model":"CBP","category":"service"}}]}';
        Test.startTest();
        Utility.createWebhookLog(channel, payload);
        Test.stopTest();
        
    }
    
    /**
* @ methodname             : getTargetSourceTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : WhatsApp_Template__c.
* @ param                  : none.
* @ description            : This method is to Test if it returns target source.
* @ return                 : none.
*/
    @isTest
    static void getTargetSourceTest() {
        
        List<WhatsApp_Template__c> whatsAppTemplateRec = [Select Id From WhatsApp_Template__c];
        string recId = whatsAppTemplateRec[0].Id;
        Test.startTest();
        string trgetSource = Utility.getTargetSource(recId);
        Test.stopTest();
        system.assertEquals('Contact',trgetSource);
        
    }
    
    /**
* @ methodname             : getTemplateDataTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : Template__c.
* @ param                  : none.
* @ description            : This method is to Test if it returns template record.
* @ return                 : none.
*/
    @isTest
    static void getTemplateDataTest() {
        
        List<Template__c> tempRec = [Select Id From Template__c];
        String tempRecId = tempRec[0].Id;
        Test.startTest();
        Template__c getTemplateRec = Utility.getTemplateData(tempRecId);
        Test.stopTest();
        system.assertNotEquals(Null,getTemplateRec);
        
    }
    
    
    /**
* @ methodname             : getWhatsAppTemplateTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : WhatsApp_Template__c.
* @ param                  : none.
* @ description            : This method is to Test if it returns WhatsApp_Template__c source.
* @ return                 : none.
*/
    @isTest
    static void getWhatsAppTemplateTest() {
        
        List<WhatsApp_Template__c> TempRec = [Select Id From WhatsApp_Template__c];
        String tempRecId = TempRec[0].Id;
        Test.startTest();
        WhatsApp_Template__c getWhatsappTemplateRec = Utility.getWhatsAppTemplate(tempRecId);
        Test.stopTest();
        system.assertNotEquals(Null,getWhatsappTemplateRec);
        
    }
    
        /**
* @ methodname             : getApprovedWhatsAppTemplateTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : WhatsApp_Template__c.
* @ param                  : none.
* @ description            : This method is to test if it returns WhatsApp Template.
* @ return                 : none.
*/
    @isTest
    static void getApprovedWhatsAppTemplateTest() {
        
        WhatsApp_Template__c getWhatsAppTemplate =[Select ID, Status__c, Whatsapp_Approval_Status__c 
                                                   From WhatsApp_Template__c];
        getWhatsAppTemplate.Status__c = 'Approved';
        getWhatsAppTemplate.Whatsapp_Approval_Status__c = 'APPROVED';
        getWhatsAppTemplate.Template_Type__c = 'Business Initiative';
        update getWhatsAppTemplate;
        Test.startTest();
        List<WhatsApp_Template__c> approvedWhatsappTemp = Utility.getApprovedWhatsAppTemplate();
        Test.stopTest();
        system.assertNotEquals(Null,approvedWhatsappTemp);
        
    }
    
            /**
* @ methodname             : getSupportdLanguageWhatsAppTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : none.
* @ param                  : none.
* @ description            : This method is to test if it returns get Supported_Language__mdt metadata.
* @ return                 : none.
*/
    @isTest
    static void getSupportdLanguageWhatsAppTest() {
        
        Test.startTest();
        List<Supported_Language__mdt> languageMtdt= Utility.getSupportdLanguageWhatsApp();
        Test.stopTest();
        
    }
}