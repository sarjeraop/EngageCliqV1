/**
  *  @classname  			: SBConfigController
	*  @author 					: Shriram Mahamuni
	*  @description  		: This controller class plays a vital role in the administration and management of "Send Button Configuration" records within your Salesforce Application.
										 		This class is designed to facilitate the configuration and customization of the behavior of Send buttons.
	*  @modificationlog
	*  	#		Date						Description					Modified By
	*		1.	29-10-2023			Initial Version			Shriram mahamuni
*/
public with sharing class SendButtonConfigurationController {
    
	/**
	  *  @methodname 					: initializeComponent
		*  @author 							: Shriram Mahamuni
		*  @objectreferenced  	: Send_Configuration__c, ApexPage
		*  @param  							: None
		*  @description  				: This method is responsible for determining whether the current user has the necessary permissions to access or perform specific actions related to configure the send button configuration within an application.
											 				This method is crucial for enforcing access control and security, ensuring that only authorized users can utilize configuration feature.
		*  @return 							: void
	*/
	@AuraEnabled(cacheable=true)
	public static void initializeComponent() {
		ApexResultSet aResult = new ApexResultSet();
		Map<String, String> accessMap = new Map<String, String>();

		String sbcObjectName = Constants.SBCSTRING;
		List<String> sbcFieldsList = new List<String>{Constants.OBJECTNAMESTRING,Constants.PHONEFIELDSSTRING,Constants.NAMEFIELDSTRING};

		String apexPageObjectName = Constants.APEXPAGESTRING;
		List<String> apexPageFieldsList = new List<String>{Constants.NAMESTRING,Constants.MARKUPSTRING,Constants.CONTROLLERTYPESTRING,Constants.MASTERLABELSTRING,Constants.APIVERSIONSTRING};

		try{
			SecurityService.checkInsertable(sbcObjectName,sbcFieldsList);
		}catch(Exception ex){
			CustomException customEx = new CustomException(Constants.ERRORSBCFEATURENOACCESS);
			ApplicationLogger.logException(customEx);
			throw customEx;
		}
	}


	/**
	  *  @methodname : getAllObjects
		*  @author : Shriram Mahamuni
		*  @objectreferenced  : None
		*  @param  : None
		*  @description  : This method is developed to retrieve information about all sObjects (standard and custom objects) available in the Salesforce organization.
											 It generates a map where the keys are object API names and the values are label of an object.
		*  @return : Map<String,String>
	*/
	@AuraEnabled(cacheable=true)
	public static Map<String,String> getAllObjects(){
		Map<String,String> allObjectsMap = Utility.getAllObjects();
		return allObjectsMap;
	}


	/**
	  *  @methodname : getExistingSBCs
		*  @author : Shriram Mahamuni
		*  @objectreferenced  : Send_Configuration__c
		*  @param  : None
		*  @description  : This apex method is responsible for retrieving and providing information about existing "Send Button Configurations" stored within the Salesforce environment.
		*  @return : ApexResultSet
	*/
	@AuraEnabled(cacheable=true)
	public static ApexResultSet getExistingSBCs(){
		ApexResultSet aResult = new ApexResultSet();
		aResult = Utility.getExistingSBCs();
		return aResult;
	}


	/**  @methodname					: createSendButtonConfiguration
		*  @author						 	: Shriram Mahamuni
		*  @objectreferenced		: Send_Configuration__c
		*  @param						  	: String,String,String
		*  @description					: This apex method is responsible for creating new "Send Button Configurations" in the Salesforce environment.
		*  @return						 	: ApexResultSet
	*/
	@AuraEnabled    
    public static ApexResultSet createSendButtonConfiguration(String objectName, String phoneFields, String nameField, String optInField){
      ApexResultSet aResult = new ApexResultSet();
			List<Send_Configuration__c> sbConfigList = new List<Send_Configuration__c>();

			Send_Configuration__c sbcRecord = new Send_Configuration__c();
			sbcRecord.Object_Name__c = objectName;
			sbcRecord.Phone_Fields__c = phoneFields;
			sbcRecord.Name_Field__c = nameField;
			sbcRecord.Consent_Field__c = optInField;
			sbConfigList.add(sbcRecord);

			DatabaseService.DB_Input dbInput = new DatabaseService.DB_Input(sbConfigList,true,true,Constants.SENDBUTTONCONFIGURATIONCONTROLLERCLASS);
			
        
      DatabaseService.DB_Result  result = DatabaseService.dbInsert(dbInput);

			if (!result.hasError){                
				aResult.data = result.successRecordIds;
				aResult.message = Constants.SBCRECORDCREATEDMSGSTRING;
				aResult.isSuccess = true;
      }else{
				aResult.data = result.errorMap;
				aResult.message = Constants.ERRORNEWSBCCREATIONERROR;
				aResult.isSuccess = false;
				ApplicationLogger.logException(new CustomException(Constants.ERRORNEWSBCCREATIONERROR));
      }
			return aResult;
    }

		/**  @methodname : prepareVFPage
			*  @author : Shriram Mahamuni
			*  @objectreferenced  : None
			*  @param  : String
			*  @description  : This method  involves the preperation and configuration of a Visualforce (VF) page in Salesforce.
			*  @return : ApexResultSet
		*/
		@AuraEnabled
		public static ApexResultSet prepareVFPage(String objectAPIName){
			ApexResultSet aResult = new ApexResultSet();

			string objNameWithoutSuffix = '';
      if(objectAPIName.contains('__c')){
          objNameWithoutSuffix = (objectAPIName.remove('__c')).remove(Constants.NAMESPACEPREFIX);

      }else{
          objNameWithoutSuffix = objectAPIName;
      }
      String pageName = objNameWithoutSuffix + Constants.VFPAGESUFFIX;
      if(pageName.length() > 40){
          pageName = objNameWithoutSuffix + Constants.VFPAGESUFFIXSHORT;
      }
            
			String apiVersion = Utility.getLatestAPIVersion();
			String markup = SendButtonConfigurationController.prepareVFMarkup(objectAPIName);
			Map<String,String> bodyMap = new Map<String,String>();
            bodyMap.put(Constants.NAMESTRING,String.valueOf(pageName));
            bodyMap.put(Constants.MARKUPSTRING,markup);
            bodyMap.put(Constants.CONTROLLERTYPESTRING,'1');
            bodyMap.put(Constants.MASTERLABELSTRING,String.valueOf(pageName));
            bodyMap.put(Constants.APIVERSIONSTRING,apiVersion);
			aResult = SendButtonConfigurationController.makeAPICall(JSON.serialize(bodyMap));
			
			List<ApexPage> apexPageList = [select Id from ApexPage];
			system.debug('apex page list === '+ apexPageList);

			
			system.debug('aResult when vf page is created === '+ aResult);
            return aResult;
		}

		/**  @methodname					: prepareVFMarkup
			*  @author						 	: Shriram Mahamuni
			*  @objectreferenced		: None
			*  @param						  	: String
			*  @description					: This method involves the creation, design, and configuration of Visualforce (VF) markup within Salesforce.
												 				It takes dynamic parameter as Object name.
			*  @return 							: String
		*/
		public static String prepareVFMarkup(String objectNameString){
			String cmpNameSpace = String.isNotBlank(Constants.NAMESPACEPREFIXFORCLASS) ? Constants.NAMESPACEPREFIXFORCLASS : Constants.DEFAULTNAMESPACEPREFIXFORCLASS;
	  String markup =   '<apex:page standardController=\''+objectNameString+'\' recordSetVar=\'records\' extensions=\''+Constants.NAMESPACEPREFIXFORCLASS+'.SendButtonVFPageExtension\'>\n';
      markup = markup+  '    <apex:includeLightning />\n';
      markup = markup + '    <div id="lightning"/>\n';
      markup = markup + '    <script>\n';
      markup = markup + '		 var accRecords = \'{!recIds}\';\n';
      markup = markup + '		 if(accRecords.length <= 0){\n';
      markup = markup + '        //alert(\'Please select atleast 1 record\');\n';
			markup = markup + '        showToast(\'Error\',\'Please select atleast 1 record\',\'error\');\n';
      markup = markup + '				 window.open(\'/one/one.app?source=aloha#/sObject/'+objectNameString+'/home\',\'_self\');\n';
      markup = markup + '		 }else{\n';
      markup = markup + '				 $Lightning.use(\"'+cmpNameSpace+':AuraApplicationPlaceholder\", function()\n {\n';
      markup = markup + '											$Lightning.createComponent(\"'+cmpNameSpace+':lwcredirector\",\n';
      markup = markup + '											{\n';
      markup = markup + '													selectedRecordIds : accRecords\n';
      markup = markup + '											},\n';
      markup = markup + '											\"lightning\",\n';
      markup = markup + '											function(cmp) {\n';
      markup = markup + '												console.log(\"component was created\");\n';
      markup = markup + '											}\n';
      markup = markup + '										);\n';
      markup = markup + '									});\n';
      markup = markup + '								}\n';
			markup = markup + '					function showToast(title,message,type) {\n';
			markup = markup + '						sforce.one.showToast({\n';
			markup = markup + '						"title": title,\n';
			markup = markup + '						"message": message,\n';
			markup = markup + '						"type": type \n';
			markup = markup + '						});\n';
			markup = markup + '					}\n';
      markup = markup + '			</script>\n';
      markup = markup + '</apex:page>';
			return markup;
		}

		/**  @methodname					: makeAPICall
			*  @author						 	: Shriram Mahamuni
			*  @objectreferenced		: ApexPage
			*  @param						  	: String
			*  @description					: This method used to start the initiation and execution of an HTTP request to create a vf page.
			*  @return						 	: ApexResultSet
		*/
		public static ApexResultSet makeAPICall(String bodyString){
			ApexResultSet aResult = new ApexResultSet();
			HttpRequest req = new HttpRequest();

			String salesforceHost = System.Url.getOrgDomainUrl().toExternalForm();
			String url =  salesforceHost + Constants.URLSTRING;
			url = url.replace('latestAPIVersion','v'+Utility.getLatestAPIVersion());

			req.setMethod(Constants.POSTMETHODSTRING);
			req.setEndpoint(url);
			req.setHeader(Constants.CONTENTTYPESTRING, Constants.APPLICATIONJSON);
			req.setBody(bodyString);

            if(Test.isRunningTest())
            {
            	integer i = 1/1;
            }
			else
            {
                String content = Page.SessionPage.getContent().toString();
                Integer s = content.indexOf(Constants.START_OF_SESSION_IDSTRING) + Constants.START_OF_SESSION_IDSTRING.length(),
				e = content.indexOf(Constants.END_OF_SESSION_IDSTRING);
				String sessionId = content.substring(s, e);
                req.setHeader(Constants.AUTHORIZATIONSTRING, Constants.BEARERSTRING + sessionId);
            }

			Http http = new Http();
			HTTPResponse res = http.send(req);

			String jsonString =res.getBody();
      system.JSONParser parser = JSON.createParser(jsonString);

			while(parser.nextToken()!=null){
        if(parser.getText()=='success'){
          parser.nextToken();
					aResult.isSuccess = true;
        }else if(parser.getText()=='message'){
                    parser.nextToken();
					aResult.isSuccess = false;
					aResult.message = parser.getText();
				}
      }
			return aResult;
	}


	/**
	* @ methodname             : getfields.
	* @ author                 : Sarjerao Pujari.
	* @ objectreferenced       : None.
	* @ param                  : None.
	* @ description            : This method is used to get all the fields of object.
	* @ return                 : None.
	*/
	@AuraEnabled(cacheable=true)
	public static List<FieldDefinition> getfields(string objectname){
	    string query = 'select DataType,Label,  DeveloperName,QualifiedApiName from FieldDefinition where EntityDefinition.QualifiedApiName = :objectname ORDER BY Label ASC ';
	    list<FieldDefinition> lstObject = Database.query(query);
	    for(Integer i=0;i<lstObject.Size();i++){
	    }
	    return lstObject;
	}
 

	/**
	* @ methodname             : getRecordData.
	* @ author                 : Sarjerao Pujari.
	* @ objectreferenced       : None.
	* @ param                  : None.
	* @ description            : This method is used to get all the record data based on record Id.
	* @ return                 : None.
	*/
	@AuraEnabled(cacheable=true)
	public static List<Send_Configuration__c> getRecordData(string recId)
	{
		string PCKNAMESPACEPREFIX = Constants.NAMESPACEPREFIX;
		system.debug('name space prefix === '+PCKNAMESPACEPREFIX);
		system.debug('SBC record id == '+recId);
		List<Send_Configuration__c> sbcList = [select Id, Object_Name__c, Phone_Fields__c, Name_Field__c, Consent_Field__c from Send_Configuration__c where Id =: recId ];
		//return [select Id, Object_Name__c, Phone_Fields__c, Name_Field__c, Consent_Field__c from Send_Configuration__c where Id =: recordId ];
		return sbcList;
	}


	/**
	* @ methodname             : updateSendButtonConfiguration.
	* @ author                 : Sarjerao Pujari.
	* @ objectreferenced       : None.
	* @ param                  : None.
	* @ description            : This method is used to update the Send Configuration record after Edit.
	* @ return                 : None.
	*/
	@AuraEnabled
	public static void updateSendButtonConfiguration(string recId, string objName, string phoneFields, string nameField, string selectedConsent)
	{
		system.debug('recId in update == '+recId);
		Send_Configuration__c sendConfigurationobj = [select Id, Object_Name__c, Phone_Fields__c, Name_Field__c, Consent_Field__c from Send_Configuration__c where Id =: recId];	
		system.debug('sendConfigurationobj in update == '+sendConfigurationobj);
	    sendConfigurationobj.Id = recId;
		sendConfigurationobj.Object_Name__c = objName;
		sendConfigurationobj.Phone_Fields__c = phoneFields;
		sendConfigurationobj.Name_Field__c = nameField;
		sendConfigurationobj.Consent_Field__c = selectedConsent;
		update sendConfigurationobj;
	}

	/**
	* @ methodname             : getAllVfPages.
	* @ author                 : Sarjerao Pujari.
	* @ objectreferenced       : ApexPage.
	* @ param                  : None.
	* @ description            : This method is used to get all the Existing Vf Pages.
	* @ return                 : string.
	*/
	@AuraEnabled
	public static string getAllVfPages(string objName)
	{
		string createSBC;
		system.debug('objName to fetch Vf Page == '+objName);
		string FullpageName = objName+Constants.VFPAGESUFFIX;
		string ShortPageName = objName+Constants.VFPAGESUFFIXSHORT;
		system.debug('full Page Name === '+FullpageName);
		system.debug('Short Page Name=== '+ShortPageName);
		List<ApexPage> vfPageList = [select Id,name from ApexPage];

		for(Integer i=0;i<vfPageList.Size();i++)
		{
			if(vfPageList[i].name == FullpageName || vfPageList[i].name == ShortPageName)
			{
				createSBC = 'True';
			}else{
				createSBC = 'False';
			}
		}
		system.debug('create SBC value === '+ createSBC);
		return createSBC;
	}
}