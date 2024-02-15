/* 
 * @ classname          : MockTestOfCreateVfPage 
 * @ author             : Sarjerao Pujari.
 * @ date               : 03-Nov-2023
 * @ description        : This Class is specially designed to Create the response.
 
 * @ modificationlog
 * 1.
 */
@isTest
global class SendButtonConfigurationControllerMock implements HttpCalloutMock{

/**
 * @ methodname             : respond.
 * @ author                 : Sarjerao Pujari. 
 * @ ObjectReferenced       : None.
 * @ param                  : HTTPRequest.
 * @ description            : This respond method is used to create a response to test the SendButtonConfigurationController Apex Class.
 * @ return                 : List. 
 */    
    public HTTPResponse respond(HTTPRequest req)
    {        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success": true}');
        res.setStatusCode(200);
        return res;    
    }   
}