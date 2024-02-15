/**  @classname       : IChannelServiceHandler
  *  @author          : Rati Kulkarni
  *  @date            : 19-Oct-2023
  *  @description     : Interface to initiate methods, that are required to send message through any channel.
  *  @modificationlog
  *  1.     
*/
public interface IChannelServiceHandler {
    IChannelServiceHandler init(Map<String,Object> mapChannelRequest);
    IChannelServiceHandler validate();
    IChannelServiceHandler processRequest();
    IChannelServiceHandler processResponse(); 
    ApexResultSet getResult();
}