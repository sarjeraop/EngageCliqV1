/**  @classname  : IWebhookServiceHandler
  *  @author : Shriram Mahamuni
  *  @date : 23-10-2023
  *  @description  : This interface defines a contract for specific channel service of a communication channel. 
                     A channel service represents a specific integration that can process incoming webhook payloads.
  *  @modificationlog
  *  	#		    Date		          Description			    Modified By
  *	  1.		  23-10-2023  			Initial version     Shriram Mahamuni										
*/
public Interface IWebhookServiceHandler {
    /**  @methodname : execute
      *  @author : Shriram Mahamuni
      *  @objectreferenced  : None
      *  @param  : Object (Pass the channel specific webhook payload as it is in string format to process.)
      *  @description  : This method is responsible for handling incoming webhook data, parsing it, and taking appropriate actions based on the data received in payload.
      *  @return : List<Object>
    */
	void execute(Object webhookPayload);
}