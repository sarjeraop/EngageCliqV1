public class LeadConversionController
{
    @AuraEnabled
    public static string convertLeadToContact(Id leadId)
    {
        system.debug('Record Id === '+leadId);
        Database.LeadConvert LeadConvert=new Database.LeadConvert();
        LeadConvert.setLeadId(leadId);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        LeadConvert.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr=Database.convertLead(LeadConvert);
        system.debug('lcr:: '+lcr);
        
        string contactId =  lcr.getContactId(); 
        return contactId;
    }
}