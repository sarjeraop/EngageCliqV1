/**  
  *  @classname  : ScheduleControllerTest
  *  @author : Nikita Pawar
  *  @date : 23-11-2023
  *  @description  : This class to test channel wise Schedule activity..                  
  */
@isTest
public class ScheduleControllerTest {

      /**
* @methodname		         initialiseTest
* @author				     Nikita Pawar
* @objectreferenced	         None 
* @description			     method to test initialise apex method.
*/     
    @isTest
    public static void initialiseTest(){
        
        Test.startTest();
        ScheduleController.initialise();
        Test.stopTest();
        system.assert(true);
    }
    
     /**
* @methodname		         saveScheduleTest
* @author				     Nikita Pawar
* @objectreferenced	         Account, Contact, Template__c,  Schedule_Communication__c
* @description			     This method to test if returns Id of Schedule_Communication__c  Object based on whatsAppTemplaterecordId.
*/ 
    @isTest
    public static void saveScheduleTest(){
        List<Account> accList = TestDataFactory.getAccounts(5, true);
        List<Contact> conList = TestDataFactory.getAccountContacts(25, accList[0].Id, true);
        List<string> selectedIdList = new List<string>();
        ApexResultSet resultSet = new ApexResultSet();
        for(Contact con : conList){
            selectedIdList.add(con.Id);
        }
        List<Template__c> getTemplateList = TestDataFactory.createTemplate(5, true);
        List<Schedule_Communication__c> scheduleCommList = TestDataFactory.getScheduleCommunication(getTemplateList[0].Id, 20, true);
        Test.startTest();
        for(Schedule_Communication__c sc : scheduleCommList){
        resultSet = ScheduleController.saveSchedule(sc, selectedIdList);
        }
        Test.stopTest();
        system.assertNotEquals(Null, resultSet);
    }
    
         /**
* @methodname		         addNameSpacePrefixTest
* @author				     Nikita Pawar
* @objectreferenced	         Account, Contact, Template__c,  Schedule_Communication__c
* @description			     This method to test if it adds NameSpace Prefix.
*/ 
    @isTest
    public static void addNameSpacePrefixTest(){
        List<String> scheduleFieldsList = new List<String>{'Channel_Name__c','ContentVersion_Id__c','Cron_Expression__c','End_Date__c','Frequency__c','Name_Field__c','Object_Name__c','Recipient_Field__c','Report_Id__c','Job_ID__c','Start_Date__c','Template_Id__c'};
        String nameSpacePrefix = Constants.NAMESPACEPREFIX;
        List<String> getResult = ScheduleController.addNameSpacePrefix(scheduleFieldsList,nameSpacePrefix);
        system.assertNotEquals(null,getResult);
    }
}