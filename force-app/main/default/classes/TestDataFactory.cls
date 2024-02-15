/**
* @ classname           : TestDataFactory
* @ author              : Sarjerao Pujari
* @ date                : 23 Oct 2023
* @ description         : The TestDataFactory class is a special type of class—it is a public class that is annotated
with @isTest and can be accessed only from a running test.

* @ Modification Logs
*     #		     Date(DD/MM/YYYY)		    Description		    	 Modified By
*     1        16/10/2023             Initial Version      Sarjerao Pujari.
*/
@isTest
public class TestDataFactory
{
    
    /** @ methodname              : createContacts
*   @ author                  : Sarjerao Pujari
*   @ objectreferenced        : Contact
*   @ param                   : integer
*   @ description             : This method is specifically designed to craete a Contacts.
*   @ return                  : List<Contact>
*/
    public static List<Contact> createContacts(integer numOfContacts)
    {
        List<Contact> ContactList = new List<Contact>();
        for(Integer count = 0; count<numOfContacts; count++)
        {
            Contact ContactObj = new Contact();
            ContactObj.FirstName = 'Contact'+count;
            ContactObj.Phone = '8669106793';
            ContactObj.LastName = 'Test';
            ContactObj.AssistantPhone = '7564837855';
            ContactList.add(ContactObj);
        }
        insert ContactList;
        return ContactList;
    }
    
    /** @ methodname              : createSBCRecords
*   @ author                  : Sarjerao Pujari
*   @ objectreferenced        : Send_Configuration__c
*   @ param                   : integer
*   @ description             : This method is specifically designed to craete a Send_Configuration__c records.
*   @ return                  : List<WhatsApp_Template__c>
*/
    public static List<Send_Configuration__c> createSBCRecords(integer numOfSBC,string objName)
    {
        List<Send_Configuration__c> SBCtList = new List<Send_Configuration__c>();
        for(Integer count = 0; count<numOfSBC; count++)
        {
            Send_Configuration__c sbcObj = new Send_Configuration__c();
            sbcObj.Object_Name__c = objName;
            sbcObj.Phone_Fields__c = 'Phone';
            sbcObj.Name_Field__c = 'FirstName';
            SBCtList.add(sbcObj);
        }
        
        insert SBCtList;
        return SBCtList;
    }
    
    /** @ methodname          : getScheduleCommunicationDetail
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : Schedule_Logs__c
*   @ param                   : String, integer, boolean
*   @ description             : This method is specifically designed to craete a Schedule_Logs__c records.
*   @ return                  : List<Schedule_Logs__c>
*/
    public static List<Schedule_Logs__c> getScheduleCommunicationDetail(String scheduleCommuniID, integer numOfscheduleCommDetail, boolean isInsert){
        List<Schedule_Logs__c> scheduleCommunicationList = new List<Schedule_Logs__c>();
        for(Integer count = 0; count < numOfscheduleCommDetail; count++){
            Schedule_Logs__c schedleCommDetail = new Schedule_Logs__c();
            schedleCommDetail.Run_Time_Date__c = Date.newInstance(2023, 11, 5);
            schedleCommDetail.Total_Fail__c = 10.5;
            schedleCommDetail.Total_Success__c = 20;
            schedleCommDetail.Schedule_Communication__c = scheduleCommuniID;
            scheduleCommunicationList.add(schedleCommDetail);
        }
        if(isInsert){
            insert scheduleCommunicationList;
        }
        return scheduleCommunicationList;
    }
    
        /** @ methodname          : getScheduleCommunication
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : Schedule_Communication__c
*   @ param                   : String, integer, boolean
*   @ description             : This method is specifically designed to craete a Schedule_Communication__c records.
*   @ return                  : List<Schedule_Communication__c>
*/
    public static List<Schedule_Communication__c> getScheduleCommunication(string templateId,integer numOfscheduleComm, boolean isInsert){
        
        List<Schedule_Communication__c> scheduleCommList = new List<Schedule_Communication__c>();
        for(Integer count = 0; count < numOfscheduleComm; count++){
            Schedule_Communication__c schedleCommunicationObj = new Schedule_Communication__c();
            schedleCommunicationObj.Start_Date__c = Date.newInstance(2025, 10, 25);
            schedleCommunicationObj.End_Date__c = Date.newInstance(2025, 11, 1);
            schedleCommunicationObj.Channel_Name__c = 'WhatsApp';
            schedleCommunicationObj.Recipient_Field__c = 'Phone';
            schedleCommunicationObj.Name_Field__c = 'FirstName';
            schedleCommunicationObj.Object_Name__c = 'Contact';
            schedleCommunicationObj.Template_Id__c = templateId;
            schedleCommunicationObj.Frequency__c = 'Once';
            schedleCommunicationObj.Cron_Expression__c = '0 2 21 10/1 * ?';
            scheduleCommList.add(schedleCommunicationObj);
        }
        if(isInsert){
            insert scheduleCommList;
        }
        return scheduleCommList;
    }
    
        /** @ methodname          : getAccounts
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : Account
*   @ param                   : integer, boolean
*   @ description             : This method is specifically designed to craete a Account records.
*   @ return                  : List<Account>
*/    
    public static List<Account> getAccounts(Integer numAccounts, boolean isInsert) {
        List<Account> lstAccount = new List<Account>();
        for(Integer count = 0;count<numAccounts;count++){
            Account objAccount = new Account();
            objAccount.Name ='Name '+count;
            objAccount.BillingCity ='City '+count;
            objAccount.BillingState ='State '+count;
            lstAccount.add(objAccount);
        }
        if(isInsert){
            insert lstAccount;
        }
        return lstAccount;
    }
   
        /** @ methodname          : getAccountContacts
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : Contact
*   @ param                   : integer, Id, boolean
*   @ description             : This method is specifically designed to craete a Contact records.
*   @ return                  : List<Contact>
*/
    public static List<Contact> getAccountContacts(Integer numContacts, Id partnerAccountId, boolean isInsert) {
        List<Contact> lstContact = new List<Contact>();
        for(Integer count = 0;count<numContacts;count++){
            Contact record = new Contact();
            record.lastName = 'Name'+count;
            record.email = record.lastName +'@testemail.com';
            //record.AccountId = partnerAccountId;
            record.Department = 'Marketing';
            record.Phone = '3243234534';
            record.AssistantPhone = '917083702345';
            lstContact.add(record);
        }
        if(isInsert){
            insert lstContact;
        }
        return lstContact;
    }

        /** @ methodname          : getUser
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : User
*   @ param                   : integer, string, boolean
*   @ description             : This method is specifically designed to craete a User.
*   @ return                  : List<User>
*/    
    public static List<User> getUser(Integer numUser, string contactId,boolean isInsert){
        Profile portalProfile = [select Id, Name, UserLicense.Name
                                 from Profile
                                 where UserType = 'PowerPartner'
                                 And Name = 'Partner Community Custom'
                                 And UserLicense.Name = 'Partner Community'
                                 limit 1];
        
        List<User> userList = new List<User>();
        for(Integer Count=0; Count<numUser; count++){
            User theUser = new User();
            theUser.Username = 'test123@test.com'+Count;
            theUser.ContactId = contactId;
            theUser.ProfileId = portalProfile.Id;
            theUser.Alias = 'test123';
            theUser.Email = 'test123@test.com';
            theUser.EmailEncodingKey = 'UTF-8';
            theUser.LastName = 'McTesty';
            theUser.CommunityNickname = 'test123';
            theUser.TimeZoneSidKey = 'America/Los_Angeles';
            theUser.LocaleSidKey = 'en_US';
            theUser.LanguageLocaleKey = 'en_US';
            //Account partnerAcc =getPartnerAccount();
            //system.debug('partnerAccID '+partnerAcc.Id);
            //theUser.Contact.AccountId =partnerAcc.Id;
            userList.add(theUser);
        }
        if(isInsert){
            insert(userList);
        }
        system.debug('UserList = '+userList);
        return userList;
    }
 
        /** @ methodname          : createUser
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : none
*   @ param                   : none
*   @ description             : This method is specifically designed to craete a User.
*   @ return                  : User
*/
    public static User createUser(){
        
        User testUser = new User(
            LastName = 'last',
            Email = 'engagecliq@test.com',
            Username = 'engagecliq@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id
        );
        insert testUser;
        return testUser;
        
        
    }
    
        /** @ methodname          : getLeads
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : Lead
*   @ param                   : integer, boolean
*   @ description             : This method is specifically designed to craete a Lead records.
*   @ return                  : List<Lead>
*/
    public static List<Lead> getLeads(Integer numLead, boolean isInsert) {
        List<Lead> leadLst = New List<Lead>();
        for(Integer count = 0;count<numLead;count++){
            Lead leadObj = new Lead();
            leadObj.Company = 'Company'+count;
            leadObj.LastName = 'lead'+count;
            leadObj.Status = 'Open - Not Contacted';
            leadLst.add(leadObj);
        }
        if(isInsert){
            insert leadLst;
        }
        return leadLst;
    }

        /** @ methodname          : createTemplate
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : Template__c
*   @ param                   : integer, boolean
*   @ description             : This method is specifically designed to craete a Template__c records.
*   @ return                  : List<Template__c>
*/    
    public static List<Template__c> createTemplate(integer numOfTemplate, boolean isInsert){
        
        List<Template__c> templateList = new List<Template__c>();
        for(Integer count = 0; count<numOfTemplate; count++){
            Template__c templateObj = new Template__c();
            templateObj.IsActive__c = true;
            templateObj.Description__c = 'this is test template';
            templateObj.Name__c = 'template'+Count;
            templateObj.Target_Source__c = 'Contact';
            templateList.add(templateObj);
        }
        if(isInsert){
            insert templateList;
        }
        return templateList;
    }
    
        /** @ methodname          : createWhatsAppTemplate
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : WhatsApp_Template__c
*   @ param                   : String ,integer, boolean
*   @ description             : This method is specifically designed to craete a Template__c records.
*   @ return                  : List<Template__c>
*/    
    public static List<WhatsApp_Template__c> createWhatsAppTemplate(String templateId,integer numOfWhatsAppTemplate, boolean isInsert){
        
        List<WhatsApp_Template__c> whatsAppTemplateList = new List<WhatsApp_Template__c>();
        for(Integer count = 0; count<numOfWhatsAppTemplate; count++){
            WhatsApp_Template__c whatsAppTemplateObj = new WhatsApp_Template__c();
            whatsAppTemplateObj.Name__c = 'Welcome Template'+count;
            whatsAppTemplateObj.IsActive__c = true;
            whatsAppTemplateObj.Template_ID__c = templateId;
            whatsAppTemplateObj.JSON_Payload__c = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Test template","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"sobjectType":"WhatsApp_Template__c","Status__c":"Approved","Name":"test_bot","Language__c":"en_US","Template_Type__c":"Business Initiative","WhatsApp_Category__c":"MARKETING","IsActive__c":true,"JSON_Payload__c":"","JSON_Wrapper__c":""},"language":"en_US","targetObject":"Contact","body":"This is a test Message","media":"","messageType":"Button","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Satisfactory","phone_number_OR_url":"","id":1},{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Awesome","phone_number_OR_url":"","id":2}],"sampleValues":[],"fieldMapping":"[]"}';
            whatsAppTemplateObj.Message_Body__c ='<p>Hello, {!Name} Good Morning</p>';
            whatsAppTemplateObj.WhatsApp_Category__c = 'MARKETING';
            whatsAppTemplateObj.Template_Type__c = 'User Initiative';
            whatsAppTemplateObj.Language__c = 'en_US';
            whatsAppTemplateObj.JSON_Wrapper__c = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Test template","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"sobjectType":"WhatsApp_Template__c","Status__c":"Approved","Name":"test_bot","Language__c":"en_US","Template_Type__c":"Business Initiative","WhatsApp_Category__c":"MARKETING","IsActive__c":true,"JSON_Payload__c":"","JSON_Wrapper__c":""},"language":"en_US","targetObject":"Contact","body":"This is a test Message","media":"","messageType":"Button","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Satisfactory","phone_number_OR_url":"","id":1},{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Awesome","phone_number_OR_url":"","id":2}],"sampleValues":[],"fieldMapping":"[]"}';
            whatsAppTemplateList.add(whatsAppTemplateObj);
        }
        if(isInsert){
            insert whatsAppTemplateList;
        }
        return whatsAppTemplateList;
    }

        /** @ methodname          : createQuickTexts
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : QuickText
*   @ param                   : integer, boolean
*   @ description             : This method is specifically designed to craete a QuickText records.
*   @ return                  : List<QuickText>
*/    
    public static List<QuickText> createQuickTexts(integer numOfQuickText, boolean isInsert){
        
        List<QuickText> listOfQuickText = new List<QuickText>();
        for(Integer count = 0; count < numOfQuickText; count++){
            QuickText objQuickText = new QuickText();
            objQuickText.Name = 'quickText'+count;
            objQuickText.Message = 'Good Morining';
            listOfQuickText.add(objQuickText);
        }
        if(isInsert){
            insert listOfQuickText;
        }
        return listOfQuickText;
    }

        /** @ methodname          : createOutboundMessage
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : Outbound_Message__c
*   @ param                   : String, integer, Integer,boolean
*   @ description             : This method is specifically designed to craete a Outbound_Message__c records.
*   @ return                  : List<Outbound_Message__c>
*/    
    public static List<Outbound_Message__c> createOutboundMessage(string whatsAppTemplateId,string sourceRecordId,integer numOfOutboundMessage, boolean isInsert){
        List<Outbound_Message__c> outBoundList = new List<Outbound_Message__c>();
        for(Integer count = 0; count < numOfOutboundMessage; count++){
            Outbound_Message__c outBoundObj = new Outbound_Message__c();
            outBoundObj.Channel__c = 'WhatsApp';
            outBoundObj.Message_Text__c = 'Hello ... Good Morning';
            outBoundObj.Mobile__c = '917083702342';
            outBoundObj.SentTime__c = system.now();
            outBoundObj.WhatsApp_Template__c = whatsAppTemplateId;
            outBoundObj.Source_Record_Id__c = sourceRecordId;
            outBoundObj.Media__c = TestDataFactory.createContentDocument();
            outBoundObj.FailedTime__c = system.now();
            outBoundObj.ReadTime__c = Datetime.now();
            outBoundObj.DeliveredTime__c = Datetime.now();
            outBoundList.add(outBoundObj);
        }
        if(isInsert){
            insert  outBoundList;
        }
        return outBoundList;
        
    }

        /** @ methodname          : createStaticResourceInfo
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : StaticResource
*   @ param                   : integer
*   @ description             : This method is specifically designed to craete a StaticResource.
*   @ return                  : List<StaticResource>
*/    
    public static List<StaticResource> createStaticResourceInfo(integer numOfStaticResourceInfo){
        
        List<StaticResource> listOfStaticResourceInfo = new List<StaticResource>();
        for(Integer count = 0; count < numOfStaticResourceInfo; count++){
            StaticResource objStaticResource = new StaticResource();
            objStaticResource.name = 'objStaticResourceInfo'+count;
            listOfStaticResourceInfo.add(objStaticResource);
        }
        return listOfStaticResourceInfo;
    }
    
    string Id = '0685j00000JNo8OAAT';
    
    public static List<ContentDistribution> createContentDistribution(integer numOfContentDistribution,String Id){
        
        List<ContentDistribution> listOfContentDistribution = new List<ContentDistribution>();
        for(Integer count = 0; count < numOfContentDistribution; count++){
            ContentDistribution objContentDistribution= new ContentDistribution();
            objContentDistribution.name = 'ContentDistribution'+count;
            objContentDistribution.ContentVersionId = Id;
            listOfContentDistribution.add(objContentDistribution);
        }
        return listOfContentDistribution;
    }
  
    /** @ methodname              : createContentDocument
*   @ author                  : Sarjerao Pujari
*   @ objectreferenced        : contentVersion
*   @ param                   : none
*   @ description             : This method is specifically designed to craete a contentVersion record.
*   @ return                  : string
*/  
    public static string createContentDocument()
    {
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        List<ContentVersion> documents = [SELECT Id FROM ContentVersion];
        string ConversionId = documents[0].Id;
        TestDataFactory.createContentDistribution(1,ConversionId);
        return ConversionId;
        
    }
    
             /** @ methodname              : createInboundRecords
*   @ author                  : Sarjerao Pujari
*   @ objectreferenced        : Inbound_Message__c
*   @ param                   : none
*   @ description             : This method is specifically designed to craete a Inbound_Message__c record.
*   @ return                  : List<Inbound_Message__c>
*/   
    public static List<Inbound_Message__c> createInboundRecords()
    {
        List<Inbound_Message__c> inboundList = new List<Inbound_Message__c>();
        Inbound_Message__c objInBound = new Inbound_Message__c();
        objInBound.Message_Text__c = 'InBound Text Message';
        objInBound.Mobile__c = '8669106793';
        inboundList.add(objInBound);
        
        insert inboundList;
        return inboundList;
    }
    
    List<Contact> conList = TestDataFactory.createContacts(1);
    string recId = conList[0].id;
    public static List<Conversation__c> createConversationData(string recId)
    {
        
        List<Account> accList = TestDataFactory.getAccounts(2, true);
        List<Contact> contactRecordsList = TestDataFactory.getAccountContacts(10, accList[0].Id, true);
        List<Template__c> templateList = TestDataFactory.createTemplate(5, true);
        List<WhatsApp_Template__c> whtasAppTemplateList = TestDataFactory.createWhatsAppTemplate(templateList[0].Id, 5, true);
        List<Outbound_Message__c> getOutboundMsg = TestDataFactory.createOutboundMessage(whtasAppTemplateList[0].Id, contactRecordsList[0].Id, 10, true);
        List<Send_Configuration__c> sbc = TestDataFactory.createSBCRecords(1, 'Contact');
        TestDataFactory.createInboundRecords();
        List<Outbound_Message__c> lstOfOutBound = [select id,Message_Text__c from Outbound_Message__c];
        List<Inbound_Message__c> lstOfInbound = [select id,Message_Text__c from Inbound_Message__c];
        system.debug('@@lstOfInbound '+lstOfInbound);
        system.debug('@@lstOfInbound '+lstOfInbound);
        List<Conversation__c> conversationList = new List<Conversation__c>();
        for(Integer count = 0; count < 2; count++)
        {
            Conversation__c objConversation = new Conversation__c();
            objConversation.Inbound_Communication_Message__c = lstOfInbound[count].id;
            objConversation.Outbound_Communication_Message__c = lstOfOutBound[count].id;
            objConversation.Related_To__c = recId;
            conversationList.add(objConversation);
        }
        insert conversationList;
        return conversationList;
    }
    
    public static list<EntityDefinition> getObjects()
    {
        List<EntityDefinition> Entitylist = new List<EntityDefinition>();
        Entitylist = [SELECT Id, MasterLabel,
                      DeveloperName, QualifiedApiName FROM
                      EntityDefinition WHERE IsCustomizable = true
                      ORDER BY MasterLabel];
        
        return Entitylist;
    }
 
            /** @ methodname              : getChannelRequestMap
*   @ author                  : Sarjerao Pujari
*   @ objectreferenced        : Contact
*   @ param                   : none
*   @ description             : This method is specifically designed to craete a ChannelRequestMap record.
*   @ return                  : Map<String,Object>
*/
    public static Map<String,Object> getChannelRequestMap(){
        List<Contact> recordContact =TestDataFactory.getAccountContacts(5, Null, true);
        List<String> recordIds = new List<String>();
        recordIds.add(recordContact[0].Id);
        Map<String,Object> inputData = new Map<String,Object>();
        inputData.put('recordIds', recordIds);
        inputData.put('records', recordContact);
        inputData.put('objectAPIName','Contact');
        inputData.put('mobileFieldAPIName','Phone');
        inputData.put('messageText','<p>hi</p>');
        inputData.put('document',Null);
        inputData.put('channel','WhatsApp');
        inputData.put('templateId',Null);
        return inputData;
    }

        /** @ methodname              : createChannelMap
*   @ author                  : Sarjerao Pujari
*   @ objectreferenced        : Contact
*   @ param                   : none
*   @ description             : This method is specifically designed to craete a ChannelMap record.
*   @ return                  : object
*/     
    public static object createChannelMap()
    {
        List<Contact> contactList = TestDataFactory.createContacts(1);
        map<string,object> ChannelMap = new map<string,object>();
        ChannelMap.put('records',contactList);
        ChannelMap.put('channel','WhatsApp');
        ChannelMap.put('objectAPIName','Contact');
        ChannelMap.put('messageText','Hello World');
        ChannelMap.put('mobileFieldAPIName','phone');
        return ChannelMap;
    }
 
        /** @ methodname              : createConversation
*   @ author                  : Sarjerao Pujari
*   @ objectreferenced        : Conversation__c
*   @ param                   : string
*   @ description             : This method is specifically designed to craete a Conversation__c record.
*   @ return                  : none
*/  
    public static void createConversation(string recId)
    {
        List<Conversation__c> conversationList = new List<Conversation__c>();
        Conversation__c conversationObj = new Conversation__c();
        conversationObj.Inbound_Communication_Message__r.Message_Text__c = 'InBound Message Text';
        conversationObj.Inbound_Communication_Message__r.Mobile__c = '8669106793';
        conversationObj.Outbound_Communication_Message__r.Message_Text__c = 'OutBound Message Text';
        conversationObj.Outbound_Communication_Message__r.Mobile__c = '8669106793';
        conversationObj.Related_To__c = recId;
        
        conversationList.add(conversationObj);
        system.debug('conversationList === '+ conversationList);
        insert conversationList;
        
    }
    
    /** @ methodname              : createDocumentData
*   @ author                  : Sarjerao Pujari
*   @ objectreferenced        : ContentVersion
*   @ param                   : none
*   @ description             : This method is specifically designed to craete a ContentVersion.
*   @ return                  : string
*/     
    public static string createDocumentData()
    {
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle',
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob,
            origin = 'H'
        );
        insert contentVersion_1;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        string documentId = contentVersion_2.ContentDocumentId;
        return documentId;
    }

    /** @ methodname              : CreateChannelRequestMap
*   @ author                  : Sarjerao Pujari
*   @ objectreferenced        : Template__c, WhatsApp_Template__c,Contact
*   @ param                   : integer
*   @ description             : This method is specifically designed to craete a ChannelRequestMap.
*   @ return                  : map<string,object>
*/    
    public static map<string,object> CreateChannelRequestMap()
    {
        List<Template__c> getTemplate = TestDataFactory.createTemplate(1, true);
        List<WhatsApp_Template__c> getWhatsAppTemplate = TestDataFactory.createWhatsAppTemplate(getTemplate[0].Id, 1, true);
        TestDataFactory.createContacts(1);
        List<Contact> createContact = [Select Id, Name, email, Department, Phone From Contact Limit 1];
        String templateId = [select Id from whatsApp_Template__c].Id;
        String recordIds = createContact[0].Id;
        String phoneField ='Phone';
        String nameField = 'Name';
        String objectName = 'Contact';
        Map<String,Object> mapChannelRequest = new Map<String,Object>();
        mapChannelRequest.put('recordIds',recordIds);
        mapChannelRequest.put('records',createContact);
        mapChannelRequest.put('phoneFieldName',phoneField);
        mapChannelRequest.put('mobileFieldAPIName',phoneField);
        mapChannelRequest.put('nameFieldName',nameField);
        mapChannelRequest.put('objectName',objectName);
        mapChannelRequest.put('channel','WhatsApp');
        mapChannelRequest.put('templateId',templateId);
        return mapChannelRequest;
    }
    
         /** @ methodname          : CreateObjectPermissions
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : ObjectPermissions
*   @ param                   : String, boolean, boolean,boolean,boolean,boolean,string.
*   @ description             : This method is specifically designed to craete a FieldPermissions.
*   @ return                  : ObjectPermissions
*/
    public static ObjectPermissions CreateObjectPermissions(string SObjectType, boolean PermissionsRead,boolean PermissionsCreate, boolean PermissionsEdit,boolean PermissionsDelete,boolean isInsert, string permissionSetId){
        ObjectPermissions objPermission = new ObjectPermissions();
        objPermission.SObjectType = SObjectType;
        objPermission.PermissionsRead = PermissionsRead;
        objPermission.PermissionsCreate = PermissionsCreate;
        objPermission.PermissionsEdit = PermissionsEdit;
        objPermission.PermissionsDelete = PermissionsDelete;
        objPermission.ParentId = permissionSetId;
        
        if(isInsert){
            insert  objPermission;
        }
        return objPermission;
        
    }
    
         /** @ methodname          : CreateFieldPermissions
*   @ author                  : Nikita Pawar
*   @ objectreferenced        : FieldPermissions
*   @ param                   : String, boolean, boolean,string, boolean,string.
*   @ description             : This method is specifically designed to craete a FieldPermissions.
*   @ return                  : FieldPermissions
*/ 
    public static FieldPermissions CreateFieldPermissions(String SObjectType, boolean PermissionsRead, boolean PermissionsEdit, string Field, boolean isInsert, string permissionSetId){
        FieldPermissions fieldPerm = new FieldPermissions();
        fieldPerm.SObjectType = SObjectType;
        fieldPerm.PermissionsRead = PermissionsRead;
        fieldPerm.PermissionsEdit = PermissionsEdit;
        fieldPerm.Field = Field;
        fieldPerm.ParentId = permissionSetId;
        
        if(isInsert){
            insert  fieldPerm;
        }
        return fieldPerm;
    }
}