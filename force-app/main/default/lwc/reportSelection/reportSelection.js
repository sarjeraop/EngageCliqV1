import { LightningElement,wire,track } from 'lwc';
import getReportFolders from '@salesforce/apex/BulkMessageController.getReportFolders';
import getReports from '@salesforce/apex/BulkMessageController.getReports';
import getReportDetails from '@salesforce/apex/BulkMessageController.getReportDetails';  //
import getReportBaseObject from '@salesforce/apex/BulkMessageController.getReportBaseObject';
import getAllActiveApprovedTemplates from '@salesforce/apex/BulkMessageController.getAllActiveApprovedTemplates';
import getAllSendButtonConfigs from '@salesforce/apex/BulkMessageController.getAllSendButtonConfigs'; //
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from "lightning/navigation";
import {getPackagePrefix} from "c/utils";
import {getSbc} from "c/utils";
import {getSelectedTemplate} from "c/utils";
import Channel from "@salesforce/schema/Outbound_Message__c.Channel__c";
import getChannel from '@salesforce/apex/BulkMessageController.getActiveChannel';
import ERRORWHIEGETTINGREPORTS from "@salesforce/label/c.error_while_getting_reports";
import REPORTSTICKYNOTE from "@salesforce/label/c.sticky_note_on_report_page_label";
import ERRORWHILEPROCESSINGRECORDS from "@salesforce/label/c.ErrorReportNotHaveRecords";
import ONEAPPLINK from "@salesforce/label/c.one_app_link_label";
export default class ReportSelection extends NavigationMixin(LightningElement){
@track reportError;
@track folderOptions=[];
@track reportOptions=[];
@track recordIs=[];
@track objectOptions=[];
@track channelOptions=[];
@track objectDisplayName;
@track showObjectName = false;
@track objectApiName;
@track selectedObject;
@track selectedChannel;
@track phonefieldOptions = [];
@track fieldsInfos = {};
@track templateOptions = [];
@track phoneFieldName;
@track templateId;
@track allActiveApprovedTemplates = [];
@track nameField;
@track phoneAvailable = false;
@track showSpinner = false;
@track showFields = false;
value ='';
reportId;
phonestring;
OptInOptOutField;
phoneFields=[];
requestMap;


@wire(getAllActiveApprovedTemplates,{objectName :'$selectedObject',channelName :'$selectedChannel' })
wiredTemplates({ error, data }){
    if(data){
        this.allActiveApprovedTemplates = data.data;
         let templateArrays = [];
        try {
                for (var key in data.data) {
                if(key != 'null'){
                    templateArrays = [...templateArrays ,{value:  data.data[key]['Id'], label: key}];
                }
            }
                this.templateOptions = templateArrays;
       //}
            }catch (error) {
                this.error = error;
                
            }
        } else if (error) {
            this.error = error;
            
    }
}

@wire(getObjectInfo, { objectApiName: '$selectedObject' })
    objectInfo({ error, data }) {
        if (data) {
            this.fieldsInfos = new Object(data.fields);
             for(let fieldName in this.fieldsInfos) {
                let fieldInfo = this.fieldsInfos[fieldName];
             }
            getAllSendButtonConfigs({objectName :this.selectedObject })
            .then((result)=>{
                var sbc = getSbc(); // utlils call to get send button configuration fields
                 for (var key in result.data) {
                  this.nameField = result.data[key][sbc['namefield']];
                  this.phonestring = result.data[key][sbc['phonefield']];
                  this.OptInOptOutField = result.data[key][sbc['optfield']];
                  this.phoneFields = this.phonestring.split(",")
            }
                 this.phoneFields.forEach(fieldName => {
                let fieldInfo = this.fieldsInfos[fieldName];
                const  fieldlabel = fieldInfo['label']
                this.phonefieldOptions = [...this.phonefieldOptions ,{value: fieldName , label: fieldlabel} ];
            })

            }).catch((error)=>{
                let msg = 'Error in finding send button configuration for selected object'
                this.error = error;
                this.showErrorToast(msg)
            })
        }
        else if (error) {
            this.error = error;
        }
    }
    connectedCallback(){
        let  msg = REPORTSTICKYNOTE;
        this.showStickyToast(msg,'info');
        this.getChannelData();
        this.getReportFolderData();
    }

// apex call to get all Report Folder data
getReportFolderData(){
    getReportFolders()
    .then((result) => {     
        let options = [];
        result.data.map(element=>{
            options = [...options ,{value: element.Name,
                label: element.Name}];
        });
        this.folderOptions = options;
        
    }).catch((error) => {
        this.error = error;
    });
}
// apex call to get all active channels
getChannelData(){
    getChannel()
        .then((result) =>{
            if (result) {
            const mapChannel = new Map(Object.entries(result));
            mapChannel.forEach((value, key, map)=>{
            this.channelOptions = [...this.channelOptions ,{label: value[Channel.fieldApiName], value: key}];
            });
            }
        })
        .catch((error) =>{
            this.error = error;
            this.result = undefined;
        })
}

handleFolderChange(event){
        const selectedFolderName = event.target.value;
        this.template.querySelector('.commChannel').value = null;
        this.template.querySelector('.reportclass').value = null;
        this.template.querySelector('.associateObj').value = null;
        this.templateOptions = [];
        this.phonefieldOptions = [];
        this.showFields = false;
        this.showPhoneTemplate=false;
        let reportArray = [];
        getReports({ fldrName : selectedFolderName})
            .then(result => {
                if(result.data == null || result.data == ' ' || result.data.length == 0){
                    this.reportOptions=[];
                }
                 if(result.data != null && result.data.length>0){
                result.data.map(element=>{
                    this.showFields = true;
                reportArray = [...reportArray ,{value: element.Id,
                    label: element.Name}];
            });
                this.reportOptions = reportArray;
                this.phoneAvailable=true;
        }else{
            // this.reportError = ERRORWHIEGETTINGREPORTS;
             let  msg = ERRORWHIEGETTINGREPORTS;
             this.showStickyToast(msg,'error');
        }
    })

}

    handleReportChange(event){
          this.reportId= event.target.value
          this.showSpinner = true;
          this.selectedObject='';
          this.template.querySelector('.selection').value = null;
          this.template.querySelector('.commChannel').value = null;
          this.template.querySelector('.selectPhone').value = null;
          getReportDetails({reportId : this.reportId})
          .then(result =>{
              this.showPhoneTemplate = false;
              this.showObjectName = false;
              
              if( result.data != null && result.data.length>0){
               this.showObjectName = true;
               this.showPhoneTemplate = true;
               this.resetFields();
              this.recordIs=result.data;
              this.handleReportObject(this.recordIs[0])
              this.showSpinner = false
              }else{
            this.showSpinner = false;
            let msg=ERRORWHILEPROCESSINGRECORDS;
            //this.showErrorToast(msg);
            console.log('msg :'+msg);
            this.showStickyToast(msg,'error');
            console.log('msg :'+msg);
              }

          })
    }

     handleReportObject(recId){
          getReportBaseObject({recorId :recId})
         .then((result) => {
            for (var key in result.data) {
                this.objectDisplayName=result.data[key];
                this.objectApiName=key ;
                this.selectedObject = this.objectApiName;
                this.showObjectName = true;
            }
        }).catch((error) => {
            this.error = error;
        });
    }
    handlePhoneFieldChange(event){
        this.phoneFieldName = event.target.value
    }
    handleChannelChange(event){
        this.selectedChannel =  event.target.value
    }
    handleTemplateChange(event){
        this.templateId = event.target.value;
    }
    handleRefresh(){
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = null;
        });
        this.objectDisplayName = null;
        this.reportOptions=[];
        this.templateOptions = [];
        this.phonefieldOptions = [];
        
    }
    handlePreview(){
        var data = this.allActiveApprovedTemplates;
        var msg='';
        var template = getSelectedTemplate();// utlils call to get template fields
        for(var key in data){
            if(data[key]['Id'] === this.templateId){
                msg = data[key][template['Message_Body__c']];
                break;
            }
        }

         const isInputsCorrect = [...this.template.querySelectorAll('.validate')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isInputsCorrect) {
           
                var pkgPrefix = getPackagePrefix(); // utlils call to get pkg prefix
                this.requestMap = {
                    'recordIds': this.recordIs.toString(),
                    'channel': this.selectedChannel,
                    'objectName': this.objectApiName,
                    'mobileFieldAPIName':this.phoneFieldName,
                    'phonefield':this.phoneFieldName,
                    'nameField':this.nameField,
                    'optField':this.OptInOptOutField,
                    'selectedTemplateId' : this.templateId,
                    'selectedChannelName': this.selectedChannel,
                    'templateText' : msg,
                    'reportId' :this.reportId,
                    'source' : 'report'
                    };//
      let cmpDef = {
            componentDef: pkgPrefix['prefix']+':whatsappMessageSendContainer',
            attributes: {
               /* selectedIds : this.recordIs.toString(),
                objname : this.objectApiName,
                phoneFieldAPIName : this.phoneFieldName,
                nameFieldAPIName : this.nameField,
                selectedTemplateId : this.templateId,
                selectedChannelName : this.selectedChannel,
                reportId :this.reportId,
                templateText : msg*/
                parameters : this.requestMap
            }
          };
          let encodedDef = btoa(this.toBinaryStr(JSON.stringify(cmpDef)));
           this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
              url: ONEAPPLINK + encodedDef
            }
          });
        
        }else{
        }
    }

    toBinaryStr(str) {
    const encoder = new TextEncoder();
    // 1: split the UTF-16 string into an array of bytes
    const charCodes = encoder.encode(str);
    // 2: concatenate byte data to create a binary string
    return String.fromCharCode(...charCodes);
    }

     resetFields(){
         this.objectDisplayName='';
        if(this.phonefieldOptions.length > 0) {
             this.phonefieldOptions.length=0;
            }

        if(this.templateOptions.length > 0) {
            this.templateOptions.length=0;
        }
    }
  showErrorToast(msg) {
    const evt = new ShowToastEvent({
        title: 'Error Message',
        message: msg,
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}

showStickyToast(msg,variant) {
    const evt = new ShowToastEvent({
        title: '',
        message: msg,
        variant: variant,
        mode: 'sticky'
    });
    this.dispatchEvent(evt);
}

}