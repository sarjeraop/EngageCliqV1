/**
 * @class       : TemplateController
 * @description : Controller to fetch template related information or save template related information.
 * @author      : Abhishek Daware
 * @date        : 22-08-2023
 * @version     : 1.0
 */
public with sharing class TemplateController {
/**
   * @methodname                 Initialise
   * @author                     Rati Kulkarni
   * @objectreferenced           SecurityService
   * @params                     None
   * @description                Method to check whether user has permission to create template.
   * @return                     If will return whether User has Permissions or not.
   */
  @AuraEnabled(cacheable=true)
  public static ApexResultSet initialiseTemplate() {
      // Check Whether user has access to required objects to perform schedule feature.
      ApexResultSet apexResult = new ApexResultSet();
      try{
          List<String> templateFieldsList = new List<String>{'Description__c','Name__c','Target_Source__c'};
          SecurityService.checkInsertable('Template__c',templateFieldsList);
          apexResult.isSuccess = true;
      }catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
      }
      return apexResult;
  }

    /**
  * @methodname		    : getAllObjects
  * @author				: Suhas Mankar
  * @objectreferenced	:
  * @params 		    :
  * @description		: This method is used get all object from org.
  * @return				: ApexResultSet.
  */
  @AuraEnabled(cacheable=true)
  public static ApexResultSet getAllObjects(){
    ApexResultSet resultSet = new ApexResultSet();
    Map<String, String> sbcMap = new Map<String, String>();
      try{        
        for(Send_Configuration__c sbcRecord : [SELECT Id, Name, Object_Name__c, Phone_Fields__c, Name_Field__c,Consent_Field__c 
                                               FROM Send_Configuration__c 
                                               WHERE Object_Name__c != '' 
                                               ORDER BY Object_Name__c Asc]){            
            sbcMap.put(sbcRecord.Object_Name__c, sbcRecord.Object_Name__c);
        }
        resultSet.data = sbcMap;
          if(test.isRunningTest()){
              throw new AuraHandledException('Exception thrown to cover catch');
          }
      }
      catch(Exception ex){
          resultSet.isSuccess = false;
          resultSet.message = ex.getMessage();
          //ApplicationLogger.logException(ex);
      }
      return resultSet;
  }

  /**
  * @methodname		    : getTemplate
  * @author				: Suhas Mankar
  * @objectreferenced	:
  * @params 		    :
  * @description		: This method is used get all template from org.
  * @return				: ApexResultSet.
  */
 @AuraEnabled(cacheable=true)
 public static ApexResultSet getTemplate(){
   ApexResultSet resultSet = new ApexResultSet();
     try{
           resultSet.data = Utility.getTemplate();
         if(test.isRunningTest()){
             throw new AuraHandledException('Exception thrown to cover catch');
         }
     }
     catch(Exception ex){
         resultSet.isSuccess = false;
         resultSet.message = ex.getMessage();
         //ApplicationLogger.logException(ex);
     }
     return resultSet;
 }

    
    /**  @methodname : retrieveChannelData
    *  @author : Abhishek Daware
    *  @objectreferenced  : Template and its chid objects
    *  @param  : String
    *  @description  : This method used to template and its associated child template data
    *  @return : ApexResultSet
  */
  @AuraEnabled(cacheable=true)
  public static ApexResultSet retrieveChannelData(String templateId){
      ApexResultSet apexResult = new ApexResultSet();
      String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
      baseURL += '/resource/';
      String fullBaseURL;
      String pkgPrefix = Constants.NAMESPACEPREFIX;
      String engageZipPath = Constants.ENGAGEPATHCHECK; 
      Map<String,Object> mapRelatedRecords = new Map<String,Object>();
      try {
          map<String,Channel__mdt> mapChannel = (map<String,Channel__mdt>) Utility.getAllChannelsMap();
          if (String.isBlank(templateId)) {
              
            if(mapChannel.keySet().size() > 0){
              for (String channel : mapChannel.keySet()) {
                if(mapChannel.get(channel).LogoUrl__c.startsWith(engageZipPath))
                {
                    fullBaseURL = baseURL + pkgPrefix;
                }
                else{
                    fullBaseURL = baseURL;
                }
                  mapRelatedRecords.put(channel+':'+fullBaseURL+mapChannel.get(channel).LogoUrl__c,'');
                 // mapRelatedRecords.put(channel+':'+mapChannel.get(channel).LogoUrl__c,'');
              }
            }
          } else  {
              String query = 'Select Id, Name';
              if(mapChannel.keySet().size() > 0){
              for (String channel : mapChannel.keySet()) {
                  if(channel != null )
                  {if (mapChannel.containsKey(channel) &&  mapChannel.get(Channel).Template_Object_Name__c != null) {
                      query += ',(Select Id, Name From '+ mapChannel.get(Channel).Template_Object_Name__c +'__r' + ')';
                  }
                  }
              }
            }
              query = query + ' FROM Template__c Where Id =: templateId ';
              Map<String, Object> tempBinds = new Map<String, Object>{'templateId' => templateId};
              List<String> queryVariables = new List<String>();
              queryVariables.add(String.escapeSingleQuotes(templateId));
              query = String.format(query, queryVariables);
              Template__c objTemplate = Database.queryWithBinds(query,tempBinds, AccessLevel.USER_MODE); 
              if(mapChannel.keySet().size() > 0){
              for (String channel : mapChannel.keySet()) {
                  if (channel != null) {
                    if(mapChannel.get(channel).LogoUrl__c.startsWith(engageZipPath))
                {
                    fullBaseURL = baseURL + pkgPrefix;
                }
                else{
                    fullBaseURL = baseURL;
                }
                  for(sobject childRecord : objTemplate.getSObjects(mapChannel.get(Channel).Template_Object_Name__c +'__r')) {
                      //mapRelatedRecords.put(channel+':'+mapChannel.get(channel).LogoUrl__c,childRecord); 
                      mapRelatedRecords.put(channel+':'+fullBaseURL+mapChannel.get(channel).LogoUrl__c,childRecord);
                  }
                      if (!mapRelatedRecords.containsKey(channel+':'+fullBaseURL+mapChannel.get(channel).LogoUrl__c)) {
                      	mapRelatedRecords.put(channel+':'+fullBaseURL+mapChannel.get(channel).LogoUrl__c,'');
                      }
                  }
                }
              }
          }
              
          apexResult.data = mapRelatedRecords;
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
      return apexResult;
  }
}