/**
 * @classname	    	SchedulerHelper (ScheduleController)
 * @TestClass			SchedulerHelperTest
 * @author				Rati Kulkarni
 * @description			This class performes data preperation for Scheduling activity and schedules a job.
 *                      It includes Schedule Communication object creation, csv file creation for future references.
 * @createddate			28-August-2023
 * @modificationlog
 */

public with sharing class SchedulerHelper {

    /**
   * @methodname			saveSchedule
   * @author				Rati Kulkarni
   * @objectreferenced	    Schedule_Communication__c,ScheduledBatchable
   * @params				Schedule_Communication__c,List<String>
   * @description			This method returns Id of Schedule_Communication__c  Object based on whatsAppTemplaterecordId.
   * @return				Id of Schedule_Communication__c
   */
    @AuraEnabled
    public static String saveSchedule(Schedule_Communication__c objScheduleCommunication,List<String> selectedIdList){
        List<Schedule_Communication__c> scheduleCommunicationList = new List<Schedule_Communication__c>();
        if(selectedIdList.size()> 0 && objScheduleCommunication.Report_Id__c == null){
            // create csv file
            system.debug('@@ selectedIdList '+selectedIdList);
            objScheduleCommunication.ContentVersion_Id__c = createCSV(selectedIdList,objScheduleCommunication.Object_Name__c + '_' + objScheduleCommunication.Name_Field__c + '_'+objScheduleCommunication.Recipient_Field__c);
        }
        scheduleCommunicationList.add(objScheduleCommunication);
        //schedule a job and assign jobId here
        DatabaseService.DB_Result dbResult = DatabaseService.dbInsert(new DatabaseService.DB_Input(scheduleCommunicationList,true, true, 'SchedulerHelper'));
        
        objScheduleCommunication = (Schedule_Communication__c)dbResult.idToSObjectMap.get(dbResult.successRecordIds[0]);
    
        ScheduledBatchable s = new ScheduledBatchable(objScheduleCommunication);
        objScheduleCommunication.Job_ID__c = System.schedule('Scheduled through Engagecliq'+objScheduleCommunication.Cron_Expression__c, objScheduleCommunication.Cron_Expression__c, s); //
        //scheduleCommunicationList.add(objScheduleCommunication);
        if(objScheduleCommunication.Job_ID__c != null){
            dbResult = DatabaseService.dbUpdate(new DatabaseService.DB_Input(scheduleCommunicationList,true, true, 'SchedulerHelper'));
         }else{
            dbResult = DatabaseService.dbDelete(new DatabaseService.DB_Input(scheduleCommunicationList,true, true, 'SchedulerHelper'));
         }
                    
        return dbResult.successRecordIds[0];
    }
    
    /*create a CSV file from a list of Strings each string should be a row
    */
    /**
   * @methodname				    createCSV
   * @author				Rati Kulkarni
   * @objectreferenced	    Schedule_Communication__c,ScheduledBatchable
   * @params				Schedule_Communication__c,List<String>
   * @description			This method creates a CSV file from a list of Record Ids 
   * @return				create file.
   */
    public static String createCSV(List<String> csvRowList, String title){
        String concantenatedStr='';
        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        for(String row :csvRowList){ 
            system.debug('@@ row in csv '+row);
            i++;
            if(row != null){
                concantenatedStr += (String)row + ((i != rowListSize) ? '\n' : '');//add new line
            }
        }
        system.debug('@@ concantenatedStr '+concantenatedStr);
        title += '.csv';
        return createFile(concantenatedStr, title);
    }

    /**
   * @methodname				    createFile
   * @author				Rati Kulkarni
   * @objectreferenced	    ContentVersion
   * @params				versionData,file title
   * @description			This method creates a file from string
   * @return				create file.
   */
    public static String createFile(String versionData, String title) {
        ContentVersion cv = new ContentVersion();
        List<ContentVersion> cvList = new List<ContentVersion>();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce, the name of file to be in the library
        cv.VersionData = Blob.valueOf(versionData); //file data
        cvList.add(cv);
        DatabaseService.DB_Result dbResult = DatabaseService.dbInsert(new DatabaseService.DB_Input(cvList,true, true, 'SchedulerHelper'));  
        return dbResult.successRecordIds[0];
    }
}