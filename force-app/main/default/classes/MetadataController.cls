/* 
 * @ classname          : metadataController 
 * @ author             : Sarjerao Pujari.
 * @ date               : 28-Jan-2024
 * @ description        : This class is used to insert or deploy metadata record.
 
 * @ modificationlog
 * 1.
 */
public with sharing class MetadataController implements Metadata.DeployCallback
{

/**
 * @ methodname             : getMetadata.
 * @ author                 : Sarjerao Pujari. 
 * @ ObjectReferenced       : Channel_Configuration__mdt.
 * @ param                  : None.
 * @ description            : This method is used to fetch the record of Channel_Configuration__mdt and returns.
 * @ return                 : List. 
 */
@AuraEnabled(Cacheable = true)
public static List<Channel_Configuration__mdt> getMetadata(){
    List<Channel_Configuration__mdt>  channelConfigList = [SELECT Id, DeveloperName, API_key__c, Business_ID__c,Endpoint_URL__c, PhoneNo_Id__c FROM Channel_Configuration__mdt];
    return channelConfigList;
}


public void handleResult(Metadata.DeployResult result,Metadata.DeployCallbackContext context)
{
    try
    {
        if (result.status == Metadata.DeployStatus.Succeeded)
        {
            System.debug('success: '+ result);
        } 
        else
        {
            // Deployment was not successful
            System.debug('fail: '+ result);
        }
    }
    catch (Exception e)
    {
        ApplicationLogger.logException(e);
    }

}

/**
 * @ methodname             : createMetadataRecord.
 * @ author                 : Sarjerao Pujari. 
 * @ ObjectReferenced       : Channel_Configuration__mdt.
 * @ param                  : Object.
 * @ description            : This method is used to insert or deploy a custom metadata record.
 * @ return                 : None. 
 */
@AuraEnabled
public static ApexResultSet createMetadataRecord(Channel_Configuration__mdt lstMetadata)
{
    ApexResultSet aResult = new ApexResultSet();
    // Set up custom metadata to be created in the subscriber org.
    Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
    customMetadata.fullName = Constants.NAMESPACEPREFIX+'Channel_Configuration.'+lstMetadata.DeveloperName;
    customMetadata.label = lstMetadata.DeveloperName;
    List<String> ListAPINAmess = new List<String>{Constants.NAMESPACEPREFIX+'API_key__c',Constants.NAMESPACEPREFIX+'Business_ID__c',Constants.NAMESPACEPREFIX+'PhoneNo_Id__c',Constants.NAMESPACEPREFIX+'Endpoint_URL__c'};                     
        for (String str : ListAPINAmess) {
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = str;
            customField.value = lstMetadata.get(str);
            customMetadata.values.add(customField);
        }

    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    mdContainer.addMetadata(customMetadata);
    // Setup deploy callback, MyDeployCallback implements
    // the Metadata.DeployCallback interface (code for
    // this class not shown in this example)
    CustomMetadataCallback callback = new CustomMetadataCallback();
    // Enqueue custom metadata deployment
    // jobId is the deployment ID
    
    try{
        if(!Test.isRunningTest())
        {
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            aResult.isSuccess = true;
            aResult.message = 'Channel Metadata record is Successfully Created';
        }
    }catch(DmlException e){
        aResult.isSuccess = false;
    }
    return aResult;
}}