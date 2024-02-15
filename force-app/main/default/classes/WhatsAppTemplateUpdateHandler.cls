/**  
*  @classname  : WhatsAppTemplateUpdateHandler
*  @author : Shriram Mahamuni
*  @date : 17-10-2023
*  @description  : This class plays a main role in managing and processing updates to message templates within the WhatsApp (WA) platform. 
*  @modificationlog
*  		#		Date		            Description		      Modified By
*	    1.	17-10-2023          Initital Version    Shriram Mahamuni									
*/
public inherited sharing class WhatsAppTemplateUpdateHandler implements IWebhookServiceHandler{

  /**  
  *  @methodname : execute
  *  @author : Shriram Mahamuni
  *  @objectreferenced  : WhatsApp_Template__c
  *  @param  : Object (Deserialized value Payload received in Whatsapp payload)
  *  @description  : This method is used to update the whatsapp template status according to payload received.
  *  @return : Void
  */
  public static void execute(Object valueObj){
    try{
      Map<String, Object> inputMap = (Map<String, Object>) valueObj;
      Webhook_Configuration__mdt objWbkConfg = (Webhook_Configuration__mdt)inputMap.get('confgData');
      if (objWbkConfg != null && objWbkConfg.Enable_Logging__c) {
        String payload = JSON.serialize(inputMap.get('payload'));
        Utility.createWebhookLog(Constants.WHATSAPPSTRING,payload);
      }
      //Check for Read access on WhatsApp Templat Object.
      List<String> fieldListForRead = new List<String>{Constants.WHATSAPPIDSTRING};
      SecurityService.checkAccessible(Constants.WHATSAPPTEMPLATE,fieldListForRead);
      //Check for Update access on WhatsApp Templat Object.
      List<String> fieldListForUpdate = new List<String>{Constants.WATEMPLATEAPPROVALSTATUSSTRING,Constants.WATEMPLATEREJECTIONREASONSTRING,Constants.STATUSSTRING};
	  //SecurityService.checkUpdatable(Constants.WHATSAPPTEMPLATE,fieldListForUpdate);



      WhatsAppTemplateUpdateHandler.prepareTemplateRecords(inputMap.get('payload'));
    } catch (Exception ex) {
        ApplicationLogger.logException(ex);
    } 
  }

  /**  
  *  @methodname : prepareTemplateRecords
  *  @author : Shriram Mahamuni
  *  @objectreferenced  : WhatsApp_Template__c
  *  @param  : Object
  *  @description  : This method is responsible for preparing the Whatsapp Template record and update it in the system.
  *  @return : Void
  */
  public static void prepareTemplateRecords(Object valueObj){
    Map<String, Object> valueMap = (Map<String, Object>)valueObj;

    //get the values from webhook
    String approvalStatus = (String) valueMap.get(Constants.EVENTSTRING);
    String message_template_id = String.valueOf(valueMap.get(Constants.MESSAGE_TEMPLATE_IDSTRING));
    String message_template_name = (String) valueMap.get(Constants.MESSAGE_TEMPLATE_NAMESTRING);
    String message_template_language = (String) valueMap.get(Constants.MESSAGE_TEMPLATE_LANGUAGESTRING);
    String reason = (String) valueMap.get(Constants.REASONSTRING);

    //Create list instance of whatsapp template
    List<WhatsApp_Template__c> whatsappTemplateList = new List<WhatsApp_Template__c>();

    //create the whatsapp template record. 
    WhatsApp_Template__c wt = new WhatsApp_Template__c();
    wt.Whatsapp_Approval_Status__c = approvalStatus;
    if(approvalStatus.equalsIgnoreCase(Constants.REJECTEDSTRING)){
        wt.Rejection_Reason__c = reason;
        wt.Status__c = Constants.WANOTAPPROVEDSTRING;
    }else if(approvalStatus.equalsIgnoreCase(Constants.APPROVEDSTRING)){
        wt.Status__c = Constants.APPROVEDSTRING;
				wt.Rejection_Reason__c = '';
    }
    //get the template id from request body.
    String whatsAppTemplateId = WhatsAppTemplateUpdateHandler.getWATemplateId(message_template_id);
    wt.Id = whatsAppTemplateId;
    whatsappTemplateList.add(wt);

    //Prepare the input parameter.
    DatabaseService.DB_Input dbInput = new DatabaseService.DB_Input(whatsappTemplateList,true,true,Constants.WATEMPLATEUPDATEHANDLERCLASS);

    //Invoke the update call.
    DatabaseService.DB_Result dbResult = DatabaseService.dbUpdate(dbInput);
  }

  /**  
  *  @methodname : getWATemplateId
  *  @author : Shriram Mahamuni
  *  @objectreferenced  : WhatsApp_Template__c
  *  @param  : String
  *  @description  : This method is return the Template Id by passing the whatsapp Template Id. 
  *  @return : String
  */
  public static String getWATemplateId(String message_template_id) {
    String userType = UserInfo.getUserType();
    String waTemplateId = '';
    try{
      List<WhatsApp_Template__c> wTemplateList = new List<WhatsApp_Template__c>();
      String queryMode = userType.equalsIgnoreCase(Constants.GUESTSTRING) ? 'SYSTEM_MODE' : 'USER_MODE';
      String query = 'SELECT Id FROM WhatsApp_Template__c Where WhatsApp_Template_ID__c =: message_template_id WITH '+queryMode+' Limit 1';
      
      wTemplateList = database.query(query);

      if(wTemplateList.size() > 0){
        waTemplateId = wTemplateList[0].Id;
      }
    }catch(Exception ex){
      ApplicationLogger.logException(ex);
    } 

      return waTemplateId;
  }
}