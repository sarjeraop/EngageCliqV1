import { LightningElement,api, wire,track} from 'lwc';
import getAllDataFromApex from  '@salesforce/apex/BulkMessageController.getDataFromApex';
import { NavigationMixin } from 'lightning/navigation';
 // this component do not support toast message.
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllActiveApprovedTemplates from '@salesforce/apex/BulkMessageController.getAllActiveApprovedTemplates';
import checkForReadAccess from '@salesforce/apex/BulkMessageController.CheckForAccess';
import ACCESSCHECK from '@salesforce/apex/BulkMessageController.initialise';
import NAVIGATIONlINK from "@salesforce/label/c.contains_navigation_link_label";
import NAVIGATIONFilterlINK from "@salesforce/label/c.contains_navigation_filter_link_label";
import NAVIGATIONSELFlINK from "@salesforce/label/c.contains_navigation_self_link_label";
import ONWAPPLINK from "@salesforce/label/c.one_app_link_label";
import SELECTCHANNEL from "@salesforce/label/c.select_channel_label";
import SELECTTEMPLATE from "@salesforce/label/c.select_template_label";
import READ from "@salesforce/label/c.read_access";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {getPackagePrefix} from "c/utils";

//import WHATSAPPMESSAGESENDCONTAINER from "@salesforce/label/c.whats_app_message_send_container";
import {getSbc} from "c/utils";
export default class Lwcredirector extends NavigationMixin(LightningElement) {
    @api selectedRecordIds;
    @api sbc; 
    @track objName;
    @track allAvailableChannels  = [];
    @track allAvailableChannelUIs;
    @track allSBCs;
    @track allActiveApprovedTemplates = [];
    @track loader = false;
    @track nextDisable = false;
    @track nameFieldAPIName;
    @track phoneFieldAPIName;
    OptInOptOutField; 
    requestMap
    @track errormessage = 'missing field';
    @track showChannelError = false;
    @track showTemplateError = false;
    @track showPhoneFieldError = false;
    @track showAccessError = false;
    @track activeApprovedTemplatesMap = [];
    @track availableChannelsMap = [];
    @track allAvailableChannelUIsMap = [];
    @track phonefieldOptions = [];
    @track selectedChannelName;
    @track selectedTemplateId;
    @track selectedTemplateText;
    @track showTemplatePreview = false;
    @track fieldsInfos=[];
    @track validateFields = false;
    connectedCallback() {
        this.loader = true;
        this.sbc = getSbc();
        this.getAccessCheck();
        getAllDataFromApex({ selectedRecords: this.selectedRecordIds })
            .then((result) => {
                this.loader = false;
                this.objName = result.data.objectName;
                this.allAvailableChannels = result.data.allAvailableChannels;
                this.allActiveApprovedTemplates = result.data.allActiveApprovedTemplates;

                this.allAvailableChannelUIsMap = result.data.allAvailableChannelUIs;
                this.allSBCs = result.data.allSBCs;

                this.processAllChannelsList();
              //  this.processAllSBCs();

            })
            .catch((error) => {
                this.loader = false;
        });
    }

    // Apex call to get all field aceess check for user
     getAccessCheck(){
        ACCESSCHECK()
            .then((result) => {
                if(result.isSuccess === false){
                    //this.showToast('Error',result.message,'Error','dismissable')
                  this.nextDisable = true;
            }else{
                this.nextDisable = false;
            }
            })
            .catch((error) => {
                this.error = error;
                this.data = undefined;

            });
    }
    @wire(getObjectInfo, { objectApiName: '$objName' })
    objectInfo({ error, data }) {
        if (data) {
            this.fieldsInfos = new Object(data.fields);
            //console.log('this.fieldsInfos :'+JSON.stringify(this.fieldsInfos));
            this.processAllSBCs();
             /*for(let fieldName in this.fieldsInfos) {
                let fieldInfo = this.fieldsInfos[fieldName];
             }*/
    }
    }
    @wire(getAllActiveApprovedTemplates,{objectName :'$objName',channelName :'$selectedChannelName' })
    wiredTemplates({ error, data }){
        if(data){
            this.allActiveApprovedTemplates = data.data;
            let templateArrays = [];
            try {
                    //console.log('data.data :'+JSON.stringify(data.data));
                    for(var key in data.data){
                        if(key != 'null'){
                            templateArrays = [...templateArrays,{value:data.data[key]['Id'],label:key}];
                        }  
                    }
                    this.activeApprovedTemplatesMap = templateArrays;
                    //console.log('this.activeApprovedTemplatesMap :'+JSON.stringify(this.activeApprovedTemplatesMap));
                }catch (error) {
                    this.error = error;
                }
            } else if (error) {
                this.error = error;
        }
}

    processAllChannelsList(){
        for(var i=0; i<this.allAvailableChannels.length; i++)  {
            this.availableChannelsMap = [...this.availableChannelsMap ,{value: this.allAvailableChannels[i] , label: this.allAvailableChannels[i]} ];
        }
    }

    processAllApprovedTemplateMap(){

        var data = this.allActiveApprovedTemplates;
        var templateArrays = [];
        for(var key in data){
            templateArrays = [...templateArrays,{value:data[key]['Id'],label:data[key]['Name']}];
        }
        this.activeApprovedTemplatesMap = templateArrays;
    }

    processAllSBCs(){
        //this.phoneFieldAPIName = this.allSBCs[this.objName][this.sbc.phonefield];
        let allPhoneFieldAPIName = this.allSBCs[this.objName][this.sbc.phonefield];
        this.nameFieldAPIName = this.allSBCs[this.objName][this.sbc.namefield];
        this.OptInOptOutField = this.allSBCs[this.objName][this.sbc.optfield];
        //console.log('allPhoneFieldAPIName :'+allPhoneFieldAPIName);
        let phoneFields = allPhoneFieldAPIName.split(",");
        phoneFields.forEach(fieldName => {
            //console.log('fieldName :'+fieldName);
            let fieldInfo = this.fieldsInfos[fieldName];
            //console.log('fieldInfo :'+fieldInfo);
            const  fieldlabel = fieldInfo['label'];
            this.phonefieldOptions = [...this.phonefieldOptions ,{value: fieldName , label: fieldlabel} ];
        })
    }

    handleSelectedChannel(event){
        this.loader = true;
        this.selectedChannelName = event.detail.value;
        this.loader = false;
    }

    handleSelectedTemplate(event){
        this.loader = true;
        this.selectedTemplateId = event.detail.value;
        var data = this.allActiveApprovedTemplates;
        var msg
        var namePrefix = getPackagePrefix();
        for(var key in data){
            if(data[key]['Id'] === this.selectedTemplateId){
                msg = data[key][namePrefix['PKGPREFIX']+'Message_Body__c'];
            }
        }
        this.checkForMergeField(msg);
        this.selectedTemplateText = msg;
        this.showTemplatePreview = true;
        this.loader = false;
    }
    
    handlePhoneFieldChange(event){
        this.phoneFieldAPIName = event.target.value;
       // //console.log('this.phonefieldAPIName :'+this.phoneFieldAPIName);
    }
    navigateToList() {
        window.open(NAVIGATIONlINK+this.objName+ NAVIGATIONFilterlINK,NAVIGATIONSELFlINK);
    }

    checkForMergeField(msg){
        try{
            const matches = msg.matchAll(/{!(.*?)}/g);
            //console.log('matches :'+Array.from(matches, x => x[1]));
            var attributesString = Array.from(matches, x => x[1]);
            this.showAccessError = false;
            this.nextDisable = false;
            if(attributesString.length > 0){
                checkForReadAccess({objectName : this.objName , fieldList : attributesString, access : READ })
                .then(result => {
                    if (result !== null) {
                        console.log('result : '+JSON.stringify(result));
                        if(result.isSuccess == false){
                            this.nextDisable = true;
                            this.showAccessError = true;
                            //this.showToast('error',JSON.stringify(result.message),'error','dismissable')
                        }else{
                            
                            console.log('success');
                            //this.showToast('success','User has access to fields','error','dismissable')
                        }
                    }
                }).catch(error =>{
                    console.log('error :'+JSON.stringify(error));
                });
            }
            //console.log('attributesString :'+JSON.stringify(attributesString.length));
            /*attributesString.forEach(element => {
            console.log('matching strings : '+JSON.stringify(element));
            });*/
        }catch(e){
            console.log('error :'+JSON.stringify(e));
        }
    }


    finish(){

        const isInputsCorrect = [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (this.selectedChannelName === undefined && this.selectedTemplateId === undefined){
            this.showChannelError = true;
            this.showTemplateError = false;
        }else{
            this.showChannelError = false;
            this.showTemplateError = false;
        }

        if(this.selectedChannelName === undefined){
            this.showChannelError = true;
            this.validateFields = false;
        }else if(this.selectedTemplateId === undefined){
            this.showTemplateError = true;
            this.validateFields = false;
        }else if(this.phoneFieldAPIName == undefined){
            this.showPhoneFieldError = true;
            this.validateFields = false;
        }else{
            this.validateFields = true;
        }

        if(this.validateFields){
        this.loader = true;
        var namePrefix = getPackagePrefix();
        //console.log('this.phoneFieldAPIName :'+this.phoneFieldAPIName);
        //(String objectName,String nameField, String phonefield, String recordIds,String optField){
        this.requestMap = {
            'recordIds': this.selectedRecordIds,
            'channel': this.channelSelected,
            'objectName': this.objName,
            'mobileFieldAPIName':this.mobileFieldAPIName,
            'phonefield':this.phoneFieldAPIName,
            'nameField':this.nameFieldAPIName,
            'optField':this.OptInOptOutField,
            'selectedTemplateId' : this.selectedTemplateId,
            'templateText' : this.selectedTemplateText,
            'selectedChannelName': this.selectedChannelName
            };
        //console.log('requestMap :'+JSON.stringify(this.requestMap));
        let cmpDef = {
            componentDef: namePrefix['prefix']+':whatsappMessageSendContainer',
            attributes: {
                parameters : this.requestMap
            }
          };
          let encodedDef = btoa(this.toBinaryStr(JSON.stringify(cmpDef)));
           window.open(ONWAPPLINK + encodedDef,NAVIGATIONSELFlINK);
          this.loader = false;
        }
    }

    toBinaryStr(str) {
    const encoder = new TextEncoder();
    // 1: split the UTF-16 string into an array of bytes
    const charCodes = encoder.encode(str);
    // 2: concatenate byte data to create a binary string
    return String.fromCharCode(...charCodes);
    }


    validateSelectedChannel(){
        const allValid = [...this.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity() && this.selectedChannelName == undefined ? false : true;
            }, true);

        // 2 - Returns true/false; if the validation were asynchronous, it should return a Promise instead
        if(allValid){
            alert(SELECTCHANNEL);
        }
        return !allValid;
    }

    validateSelectedTemplate(){
        const allValid = [...this.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity() && this.selectedTemplateId == undefined ? false : true;
            }, true);

        // 2 - Returns true/false; if the validation were asynchronous, it should return a Promise instead
        if(allValid){
            alert(SELECTTEMPLATE);
        }
        return !allValid;
    }
    // Display customized toast message
    /*showToast(title,message,variant,mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
      }*/

}