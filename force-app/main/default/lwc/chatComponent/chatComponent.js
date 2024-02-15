import { LightningElement,wire,track,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getSbc } from "c/utils";
import { getSelectedTemplate } from "c/utils";
import Attachment from 'c/attachmentModel';
//import chatColor from '@salesforce/resourceUrl/messagecolor';
import EngageCliq from '@salesforce/resourceUrl/engagecliq'; 
import RecordDetailFinder from '@salesforce/apex/ChatController.recordDetailFinder';
import SendButtonConfiguration from '@salesforce/apex/ChatController.sbcRecordFinder';
import SENDMESSAGE from '@salesforce/apex/ChatController.chatMessageSend';
import ConversationList from '@salesforce/apex/ChatController.conversationData';
import ACCESSCHECK from '@salesforce/apex/ChatController.initialise';
import GETCHANNEL from '@salesforce/apex/ChatController.getActiveChannel';
import BI from "@salesforce/label/c.business_initiative_label";
import SEND from "@salesforce/label/c.send_label";
import MESSAGEBODY from "@salesforce/label/c.message_body_label";
import EMPTYBODY from "@salesforce/label/c.message_body_is_empty_label";
import ATTACHMENTMODEL from "@salesforce/label/c.attachment_label";
import QUICKTEXT from "@salesforce/label/c.quick_text_label";
import QUICKTEXTNAME from "@salesforce/label/c.quick_text_name_label";
import QUICKTEXTSEND from "@salesforce/label/c.select_quick_text_to_send_label";
import TEMPLATE from "@salesforce/label/c.template_label";
import TEMPLATENAME from "@salesforce/label/c.template_name_label";
import TEMPLATESEND from "@salesforce/label/c.select_template_to_send_label";
import SELECTPHONENUMBER from "@salesforce/label/c.select_phone_number_label";
import ERRORMAXLENGTH from "@salesforce/label/c.you_have_exceeded_the_max_length";
import CLEAR from "@salesforce/label/c.clear_label";
import INACTIVEERROR from "@salesforce/label/c.inactive_session_label";
import TEMPLATEATTACHMENTERROR from "@salesforce/label/c.template_attchment_error_label";
import SBC from "@salesforce/label/c.send_button_configuration_label";
import NOTCREATED from "@salesforce/label/c.not_created_label";
import MESSAGETOSEND from "@salesforce/label/c.write_a_message_to_send_label";
import DELETE from "@salesforce/label/c.delete_label";
import CLOSE from "@salesforce/label/c.close_label";


export default class ChatComponent extends NavigationMixin(LightningElement){
    
   @api recordId; /// holds the value of record id
   @api objectApiName; // holds the value of object name

   @track totalMessages = []; // hold the list of total conversation records
   @track messages =[];     // message list to particular recordId
   @track _wiredMessage;
   @track attachmentObject ={}; // holds the value url for attachment to be send to whatsapp
   @track childData = {};
   @track label = {
    ATTACHMENTMODEL,
                    MESSAGEBODY,
                    QUICKTEXT,
                    BI,
                    SEND,
                    TEMPLATE,
                    SELECTPHONENUMBER,
                    CLEAR,
                    MESSAGETOSEND,
                    DELETE,
                    CLOSE

                };
   phoneOption = []; // holds the value of display phone no to send message
   phoneFieds = [];   // list of phone field
   queryFields = [];   //list of fields with combination of objectName and field name
   channelOption = [] // holds the active channel
  
   nameField;       // holds the API name of nameField from sbc record
   activeColour; // varriant for chat session icon  
   phone ='';        //phone number selected to send message  
   outBondMmsg; // object hold outbound message record
   optField;
   requestMap ={}; // Map need to send for API Callout
   charecterLeft;    // holds the value of charecter left for richtext input
   mobileFieldAPIName;  // holds the value of API name for selected number
   mobileFieldLabel;    // holds the value of Label name for selected number   
   attachmentName; // hold the name of attachment selected
   apiNameVsLabelMap;  // map which store apiName and label 
   phoneString;       // string containing phone field comma seperated from send button configuration
   filedSet;        // list of phone fields 
   buttonVisibility;    // hold the boolean value for new button on modelPopup component
   errorMessage =''; // errror message to show when max length for message body reached   
   selectedName = '';        // holds the Name  to display in UI
   messageBody = '';    // hold the value of message 
   templateId = '';   //hold the Id of seleced template
   nameToDisplay = '';  // hold the value of nameField from sbc record which is used to show on UI
   error;      // holds the information regarding errror
   editMode = true; // value for disabling input rich text 
   showPopUp = false;  // to enable or disable the popup model for quick text and template selection
   validity =true;
   buttonDisable = true;
   isActiveChat = false;   // chat is active or not
   closeIcon = false;
   channelSelected = 'WhatsApp'; // hold the value of selected channel
   activeIcon = 'utility:end_chat'; // icon name for active inactive chat
   iconText = 'Session Inactive'; //hover text for chat session
   maxLenth = 1024; // holds the value of maximum length for rich input text   
    // hold the json payload value which is use in sending whatsApp message
   allowedFormats = ['bold',
                    'italic',
                    'strike',
                    'link'];    // alloweble formate for message body

    
    // CONSTANTS = getConstants();
    @api sbc;
    get phoneOptions(){
        return this.phoneOption;
    }

    get channelOptions(){
        return this.channelOption;
    }

    connectedCallback(){
        this.getAccessCheck();
        this.getChannel();
        if(this.objectApiName && this.objectApiName != undefined){
        this.getSendButtonConfigurationData();
        }
    }

    renderedCallback() {        
        this.scroll();
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        
        loadStyle(this, EngageCliq+'/CSS/messagecolor.css').then(()=>{
        }).catch(error=>{ 
        }) 
         
    } 

    // to set scroll on last message on load of component
    scroll(){
        
        const messageBody = this.template.querySelector('.chatcontainer');
        messageBody.scrollTop = messageBody.scrollHeight;
        
    }
 
    // wire call to get all related field for object
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo({ error, data }) {
        if (data) {
            let fieldsInfos = new Object(data.fields);
            let fieldMap = new Map();
            for(let fieldName in fieldsInfos) {
                let fieldInfo = fieldsInfos[fieldName];               
                if(fieldInfo['dataType']!= 'Reference' && 
                    (fieldInfo['dataType']== 'Phone') || (fieldInfo['dataType']== 'String')){
                        fieldMap.set(fieldName, fieldInfo['label']);   
                }    
            }
            this.apiNameVsLabelMap = fieldMap ;
            this.error =undefined;
        }    
        else if (error) {
            this.error = error; 
            this.data = undefined;           
        }
    }
   
    // wire call to get phone filed value for current recordId
    @wire(getRecord, { recordId: "$recordId", fields: "$filedSet"})
    wiredRecordData({ error, data }) {        
    if (data) {
        this.phoneOption  =[];
        this.phone =''; 
        setTimeout(() => {        
        for (var key in data.fields) {
            const alphabeticCharactersPattern = /[a-zA-Z]+/;            
            this.phoneFieds.forEach(field => {                 
                if(data.fields[field].value != null && 
                    key == field && !(data.fields[field].value.match(alphabeticCharactersPattern))){
                        if(this.apiNameVsLabelMap.get(field) && data.fields[field].value){
                    this.phoneOption = [...this.phoneOption ,{label: this.apiNameVsLabelMap.get(field), value: data.fields[field].value}];
                        }
                }
            })
          }
          },2500)
          this.error =undefined;
         }
        if (error) {
            this.error = error;
            this.data = undefined;  
        }
    }

    //wire call to get conversation for given recordId and display message in UI
    @wire(ConversationList, { recId: '$recordId', channel: '$channelSelected' })
    getMessages(wireResult) {
        const {data, error } = wireResult;
        this._wiredMessage = wireResult;
        this.totalMessages = data;         
        if (data) {
            this.editMode =true;          
            this.messages = data; 
            this.totalMessages = data;        
            this.messages.forEach(msg => {          
                if(msg.isActive === true){
                    this.maxLenth = 4096;
                    this.isActiveChat = msg.isActive;
                    this.activeIcon = 'utility:chat';
                    this.activeColour = 'Success'
                    this.iconText = 'Session Active'; 
                    this.editMode =false;                   
                }                                
            });
            this.getMsgForMobileNumber(this.phone);
            this.error = undefined;        
        } else if (error) {
            this.error = error;
            this.data = undefined;  
        }
    }

     // Apex call to get all field aceess check for user
     getAccessCheck(){
        ACCESSCHECK()
            .then((result) => {                     
                if(result.isSuccess === false){
                    this.showErrorToast(result.message);                        
                } 
                this.error =undefined;                                    
            })
            .catch((error) => {
                this.error = error; 
                this.data = undefined;
                
            });
    }
    
     // Apex call to get all active channels
     getChannel(){
       GETCHANNEL()
            .then((result) => {                     
                if(result.isSuccess){
                    const mapChannel = new Map(Object.entries(result.data));            
                    mapChannel.forEach((value, key, map)=>{
                    this.channelOption = [...this.channelOption ,{label: key, value: key}];                   
                    }); 
                    this.error =undefined;     
                    }
                else{
                    this.showErrorToast(data.message);
                    this.error =data.message;
                }                        
                                                    
            })
            .catch((error) => {
                this.error = error; 
                this.data = undefined;
                
            });  
     }
  
    // Apex call to get send buttonconfiguration record for object
    getSendButtonConfigurationData(){
        SendButtonConfiguration({objName: this.objectApiName})
            .then((result) => {                   
                if (result.isSuccess) { 
                    this.sbc = getSbc();
                        var mapSbc = new Map(Object.entries(result.data));
                        var element = mapSbc.get(this.objectApiName);
                        if(element[this.sbc.phonefield]){
                        this.phoneString = element[this.sbc.phonefield];
                        }
                        if(element[this.sbc.namefield]){
                        this.nameField = element[this.sbc.namefield];
                        }
                        if(element[this.sbc.optfield]){
                            this.optField = element[this.sbc.optfield];
                        }
                        
                        this.nameToDisplay = this.nameField
                          
                        if(this.phoneString != undefined){
                        this.phoneFieds = this.phoneString.split(",");
            
                        this.phoneFieds.forEach(field => {
                            
                            this.queryFields.push(this.objectApiName+'.'+field)
                            })
                            }
                        
                        this.filedSet = this.queryFields;
                        this.error = undefined;
                        this.getRecordDetail();    
                } 
                else{
                    if(result.message.includes('List has no rows for assignment to SObject')){
                        this.showErrorToast(SBC+' '+this.objectApiName+' ' +NOTCREATED);
                        this.error = SBC+' '+this.objectApiName+' ' +NOTCREATED;
                    }
                    else{
                    this.showErrorToast(result.message);
                    }
                    this.error = result.message;
                }                                   
            })
            .catch((error) => {
                this.error = error; 
                this.data = undefined;
                
            }); 
    }

    // Apex call to get Name value to display on UI
    getRecordDetail(){
        RecordDetailFinder({recId: this.recordId, objName: this.objectApiName, queryField : this.nameField})
        .then((result) => {
            if (result.isSuccess) { 
                this.objRecords = result.data;
                    if(result.data[0][this.nameToDisplay]) {   
                this.selectedName = result.data[0][this.nameToDisplay]; 
                    }
                this.error = undefined;        
            } 
            else{
                this.error = data.message;
                this.showErrorToast(data.message);
            }                                    
        })
        .catch((error) => {
            this.error = error; 
            this.data = undefined;
            
        }); 
    }

    handleMessage(){
        refreshApex(this._wiredMessage);

    }
    handleError(){
        refreshApex(this._wiredMessage);
    }
    

    // method for handling child(model PopUp) event on call
    handleCustomEvent(event) {
            const textVal = event.detail; 
            this.buttonDisable = true;
            this.showPopUp = false; 
            this.editMode =false;
            this.error ='';
            
            if(textVal != null && textVal != undefined ){
                
                if(textVal.sourceData != '' && textVal.sourceData != undefined){
                    
                    if(textVal.name == TEMPLATENAME){
                        var objTemplate = getSelectedTemplate();                
                        this.templateId = textVal.sourceData.Id; 
                        this.selectedQuicktext = '';
                        this.messageBody = textVal.sourceData[objTemplate['Message_Body__c']] != undefined ? textVal.sourceData[objTemplate['Message_Body__c']] : '';                        
                        
                        if(textVal.sourceData[objTemplate['Template_Type__c']] == BI){
                            this.editMode =true;                 
                        }
                        else{
                            this.editMode =false;
                        }
                       
                        }
                        if(textVal.name == QUICKTEXTNAME){
                            this.editMode =true;  
                            this.selectedQuicktext = textVal.sourceData.Message;
                            this.checkForMergeField(this.selectedQuicktext);
                            this.templateId = '';                        
                            this.messageBody = this.selectedQuicktext.replaceAll(this.objectApiName+'.' , ''); 
                                              
                         }
                this.childData.componentName ='';
                this.childData.componentPlaceHolder = '';
                           
                }
                
            }
            this.disableSendButton();
            
    }

    checkForMergeField(msg){
       
            const matches = msg.matchAll(/{!(.*?)}/g);
            var attributesString = Array.from(matches, x => x[1]);
            
            if(attributesString.length > 0){
                attributesString.forEach((msg)=>{
                    var parts = msg.split('.');
                    // Get the text before the dot
                    var textBeforeDot = parts[0];
                    
                    if((textBeforeDot !== this.objectApiName)){
                        this.error = 'Object use in merged field and current object is mismatched';
                        this.showErrorToast(this.error);
                    }   
                    });   
            }
            
       
    }

    
    // action on richtext toolbar click 
    async toolbarClick(event){  
        if(event.target.name === CLEAR){
            this.resetValues();
        }
        if(event.target.name == TEMPLATE){             
            this.showPopUp = true;
            this.childData = {                                
                                "compoName" : TEMPLATENAME,
                                "placeHolder" : TEMPLATESEND,
                                "newButtonVisibility" : false,
                                "showPopUp" : true,
                                "active": this.isActiveChat,
                                "objectName": this.objectApiName
                             }; 
            }

        if(event.target.name === QUICKTEXT){
            this.showPopUp = true;
            this.childData = {                                
                                "compoName" : QUICKTEXTNAME,
                                "placeHolder" : QUICKTEXTSEND,
                                "newButtonVisibility" : true,
                                "showPopUp" : true
                             };                            
        }

        if(event.target.name === ATTACHMENTMODEL){
            const resultURL = await Attachment.open({                                
            size: 'medium',
            description: 'Accessible description of modal\'s purpose',
            content: 'Passed into content api',
            fileFormats: ['.csv', '.pdf', '.png', '.jpeg',  '.jpg', '.doc', '.docx', '.mp4', '.3gp']
            });            
        if(resultURL != undefined || resultURL != null){
            if(this.isActiveChat){
            if(this.templateId !== ''){
                this.showErrorToast(TEMPLATEATTACHMENTERROR);
            }
            else{
                this.attachmentObject.Url = resultURL.url; 
                this.attachmentObject.Id =resultURL.id;
                this.attachmentObject.Name = resultURL.name;
                this.maxLenth = this.maxLenth - this.attachmentObject.Url.length;
                this.closeIcon = true;
            }
        }
        
        else{
            this.showErrorToast(INACTIVEERROR);
        }
       this.disableSendButton();
        }
            
        }
        this.whatsappTogglePanel();
    }

    disableSendButton(){ 
        if(((this.attachmentObject.Url != '' && this.attachmentObject.Url != undefined) 
                || ( this.messageBody != '' && this.messageBody != undefined) 
                || (this.templateId !='')) 
            && (this.phone != '') 
            && (!(this.maxLenth - this.messageBody.length) <= 0) 
            &&(this.error == undefined || this.error == '')) {
           this.buttonDisable = false;
         }
        else{ 
            this.buttonDisable = true;            
        }
    }

    whatsappTogglePanel(){
        let getIddemo = this.template.querySelector("div[data-my-id=demo]")
        if(getIddemo.classList.contains("chatpanelnone")){
         getIddemo.classList.remove("chatpanelnone")
         getIddemo.classList.add("chatpaneldisplay")       
        }else{
         getIddemo.classList.add("chatpanelnone")
         getIddemo.classList.remove("chatpaneldisplay")         
        }
        window.close();    
    }


    // function for opening preview of attachment file
    handlePreview(event){
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview',
                target: '_blank'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }
    

    //function to handle phone number change
    handlePhoneChange(event){        
        this.phone = event.target.value;
        this.phoneOptions.forEach(num =>{
            if(num.value === this.phone){
            this.mobileFieldLabel = num.label;
                }
            });
        if(this.mobileFieldLabel != undefined){  
            this.apiNameVsLabelMap.forEach((value, key, map)=>{ 
                if(value===this.mobileFieldLabel){
                    this.mobileFieldAPIName = key;
                    }
              });               
        }      
        this.disableSendButton();       
        if(this.totalMessages.length > 0){
        this.getMsgForMobileNumber(this.phone);
        }
    }

    // function to remove attachment from message body 
    handleButtonClick(){
       this.attachmentObject ={};
        this.closeIcon = false;
        this.disableSendButton();        
    }
    
    handleChange(event){
        this.validity = true;
        if(event.target.name === MESSAGEBODY){
        this.messageBody = event.target.value;        
        if((this.maxLenth - this.messageBody.length) <= 0){
            this.validity = false;
            this.errorMessage = ERRORMAXLENGTH;
        }     
        }
        this.disableSendButton();  
    }
   
    //function to filter messages base on number
    getMsgForMobileNumber (num){ 
        let tempList = [];
        if(num != ''){
        this.totalMessages.forEach(msg =>{  
            let tempRec = Object.assign({}, msg);          
            if(msg.isInbound){
                if(msg.inOutMessage.inBound.mobile === num ){                    
                    tempList.push(tempRec);
                 }
             }
            else if(msg.inOutMessage.outBound.mobile === num ){ 
                tempList.push(tempRec);
                     }                
            });
        }

        if(tempList.length > 0){
        this.messages = tempList;
         }
        }


    // after sending message function to reset the values of varaibles
    resetValues(){
        if(this.isActiveChat){
            this.editMode =false;
        } 
        else{
            this.editMode =true; 
        }
        this.childData = {};
        this.selectedQuicktext = '';
        this.templateId = '';
        this.messageBody = '';
        this.requestMap = {};
        this.closeIcon =false;
        this.buttonDisable = true;        
        this.attachmentObject ={}
        this.maxLenth = 1024;
        this.outBondMmsg ={};

       }

    showErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToast(message) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
   
    // action on send button click  prepare map and send message
     handleSend(){  
        this.buttonDisable = true;        
        if((this.messageBody == '' || this.messageBody == undefined) && 
            (this.attachmentObject.Url == '' || this.attachmentObject.Url == undefined) && 
            (this.templateId =='')) {
            this.validity = false;
            this.errorMessage = EMPTYBODY;
            this.buttonDisable = true;
        }    
        else if(this.messageBody.length > this.maxLenth){
            this.validity = false;
            this.errorMessage = ERRORMAXLENGTH;
            this.buttonDisable = true;
        }
        else if(this.phone && this.phone != '' && this.phone != undefined ){    
            this.validity = true;
             this.outBondMmsg = {               
                inOutMessage : {
                    outBound:{
                        msg: this.messageBody,
                        mobile : this.phone
                        }
                    }                                                
                 };

        this.messages= [...this.messages, this.outBondMmsg];
            this.requestMap = {
                'recordId': this.recordId,
                'channel': this.channelSelected,
                'objectAPIName':this.objectApiName,
                'mobileFieldAPIName':this.mobileFieldAPIName,
                'templateId':this.templateId,
                'messageText':this.messageBody,
                'document': this.attachmentObject,
                'optField': this.optField
                };
                console.log('requestMap : ',JSON.stringify(this.requestMap));
               SENDMESSAGE({mapChannelRequest :this.requestMap})
                .then((result) => { 
                    if(result.isSuccess){
                        this.getMsgForMobileNumber(this.phone);
                        refreshApex(this._wiredMessage);
                        this.resetValues();
                        this.buttonDisable = true; 
                        this.showSuccessToast('Success');
                        this.error = undefined
                        }
                    else{
                        this.getMsgForMobileNumber(this.phone);
                        refreshApex(this._wiredMessage);
                        this.resetValues();
                        this.showErrorToast(result.message);
                        }                  
                })
                .catch((error) => {
                    refreshApex(this._wiredMessage);
                    this.resetValues();
                    console.log('error :'+JSON.stringify(error));
                    this.showErrorToast(error);
                    
                });
            }
                  
}

}