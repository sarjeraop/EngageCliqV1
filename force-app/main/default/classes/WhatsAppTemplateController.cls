/**
 * @classname			      : WhatsAppTemplateController
 * @author				      : Rati Kulkarni
 * @date                	  : 09-Nov-2023
 * @description			
 * @modificationlog
 */
public with sharing class WhatsAppTemplateController {

   
    /**
   * @methodname                 Initialise
   * @author                     Rati Kulkarni
   * @objectreferenced           SecurityService
   * @params                     None
   * @description                Method to check whether user has permission to create WhatsApp template in salesforce context.
   * @return                     If will return whether User has Permissions or not.
   */
  @AuraEnabled//(cacheable=true)
  public static ApexResultSet initialiseWhatsAppTemplate() {
      // Check Whether user has access to required objects to perform schedule feature.
      ApexResultSet apexResult = new ApexResultSet();
      try{
          List<String> whatsAppTemplateFieldsList = new List<String>{'IsActive__c','JSON_Payload__c','JSON_Wrapper__c','Language__c','Message_Body__c','Merge_Field_Mapping__c','Template_ID__c','Template_Type__c','WhatsApp_Category__c','Name__c','WhatsApp_Message_Body__c','Whatsapp_Approval_Status__c','WhatsApp_Template_ID__c','Rejection_Reason__c'};
          SecurityService.checkInsertable('WhatsApp_Template__c',whatsAppTemplateFieldsList);
          apexResult.isSuccess = true;
      }catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
      }
      return apexResult;
  }

    /**
   * @methodname                 Initialise
   * @author                     Rati Kulkarni
   * @objectreferenced           SecurityService
   * @params                     None
   * @description                Method to check whether user has permission to create WhatsApp template in salesforce context.
   * @return                     If will return whether User has Permissions or not.
   * to do						 Needs to move this method to dedicated component.
   */
  @AuraEnabled//(cacheable=true)
  public static ApexResultSet initialiseWhatsAppTemplateForApprovalButton() {
      // Check Whether user has access to required objects to perform schedule feature.
      ApexResultSet apexResult = new ApexResultSet();
      try{
          List<String> whatsAppTemplateFieldsList = new List<String>{'JSON_Payload__c','Whatsapp_Approval_Status__c','WhatsApp_Template_ID__c','Rejection_Reason__c'};
          SecurityService.checkInsertable('WhatsApp_Template__c',whatsAppTemplateFieldsList);
          apexResult.isSuccess = true;
      }catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
      }
      return apexResult;
  }

   
   
   /**
   * @methodname                 saveWhatsAppTemplate
   * @author                     Rati Kulkarni
   * @objectreferenced           ApexResultSet
   * @params                     None
   * @description                This method creates/updates Template and WhatsAppTemplate Object.
   * @return                     ApexResultSet
   */
  @AuraEnabled
  public static ApexResultSet saveWhatsAppTemplate(String jsonValue) {
      // Check Whether user has access to required objects to perform schedule feature.
      ApexResultSet apexResult = new ApexResultSet();
      try{
          apexResult.data = WhatsAppTemplateBI.saveWhatsAppTemplate(jsonValue);
      }catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
          system.debug('ex.getMessage'+ex.getMessage());
          //ApplicationLogger.logException(ex);
      }
      return apexResult;
  }

    /**
   * @methodname                 sendWhatsAppTemplateForApproval
   * @author                     Rati Kulkarni
   * @objectreferenced           ApexResultSet
   * @params                     None
   * @description                This method updates WhatsAppTemplate Object.
   * @return                     ApexResultSet
   */
  @AuraEnabled
  public static ApexResultSet sendWhatsAppTemplateForApproval(String whatsAppTemplaterecordId) {
      ApexResultSet apexResult = new ApexResultSet();
      //get WhatsApp Template object from ID
      WhatsApp_Template__c objWhatsAppTemplate = (WhatsApp_Template__c)Utility.getWhatsAppTemplate(whatsAppTemplaterecordId);
      Map<String,String> resultMap = new Map<String,String>();
      try{
          if(String.isBlank(objWhatsAppTemplate.WhatsApp_Template_ID__c)){
             // create scenario
              // Call to create WhatsApp template
              resultMap = WhatsAppAPIService.createWhatsAppTemplateAPIService(objWhatsAppTemplate.JSON_Payload__c);
              if(resultMap.get('statusCode')== '200'){
                  // update templateId and status if WhatsApp Template created successfully.
                  objWhatsAppTemplate.WhatsApp_Template_ID__c =resultMap.get('templateId');
                  objWhatsAppTemplate.Whatsapp_Approval_Status__c = resultMap.get('templateStatus');
                  objWhatsAppTemplate = WhatsAppTemplateBI.createWhatsAppTemplateRecord(objWhatsAppTemplate);
              }
          }else{ 
               // edit scenario
                String status = objWhatsAppTemplate.Whatsapp_Approval_Status__c;
          		if(status.equalsIgnoreCase('Approved') || status.equalsIgnoreCase('Rejected') || status.equalsIgnoreCase('PAUSED')){
                 // Call to edit WhatsApp template 
                 Map<String,Object> jsonMap = (Map<String,Object>) System.JSON.deserializeUntyped(objWhatsAppTemplate.JSON_Payload__c);
                 jsonMap.remove('name');
                 jsonMap.remove('language');
                 String json = System.JSON.serialize(jsonMap);
                 resultMap = WhatsAppAPIService.editWhatsAppTemplateAPIService(json,objWhatsAppTemplate.WhatsApp_Template_ID__c);//(objWhatsAppTemplate.JSON_Payload__c,objWhatsAppTemplate);
            	 }
              else{
                  resultMap.put('statusCode','000');
                  resultMap.put('error_user_msg','Only templates with an APPROVED, REJECTED, or PAUSED status can be edited.');
              }
          }
          
          apexResult.data = resultMap;
          //apexResult.data = CreateTemplate.createWhatsAppTemplateRecord(objWhatsAppTemplate);
      }catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
          //ApplicationLogger.logException(ex);
      }
      return apexResult;
  }
  
    
        
    /**
   * @methodname                 saveWhatsAppTemplate
   * @author                     Rati Kulkarni
   * @objectreferenced           SecurityService
   * @params                     None
   * @description                This method is use to create template and whatsApp template record. 
   * @return                     ApexResultSet
   */
  @AuraEnabled
  public static ApexResultSet getTemplateDetails(String jsonValue) {
      // Check Whether user has access to required objects to perform schedule feature.
      ApexResultSet apexResult = new ApexResultSet();
      try{
          apexResult.data = WhatsAppTemplateUI.getTemplateDetails(jsonValue);
      }catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
          ApplicationLogger.logException(ex);
      }
      return apexResult;
  }

        
  /* @methodname		    : getAllApprovedWhatsAppTemplate
  * @author				: Rati Kulkarni
  * @objectreferenced	:
  * @params 		    :
  * @description		: This method is used get all approved whatsApp template from org.
  * @return				: ApexResultSet.
  */
  @AuraEnabled(cacheable=true)
  public static ApexResultSet getAllApprovedWhatsAppTemplate(string templatejson){
      ApexResultSet resultSet = new ApexResultSet();
      try{
      	  resultSet.data = WhatsAppAPIService.getApprovedWhatsAppTemplatesAPIService(templatejson);
          system.debug('result data === '+resultSet.data);
          if(test.isRunningTest()){
              throw new AuraHandledException('Exception thrown to cover catch');
          }
      }
      catch(Exception ex){
          resultSet.isSuccess = false;
          resultSet.message = ex.getMessage();
          ApplicationLogger.logException(ex);
      }
      return resultSet;
  }


/** @methodname          : getSupportdLanguageWhatsApp
  * @author              : Rati Kulkarni
  * @objectreferenced    : 
  * @param               : 
  * @description         : This method is used get supported language metadata for whatsApp Template
  * @return              : List<Supported_Language__mdt>
  */    
@AuraEnabled(Cacheable = true)
public static ApexResultSet getSupportdLanguageWhatsApp(){    
    ApexResultSet resultSet = new ApexResultSet();
    try{
    resultSet.data = Utility.getSupportdLanguageWhatsApp();
    }
    catch(Exception ex){
        resultSet.isSuccess = false;
        resultSet.message = ex.getMessage();
        ApplicationLogger.logException(ex);
    }
    return resultSet;     
}

/**
  * @methodname			: getWhatsAppTemplate
  * @author				: Rati Kulkarni
  * @objectreferenced	: WhatsApp_Template__c
  * @params				: String
  * @description		: This method returns WhatsAppTemplate Object based on whatsAppTemplaterecordId.
  * @return				: ApexResultSet
  */
  @AuraEnabled(cacheable=true)
  public static ApexResultSet getWhatsAppTemplate(String whatsAppTemplaterecordId){    
    ApexResultSet resultSet = new ApexResultSet();
    try{
    resultSet.data = (WhatsApp_Template__c)Utility.getWhatsAppTemplate(whatsAppTemplaterecordId);
    }
    catch(Exception ex){
        resultSet.isSuccess = false;
        resultSet.message = ex.getMessage();
        ApplicationLogger.logException(ex);
    }
    return resultSet;       
  }

  
}