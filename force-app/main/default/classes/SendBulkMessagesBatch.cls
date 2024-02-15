/**
 * @classname			SendBulkMessagesBatch
 * @author				Rati Kulkarni
 * @date                28-August-2023
 * @description			This Batch is used to send bulk WhatsApp messages.
 * @modificationlog     
 *                      1.0 Ganesh Bhakare : Added code to calculate sucess and failure count of messages.
 */

public with sharing class SendBulkMessagesBatch implements  Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful{
    
    public list<String> recordIds = new list<String>(); 
    public Map<String,Object> mapParameters = new Map<String,Object>();
    list<String> phoneFieldList = new List<string>();
    public string templateId;
    public string phoneFields;
    public string phoneFieldAPIName;
    public string nameFieldAPIName;  
    public string channelName;  
    public string objectName;
    public String reportId;
    public integer successCount = 0;
    public integer failureCount = 0;
    public Id parentRecId;
    public date scheduleEndDate;
    public boolean isScheduledInvoked = false;
    public string reportFilter;        //Nikita P --> added Code on 06-11-2023
    public string filterReportId;      //Nikita P --> added Code on 06-11-2023
    
    // constuctor if bach is called for Listview records
    public SendBulkMessagesBatch(Map<String,Object> mapParameters){
        system.debug('SendBulkMessagesBatch mapParameters :'+mapParameters);
        this.mapParameters = mapParameters;
        this.recordIds = (List<String>)mapParameters.get('recordIds');
        this.templateId = (String)mapParameters.get('templateId');
        this.phoneFieldList = (List<String>)mapParameters.get('phoneFieldName');
        this.nameFieldAPIName = (String)mapParameters.get('nameFieldName');
        this.objectName = (String)mapParameters.get('objectName');
        this.channelName = (String)mapParameters.get('channel');
        this.filterReportId = (String)mapParameters.get('reportId');       //Nikita P --> added Code on 06-11-2023
        this.reportFilter = (string)mapParameters.get('filterCritera');    //Nikita P --> added Code on 06-11-2023
        if(this.phoneFieldList.size() > 0){
            this.phoneFieldAPIName = this.phoneFieldList[0];
        } 
    }

    // constructor for Scheduled jobs 
    public SendBulkMessagesBatch(Schedule_Communication__c objScheduleCommunication) {
        isScheduledInvoked = true;
        parentRecId = objScheduleCommunication.Id;
        scheduleEndDate = objScheduleCommunication.End_Date__c;
        if(objScheduleCommunication.Report_Id__c != null){ // If it is scheduled for report 
            this.reportId = objScheduleCommunication.Report_Id__c;
            this.recordIds = (List<String>)ReportUtility.getReportDetails(this.reportId); // get records for selected report Id.
        }else{ //csv logic
            ContentVersion cv = [SELECT Id,ContentDocumentId,FileExtension,Title,VersionData 
                  FROM ContentVersion 
                  WHERE id =: objScheduleCommunication.ContentVersion_Id__c];
                  system.debug('@@ content version '+cv.Id);
            this.recordIds = cv.VersionData.toString().split(',');
            system.debug('@@  this.recordIds '+ this.recordIds);
        }

        this.channelName = objScheduleCommunication.Channel_Name__c;
        this.templateId = objScheduleCommunication.Template_Id__c;
        this.phoneFieldList = String.valueOf(objScheduleCommunication.Recipient_Field__c).split(',');
        this.nameFieldAPIName = objScheduleCommunication.Name_Field__c;
        this.objectName = objScheduleCommunication.Object_Name__c;
        if(this.phoneFieldList.size() > 0){
            this.phoneFieldAPIName = this.phoneFieldList[0];
        }
    }
        
 /**
   * @methodname		    start
   * @author				Rati Kulkarni
   * @objectreferenced	    Database
   * @params 				Database.BatchableContext
   * @description			start Method to get records for list of recordIds.
   * @return				records for recordIds.
   */
    //public  Database.QueryLocator start(Database.BatchableContext BC)
    public  List<SObject> start(Database.BatchableContext BC)
    {

        String query;
        if(this.reportFilter == null){
            query = 'SELECT {0} , {1} FROM {2} WHERE Id IN : recordIds';
        }Else {
            query = 'SELECT {0} , {1} FROM {2} WHERE reportFilter'; 
        }
        Map<String,Object> queryBindValues = new Map<String, Object>{'recordIds'=>recordIds};

        List<String> queryVariables = new List<String>();
        queryVariables.add(String.escapeSingleQuotes(this.nameFieldAPIName));
        queryVariables.add(String.escapeSingleQuotes(this.phoneFieldAPIName));
        queryVariables.add(String.escapeSingleQuotes(this.objectName));
        query = String.format(query, queryVariables);
        return Database.queryWithBinds(query,queryBindValues,AccessLevel.USER_MODE);
    }
  
    /**
   * @methodname		    execute
   * @author				Ganesh Bhakare
   * @objectreferenced	    Database,SObject
   * @params 				Database.BatchableContext,List<SObject>
   * @description			This method will invoke send method in each transaction.  .
   * @return				nothing.
   */
    public void execute(Database.BatchableContext BC,List<SObject> recipientRecords)
    {
        Map<String,Object> dataToBeSent = new Map<String,Object>();
        system.debug('@@ recipientRecords.size() :'+recipientRecords.size());
        dataToBeSent.put('records',recipientRecords);
        //dataToBeSent.put('recordIds',recordIds);
        List<String> recIds = new List<String>();
        for(SObject rec : recipientRecords){
            recIds.add(rec.Id);
        }
        dataToBeSent.put('recordIds',recIds);
        dataToBeSent.put('objectAPIName',objectName);
        dataToBeSent.put('mobileFieldAPIName',phoneFieldAPIName);
        dataToBeSent.put('nameFieldAPIName',nameFieldAPIName);
        dataToBeSent.put('templateId',templateId);
        dataToBeSent.put('channel',channelName);
        
        Map<String,Integer> returnedMap = SendBulkMessageBatchService.processData(dataToBeSent);
        system.debug('@@ returnedMap '+returnedMap);
        if(returnedMap.containsKey('failCount')){
            failureCount += returnedMap.get('failCount');
            system.debug('@@ failureCount batch'+failureCount);
        }if(returnedMap.containsKey('successCount')){
            successCount += returnedMap.get('successCount');
            system.debug('@@ successCount batch'+successCount);
        } 
    }

    /**
   * @methodname		    finish
   * @author				Ganesh Bhakare
   * @objectreferenced	    Database,SObject
   * @params 				Database.BatchableContext
   * @description			This method will Abort Scheduling job if enddate < next scheduled date.
   * @return				nothing.
   */
    public void finish(Database.BatchableContext BC) {
        // remove current item and fetch next item for further iteration.
        /*if(this.phoneFieldList.size()> 1){
            this.phoneFieldList.remove(0);
            if(this.mapParameters.isEmpty()){
                this.mapParameters.put('recordIds',this.recordIds);
                this.mapParameters.put('templateId',this.templateId);
                this.mapParameters.put('nameFieldName',this.nameFieldAPIName);
                this.mapParameters.put('objectName',this.objectName);
                this.mapParameters.put('channel',this.channelName);
            }
            this.mapParameters.put('phoneFieldName',this.phoneFieldList);
            SendBulkMessagesBatch sendBulkMsg = new SendBulkMessagesBatch(this.mapParameters);
            Database.executeBatch(sendBulkMsg, 50);
          }*/
         /* system.debug('@@ isScheduledInvoked '+isScheduledInvoked);
          system.debug('@@ failureCount finish'+failureCount);
          system.debug('@@ successCount finish'+successCount);*/
        if(isScheduledInvoked){
            Schedule_Logs__c objScheduleLogs = new Schedule_Logs__c();
            objScheduleLogs.Total_Fail__c = failureCount;
            objScheduleLogs.Total_Success__c = successCount;
            objScheduleLogs.Schedule_Communication__c = parentRecId;
            objScheduleLogs.Name = 'Schedule Detail Rec';
            //create Schedule communication Details record
            insert objScheduleLogs;
            Schedule_Communication__c sc = [SELECT Job_ID__c 
                                            FROM Schedule_Communication__c 
                                            WHERE Id=:parentRecId 
                                            LIMIT 1];
            
            // get next Schedule date and time
            date todayDate = date.today();
            CronTrigger ct = [SELECT Id, NextFireTime 
                              FROM CronTrigger 
                              WHERE Id=:sc.Job_ID__c limit 1];
            if(ct!= null){
            //Stop next scheduling, if Next Schedule date time is greater than schedule EndDate
            if(ct.NextFireTime > scheduleEndDate){
                System.abortJob(ct.Id);
            }
          }
        }
    }
}