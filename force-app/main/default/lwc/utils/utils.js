const PREFIX = 'c';
const PREFIXWITHUNDERSCORE = '';
const getSbc = () => {
  let sbc = {};
  sbc.phonefield = PREFIXWITHUNDERSCORE+'Phone_Fields__c';
  sbc.namefield = PREFIXWITHUNDERSCORE+'Name_Field__c';
  sbc.optfield = PREFIXWITHUNDERSCORE+'Consent_Field__c'
  return sbc;
};
const getPackagePrefix = () => {
  let prefix  = {}
  prefix.prefix = PREFIX;
  prefix.PKGPREFIX = PREFIXWITHUNDERSCORE;

  return prefix;
}
const getTemplate = () => {
  let template = {};
  template.name = PREFIXWITHUNDERSCORE + 'Name__c';
  template.targetSource = PREFIXWITHUNDERSCORE + 'Target_Source__c';
  template.description = PREFIXWITHUNDERSCORE + 'Description__c';
  template.Id = PREFIXWITHUNDERSCORE + 'Id';
  return template;
}
const getWhatsAppTemplate = () => {
  let whatsAppTemplate = {};
  whatsAppTemplate.active = PREFIXWITHUNDERSCORE + 'IsActive__c';
  whatsAppTemplate.category = PREFIXWITHUNDERSCORE + 'WhatsApp_Category__c';
  whatsAppTemplate.type = PREFIXWITHUNDERSCORE + 'Template_Type__c';
  whatsAppTemplate.status = PREFIXWITHUNDERSCORE + 'Status__c';
  whatsAppTemplate.language = PREFIXWITHUNDERSCORE + 'Language__c';
  whatsAppTemplate.jsonPayload = PREFIXWITHUNDERSCORE + 'JSON_Payload__c'
  whatsAppTemplate.whatsAppTemplateId = PREFIXWITHUNDERSCORE +'WhatsApp_Template_ID__c';
  whatsAppTemplate.whatsAppTemplateStatus = PREFIXWITHUNDERSCORE +'Whatsapp_Approval_Status__c';
  whatsAppTemplate.name = PREFIXWITHUNDERSCORE +'Name__c';
  return whatsAppTemplate;
}
const getSelectedTemplate = () => {
  let selectedTemplate = {};
  selectedTemplate.Message_Body__c = PREFIXWITHUNDERSCORE + 'Message_Body__c';
  selectedTemplate.Template_Type__c = PREFIXWITHUNDERSCORE + 'Template_Type__c';
  return selectedTemplate;
}
const getSchedule = () => {
  let schedule = {};
  schedule.cronExpression = PREFIXWITHUNDERSCORE + 'Cron_Expression__c';
  schedule.templateId = PREFIXWITHUNDERSCORE + 'Template_Id__c';
  schedule.reportId = PREFIXWITHUNDERSCORE + 'Report_Id__c';
  schedule.objectName = PREFIXWITHUNDERSCORE + 'Object_Name__c';
  schedule.phoneField = PREFIXWITHUNDERSCORE + 'Recipient_Field__c';
  schedule.nameField = PREFIXWITHUNDERSCORE + 'Name_Field__c';
  schedule.channel = PREFIXWITHUNDERSCORE + 'Channel_Name__c';
  schedule.endDate = PREFIXWITHUNDERSCORE + 'End_Date__c';
  schedule.startDate = PREFIXWITHUNDERSCORE + 'Start_Date__c';
  schedule.frequency = PREFIXWITHUNDERSCORE + 'Frequency__c';

  return schedule;
}

const getTemplateName = () => {
  return PREFIXWITHUNDERSCORE+'Name__c';;
}

export { getSbc}
export {getPackagePrefix }
export {getTemplate}
export {getSelectedTemplate}
export {getSchedule}
export {getWhatsAppTemplate}