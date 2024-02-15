@RestResource(urlMapping = '/webhook/*')
/**  
*	 @classname  : WebhookSubscription
*  @author : Shriram Mahamuni
*  @date : 16-10-2023
*  @description  : This class serves as a fundamental component for handling incoming webhook requests and managing communication between external systems. 
									 This class is designed to process, validate, and respond to incoming webhook events, enabling real-time data exchange and interaction with external entities.
*  	 #			Date					Description				Modified By
*	   1      16-10-2023		Initial Version		Shriram Mahamuni
*/
global without sharing class WebhookSubscription{
  /**  
	*  @methodname : handleGetRequest
	*  @author : Shriram Mahamuni
	*  @objectreferenced  : None
	*  @param  : None
	*  @description  : This method is designed to handle incoming HTTP GET requests. 
										 This method is responsible for processing and responding to GET requests received via webhook.
	*  @return : None
	*/
  @HttpGet
  global static void handleGetRequest() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

		//Whatsapp service related code - start
    String whatsAppWebhookToken = Constants.HUB_VERIFY_TOKEN;
    String whatsAppWebhookVerificationToken = Constants.WEBHOOK_VERIFY_TOKEN;
		String hubChallenge = Constants.HUB_CHALLENGE;

    if(whatsAppWebhookVerificationToken.equals(req.params.get(whatsAppWebhookToken))){
      res.responseBody = blob.valueOf(req.params.get(hubChallenge));
    }
		//Whatsapp service related code - End
  }

  /**  
	*  @methodname : handlePostRequest
	*  @author : Shriram Mahamuni
	*  @objectreferenced  : None
	*  @param  : None
	*  @description  : This method serves as the entry point for processing incoming HTTP POST requests in the context of a webhook class. 
										 This method is responsible for handling and managing the data contained in POST requests. 
										 It plays a main role in processing webhook payloads and triggering actions or events in response to the received data.
	*  @return : None
	*/
  @HttpPost
  global static void handlePostRequest() {
		RestRequest req = RestContext.request;

    //get channel name from webhook URL
    String channelName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		String requestBody = RestContext.request.requestBody.toString();
		String serviceClassName;

		// get channel specific mapping from metadata
		Channel__mdt channelMapping = Channel__mdt.getInstance(channelName);
		

	  if(channelMapping != null && String.isNotBlank(channelMapping.Webhook_Service_Class__c)){ 
			try{
				Type classType = Type.forName(channelMapping.Webhook_Service_Class__c);
	    	if (classType != null && classType.newInstance() instanceof IWebhookService) {
	    	  IWebhookService instance = (IWebhookService) classType.newInstance();
	    	  instance.process(requestBody); // Call a method on the dynamically instantiated instance
	    	}else{
					ApplicationLogger.logException(new CustomException(Constants.ERRORMSGINCORRECTSERVICECLASS));
				}
			}catch(Exception ex){
				ApplicationLogger.logException(ex);
			}
	  } else {
			ApplicationLogger.logException(new CustomException(Constants.ERRORMSGINCORRECTCHANNELNAME));

		}
  }
}