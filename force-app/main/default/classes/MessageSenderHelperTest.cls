@isTest
public class MessageSenderHelperTest {
/**
* @methodname		         createTestData
* @author				     Nikita Pawar
* @objectreferenced	         template__c, User, WhatsApp_Template__c
* @description			     method to create test data.
*/     
    @testSetup
    public static void createTestData(){
       List<Contact> contactList = TestDataFactory.createContacts(1);
    }
}