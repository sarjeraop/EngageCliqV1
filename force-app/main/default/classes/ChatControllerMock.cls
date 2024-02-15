/* 
 * @ classname          : ChatControllerMock.
 * @ author             : Sarjerao Pujari.
 * @ date               : 23-Oct-2023
 * @ description        : ChatControllerMock is used to create a response for ChatController Class.
 
 * @ modificationlog
 * 1.Sarjerao Pujari       20-Nov-2023        Add Code Comments
 */
@isTest
public class ChatControllerMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        Map<String, Object> responseBody = new Map<String, Object>
        {'messaging_product' => 'whatsapp',
            'contacts' => new List<Map<String, Object>>
        { new Map<String, Object>{'input' => '919890621026',
            					  'wa_id' => '919890621026'}},
                                   'messages' => new List<Map<String, Object>>
                                  {new Map<String, Object>{
                                   'id' => 'wamid.HBgMOTE5ODkwNjIxMDI2FQIAERgSQTNEQUYwQzlFMjNERkFCMkU5AA=='}}};
        responseBody.put('key1', 'value1');
        responseBody.put('key2', 42);
        String jsonResponse = JSON.serialize(responseBody);
        res.setBody(jsonResponse);
        
        return res;
    }
}