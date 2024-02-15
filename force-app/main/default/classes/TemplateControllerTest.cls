/**  
*  @classname      : TemplateControllerTest
*  @author         : Nikita Pawar
*  @date           : 01-12-2023
*  @description    : This class tests all the features of classs SecurityService.                  
*/
@isTest
public class TemplateControllerTest {

        /**
* @methodname		         createTestData
* @author				     Nikita Pawar
* @objectreferenced	         template__c, User
* @description			     method to create test data.
*/ 
    @testSetup
    public static void createTestData(){
       
        List<template__c> tmpList = TestDataFactory.createTemplate(1,true);

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
* @methodname            initialiseTemplateTest
* @author                Nikita Pawar
* @objectreferenced      User
* @description           This method used to test whether User has Permissions or not.
*/
    @isTest
    public static void initialiseTemplateTest(){
        
        user testUser = [Select Id, Email 
                         From User 
                         Where Email = 'engagecliq@test.com'
                         Limit 1];
        System.runAs(testUser) {
        Test.startTest();
        ApexResultSet apexResult = TemplateController.initialiseTemplate();
        Test.stopTest();
        system.assertEquals(false, apexResult.isSuccess);
        }
    }

        /**
* @methodname            getAllObjectsTest
* @author                Nikita Pawar
* @objectreferenced      User
* @description           This method used to test whether able get all object from org.
*/    
    @isTest
    public static void getAllObjectsTest(){
        
        user testUser = [Select Id, Email 
                         From User 
                         Where Email = 'engagecliq@test.com'
                         Limit 1];
        System.runAs(testUser) {
        Test.startTest();
        ApexResultSet apexResult = TemplateController.getAllObjects();
        Test.stopTest();
        system.assertEquals(false, apexResult.isSuccess);
        }
    }

        /**
* @methodname            getTemplateTest
* @author                Nikita Pawar
* @objectreferenced      
* @description           This method used to test whether able get all template from org.
*/      
    @isTest
    public static void getTemplateTest(){
       
        Test.startTest();
        ApexResultSet apexResult = TemplateController.getTemplate();
        Test.stopTest();
        system.assertEquals(false, apexResult.isSuccess);
    }

        /**
* @methodname            retrieveChannelDataTest
* @author                Nikita Pawar
* @objectreferenced      Template__c
* @description           This method used to test whether able get template and its associated child template data.
*/ 
     @isTest
    public static void retrieveChannelDataTest(){
        
        String templateId = [Select Id from Template__c limit 1].Id;
        Test.startTest();
        ApexResultSet resultset =  TemplateController.retrieveChannelData(templateId);
        Test.stopTest();
        system.assertEquals(true, resultset.isSuccess);
    }
}