/**
 * @class       : Constants
 * @description : Class representing all the constant used in the enagecliq application
 * @author      : Abhishek Daware
 * @date        : 23-08-2023
 * @version     : 1.0
 */

public with sharing class Constants {

  public static String NAMESPACEPREFIX = '';
    public static String NAMESPACEPREFIXFORCLASS = '';
	public static String DEFAULTNAMESPACEPREFIXFORCLASS = 'c';
	public static Integer STATUSCODE = 200;    // use in callout response to check status code
  public static String STARTPATTERN = System.Label.merge_start_pattern_label;    // use in merged utility
  public static String ENDPATTERN = System.Label.merge_end_pattern_label;    // use in merged utility
  public static String MEDIAURL = '/sfc/servlet.shepherd/document/download/'; // used inchat chat controller for preview document

    public static Integer OBMESSAGEPASTDAYS = Integer.valueOf(System.Label.outbound_messages_searched_within_label);
  public static String WEBHOOK_VERIFY_TOKEN = System.Label.webhook_verify_token_label;
  public static String HUB_VERIFY_TOKEN = System.Label.hub_verify_token_label;
  public static String HUB_CHALLENGE = System.Label.hub_challenge_label;

	public static String IDFIELDSTRING = 'id';
	public static String NAMESTRING = 'Name';
	public static String MARKUPSTRING = 'Markup';
	public static String CONTROLLERTYPESTRING = 'ControllerType';
	public static String MASTERLABELSTRING = 'MasterLabel';
	public static String APIVERSIONSTRING = 'ApiVersion';
	public static String MESSAGESSTRING = 'messages';
	public static String STATUSESSTRING = 'statuses';
	public static String FAILEDSTRING = 'failed';
	public static String EVENTSTRING = 'event';
	public static String APPROVEDSTRING = 'APPROVED';


	//Field Names
  public static String CHANNELFIELD = Constants.NAMESPACEPREFIX + 'Channel__c';
  public static String MESSAGETEXTFIELD  = Constants.NAMESPACEPREFIX + 'Message_Text__c';
  public static String MOBILEFIELD = Constants.NAMESPACEPREFIX + 'Mobile__c';
  public static String INBOUNDCOMMSGFIELD= Constants.NAMESPACEPREFIX + 'Inbound_Communication_Message__c';
  public static String RELATEDTOFIELD = Constants.NAMESPACEPREFIX + 'Related_To__c';
	public static String SENTTIMESTRING = Constants.NAMESPACEPREFIX + 'SentTime__c';
	public static String DELIVEREDTIMESTRING = Constants.NAMESPACEPREFIX + 'DeliveredTime__c';
	public static String READTIMESTRING = Constants.NAMESPACEPREFIX + 'ReadTime__c';
	public static String WHATSAPPIDSTRING = Constants.NAMESPACEPREFIX + 'WhatsApp_Template_ID__c';
	public static String WATEMPLATEAPPROVALSTATUSSTRING = Constants.NAMESPACEPREFIX + 'Whatsapp_Approval_Status__c';
	public static String WATEMPLATEREJECTIONREASONSTRING = Constants.NAMESPACEPREFIX + 'Rejection_Reason__c';
	public static String STATUSSTRING = Constants.NAMESPACEPREFIX + 'Status__c';
	public static String OBJECTNAMESTRING = Constants.NAMESPACEPREFIX + 'Object_Name__c';
	public static String PHONEFIELDSSTRING = Constants.NAMESPACEPREFIX + 'Phone_Fields__c';
	public static String NAMEFIELDSTRING = Constants.NAMESPACEPREFIX + 'Name_Field__c';




	//Object Names
  public static String INBOUNDMESSAGESTRING = Constants.NAMESPACEPREFIX + 'Inbound_Message__c';
  public static String CONVERSATIONSTRING = Constants.NAMESPACEPREFIX + 'Conversation__c';
	public static String OUTBOUNDMESSAGESTRING = Constants.NAMESPACEPREFIX + 'Outbound_Message__c';
	public static String WHATSAPPTEMPLATE = Constants.NAMESPACEPREFIX + 'WhatsApp_Template__c';
	public static String SBCSTRING = Constants.NAMESPACEPREFIX + 'Send_Configuration__c';
	public static String APEXPAGESTRING = 'ApexPage';

	//inbound payload keys

	public static String FROMSTRING = 'from';
	public static String TEXTSTRING = 'text';
	public static String BODYSTRING = 'body';
	public static String REACTIONSTRING = 'reaction';
	public static String EMOJISTRING = 'emoji';
	public static String IMAGESTRING = 'image';
    public static String INTERACTIVESTRING = 'interactive';
	public static String OUTBOUNDSTATUSSTRING = 'status';
	public static String TIMESTAMPSTRING = 'timestamp';
	public static String ERRORSSTRING = 'errors';
	public static String TITLESTRING = 'title';
    public static String BUTTONREPLYSTRING = 'button_reply';
    public static String BUTTONSTRING = 'button';
    public static String LISTREPLYSTRING = 'list_reply';
    public static String TYPESTRING = 'type';

	//Whatspapp Text String
	public static String WHATSAPPSTRING = 'WhatsApp';

	//others
	public static String CUSTOMOBJECTSUFFIX = '__c';


	//classNames
	public static String WAINBOUNDHANDLERCLASS = 'WhatsAppInboundHandler';
	public static String WAOUTBOUNDHANDLERCLASS = 'WhatsAppOutboundHandler';
	public static String WATEMPLATEUPDATEHANDLERCLASS = 'WhatsAppTemplateUpdateHandler';
	public static String SENDBUTTONCONFIGURATIONCONTROLLERCLASS = 'SBConfigController';
    public static String CREATETEMPLATECLASS = 'WhatsAppTemplateBI';

	//outbound message statuses
	public static String SENTSTATUSESTRING = 'sent';
	public static String READSTATUSESTRING = 'read';
	public static String DELIVEREDSTATUSESTRING = 'delivered';
	public static String FAILEDSTATUSESTRING = 'failed';

	//value payload keys whatsapp
	public static String VALUEEVENTSTRING ='event';

	//Whatsapp services Selection strings
	public static String SERVICESMESSAGETEMPLATESTATUSUPDATESTRING = 'message_template_status_update';

	//template status update keys
	public static String MESSAGE_TEMPLATE_IDSTRING = 'message_template_id';
	public static String MESSAGE_TEMPLATE_NAMESTRING = 'message_template_name';
	public static String MESSAGE_TEMPLATE_LANGUAGESTRING = 'message_template_language';
	public static String REASONSTRING = 'reason';

	//Whatsapp Template statuses
	public static String REJECTEDSTRING = 'REJECTED';
	public static string WANOTAPPROVEDSTRING = 'Not Approved';
	public static string WAAPPROVEDSTRING = 'Approved';

	//outbound message query fields
	public static string INBOUNDQUERYMOBILESTRING = 'Mobile__c';

	//Webhook Payload keys
	public static String PAYLOADENTRY = 'entry';
	public static String PAYLOADCHANGES = 'changes';
	public static String PAYLOADFIELD = 'field';
	public static String PAYLOADVALUE = 'value';

	//Webhook error messages.
	public static String ERRORMSGINCORRECTSERVICECLASS = System.Label.webhook_service_class_not_found_error_label;
	public static String ERRORMSGINCORRECTCHANNELNAME = System.Label.webhook_incorrect_channel_error_label;
	public static String ERRORMSGINCORRECTWASERVICEHANDLERCLASS = System.Label.class_not_found_error;
	public static String ERRORMSGNOSBCEXISTFOROBJECT = System.Label.webhook_no_sbc_exist_for_object_label;
	public static String ERRORMSGINCORRECTWEBHOOKPAYLOAD =  System.Label.webhook_incorrect_payload_received_label;
	public static String ERRORMSGINCORRECTSTATUS =  System.Label.webhook_incorrect_status_received_label;


	//setup object suffixes
	public static String HISTORYSTRING = 'history';
	public static String TAGSTRING = 'tag';
	public static String SHARESTRING = 'share';
	public static String FEEDSTRING = 'feed';
	public static String GROUPSTRING = 'group';
	public static String PUBLICSTRING = 'public';

	//Utility class error messages
	public static String errorMsgErrorInFetchingAllObjects = System.Label.error_fetch_all_objects_label;

	//SBConfigController Error messages
	public static String ERRORSBCFEATURENOACCESS = System.Label.error_no_access_to_sbc_feature_label;
	public static String ERROREXISTINGSBCACCESS = System.Label.error_existing_sbc_access_label;
	public static String SBCRECORDCREATEDMSGSTRING = System.Label.message_sbc_created_label;
	public static String ERRORNEWSBCCREATIONERROR = System.Label.error_in_sbc_creation_label;

	//SBConfigController other strings
	public static String VFPAGESUFFIX = 'SendButtonConfiguration';
	public static String VFPAGESUFFIXSHORT = 'SBConfig';

	public static String URLSTRING = '/services/data/latestAPIVersion/sobjects/ApexPage';
	public static String POSTMETHODSTRING = 'POST';
	public static String CONTENTTYPESTRING = 'Content-type';
	public static String APPLICATIONJSON = 'application/json';

	public static String START_OF_SESSION_IDSTRING = 'Start_Of_Session_Id';
	public static String END_OF_SESSION_IDSTRING = 'End_Of_Session_Id';

	public static String AUTHORIZATIONSTRING = 'Authorization';
	public static String BEARERSTRING = 'Bearer ';

	//Utility strings
	public static String CHANNELICONSTRING = 'ChannelIcon';
	public static String COMPONENTNAME = 'componentName';
	public static String RELATIONSHIPNAME = 'relationshipName';

	// used to store engageclick zip static resource path 
	public static String ENGAGEPATHCHECK = System.Label.engagecliq_folder;

	//Utility strings
	public static String GUESTSTRING = 'Guest';
}