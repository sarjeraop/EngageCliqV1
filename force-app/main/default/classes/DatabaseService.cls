/**
 * @name				DatabaseService
 * @TestClass			DatabaseServiceTest
 * @author				Purushottam Bhaigade
 * @description			This is database class which help to perform dml and error handling
 * 						Notes :
 * 							1.	Use collection with index in case of insert failure as insert doesn't contains
 * 								Id if records fails during insert.
 * 							2.	Use overide constructor while sending DB_Input for DML operations.
 * 
 * @createddate			
 */
public inherited sharing class DatabaseService {

    /**
     * @name				DB_Result
     * @author				Purushottam Bhaigade
     * @description			This is wrapper class holds Database operation result which can be use by caller class/method
     * @createddate			2-March-2021
     */
    public class DB_Result {

        public Map<Id, String> errorMap {get;set;}
        public Map<Id, SObject> idToSObjectMap {get;set;}
        public Map<Id, String> successMap {get;set;}
        public Map<Id, Sobject> idToSObjectSuccessOnlyMap {get;set;} // Added by Nikhil
        public boolean hasError {get;set;} // holds value to true when there is any error/exception
        public List<Id> successRecordIds {get;set;} // holds the id or records which got process successfully 
        public List<sObject> errorRecordList {get;set;}
        public Map<Integer,String> indexToErrorMessageMap {get;set;}
        public Map<Integer,SObject> indexToSObjectMap {get;set;}
        
        public DB_Result() {
            this.hasError = false;
            this.indexToSObjectMap = new Map<Integer,SObject>();
            this.idToSObjectMap = new Map<Id, SObject>();
            
            //Collection for successful records
            this.successRecordIds = new List<Id>();
            this.successMap = new Map<Id, String>();
            
            //Collection for failed records
            this.errorRecordList = new List<SObject>();
            this.errorMap = new Map<Id, String>();
            this.indexToErrorMessageMap = new Map<Integer,String>();
            this.idToSObjectSuccessOnlyMap = new Map<Id, Sobject>();
        }
    }
    
    /**
     * @name				DB_Input
     * @author				Purushottam Bhaigade
     * @description			This is wrapper class holds data which is being use in database operation along with caller class name
     * @createddate			2-March-2021
     */
    public class DB_Input {

        public List<sObject> sObjectList {get;set;} // holds list of object record which need to process
        public boolean allOrNone {get;set;} // parameter specifies whether the operation allows partial success if it
        									// set to false then it allow to process records partially
        public boolean doLogException {get;set;} // set to true if wants to log exception in Error Log object
        public String className {get;set;} // holds name of caller class
        public Schema.sObjectField uniqueFiledName {get;set;} // holds the unique field which will be used in upsert
        
        public DB_Input(sObject sObj, boolean allOrNone, boolean doLogException, String className) {
            this.sObjectList.add(sObj);
            this.allOrNone = allOrNone;
            this.doLogException = doLogException;
            this.className = className;
        }
        
        public DB_Input(List<sObject> sObjectList, boolean allOrNone, boolean doLogException, String className) {
            this.sObjectList = sObjectList;
            this.allOrNone = allOrNone;
            this.doLogException = doLogException;
            this.className = className;
        }
        
         public DB_Input(List<sObject> sObjectList, boolean allOrNone, boolean doLogException, String className,Schema.sObjectField uniqueFiledName) {
            this.sObjectList = sObjectList;
            this.allOrNone = allOrNone;
            this.doLogException = doLogException;
            this.className = className;
            this.uniqueFiledName = uniqueFiledName;
        }
    }
    
    /**
     * @name				dbInsert
     * @author				Purushottam Bhaigade
     * @objectreferenced	sObject, Database.SaveResult, Error_Log__c
     * @params				DatabaseService.DB_Input
     * @description			This is wrapper method for database insert operation which handles exception internally 
     * @return				DatabaseService.DB_Result
    */
    public static DB_Result dbInsert(DB_Input dbInput){
        
        DB_Result dbResult = new DB_Result();
        system.debug('dbResult =='+dbResult);
        
        if(dbInput == null || dbInput.sObjectList == null || dbInput.sObjectList.isEmpty()){
            return dbResult;
        }
            system.debug('@@ dbInput.sObjectList '+dbInput.sObjectList);
        List<Database.SaveResult> saveResultList = Database.insert(dbInput.sObjectList, dbInput.allOrNone);
        system.debug('saveResultList =='+saveResultList);
        
        List<Database.Error> dbErrors = new List<Database.Error> ();
        
        integer index = 0;
        for (Database.SaveResult sr : saveResultList) {
            sObject sObj = dbInput.sObjectList[index];
            
            if(sObj == null){
                continue;
            }
            
            Id sObjId = (Id) sObj.get('Id');
            
            if (sr.isSuccess()) {
                String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + sObjId;
                dbResult.successMap.put(sObjId, recordUrl);
                dbResult.successRecordIds.add(sr.getId());
                dbResult.idToSObjectMap.put(sObjId, sObj);
            }
            else {
				String errMsg = sr.getErrors()[0].getMessage();
                dbErrors.addAll(sr.getErrors());  
                dbResult.errorRecordList.add(sObj);
                dbResult.errorMap.put(sObjId, errMsg);
                dbResult.indexToErrorMessageMap.put(index, errMsg);
            }
            dbResult.indexToSObjectMap.put(index, sObj);
            index++;
        }
        dbResult = DatabaseService.logDBErrors(dbErrors, dbInput, dbResult);
        return dbResult;
    }
    
	/**
     * @name				dbUpdate
     * @author				Purushottam Bhaigade
     * @objectreferenced	sObject, Database.SaveResult, Error_Log__c
     * @params				DatabaseService.DB_Input
     * @description			This is wrapper method for database update operation which handles exception internally 
     * @return				DatabaseService.DB_Result
    */
    public static DB_Result dbUpdate(DB_Input dbInput){

        DB_Result dbResult = new DB_Result();
        
        if(dbInput == null || dbInput.sObjectList == null || dbInput.sObjectList.isEmpty()){
            return dbResult;
        }
        
        List<Database.SaveResult> saveResultList = Database.update(dbInput.sObjectList, dbInput.allOrNone);
        
        List<Database.Error> dbErrors = new List<Database.Error> ();
        
        integer index = 0;
        for (Database.SaveResult sr : saveResultList) {
            
            sObject sObj = dbInput.sObjectList[index];
            if(sObj == null){
                continue;
            }
            Id sObjId = (Id) sObj.get('Id');
            
            if (sr.isSuccess()) {
                String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + sObjId;
                dbResult.successMap.put(sObjId, recordUrl);
                dbResult.successRecordIds.add(sr.getId());
                dbResult.idToSObjectSuccessOnlyMap.put(sObjId,sObj); /*Nikhil added this*/
            }
            else {
                String errMsg = sr.getErrors()[0].getMessage();
                dbErrors.addAll(sr.getErrors());
                dbResult.errorRecordList.add(sObj);
                dbResult.errorMap.put(sObjId, errMsg);
                dbResult.indexToErrorMessageMap.put(index, errMsg);
            }
            dbResult.idToSObjectMap.put(sObjId, sObj);
            dbResult.indexToSObjectMap.put(index, sObj);
            index++;
        }
        dbResult = DatabaseService.logDBErrors(dbErrors, dbInput, dbResult);
        return dbResult;
    }
    
    /**
     * @name				dbDelete
     * @author				Purushottam Bhaigade
     * @objectreferenced	sObject, Database.SaveResult, Error_Log__c
     * @params				DatabaseService.DB_Input
     * @description			This is wrapper method for database delete operation which handles exception internally 
     * @return				DatabaseService.DB_Result
    */
    public static DB_Result dbDelete(DB_Input dbInput){
        
        DB_Result dbResult = new DB_Result();
        
        if(dbInput == null || dbInput.sObjectList == null || dbInput.sObjectList.isEmpty()){
            return dbResult;
        }
        
        List<Database.DeleteResult> deleteResultList = Database.delete(dbInput.sObjectList, dbInput.allOrNone);
        
        List<Database.Error> dbErrors = new List<Database.Error> ();
        
        integer index = 0;
        for (Database.DeleteResult dr : deleteResultList) {
            
            sObject sObj = dbInput.sObjectList[index];
            if(sObj == null){
                continue;
            }
            Id sObjId = (Id) sObj.get('Id');
            
            if (dr.isSuccess()) {
                String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + sObjId;
                dbResult.successMap.put(sObjId, recordUrl);
                dbResult.successRecordIds.add(dr.getId());
            }
            else {
                String errMsg = dr.getErrors()[0].getMessage();
                dbErrors.addAll(dr.getErrors());
                dbResult.errorRecordList.add(sObj);
                dbResult.errorMap.put(sObjId, errMsg);
                dbResult.indexToErrorMessageMap.put(index, errMsg);
            }
            dbResult.idToSObjectMap.put(sObjId, sObj);
            dbResult.indexToSObjectMap.put(index, sObj);
            index++;
        }
        dbResult = DatabaseService.logDBErrors(dbErrors, dbInput, dbResult);
        return dbResult;
    }
    
    /**
     * @name				dbUnDelete
     * @author				Purushottam Bhaigade
     * @objectreferenced	sObject, Database.SaveResult, Error_Log__c
     * @params				DatabaseService.DB_Input
     * @description			This is wrapper method for database delete operation which handles exception internally 
     * @return				DatabaseService.DB_Result
    */
    public static DB_Result dbUnDelete(DB_Input dbInput){
        
        DB_Result dbResult = new DB_Result();
        
        if(dbInput == null || dbInput.sObjectList == null || dbInput.sObjectList.isEmpty()){
            return dbResult;
        }
        
        List<Database.UndeleteResult> deleteResultList = Database.undelete(dbInput.sObjectList, dbInput.allOrNone);
        
        List<Database.Error> dbErrors = new List<Database.Error> ();
        
        integer index = 0;
        for (Database.UndeleteResult udr : deleteResultList) {
            
            sObject sObj = dbInput.sObjectList[index];
            if(sObj == null){
                continue;
            }
            Id sObjId = (Id) sObj.get('Id');
            
            if (udr.isSuccess()) {
                String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + sObjId;
                dbResult.successMap.put(sObjId, recordUrl);
                dbResult.successRecordIds.add(udr.getId());
            }
            else {
                String errMsg = udr.getErrors()[0].getMessage();
                dbErrors.addAll(udr.getErrors());
                dbResult.errorRecordList.add(sObj);
                dbResult.errorMap.put(sObjId, errMsg);
                dbResult.indexToErrorMessageMap.put(index, errMsg);
            }
            dbResult.idToSObjectMap.put(sObjId, sObj);
            dbResult.indexToSObjectMap.put(index, sObj);
            index++;
        }
        
        dbResult = DatabaseService.logDBErrors(dbErrors, dbInput, dbResult);    
        return dbResult;
    }
    
    /**
     * @name				dbUpsert
     * @author				Purushottam Bhaigade
     * @objectreferenced	sObject, Database.SaveResult, Error_Log__c
     * @params				DatabaseService.DB_Input
     * @description			This is wrapper method for database upsert operation which handles exception internally 
     * @return				DatabaseService.DB_Result
    */
    public static DB_Result dbUpsert(DB_Input dbInput){

        DB_Result dbResult = new DB_Result();
        
        if(dbInput == null || dbInput.sObjectList == null || dbInput.sObjectList.isEmpty()){
            return dbResult;
        }
        
        List<Database.UpsertResult> upsertResultList = Database.upsert(dbInput.sObjectList, dbInput.uniqueFiledName, dbInput.allOrNone);
        
        List<Database.Error> dbErrors = new List<Database.Error> ();
        
        integer index = 0;
        for (Database.UpsertResult upsr : upsertResultList) {
            
            sObject sObj = dbInput.sObjectList[index];
            if(sObj == null){
                continue;
            }
            Id sObjId = (Id) sObj.get('Id');
            
            if (upsr.isSuccess()) {
                String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + sObjId;
                dbResult.successMap.put(sObjId, recordUrl);
                dbResult.successRecordIds.add(upsr.getId());
            }
            else {
                String errMsg = upsr.getErrors()[0].getMessage();
                dbErrors.addAll(upsr.getErrors());
                dbResult.errorRecordList.add(sObj);
                dbResult.errorMap.put(sObjId, errMsg);
                dbResult.indexToErrorMessageMap.put(index, errMsg);
            }
            dbResult.idToSObjectMap.put(sObjId, sObj);
            dbResult.indexToSObjectMap.put(index, sObj);
            index++;
        }
        dbResult = DatabaseService.logDBErrors(dbErrors, dbInput, dbResult);
        return dbResult;
    }
    
    /**
     * @name				logDBErrors
     * @author				Purushottam Bhaigade
     * @objectreferenced	Error_Log__c, Database.Error
     * @params				List<Database.Error>, DB_Input, DB_Result
     * @description			This is database errorlog method which log all database related errors
     * @return				DB_Result
     */
    private static DB_Result logDBErrors(List<Database.Error> dbErrors, DB_Input dbInput, DB_Result dbResult){
        
        List<Error_Log__c> errorLogList = new List<Error_Log__c>();
        for(Database.Error err : dbErrors) {
            
            if(dbInput.doLogException){
                Error_Log__c errorLog = new Error_Log__c();
                errorLog.Error_Message__c = err.getMessage();
                errorLog.Fields__c = String.join(err.getFields(),',');
                errorLog.Error_Type__c = 'System.DmlException';
                errorLog.Component_Name__c = dbInput.className;
                //TODO : Check if we can change error code type from number to text then it will become more generic
                //errorLog.Error_Code__c = err.getStatusCode();
                errorLogList.add(errorLog);
            }
            dbResult.hasError = true;
        }
        insert errorLogList;
        return dbResult;
    }
}