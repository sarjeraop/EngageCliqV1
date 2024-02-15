/**  @classname     : WhatsAppService
  *  @author        : Rati Kulkarni
  *  @date          : 19-Oct-2023
  *  @description   : Class initiates processing of message sending though WhatsApp.
  *  @modificationlog
  *  1.     
*/
public with sharing class WhatsAppService implements IChannelService{
    /**
   * @methodname		     process
   * @author				     Rati Kulkarni
   * @objectreferenced	 WhatsAppServiceHandler,ApexResultSet
   * @params				     Map<String,Object>
   * @description			   This method initialises message sending process of WhatsApp channel.
   * @return				     ApexResultSet.
   */
    public static ApexResultSet process(Map<String,Object> mapChannelRequest) {
        ApexResultSet resultset= new ApexResultSet();
        WhatsAppServiceHandler whatsAppServiceHandler = new WhatsAppServiceHandler();
        resultSet = whatsAppServiceHandler.init(mapChannelRequest).validate().processRequest().processResponse().getResult();
        return resultset;
    }
}