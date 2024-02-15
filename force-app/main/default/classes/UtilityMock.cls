/*
 *  @classname  		: UtilityMock
 *  @author 			: Nikita Powar
 *  @ param             : none
 *  @description  		: UtilityMock class to test the Utility .

 *  @modificationlog
 *  	#		Date				 Description				Modified By
 *		1.	    22-12-2023			 Added Comments			    sarjerao Pujari
*/
@isTest
public class UtilityMock implements HttpCalloutMock{
    
 // Implement the respond method to return a mock HTTP response
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