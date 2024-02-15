public class MapWrapper {
    
    @AuraEnabled @InvocableVariable
    public String templateId;
    @AuraEnabled @InvocableVariable
    public List<String> recordIds;
    @AuraEnabled @InvocableVariable
    public String recipientField;
    @AuraEnabled @InvocableVariable
    public List<String> channels;
   
    

}