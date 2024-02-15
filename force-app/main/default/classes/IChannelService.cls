/**  @classname     : IChannelService
  *  @author        : Rati Kulkarni
  *  @date          : 
  *  @description   : Interface to implement channelwise processing of request.
  *  @modificationlog
  *  1.     
*/

public interface IChannelService {
  ApexResultSet process(Map<String,Object> mapChannelRequest);
}