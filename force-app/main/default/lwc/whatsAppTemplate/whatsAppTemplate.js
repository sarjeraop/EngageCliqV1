import { LightningElement,wire,track,api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Attachment from 'c/attachmentModel';
import EngageCliq from '@salesforce/resourceUrl/engagecliq';
import ACCESSCHECK from '@salesforce/apex/WhatsAppTemplateController.initialiseWhatsAppTemplate';
import NAME_FIELD from "@salesforce/schema/Template__c.Name__c";
import WHATSAPP_TEMPLATE_OBJECT from '@salesforce/schema/WhatsApp_Template__c';
import TEMPLATE_TYPE_FIELD from "@salesforce/schema/WhatsApp_Template__c.Template_Type__c";
import TEMPLATE_CATEGORY_FIELD from "@salesforce/schema/WhatsApp_Template__c.WhatsApp_Category__c";
import getApprovedTemplate from "@salesforce/apex/WhatsAppTemplateController.getAllApprovedWhatsAppTemplate";
import getBusinessId from "@salesforce/apex/WhatsAppAPIService.getBusinessId";
import languageFinder from '@salesforce/apex/WhatsAppTemplateController.getSupportdLanguageWhatsApp';
import getTemplates from '@salesforce/apex/WhatsAppTemplateController.getWhatsAppTemplate';
import { reduceErrors } from 'c/whatsAppTemplateUtils';
import {getPackagePrefix} from "c/utils";
import {getTemplate} from "c/utils";
import {getWhatsAppTemplate} from "c/utils";  
import saveTemplate from '@salesforce/apex/WhatsAppTemplateBI.saveWhatsAppTemplate';
//import saveUserInitaitiveTemplate from '@salesforce/apex/WhatsAppTemplateUI.getTemplateDetails';
import saveUserInitaitiveTemplate from '@salesforce/apex/WhatsAppTemplateController.getTemplateDetails';
import ERRORMAXLENGTH from "@salesforce/label/c.you_have_exceeded_the_max_length";
import BI from "@salesforce/label/c.business_initiative_label";
import SELECTTEMPLATES from "@salesforce/label/c.select_templates_label";
import CONTACTSYSTEMADMIN from "@salesforce/label/c.contact_system_admin_label";
import TEMPLATEUPDATED from "@salesforce/label/c.template_successfully_updated_label";
import TEMPLATECREATED from "@salesforce/label/c.template_successfully_created_label";
import BUTTONTEXT from "@salesforce/label/c.enter_value_in_button_text_label";
import ENTERMESSAGEBODY from "@salesforce/label/c.enter_message_body_label";
import MESSAGEBODYEMPTY from "@salesforce/label/c.message_body_empty";
import ENTERVALUEINLABEL from "@salesforce/label/c.enter_value_Label";

import DEFAULTVALUE from "@salesforce/label/c.default_value";
import HEADERANDFOOTERERROR from "@salesforce/label/c.header_and_footer_error";
import FILLMAPPINGVALUE from "@salesforce/label/c.fill_mapping_value";
import USERINITIATIVE from "@salesforce/label/c.user_initiative";
import INPROGRESS from "@salesforce/label/c.inprogress";
import NEWWHATSAPPTEMPLATE from "@salesforce/label/c.new_whatsApp_template";


export default class WhatsAppTemplate extends NavigationMixin(LightningModal) {
  @api namePrefix;
  @api templateParameters;
    recordId;
    temp;
    whatsAppTemp;
    formats;
    interactiveValue = 'None'
    headerSelectedValue = 'None'
    @track objectName;
    @track objWhatsAppTemplate = { 'sobjectType': 'WhatsApp_Template__c' };
    @track templateTypeOptions;
    @track templateCategoryOptions;
    @track templateLanguageOptions = [];
    @track approvedTemplateOptions = [];
    @track approvedTemplatename;
    @track isTextHeader;
    @track footerTextValue;
    @track patternString;
    @track tempBody;
    @track finalTempBody;
    @track whatsAppTemplateRecordId;

    @track jsonTemplate;
    @track picklistOrdered;
    @track searchResults;

    @track isMedia;
    @track isMediaText;
    createNewValue  = 'createNew';
    @track headerOptions = [
            { label: 'None', value: 'None' },
            { label: 'Text', value: 'Text'  },
            { label:'Media', value: 'Media'}
        ]; 
    @track UIMsgBody = '';
    @track mediaOptionValue = 'None';
    @track interactiveValue = 'None';
    @track allowedFormats = ['bold','italic','strike'];
    @track errorMessage;
    @track hhh = [];
    @track objFlag ={
      isInteractiveButton : false,
      interactActiveFlag : false,
      isBusinessInitiative : false,
      isAddButtonVisible : false,
      disableButtons : false,
      headerTextDisable : false,
      disableSaveButton : false,
      isApprovedTemplateVisible : false,
      isMediaUrl : false
  }; // Object to store all  flag value for conditional rendering
    interActiveButtonValue = 'None';
   @track templateArray =[];
    @track isAddButtonVisible;
    @track isInteractiveButton;
    @track newTemplateInfo =  {'sobjectType':'Template__c'};
    @track buttonList;
    @track buttonListSelected =
    [{
            id:0,
            type: "",
            interActiveType: this.interActiveButtonValue,
            text: "",
            phone_number_OR_url: ""
        }
    ];
    @track itemList =[
        {
            id: 0,
            value:''
        }
    ];
    @track keyIndex = 0;
    /** Start - Table Logic and variables **/
    @track filterList = [];
    finalFilterList = [];
    keyCounter = 0;
    /** End - Table Logic */

    //isMedia = false;
    value = INPROGRESS;
    templateStatus = NEWWHATSAPPTEMPLATE;
    get name() {
      return this.childProps ? getSObjectValue(this.childProps, NAME_FIELD) : "";
    }

    // retrive template object information from salesforce
    @wire(getObjectInfo, { objectApiName: WHATSAPP_TEMPLATE_OBJECT })
    templateInfo;
    //  retrive template type from salesforce to be displayed in combo box
    @wire(getPicklistValues, { recordTypeId: '$templateInfo.data.defaultRecordTypeId',
    fieldApiName: TEMPLATE_TYPE_FIELD })
    wiredTempType({ error, data }) {
        if (data) {
            this.templateTypeOptions = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
    //  retrive template category from salesforce to be displayed in combo box
    @wire(getPicklistValues, { recordTypeId: '$templateInfo.data.defaultRecordTypeId',
    fieldApiName: TEMPLATE_CATEGORY_FIELD })
    wiredTempCategory({ error, data }) {
        if (data) {
            this.templateCategoryOptions = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
// access check for fields
  getAccessCheck(){
        ACCESSCHECK()
                .then((result) => {
                    if(result.isSuccess === false){
                        this.showToast('Error',result.message,'error','dismissable');
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.data = undefined;

                });
    }
    //retrieve language from metadata to be displayed in combo box
    getlanguageData(){
      languageFinder()
          .then((result) => {
                if(result.data){
                    result.data.forEach(element=>{
                    this.templateLanguageOptions = [...this.templateLanguageOptions ,{value: element.DeveloperName,
                    label: element.MasterLabel}];
            });
                }
            })
            .catch((error) => {
                this.error = error;
                this.data = undefined;

            });
    }

    @wire(getObjectInfo, { objectApiName: '$objectName' })
    objectInfo({ error, data }) {
        if (data) {
            let fieldsInfos = new Object(data.fields);
            this.fieldItems = [];
            this.objFieldValue ='';
            for(let fieldName in fieldsInfos) {
                let fieldInfo = fieldsInfos[fieldName];
                if(fieldInfo['dataType']!= 'Reference'){
                    this.fieldItems = [...this.fieldItems ,{value: fieldName , label: fieldInfo['label']} ];
                }
            }
            this.fieldOptions = this.fieldItems;
        }
        else if (error) {
          this.error = error;
        }
    }
 async getApprovedTemplateData(){
  await  getApprovedTemplate({templatejson:this.jsonTemplate})
      .then((result) => {
          if(result.data){
            console.log('result data === '+ JSON.stringify(result.data.Id));
          if(result.data.nextURL != undefined){
            this.jsonTemplate = result.data.nextURL;
          }else{
            console.log('next url from data === '+result.data.nextURL);    
          }

            for (var key in result.data) {
              this.approvedTemplateOptions = [...this.approvedTemplateOptions ,{label: key, value: JSON.stringify(result.data[key])}];
              console.log('approved tem List == '+ JSON.stringify(this.approvedTemplateOptions));
             }
             this.hhh=this.approvedTemplateOptions;
           }
            })
      .catch((error) => {
                this.error = error;
                this.data = undefined;
            });
  }
    get template_type_options(){
        return this.templateTypeOptions;
    }
    get template_category(){
        return this.templateCategoryOptions;
    }
    get template_language(){
        return this.templateLanguageOptions;
    }
    get patternString(){
      if(this.objFlag.isBusinessInitiative){
        return '[a-zA-Z0-9\s]*';
      }else{
        return '[]*';
      }
    } 
    get parameters(){
        return {
          'previewMessage': this.finalTempBody,
          'header' : this.headerTextValue,
          'footer' : this.footerTextValue,
          'listOfButton':this.buttonListSelected,
          'listOfButtonUI':this.itemList,
          'isBusinessInitiative': this.objFlag.isBusinessInitiative
          };

    }

    get optionsCreateNew(){
      return [
        { label: 'Create New', value: 'createNew'},
        { label: 'Approved WhatsApp Templates', value: 'existing'}
      ]
    }
    get mediaOptions() {
      return [
          { label: 'Image (Supports JPG or PNG file)', value: 'Image'},
          { label: 'Video (Support MP4 file)', value: 'Video'},
          { label: 'Document (Support PDF file)', value: 'Document' }
      ];
    }
    get interactiveOptions() {
      if(this.objWhatsAppTemplate.Template_Type__c == BI){
        return [
            { label: 'None', value: 'None'},
            { label: 'Button', value: 'Button'}
        ];
      }
      else{
        return [
            { label: 'None', value: 'None'},
            { label: 'Button', value: 'Button'},
            { label: 'List', value: 'List'}
        ];
      }
    }
  //retrieve combo-box values as status options
    get statusOptions() {
      return [
          { label: 'Draft', value: 'None'},
          { label: 'Approved', value: 'Approved'},
          { label: 'Pending for Approval', value: 'Pending for Approval'},
          { label: 'Rejected', value: 'Rejected'}
      ];
    }
    get radioOptions() {
        return [
            { label: 'None', value: 'option1' },
            { label: 'Text', value: 'option2' },
            { label: 'Media', value: 'option3' },
        ];
    }

    get radioOptionsInt() {
        return [
            { label: 'None', value: 'option4' },
            { label: 'Button', value: 'option5' },
            { label: 'List', value: 'option6' },
        ];
    }

    // Updated Code by sarjerao for Business Id
    GETBUSINESSID(){
    getBusinessId()
    .then((result) => {
      this.whatsAppBusinessId = result;
      this.jsonTemplate = 'https://graph.facebook.com/v17.0/' + this.whatsAppBusinessId + '/message_templates?fields=id,name,status,category,language,components&status=APPROVED';
          })
    .catch((error) => {
              this.error = error;
              this.data = undefined;
          });
    }

    connectedCallback(){

      this.GETBUSINESSID(); 

      this.getAccessCheck();

      this.getlanguageData();
      if(this.templateParameters.recordId){
        this.recordId = this.templateParameters.recordId;
        
      }
      this.namePrefix = getPackagePrefix();
      this.temp = getTemplate();
      this.whatsAppTemp = getWhatsAppTemplate();
      const tabindex = this.getAttribute(this.temp.name);

      if(this.templateParameters)
      {
      this.newTemplateInfo[this.temp.targetSource] = this.templateParameters.Target_Source__c;
      this.newTemplateInfo[this.temp.name] = this.templateParameters.Name__c;
      this.newTemplateInfo[this.temp.description] = this.templateParameters.Description__c;
      this.newTemplateInfo['Id'] = this.templateParameters.Id;
     }
      if(this.recordId){
        this.templateStatus = 'Edit WhatsApp Template';
        this.objFlag.isBusinessInitiative = true;
          this.patternString = '[a-zA-Z0-9\s]*';
          this.getTemplateDetails();
          
      }else{
          this.objWhatsAppTemplate.Template_Type__c=USERINITIATIVE;
          this.objWhatsAppTemplate.Status__c = 'Draft';
          this.mode='createUI';
          this.patternString = '[]*';
         // this.setMode();
          
      }

      if(this.newTemplateInfo != undefined){
          //SCENARIO :Create New Template
          this.objectName = this.newTemplateInfo[this.temp.targetSource]//Target_Source__c;  //this displays selected value of combo box
          this.templateName = this.newTemplateInfo[this.temp.name].trim().toLowerCase().split(' ').join('_');
          this.objWhatsAppTemplate.Name__c = this.templateName;
          this.objWhatsAppTemplate.Language__c = 'en_US';
       }

      
     /* var recId = 'createNewOrExisting';
      var item = this.template.querySelector('[data-recid="'+recId+'"]');
      if(item){
      }*/
      
      this.setMode();
      this.displayrendering();
   }
displayrendering(){
  console.log('this.objWhatsAppTemplate.Template_Type__c :'+this.objWhatsAppTemplate.Template_Type__c);
  if(this.objWhatsAppTemplate.Template_Type__c == BI){
    this.objFlag.isBusinessInitiative = true;
}
  let item = this.template.querySelector('[data-recid="createNewOrExisting"]');
  if(item){
    console.log('item.disabled :'+item.disabled);
  }else{
    console.log('item.disabled not :');
  }
  
  this.templateArray = reduceErrors(this.mode, this.templateArray);
  console.log('this.templateArray :'+JSON.stringify(this.templateArray));
  
  if(this.templateArray){
    this.templateArray.forEach((template) => {
       if (template) {
            let recId = template.Id;
            var item = this.template.querySelector('[data-recid="'+recId+'"]');

            if (item && item != null) {
                item.disabled = template.isDisable;
            }
       }
    });
  }
}
setMode(){
    if(this.recordId != undefined && this.recordId != null){
        this.mode = 'edit';
    }else{
        this.mode = 'create';
    }
    if(this.objWhatsAppTemplate.Template_Type__c == BI){
        this.mode += 'BI';
    }else if(this.objWhatsAppTemplate.Template_Type__c == USERINITIATIVE){
        this.mode += 'UI';
    }
   }
   /* renderedCallback() {
      this.displayrendering();
    //     Promise.all([
    //         loadStyle(this, EngageCliq+'/CSS/colors.css')
    //     ])
         }*/
    // function to handle event from interactive button on add row button clicked
    handleSelectedRow(event) {
    this.buttonListSelected = event.detail;
    
  }

    handleChange(event) {
      if (event.target.name == 'index') {
          this.filterList[event.currentTarget.dataset.index].index = event.target.value;
      }
      else if (event.target.name == 'sfFieldName') {
          this.filterList[event.currentTarget.dataset.index].sfFieldName = event.target.value;
      }
      else if (event.target.name == 'sampleValue') {
          this.filterList[event.currentTarget.dataset.index].sampleValue = event.target.value;
      }
    }
    async handleCreateNewChange(event){
      this.createNewValue = event.target.value;
      if(event.target.value == 'existing'){
           await this.getApprovedTemplateData();
            this.objFlag.isApprovedTemplateVisible = true;
        }else{
        // SCENARIO : create new BI template
        this.objFlag.isApprovedTemplateVisible = false;
        this.mode = 'createBINew';
        this.resetAll();
        this.displayrendering();
         this.objWhatsAppTemplate.Name__c = this.templateName;
        this.objWhatsAppTemplate.Language__c = 'en_US';
        }
      }
  /*  handleApprovedTemplateChange(event){
        this.approvedTemplatename = event.detail.value;
        if(event.target.value != undefined && event.target.value != ''){
            // SCENARIO : create BI template from already approved template
            this.objWhatsAppTemplate.Status__c = 'Approved';
            this.objFlag.disableButtons = true;
            this.mode = 'createBI';
            this.getTemplateDetailsFromBIJsonObject(JSON.parse(event.target.value));
            let item = this.template.querySelector('[data-recid="HeaderText"]');
            console.log('item '+item);
            this.displayrendering();
        }
    }*/
    resetAll(){
      this.newobjWhatsAppTemplate = {Template_Type__c : this.objWhatsAppTemplate.Template_Type__c}
      this.objWhatsAppTemplate = this.newobjWhatsAppTemplate;
      this.objWhatsAppTemplate.Name__c = this.templateName;
      this.objWhatsAppTemplate.Language__c = 'en_US';

      this.headerTextValue='';
      this.footerTextValue = '';
      this.UIMsgBody ='';
      this.filterList=[];
      this.interactiveValue='None';
      this.objFlag.isInteractiveButton = false;
      this.buttonListSelected=[];
    }
    handleChangeTemplateType(event){
        this.objWhatsAppTemplate.Template_Type__c = event.detail.value;
        if(this.objWhatsAppTemplate.Template_Type__c == BI){
            this.headerOptions=  [
          { label: 'None', value: 'None'},
          { label: 'Text', value: 'Text'}
          ];
            this.objFlag.isBusinessInitiative = true;
            this.interactiveValue ='None';
            this.objFlag.isAddButtonVisible = false;
            this.objFlag.isInteractiveButton = false;
            this.showToast('',SELECTTEMPLATES ,'info','sticky')
            this.mode='createBINew';
        }else{
          this.headerOptions =  [
          { label: 'None', value: 'None'},
          { label: 'Text', value: 'Text'},
          { label: 'Media', value: 'Media'}
          ];
          this.objFlag.isBusinessInitiative = false;
          this.resetAll();
          this.objFlag.isAddButtonVisible = false;
          this.objFlag.isInteractiveButton = false;
          this.mode='createUI';
          }
            /*var recId = 'createNewOrExisting';
            var item = this.template.querySelector('[data-recid="'+recId+'"]');
            if(item){
            }*/

        //this.setMode();
        this.displayrendering();
    }
    updateValues(event){
        if(event.target.name === 'Category'){
            this.objWhatsAppTemplate.WhatsApp_Category__c = event.target.value;
        }else if(event.target.name === 'Language'){
            this.objWhatsAppTemplate.Language__c = event.target.value;
        }else if(event.target.name === 'Field'){
            this.objFieldValue = event.detail.value;
        }else if(event.target.name === 'HeaderText'){
            this.headerTextValue = event.target.value;
        }else if(event.target.name === 'HeaderMediaURL'){
            this.mediaURLValue = event.target.value;
        }else if(event.target.name === 'Footer'){
            this.footerTextValue = event.target.value;
            this.validateInput();
        }
    }




    validateInput() {
      const regex = /[^\p{L}\p{M}\p{Sc}\p{Z}\p{N}\p{P}\n\r]/gu;
      if (regex.test(this.footerTextValue) && this.objFlag.isBusinessInitiative == true) {
        this.objFlag.disableSaveButton = true;
        this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'Emojis are not allowed', variant: 'error' }));
      }
      else{
        this.objFlag.disableSaveButton = false;
      }
  }



    // method on chnage of radio button
    handleHeaderChange(event) {
      const header = event.detail.value;
      this.headerSelectedValue = header;
      if (this.headerSelectedValue == "Text") {
          this.isTextHeader = true;
          this.isMedia = false;
          this.isMediaText = false;
      }else if(this.headerSelectedValue == "Media"){
        this.isMedia = true;
        this.isTextHeader = false;
        //this.isMediaText = true;
      }else{
        this.headerTextValue = '';
        this.isTextHeader = false;
        this.isMedia = false;
       this.isMediaText = false;
        }
        //this.displayrendering();
      }
   // method on chnage of radio button
  handleMediaChange(event) {
    // get the string of the "value" attribute on the selected option
    this.mediaOptionValue = event.detail.value;
    if(this.mediaOptionValue == 'Image'){
      this.formats = ['.png', '.jpg'];
    }else if(this.mediaOptionValue == 'Video'){
      this.formats = ['.mp4'];
    }else if(this.mediaOptionValue == 'Document'){
      this.formats = ['.pdf'];
    }
    this.isMediaText = true;
    this.objFlag.isMediaUrl = false;
    this.mediaURLValue ='';
  }

  handleInteractiveChange(event){
      this.interactiveValue = event.target.value;
      if(this.objWhatsAppTemplate.Template_Type__c == USERINITIATIVE) {
        if(this.interactiveValue == 'List'){
         this.headerOptions=  [
          { label: 'None', value: 'None'},
          { label: 'Text', value: 'Text'}
          ];
          this.isMediaText=false;
          this.isMedia=false;    
      }else{
         this.headerOptions=  [
          { label: 'None', value: 'None'},
          { label: 'Text', value: 'Text'},
          { label: 'Media', value: 'Media'}
          ];
      }
      }
      
      
      if (this.interactiveValue == 'None') {
          this.itemList = [];
          this.objFlag.isAddButtonVisible = false;
          this.objFlag.isInteractiveButton = false;
          this.objFlag.interactActiveFlag = false;
          }
      else if(this.objWhatsAppTemplate.Template_Type__c == BI && this.interactiveValue == 'Button') {
          this.objFlag.isAddButtonVisible = false;
          this.objFlag.isInteractiveButton = true;
         }
          else{
              this.itemList =[
                  {
                      id: 0,
                      value:''
                  }
              ];
              this.objFlag.isAddButtonVisible = true;
              this.objFlag.isInteractiveButton = false;
          }
          this.disableBtn = false;
  }



  @track validity =true;
  templateBodyChange(event) {
    this.UIMsgBody = event.target.value;
    var temp = this.UIMsgBody;

      if(this.UIMsgBody.length > 1024){
                this.validity = false;
                this.errorMessage = ERRORMAXLENGTH;
                this.objFlag.disableSaveButton = true;
      }
      else{
        this.objFlag.disableSaveButton = false;
        this.errorMessage = '';
        this.validity = true;
      }
      try{
      let objSample = this.filterList;
    this.filterList.forEach(function (arrayItem) {
        if(temp.includes( arrayItem.index )){
           // temp.replace(JSON.stringify(arrayItem.index),'');
        }else{
        // remove item from array
        temp.replace(JSON.stringify(arrayItem.index),'');
        const index = objSample.indexOf(arrayItem);
        //logic to update index
        let newIndex =1;
        objSample.splice(index,1);
        objSample.forEach(function(Item){
        if(temp.includes(Item.index)){
            let newString = '{{'+newIndex+'}}';
            temp = temp.replace(Item.index,newString);

          }
          Item.index = '{{'+newIndex +'}}';
          Item.id = newIndex;
          ++newIndex;
        })
        //this.UIMsgBody = temp;
        event.target.value = temp;
        //objSample.splice(index,1);
        }
    });
    this.filterList = objSample;

    }
    catch(e){
        console.log('e:',e.message);
    }

}

    insertAttribute(event) {
      this.handleAddRow('');
      let index = '{{'+this.filterList.length+'}}';
      let cursor = this.template.querySelector('lightning-input-rich-text');
      cursor.insertTextAtCursor(index);
  }
    // Display customized toast message
    showToast(title,message,variant,mode) {
      const evt = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant,
          mode: mode
      });
      this.dispatchEvent(evt);
    }
    // get template details - Edit case - has recordId
    getTemplateDetails(){
      getTemplates({whatsAppTemplaterecordId : this.recordId })
          .then(result => {
          if (result !== null) {
            console.log('result : '+JSON.stringify(result));
            let resultString = JSON.stringify(result.data);
            resultString = resultString.replaceAll(this.namePrefix.PKGPREFIX,'');
            this.objWhatsAppTemplate = JSON.parse(resultString);
            console.log('objWhatsAppTemplate : ',this.objWhatsAppTemplate);
            if (this.objWhatsAppTemplate.WhatsApp_Message_Body__c) {
              if(this.objWhatsAppTemplate.Merge_Field_Mapping__c){
              const arrayItem = JSON.parse(this.objWhatsAppTemplate.Merge_Field_Mapping__c);//WhatsApp_Message_Body__c
              arrayItem.forEach(element=>{
                  let objRow = {
                      index: element.index,
                      sfFieldName: element.sfFieldName,
                      sampleValue: element.sampleValue
                  }
                  this.filterList = [...this.filterList ,objRow];
              });
              }
          }
         if(this.objWhatsAppTemplate.Template_Type__c != undefined){
              if(this.objWhatsAppTemplate.Template_Type__c == BI){
                this.headerOptions=  [
                                      { label: 'None', value: 'None'},
                                      { label: 'Text', value: 'Text'}
                                      ];
                this.objFlag.isBusinessInitiative = true;
                this.getTemplateDetailsFromBIJsonObject(JSON.parse(this.objWhatsAppTemplate.JSON_Payload__c));
                
              }
              if(this.objWhatsAppTemplate.Template_Type__c == USERINITIATIVE){
                this.headerOptions=  [
                                      { label: 'None', value: 'None'},
                                      { label: 'Text', value: 'Text'},
                                      { label: 'Media', value: 'Media'}
                                      ];
                
                this.objFlag.isBusinessInitiative = false;
                //this.UIMsgBody = this.objWhatsAppTemplate.WhatsApp_Message_Body__c;
                
                this.getTemplateDetailsFromUIJsonObject(JSON.parse(this.objWhatsAppTemplate.JSON_Payload__c));
              }
              if(this.objWhatsAppTemplate.WhatsApp_Message_Body__c){
                this.UIMsgBody = this.objWhatsAppTemplate.WhatsApp_Message_Body__c;
              }
            }
          if(this.objWhatsAppTemplate.JSON_Wrapper__c != undefined){
            let objWrapper =JSON.parse(this.objWhatsAppTemplate.JSON_Wrapper__c);
            if(this.newTemplateInfo == undefined){
                this.newTemplateInfo = objWrapper.templateObject;
            }
            this.objectName = objWrapper.templateObject.Target_Source__c;
            this.sampleInputList = objWrapper.sampleValues;
            this.filterList = this.sampleInputList;
            if(this.objWhatsAppTemplate.Template_Type__c == USERINITIATIVE){
                this.headerBody = objWrapper.headerBody;
                this.footer = objWrapper.footerBody;
            }
            console.log('objWrapper :'+JSON.stringify(objWrapper));
            
            if(objWrapper.mediaURL){
              this.mediaURLValue = objWrapper.mediaURL;
            }
          }
             } else {
              this.showToast('Success',CONTACTSYSTEMADMIN ,'success','dismissable');

          }
          this.setMode();
          this.displayrendering();
          })
          .catch(error => {
              this.showToast('Error',error,'error','dismissable');

          });

  }
  handleReest() {
    this.template.querySelector('form').reset();
}
    //Fetch template details from BI Json Object
    getTemplateDetailsFromBIJsonObject(templateObject){
      console.log('templateObject : '+JSON.stringify(templateObject.name));
      this.filterList=[];
      this.objWhatsAppTemplate.Name__c = templateObject.name;
      this.objWhatsAppTemplate.WhatsApp_Category__c = templateObject.category;
      this.objWhatsAppTemplate.Language__c = templateObject.language;
      if(templateObject.id){
        this.objWhatsAppTemplate.WhatsApp_Template_ID__c = templateObject.id;
        this.objWhatsAppTemplate.Whatsapp_Approval_Status__c = 'APPROVED';
      }
      if(this.objWhatsAppTemplate.WhatsApp_Template_ID__c){
        this.createNewValue = 'existing';
        this.displayrendering();
      }
      this.buttonListSelected =[];
      this.keyIndex = 0;
      if(templateObject.components){
      templateObject.components.forEach(obj => {
        if(obj.type == 'HEADER'){
          if(obj.format == 'TEXT'){
            this.headerTextValue = obj.text;
            this.headerSelectedValue = 'Text';
            this.isTextHeader = true;
            this.isMediaText = false;
            let item = this.template.querySelector('[data-recid="HeaderText"]');
          }else if(obj.format == 'MEDIA'){
            this.mediaOptionValue = objWrapper.media;
            //this.isMediaText = true;
            // need to implement for Media Header - Sprint2
          }
        }else if(obj.type =='BODY'){
            //this.objWhatsAppTemplate.Message_Body__c = obj.text;
          this.UIMsgBody = obj.text;
          if(obj.example != undefined){
            if(this.objWhatsAppTemplate.Merge_Field_Mapping__c){
              this.filterList = this.objWhatsAppTemplate.Merge_Field_Mapping__c;
            }else{
                obj.example.body_text.forEach(sampleList =>{
                let i =1;
                sampleList.forEach(sample =>{
                    this.filterList = [...this.filterList,{index:'{{'+i+'}}',sfFieldName:'',sampleValue:sample}];
                    i=i+1;
                })
                })
            }

          }
        }else if(obj.type == 'FOOTER'){
            this.footerTextValue = obj.text
         }else if(obj.type == 'BUTTONS'){
            this.interactiveValue = 'Button';
            this.objFlag.isInteractiveButton = true;
            // initialise this.buttonListSelected here
            obj.buttons.forEach(button => {
            if(button.type == 'QUICK_REPLY'){
              this.interActiveButtonValue = 'quickreply'
              let newEntry = {
              interActiveType: this.interActiveButtonValue,
              type : button.type,
              text : button.text,
              phone_number_OR_url : '',
              typeAction:'custom',
              id: this.keyIndex++
              };
              if ( this.buttonListSelected.length >= 1) {
                  this.buttonListSelected = [...this.buttonListSelected, newEntry];
              }else{
                  this.buttonListSelected = [ newEntry ];
              }
              console.log('this.buttonListSelected :'+this.buttonListSelected);
            }else if(button.type == 'PHONE_NUMBER'){
              this.interActiveButtonValue = 'calltoaction'
              let newEntry = {
                  interActiveType: this.interActiveButtonValue,
                  type : button.type,
                  text : button.text,
                  phone_number_OR_url : button.phone_number,
                  id: this.keyIndex++
                  };
              if ( this.buttonListSelected.length >= 1) {
                this.buttonListSelected = [...this.buttonListSelected, newEntry];
              }else{
                this.buttonListSelected = [ newEntry ];
              }
            }else if(button.type == 'URL'){
              this.interActiveButtonValue = 'calltoaction'
              let newEntry = {
                  interActiveType: this.interActiveButtonValue,
                  type : button.type,
                  text : button.text,
                  phone_number_OR_url : button.url,
                  id: this.keyIndex++
                  };
              if ( this.buttonListSelected.length >= 1) {
                  this.buttonListSelected = [...this.buttonListSelected, newEntry];
              } else {
                  this.buttonListSelected = [ newEntry ];
                  }
            }
            })
          }
      });

    }
    let item = this.template.querySelector('[data-recid="HeaderText"]');
    this.displayrendering();
    }
    getTemplateDetailsFromUIJsonObject(templateObject){
      this.itemList =[];
      this.keyIndex = 0;
      //header
      try{
      if(templateObject.interactive || templateObject.interactive != null){
      if(templateObject.interactive.header != undefined){
        
          if(templateObject.interactive.header.type == 'text'){
              this.headerTextValue = templateObject.interactive.header.text;
              this.headerSelectedValue = 'Text';
              this.isTextHeader = true;
          }else if(templateObject.interactive.header.type == 'Image' || templateObject.interactive.header.type == 'Video' || templateObject.interactive.header.type == 'Document'){
            this.headerSelectedValue = 'Media';
            this.isMedia =true;
            this.isMediaText = true;
            this.mediaOptionValue = templateObject.interactive.header.type;
            this.objFlag.isMediaUrl = true;
            if(templateObject.interactive.header.link){
              console.log('templateObject.interactive.header.link :'+templateObject.interactive.header.link);
              this.mediaURLValue = templateObject.interactive.header.link;
              
            }
            }else{
              this.headerSelectedValue = 'None';
            }
          }
      //footer
      if(templateObject.interactive.footer != undefined){
          this.footerTextValue = templateObject.interactive.footer.text
       }

      if(templateObject.interactive.type != 'none'){

       if(templateObject.interactive.type == 'button'){
          this.interactiveValue = 'Button';
          this.objFlag.isAddButtonVisible = true;
          this.objFlag.isInteractiveButton = false;
          templateObject.interactive.action.buttons.forEach(obj =>{
              var newItem = [{ id: this.keyIndex, value:obj.reply.title}];
              this.itemList = this.itemList.concat(newItem);
              ++this.keyIndex;
          })

      }

      else if(templateObject.interactive.type == 'list'){
        this.headerOptions=  [
          { label: 'None', value: 'None'},
          { label: 'Text', value: 'Text'}
          ];
          this.interactiveValue = 'List';
          this.objFlag.isAddButtonVisible = true;
          this.objFlag.isInteractiveButton = false;
          
          templateObject.interactive.action.sections.forEach(sec =>{
              sec.rows.forEach(obj =>{
              var newItem = [{ id: this.keyIndex, value:obj.title}];
              this.itemList = this.itemList.concat(newItem);
              ++this.keyIndex;
          })
          })
    }
    if (this.interactiveValue && this.interactiveValue == 'Button' && this.itemList && this.itemList.length > 2) {
                    this.disableButton = true;
                } else if (this.interactiveValue && this.interactiveValue == 'List' && this.itemList && this.itemList.length > 9) {
                    this.disableButton = true;
                }
                else{
                    this.disableButton = false;
                } 

  }
  }else{
    console.log('in else : ');
    var wrapperObject = JSON.parse(this.objWhatsAppTemplate.JSON_Wrapper__c);
    console.log('wrapperObject : '+JSON.stringify(wrapperObject));
    this.UIMsgBody = this.objWhatsAppTemplate.WhatsApp_Message_Body__c;
    if(wrapperObject.headerBody){
      this.headerTextValue = wrapperObject.headerBody;
    }
    if(wrapperObject.footerBody){
      this.footerTextValue = wrapperObject.footerBody;
    }
    
    if(wrapperObject.media != ''){
      //console.log('in if media : '+JSON.stringify(wrapperObject));
      if(wrapperObject.media == 'None'){
        this.headerSelectedValue = wrapperObject.media;
      }else{
        this.headerSelectedValue = 'Media';
        this.isMedia = true;
        //this.mediaOptionValue
        this.isMediaText = true;
        console.log('wrapperObject.media :'+wrapperObject.media);
        this.mediaOptionValue = wrapperObject.media;
        this.mediaURLValue =wrapperObject.mediaURL;
        this.objFlag.isMediaUrl = true;
        }
      }else if(wrapperObject.headerBody != '' || wrapperObject.headerBody == undefined){
        this.headerSelectedValue = 'Text';
        this.isTextHeader = true;
    }
  }
  }catch(error){
    this.error = error;
  }
}
handleCancel(){
 // this.handleOkay();
  //this.navigateToListView();
  this.navigateToListViewOnCancel();
}
    handleSave(){
      const isInputsCorrect = [...this.template.querySelectorAll('.validate')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
      if (isInputsCorrect) {
      if(this.mode == 'createBINew' || this.mode.includes('edit'))
        this.objWhatsAppTemplate[this.whatsAppTemp.status] = 'Draft';
      else
        this.objWhatsAppTemplate[this.whatsAppTemp.status]=this.objWhatsAppTemplate.Status__c;

      this.objWhatsAppTemplate[this.whatsAppTemp.active] = true;
      this.objWhatsAppTemplate[this.whatsAppTemp.type] = this.objWhatsAppTemplate.Template_Type__c;
      if(this.objFlag.isBusinessInitiative){
      this.objWhatsAppTemplate[this.whatsAppTemp.category]=this.objWhatsAppTemplate.WhatsApp_Category__c;
      this.objWhatsAppTemplate[this.whatsAppTemp.language]=this.objWhatsAppTemplate.Language__c;
      }
      this.objWhatsAppTemplate[this.whatsAppTemp.whatsAppTemplateId]=this.objWhatsAppTemplate.WhatsApp_Template_ID__c;
      this.objWhatsAppTemplate[this.whatsAppTemp.whatsAppTemplateStatus] = this.objWhatsAppTemplate.Whatsapp_Approval_Status__c;
      this.objWhatsAppTemplate[this.whatsAppTemp.name] = this.objWhatsAppTemplate.Name__c;
      var validityFlag = true;
        this.filterList.forEach(attribute =>{
                if(attribute.sfFieldName == ''){
                    validityFlag = false;
                }
              });
      if(validityFlag){
      //if(this.errorMessage == ''){
      if (this.objWhatsAppTemplate.Template_Type__c == BI){
        if(this.interactiveValue == 'Button' ){
          this.buttonListSelected = this.template.querySelector('c-interactive-button').sendDataToParent();
          if(this.buttonListSelected.length > 0){
              this.buttonListSelected.forEach(button =>{
                console.log('button : '+JSON.stringify(button));
                if(button.interActiveType == 'calltoaction' && (button.text == '' || button.phone_number_OR_url == '')){                  
                      this.objFlag.interactActiveFlag = true;
                  }
                  else if(button.interActiveType == 'quickreply' && button.text == ''){
                        this.objFlag.interactActiveFlag = true;
                    }
                    else{
                      this.objFlag.interactActiveFlag = false;
                    }

                  });
              this.interActiveButtonValue =this.buttonListSelected[0].interActiveType;
          }
        }
        var validityFlag = true;
        this.filterList.forEach(attribute =>{
                if(attribute.sampleValue == ''){
                    validityFlag = false;
                }
              });
        if(validityFlag){
        if ((this.UIMsgBody && this.UIMsgBody != '') ||
            (this.mediaURLValue && this.mediaURLValue != null)) {
              this.objFlag.disableSaveButton = true;
              this.objWhatsAppTemplate.JSON_Payload__c = '';
              this.objWhatsAppTemplate.JSON_Wrapper__c = '';
              this.jsonData = {
              "templateObject" : this.newTemplateInfo,
              "whatsAppTemplateObject" : this.objWhatsAppTemplate,
              "language" : this.objWhatsAppTemplate.Language__c,
              "targetObject" : this.objectName,
              "body" :  this.UIMsgBody,
              "media": this.mediaOptionValue,
              "messageType" : this.interactiveValue,
              "headerBody" : this.headerTextValue,
              "footerBody" : this.footerTextValue ,
              "mediaURL" :  this.mediaURLValue,
              "buttonValues" : this.buttonListSelected,
              "sampleValues" : this.filterList,
              "fieldMapping" : JSON.stringify(this.filterList)
              }
              if(this.objFlag.interactActiveFlag == false){
                try{
                 saveTemplate({jsonValue : JSON.stringify(this.jsonData)})
              .then(result => {
                  if (result !== null) {
                    console.log('result :'+JSON.stringify(result));
                    //console.log('result === '+JSON.stringify(result.data.Id));
                    this.whatsAppTemplateRecordId = result.Id;
                    if(this.mode.includes('edit')){
                      this.showToast('Success',TEMPLATEUPDATED,'success','dismissable');
                    }
                    else{
                      this.showToast('Success',TEMPLATECREATED,'success','dismissable');
                    }
                    this.navigateToListView();
                    //this.handleOkay();
                    
                  } else {
                    this.showToast('Error',CONTACTSYSTEMADMIN ,'error','dismissable');
                    this.objFlag.disableSaveButton = false;
                    }
                  })
                  .catch(error => {
                    this.showToast('Error',JSON.stringify(error),'error','dismissable');
                   });
                  }
                  catch(e){
                    console.log('error message === '+JSON.stringify(e));
                  }
              }
              else{
                this.objFlag.disableSaveButton = false;
                this.showToast('Error',BUTTONTEXT,'error','dismissable');

              }
          }
          else {
            this.showToast('Error',MESSAGEBODYEMPTY,'error','dismissable');
            this.objFlag.disableSaveButton = false;
           }
      }else{
            this.showToast('Error',DEFAULTVALUE,'error','dismissable');
            this.objFlag.disableSaveButton = false;
      }
      }
      else{
         if(this.interactiveValue == 'Button' && this.UIMsgBody == ''){
            this.showToast('Error',MESSAGEBODYEMPTY,'error','dismissable');
          }else{
         if((this.UIMsgBody && this.UIMsgBody != '') || 
        (this.mediaURLValue && this.mediaURLValue != null)){
          
        this.objFlag.disableSaveButton = true;
        this.objWhatsAppTemplate.Message_Body__c = this.UIMsgBody;
        this.objWhatsAppTemplate.JSON_Payload__c = '';
        this.objWhatsAppTemplate.JSON_Wrapper__c = '';
        this.jsonData = {
          "templateObject" : this.newTemplateInfo,
          "whatsAppTemplateObject" : this.objWhatsAppTemplate,
          "language" : this.objWhatsAppTemplate.Language__c,
          "targetObject" : this.objectName,
          "body" :  this.UIMsgBody,
          "media": this.mediaOptionValue,
          "messageType" : this.interactiveValue,
          "headerBody" : this.headerTextValue,
          "footerBody" : this.footerTextValue ,
          "mediaURL" :  this.mediaURLValue,
          "buttonValues" : this.itemList,
          "sampleValues" : this.filterList,
          "fieldMapping" : this.filterList
          }

          if(this.interactiveValue == 'Button' || this.interactiveValue == 'List'){
            this.objFlag.interactActiveFlag = false;
              this.itemList.forEach(button =>{
                if(button.value == ''){
                    this.objFlag.interactActiveFlag = true;
                }
              });
          }
          if(this.objFlag.interactActiveFlag === false){
            let str = JSON.stringify(this.jsonData);
            str = str.replaceAll("\\","");
            if(this.interactiveValue == 'None' && (this.headerTextValue || this.footerTextValue)){
              //this.showToast('For interactive messges only the header and footer will be visible, while plain text messages will not display header and footer');
              this.showToast('Error',HEADERANDFOOTERERROR,'error','dismiblssable');
              this.objFlag.disableSaveButton = false;
            }else{
            saveUserInitaitiveTemplate({jsonValue : str})
            .then(result => {
              if (result.data !== null) {
                //console.log('result === '+JSON.stringify(result.data.Id));
                this.whatsAppTemplateRecordId = result.data.Id;
                if(this.mode.includes('edit')){
                  this.showToast('Success',TEMPLATEUPDATED,'success','dismissable');
                }
                else{
                  this.showToast('Success',TEMPLATECREATED,'success','dismissable');
                }
                //this.handleOkay();
                this.navigateToListView();
              } else {
                this.showToast('Error',CONTACTSYSTEMADMIN ,error,'dismissable');
                this.objFlag.disableSaveButton = false;
              }
              })
          .catch(error => {
            this.showToast('Error',JSON.stringify(error.body.message()),'error','dismissable');
            this.objFlag.disableSaveButton = false;
            });
          }
        }
          else{
             // this.showErrorToast(ENTERVALUEINLABEL);
              this.showToast('Error',ENTERVALUEINLABEL,'error','dismissable');
              this.objFlag.disableSaveButton = false;
              }
    }else{
      this.showToast('Error',ENTERMESSAGEBODY,'error','dismissable');
      this.objFlag.disableSaveButton = false;
    }
          }
    /* }else{
        this.showToast('Error',ERRORMAXLENGTH,'error','dismissable');
      }*/
      }
     
       }else{
         this.showToast('Error',FILLMAPPINGVALUE,'error','dismissable');
       }
  }
}

  handleOkay() {
    this.close('okay');
  }

  navigateToListView(){
 
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
          recordId: this.whatsAppTemplateRecordId,
          objectApiName: this.namePrefix.PKGPREFIX+'WhatsApp_Template__c', 
          actionName: 'view'
      }
  });

}

navigateToListViewOnCancel(){
  this[NavigationMixin.Navigate]({
       type: 'standard__objectPage',
       attributes: {
           objectApiName: this.namePrefix.PKGPREFIX+'Template__c',
           actionName: 'list'
       },
       state: {
           filterName: 'Recent'
       }
   });
}
    /** Table logic to be rebder here */
    handleAddRow(FieldName) {

      var counter = this.filterList ? this.filterList.length : 0;
      ++ counter;
      let objRow = {
          index: '{{'+counter+'}}',
          sfFieldName: FieldName,
          sampleValue: ''
        }
      this.filterList = [...this.filterList, objRow];
    }
 
    handleRemoveRow(event) {
      this.filterList = this.filterList.filter((ele) => {
        return parseInt(ele.id) !== parseInt(event.currentTarget.dataset.index);
      });
      if (this.filterList.length == 0) {
        this.handleAddRow('');
      }
    }
    addRow() {
      ++this.keyIndex;
      var newItem = [{ id: this.keyIndex, value:'' }];
      this.itemList = this.itemList.concat(newItem);
      this.disableButton = true;

  }

  bindFieldValue(event){
    this.disableBtn = false;
    //Creating a temp varible from original record array to change the field's value
    let tempRecords = JSON.parse(JSON.stringify(this.itemList)); //JSON.parse(JSON.stringify()) used to change the reference, sometimes cause problems in redenring of the DtemplateDescription

    //change the field's value in the index whose value is changed
    tempRecords[event.target.accessKey].value = event.target.value.trim();//String.trim() is used to remove the unwanted spaces from the value

    //Reassigning the records with the fresh values from temp variable
    this.itemList = [].concat(tempRecords); //[].concat() can also be used to change the reference, sometimes cause problems in redenring of the template

    //Firing an event so that the parent component can get the latest updated record array
    if((this.objWhatsAppTemplate.Template_Type__c == USERINITIATIVE && event.target.value != '') && (this.interactiveValue == 'Button' || this.interactiveValue == 'List'))
        {
                if (this.interactiveValue && this.interactiveValue == 'Button' && this.itemList && this.itemList.length > 2) {
                    this.disableButton = true;
                } else if (this.interactiveValue && this.interactiveValue == 'List' && this.itemList && this.itemList.length > 9) {
                    this.disableButton = true;
                }
                else{
                    this.disableButton = false;
                }

            }
        else{
                this.disableButton = true;
            }
}

renderedCallback(){
  // Updated Code by Sarjerao (04-01-2024)
  if(this.UIMsgBody){
  this.tempBody = this.UIMsgBody.replaceAll('<br>', ' ');
  this.finalTempBody = this.tempBody+'</br></br>';
  }
  if(this.isCssLoaded) return
  this.isCssLoaded = true
  loadStyle(this, EngageCliq+'/CSS/colors.css').then(()=>{
  }).catch(error=>{
  })
}

   /* onTemplateSelection(event){
      console.log('event value: ',JSON.stringify(event.detail.value));
        this.approvedTemplatename = JSON.parse(event.detail.Name);
        if(event.target.value != undefined && event.target.value != ''){
        // SCENARIO : create BI template from already approved template
        this.objWhatsAppTemplate.Status__c = 'Approved';
        this.objFlag.disableButtons = true;
        this.mode = 'createBI';
        this.getTemplateDetailsFromBIJsonObject(this.approvedTemplatename);
        let item = this.template.querySelector('[data-recid="HeaderText"]');
        console.log('item '+item);
        this.displayrendering();
        }
    }*/

    getSelecetdTemplate(event){
      //console.log('value in Parent ==== '+JSON.stringify(event.detail));
      console.log('value in Parent ==== '+JSON.stringify(event.detail.data));
    if(event.detail.data){
        // SCENARIO : create BI template from already approved template
        this.objWhatsAppTemplate.Status__c = 'Approved';
        this.objFlag.disableButtons = true;
        this.mode = 'createBI';
        this.getTemplateDetailsFromBIJsonObject(event.detail.data);
        
        this.displayrendering();
    }
    }

    async openAttachmentModal(){
     
        const resultURL = await Attachment.open({                                
        size: 'medium',
        description: 'Accessible description of modal\'s purpose',
        content: 'Passed into content api',
        fileFormats: this.formats
        });            
    if(resultURL != undefined || resultURL != null){
        this.objFlag.isMediaUrl = true;
        //console.log('resultURL :'+JSON.stringify(resultURL));
        //console.log('resultURL.url :'+resultURL.url);
            this.mediaURLValue = resultURL.url; 
            console.log('mediaURLValue :'+this.mediaURLValue);
           /* this.attachmentObject.Id =resultURL.id;
            this.attachmentObject.Name = resultURL.name;
            this.maxLenth = this.maxLenth - this.attachmentObject.Url.length;*/
    }
  }
}