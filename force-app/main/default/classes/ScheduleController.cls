/**  @classname    : ScheduleController
  *  @author       : Rati Kulkarni
  *  @date         : 
  *  @description  : class representing Schedule Controller to perform channel wise Schedule activity.
  *  @version      : 1.0
*/

public with sharing class ScheduleController {
     /**
   * @methodname                 Initialise
   * @author                     Rati Kulkarni
   * @objectreferenced           SecurityService
   * @params                     None
   * @description                Method to check whether user has permission to perform Schedule Feature.
   * @return                     If will return whether User has Permissions or not.
   */
  @AuraEnabled
  public static ApexResultSet initialise() {
      String nameSpacePrefix = Constants.NAMESPACEPREFIX;
      
      // Check Whether user has access to required objects to perform schedule feature.
      ApexResultSet apexResult = new ApexResultSet();
      try{
          List<String> scheduleFieldsList = new List<String>{'Channel_Name__c','ContentVersion_Id__c','Cron_Expression__c','End_Date__c','Frequency__c','Name_Field__c','Object_Name__c','Recipient_Field__c','Report_Id__c','Job_ID__c','Start_Date__c','Template_Id__c'};
         // List<String> scheduleFieldsListWithPrefix = addNameSpacePrefix(scheduleFieldsList,nameSpacePrefix); 
          SecurityService.checkInsertable('Schedule_Communication__c',scheduleFieldsList);
          List<String> scheduleCommunicationFieldsList = new List<String>{'Run_Time_Date__c','Total_Fail__c','Total_Success__c'};
         // List<String> scheduleCommunicationFieldsListWithPrefix =  addNameSpacePrefix(scheduleCommunicationFieldsList,nameSpacePrefix);
         SecurityService.checkInsertable('Schedule_Logs__c',scheduleCommunicationFieldsList);
          apexResult.isSuccess = true;
      }catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
          ApplicationLogger.logException(ex);
          //system.debug('@@ apexResult.message '+apexResult.message);
      }
      return apexResult;
  }

/**  @methodname    : saveSchedule
  *  @author        : Rati 
  *  @param         : Schedule_Communication__c,List<String> 
  *  @description   : This method returns Id of Schedule_Communication__c  Object based on whatsAppTemplaterecordId.
  *  @return        : ApexResultSet
  */
@AuraEnabled
public static ApexResultSet saveSchedule(Schedule_Communication__c objScheduleCommunication,List<String> selectedIdList){
    ApexResultSet resultSet = new ApexResultSet();
       try{
      resultSet.data = SchedulerHelper.saveSchedule(objScheduleCommunication,selectedIdList);
       }
       catch(Exception ex){
        resultSet.isSuccess = false;
        resultSet.message = ex.getMessage();
        ApplicationLogger.logException(ex);
    }
    return resultSet; 
}
    @TestVisible
    private static List<String> addNameSpacePrefix(List<String>fieldLists, String nameSpacePrefix){
        List<String> fieldsWithNameSpacePrefix = new List<String>();
        if(fieldLists.size()>0){
            for(String field: fieldLists){
            fieldsWithNameSpacePrefix.add(nameSpacePrefix+field);
        	}
        }
        return fieldsWithNameSpacePrefix;
    }
}