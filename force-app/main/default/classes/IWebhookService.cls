/**  @classname  : IWebhookService
  *  @author : Shriram Mahamuni
  *  @date : 16-10-2023
  *  @description  : This interface defines a contract for webhook channels in a Salesforce application. 
                     A webhook channel represents a specific integration or communication channel that can receive and process incoming webhook payloads.
 *  		#    Date		      Description		      Modified By
  *	    1    16-10-2023   Initial Version     Shriram Mahamuni

*/
public Interface IWebhookService {
  /**  @methodname : process
    *  @author : Shriram Mahamuni
    *  @objectreferenced  : None
    *  @param  : Object (Pass the webhook payload as it is in string format to process.)
    *  @description  : This method responsible for handling incoming webhook data, parsing it, and take an appropriate actions based on the data received in payload.
    *  @return : List<Object>.
  */
  void process(Object webhookPayload);
}