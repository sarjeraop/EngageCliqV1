/**  
*  @classname    : WhatsAppTemplateControllerTest
*  @author       : Nikita Pawar
*  @date         : 16-11-2023
*  @description  : This class tests all the features of classs WhatsAppTemplateController.                  
*/
@isTest
public class WhatsAppTemplateControllerTest {
    
    /**
* @methodname		         createTestData
* @author				     Nikita Pawar
* @objectreferenced	         template__c, User, WhatsApp_Template__c
* @description			     method to create test data.
*/     
    @testSetup
    public static void createTestData(){
        List<template__c>tmpList = TestDataFactory.createTemplate(1,true);
        List<WhatsApp_Template__c> WPtmpList = TestDataFactory.createWhatsAppTemplate(tmpList[0].Id,1, true);
        
        // Create User to assign Permission Set 
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
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'].Id  
        );
        insert testUser;
    }
    
    /**
* @methodname            getAllApprovedWhatsAppTemplateTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method used to test whether able get all approved whatsApp template from org.
*/
    @istest
    static void getAllApprovedWhatsAppTemplateTest(){
        Test.startTest();
        String jsonString = 'https://graph.facebook.com/v17.0/106473345515586/message_templates?fields=id,name,status,category,language,components&status=APPROVED';
        ApexResultSet resultset =  WhatsAppTemplateController.getAllApprovedWhatsAppTemplate(jsonString);
        Test.stopTest();
        System.assertEquals(false, resultset.isSuccess); 
    }
    
    /**
* @methodname            getSupportdLanguageWhatsAppTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method used to test whether able get supported language metadata for whatsApp Template.
*/
    @istest
    static void getSupportdLanguageWhatsAppTest(){
        Test.startTest();
        ApexResultSet resultset =  WhatsAppTemplateController.getSupportdLanguageWhatsApp();
        Test.stopTest();
        System.assertEquals(true, resultset.isSuccess);  
    }
    
      /**
* @methodname            getSupportdLanguageWhatsAppaCatchTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method used to test whether able get supported language metadata for whatsApp Template.
*/
    @istest
    static void getSupportdLanguageWhatsAppaCatchTest(){
        user testUser = [Select Id, Email 
                         From User 
                         Where Email = 'engagecliq@test.com'
                         Limit 1];
        System.runAs(testUser) {
        Test.startTest();
        ApexResultSet resultset =  WhatsAppTemplateController.getSupportdLanguageWhatsApp();
        Test.stopTest();
        System.assertEquals(false, resultset.isSuccess);  
        }
    }
    
    /**
* @methodname            getWhatsAppTemplateTest
* @author                Nikita Pawar
* @objectreferenced      WhatsApp_Template__c
* @description           This method used to test whether able to returns WhatsAppTemplate Object based on whatsAppTemplaterecordId.
*/
    @istest
    static void getWhatsAppTemplateTest(){
        String Id = [Select Id from WhatsApp_Template__c limit 1].Id;
        Test.startTest();
        ApexResultSet resultset =  WhatsAppTemplateController.getWhatsAppTemplate(Id);
        Test.stopTest();
        System.assertNotEquals(null, ((WhatsApp_Template__c)resultset.data)); 
    }
    
    /**
* @methodname            getWhatsAppTemplateNullTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method used to test if getting exception.
*/
    @istest
    static void getWhatsAppTemplateNullTest(){
        Test.startTest();
        ApexResultSet resultset =  WhatsAppTemplateController.getWhatsAppTemplate(null);
        Test.stopTest();
        System.assertEquals(null, ((WhatsApp_Template__c)resultset.data)); 
    }
    
    /**
* @methodname            initialiseWhatsAppTemplateExcTest
* @author                Nikita Pawar
* @objectreferenced      User
* @description           This method used to test if User do not have permission to create WhatsApp template.
*/    
    @istest
    static void initialiseWhatsAppTemplateExcTest(){
        user testUser = [Select Id, Email 
                         From User 
                         Where Email = 'engagecliq@test.com'
                         Limit 1];
        System.runAs(testUser) {
            Test.startTest();
            ApexResultSet resultset =  WhatsAppTemplateController.initialiseWhatsAppTemplate();
            Test.stopTest();
            System.assertEquals(false, resultset.isSuccess, 'User do not have permission to create WhatsApp template');
        }
    }
    
    /**
* @methodname            initialiseWhatsAppTemplateTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method used to test if User have permission to create WhatsApp template.
*/    
    @istest
    static void initialiseWhatsAppTemplateTest(){
        Test.startTest();
        ApexResultSet resultset =  WhatsAppTemplateController.initialiseWhatsAppTemplate();
        Test.stopTest();
        System.assertEquals(true, resultset.isSuccess, 'User have permission to create WhatsApp template');
    }
    
        /**
* @methodname            initialiseWhatsAppTemplateCatchTest
* @author                Nikita Pawar
* @objectreferenced      user
* @description           This method used to test negative scenario with user permission.
*/    
    @istest
    static void initialiseWhatsAppTemplateCatchTest(){
        user testUser = [Select Id, Email 
                         From User 
                         Where Email = 'engagecliq@test.com'
                         Limit 1];
        System.runAs(testUser) {
        Test.startTest();
        ApexResultSet resultset =  WhatsAppTemplateController.initialiseWhatsAppTemplate();
        Test.stopTest();
        System.assertEquals(false, resultset.isSuccess, 'User have permission to create WhatsApp template');
        }
    }
    
    /**
* @methodname            saveWhatsAppTemplateTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method used to test if method creates Template and WhatsAppTemplate Object.
*/ 
    @istest
    static void saveWhatsAppTemplateTest(){
        String jsonValue = '{"templateObject":{"sobjectType":"Template__c","'+Constants.NAMESPACEPREFIX+'Target_Source__c":"Contact","'+Constants.NAMESPACEPREFIX+'Name__c":"df"},"whatsAppTemplateObject":{"'+Constants.NAMESPACEPREFIX+'Template_Type__c":"Business Initiative","'+Constants.NAMESPACEPREFIX+'Name__c":"test_bot","'+Constants.NAMESPACEPREFIX+'Language__c":"en_US","'+Constants.NAMESPACEPREFIX+'Status__c":"Approved","'+Constants.NAMESPACEPREFIX+'WhatsApp_Category__c":"UTILITY","'+Constants.NAMESPACEPREFIX+'IsActive__c":true,"JSON_Payload__c":"","JSON_Wrapper__c":""},"language":"en_US","targetObject":"Contact","body":"This is a test Message","messageType":"Button","headerBody":"Sample Test","footerBody":"SF","buttonValues":[{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Satisfactory","phone_number_OR_url":"","id":1},{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Awesome","phone_number_OR_url":"","id":2}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
        ApexResultSet resultset =  WhatsAppTemplateController.saveWhatsAppTemplate(jsonValue);
        Test.stopTest();
        System.assertEquals(true, resultset.isSuccess);
        
    }
    
    /**
* @methodname            saveWhatsAppTemplateExcTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method used to test if saveWhatsAppTemplate method able to handle exception.
*/     
    @istest
    static void saveWhatsAppTemplateExcTest(){
        String jsonValue = '{"templateObjectdsxdfxdf":{"'+Constants.NAMESPACEPREFIX+'Target_Source__c":"Contact","'+Constants.NAMESPACEPREFIX+'Name__c":"df"},"whatsAppTemplateObject":{"'+Constants.NAMESPACEPREFIX+'Template_Type__c":"Business Initiative","Name":"test_bot","'+Constants.NAMESPACEPREFIX+'Language__c":"en_US","Status__c":"Approved","WhatsApp_Category__c":"UTILITY","IsActive__c":true,"JSON_Payload__c":"","JSON_Wrapper__c":""},"language":"en_US","targetObject":"Contact","body":"This is a test Message","messageType":"Button","headerBody":"Sample Test","footerBody":"SF","buttonValues":[{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Satisfactory","phone_number_OR_url":"","id":1},{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Awesome","phone_number_OR_url":"","id":2}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
        ApexResultSet resultset =  WhatsAppTemplateController.saveWhatsAppTemplate(jsonValue);
        Test.stopTest();
        System.assertEquals(false, resultset.isSuccess,'Invalid BI Template');
        
    }
    
    /**
* @methodname            getTemplateDetailsTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method used to test if able to create template and whatsApp template record.
*/     
    @istest
    static void getTemplateDetailsTest(){
        String jsonValue = '{"templateObject":{"sobjectType":"Template__c","'+Constants.NAMESPACEPREFIX+'Name__c":"Create UI Template Test","'+Constants.NAMESPACEPREFIX+'Target_Source__c":"Contact"},"whatsAppTemplateObject":{"sobjectType":"WhatsApp_Template__c","Status__c":"Draft","Name__c":"create_ui_template_test","'+Constants.NAMESPACEPREFIX+'Language__c":"en_US","'+Constants.NAMESPACEPREFIX+'Template_Type__c":"User Initiative","Message_Body__c":"<p>Hii {!FirstName}</p>","IsActive__c":true},"language":"en_US","targetObject":"Contact","body":"<p>Hii {!FirstName}</p>","media":"","messageType":"None","headerBody":"header","footerBody":"footer","mediaURL":"","buttonValues":[{"id":0,"value":""}],"sampleValues":[{"index":1,"value":"","fieldName":"FirstName","label":"Sample text for First Name"}]}';
        Test.startTest();
        ApexResultSet resultset =  WhatsAppTemplateController.getTemplateDetails(jsonValue);
        Test.stopTest();
        system.debug('apex resultset === '+ resultset);
        System.assertEquals(true, resultset.isSuccess);
        
    }
    
        /**
* @methodname            initialiseWhatsAppTemplateForApprovalButtonTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           Method to check whether user has permission to create WhatsApp template in salesforce context.
*/
    
     @istest
    static void initialiseWhatsAppTemplateForApprovalButtonTest(){
        Test.startTest();
        WhatsAppTemplateController.initialiseWhatsAppTemplateForApprovalButton();
        Test.stopTest();
    }
    
        /**
* @methodname            initialiseWhatsAppTemplateForApprovalButtoncatchTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           Method to check negative scenario whether user has permission to create WhatsApp template in salesforce context.
*/
     @istest
    static void initialiseWhatsAppTemplateForApprovalButtoncatchTest(){
        user testUser = [Select Id, Email 
                         From User 
                         Where Email = 'engagecliq@test.com'
                         Limit 1];
        System.runAs(testUser) {
        Test.startTest();
        WhatsAppTemplateController.initialiseWhatsAppTemplateForApprovalButton();
        Test.stopTest();
        }
    }
    
            /**
* @methodname            sendWhatsAppTemplateForApprovalTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method is to test if it updates WhatsAppTemplate Object.
*/
     @istest
    static void sendWhatsAppTemplateForApprovalTest(){
        string whatsAppTemplateId = [Select Id, Name From WhatsApp_Template__c Limit 1].Id;
        Test.startTest();
        WhatsAppTemplateController.sendWhatsAppTemplateForApproval(whatsAppTemplateId);
        Test.stopTest();
    }
}