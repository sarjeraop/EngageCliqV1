import { LightningElement, api, track, wire} from 'lwc';
import getRecordsList from '@salesforce/apex/BulkMessageController.getSObjectRecords';
import getFieldLabelMapFromApex from '@salesforce/apex/BulkMessageController.getFieldLabel';
import sendWhatsappMsg from '@salesforce/apex/BulkMessageController.initiateMessageSending';
import getMeargedMessageFromApex from '@salesforce/apex/BulkMessageController.getMeargedMessage';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';
import {loadStyle} from 'lightning/platformResourceLoader'
import EngageCliq from '@salesforce/resourceUrl/engagecliq';
import SCHEDULEACTIVITY from "@salesforce/label/c.schedule_activity_label";
import TOTALRECORDSWITHPHONE from "@salesforce/label/c.total_records_with_phone_label";
import TOTALRECORDS from "@salesforce/label/c.total_record_label";
import TOTALRECORDSWITHPHONENO from "@salesforce/label/c.total_records_without_phone_no";
import SENDWHATSAPPMESSAGE from "@salesforce/label/c.send_whatsapp_message_label";
import ERRORENCOUNTERED from "@salesforce/label/c.error_encountered_label";
import CONTAINSNAVIGATIONLINK from "@salesforce/label/c.contains_navigation_link_label";
import CONTAINSNAVIGATIONFILTERLINK from "@salesforce/label/c.contains_navigation_filter_link_label";
import CONTAINSNAVIGATIONSELFLINK from "@salesforce/label/c.contains_navigation_self_link_label";
import EMPTYPHONEFIELDERRORMESSAGE from "@salesforce/label/c.empty_phone_field_error_message_label";
import MESSAGESENT from "@salesforce/label/c.message_sent_successfully";
import {getPackagePrefix} from "c/utils";
import { NavigationMixin } from "lightning/navigation";
import ONEAPPLINK from "@salesforce/label/c.one_app_link_label";
export default class WhatsappMessageSendContainer extends NavigationMixin(LightningElement) {
    //@api selectedIds;
    //@api objname;
    //@api phoneFieldAPIName;
   // @api nameFieldAPIName;
    //@api optInOptOutField;
   // @api selectedTemplateId;
   // @api selectedChannelName;
    @api allActiveApprovedTemplates = [];
    @api reportId;
    @api templateText;
    @track chartStatics =[];
    @track activeApprovedTemplatesMap = [];
    @track showScheduleComponent = false; // holds flag to display popup
    @api phoneFieldLabel;
    @api nameFieldLabel;
    @track sendDisabled = false;
    @track loader = false;
    @track unmergedMessage;
    @api objParameters =[];
    @api parameters=[];
    showSchedular = false;

    get scheduleOptions() {
        return [
            { label: SCHEDULEACTIVITY, value: 'true' }
        ];
    }
    scheduleValue = [];
    get selectedValues() {
        return this.scheduleValue.join(',');
    }

    handleScheduleChange(e) {
        if(e.detail.value == "true"){
            this.showScheduleComponent = true;
        }
    }


    @track mergedMessage;
    @track templateText;
    @track isModalOpen = false;
    @track records;
    @track columns = [];
    @track fieldAPINameVsLabelMap = [];
    @track totalRecordsWithoutPhoneNo = 0;
    @track totalRecords = 0;
    @track totalRecordsWithPhone = 0;
    @track homepageURL;
    @track refUrl;
    @track mapOfAPIvsLabel = [];
    @track options = [];
    @track value;

    connectedCallback(){
        this.loader = true;
            var data = this.allActiveApprovedTemplates;
            var templateArrays = [];
            for(var key in data){
                templateArrays = [...templateArrays,{key:data[key]['Id'],value:data[key]['Message_Body__c']}];
            }
            this.activeApprovedTemplatesMap = templateArrays;
            console.log('this.parameters :',JSON.stringify(this.parameters));
            let param = {
                "recordIds" : this.parameters.recordIds,
                "objectName" : this.parameters.objectName,
                "nameField" : this.parameters.nameField,
                "phonefield":this.parameters.phonefield,
                'reportId':this.parameters.reportId,
                "optField":this.parameters.optField
            }
            console.log('this.param :',JSON.stringify(param));
            // Rearrange the parameters
            //getRecordsList({ objectName: this.objname, nameField : this.nameFieldAPIName, phonefield:this.phoneFieldAPIName, recordIds:this.selectedIds ,optField : this.optInOptOutField})
            if(param){
            getRecordsList({ mapRequest: param})
            .then((result) => {
                this.loader = false;
                console.log('result.data :'+JSON.stringify(result.data));
                this.records = result.data.records;
                this.totalRecordsWithoutPhoneNo = result.data.totalRecordsWithoutPhoneNo;
                this.totalRecords = result.data.totalRecords;
                this.totalRecordsWithPhone = result.data.totalRecords - result.data.totalRecordsWithoutPhoneNo;
                this.chartStatics = [...this.chartStatics, {label :TOTALRECORDSWITHPHONENO ,value:result.data.totalRecordsWithoutPhoneNo} ];
                this.chartStatics = [...this.chartStatics, {label :TOTALRECORDS ,value:result.data.totalRecords} ];
                this.chartStatics = [...this.chartStatics, {label :TOTALRECORDSWITHPHONE ,value:this.totalRecordsWithPhone} ];
            })
            .catch((error) => {
                this.error = error;
                console.log('error'+JSON.stringify(error));
                this.records = undefined;
            });
        }
            this.loader = true;
            //let  fieldNames = this.phoneFieldAPIName + ','+this.nameFieldAPIName;
            let  fieldNames = this.parameters.phonefield + ','+this.parameters.nameField;
            //let array1 =this.phoneFieldAPIName.split(',');
            console.log('this.parameters.phonefield :'+this.parameters.phonefield);
            let array1 =this.parameters.phonefield.split(',');
            console.log('this.parameters.objectName :'+this.parameters.objectName);
            console.log('fieldNames :'+fieldNames);
            getFieldLabelMapFromApex({ objectName: this.parameters.objectName, fieldNames: fieldNames})
            .then((result) => {
                this.loader = false;
                var templateArrays = [];
                console.log('result of getFieldLabelMapFromApex :'+JSON.stringify(result.data));
                for (var key in result.data) {
                    for(var field in array1){
                        if(key == array1[field]){
                            this.mapOfAPIvsLabel = [...this.mapOfAPIvsLabel,{key:array1[field],value:result.data[key]}];
                        }
                    }
                    if(this.parameters.nameField == key){
                        this.nameFieldLabel = result.data[key];
                    }
                }

                this.columns = [{label : this.nameFieldLabel , fieldName : this.parameters.nameField}];

                for (var key in this.mapOfAPIvsLabel) {
                    this.columns = [...this.columns,
                        {label : this.mapOfAPIvsLabel[key].value, fieldName : this.mapOfAPIvsLabel[key].key}
                    ];
                }
                this.columns =
                [
                    ...this.columns,
                    {   label: 'Preview',type: 'button-icon',

                        typeAttributes:
                        {
                            iconName: 'utility:preview',
                            class:"custom-datatable-style",
                        }
                    }
                ];
            })
            .catch((error) => {
                    this.error = error;
            });
        }

    handleRowAction(event) {
        try{
        this.loader = true;
        //const actionName = event.detail.action.name;
        const row = event.detail.row;

        var data = this.activeApprovedTemplatesMap;
        var msg='';
        data.forEach(element => {

            if(element.key == this.selectedTemplateId){
                msg = element.value;
            }
        });
        try{
        console.log('MSG = > '+String.fromCodePoint(msg.codePointAt()));
        }
        catch(e){
            console.log('ERROR : ',e.message);
        }
        this.getPreview(row.Id,(this.parameters.templateText));
    }catch(e){
        console.log('e :' +JSON.stringify(e));
    }
    }


    showNotification(title,message,varient) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: varient
        });
        this.dispatchEvent(evt);
    }
    handleClick(){

        this.showScheduleComponent = true;
    }
     getPreview(recordId,message){
        this.unmergedMessage = message;
        console.log('message :'+message);

        if(this.unmergedMessage.includes("{!"))
        {
            getMeargedMessageFromApex({ message: this.unmergedMessage, recordId : recordId, objName: this.parameters.objectName})
            .then((result1) => {
                this.loader = false;
                const result =  LightningAlert.open({
                    message: result1.data,
                    variant: 'header',
                    label: 'Message Preview',
                    theme : 'alt-inverse'
                    // setting theme would have no effect
                });

            })
            .catch((error) => {
                console.log('error :'+JSON.stringify(error));
                this.error = error;
            });
        }
        else
        {
            this.loader = false;
            const result =  LightningAlert.open({
                message: this.unmergedMessage,
                variant: 'header',
                label: 'Message Preview',
                theme : 'alt-inverse'
                // setting theme would have no effect
            });
        }
    }

    validate(){
    }
    closeModal() {
        this.isModalOpen = false;
    }
    finish(){
        if(this.totalRecordsWithPhone == 0)
        {
            this.emptyPhoneNumberError();
        }
        else
        {
            const confirmBox =  LightningConfirm.open({
                message: SENDWHATSAPPMESSAGE+' '+ this.totalRecordsWithPhone +' recipient?',
                variant: 'header',
                label: 'Confirm?',
                theme : 'alt-inverse'
                // setting theme would have no effect
            }).then((result) => {
                if(result){
                    console.log('result : ',result);
                    this.sendDisabled = true;
                    this.initiateSending();
                }
            })
            .catch((error) =>{
                console.log('error : '+JSON.stringify(error));
            })
       }
    }

     handleClick() {

     if(this.totalRecordsWithPhone == 0)
        {
            this.emptyPhoneNumberError();
        }else{
            this.showSchedular = true;
             this.objParameters = {
                            'recordIds': this.parameters.recordIds ,
                            'templateId' : this.parameters.selectedTemplateId,
                            'phoneFieldName' : this.parameters.phonefield,
                            'nameFieldName':this.parameters.nameField,
                            'objectName':this.parameters.objectName,
                            'channel' : this.parameters.selectedChannelName,
                            'reportId':this.parameters.reportId
                        }
        }
    }
    handleClose(event){
        this.showSchedular = event.detail.value
    }

    initiateSending(){
        console.log('this.parameters.selectedChannelName :'+this.parameters.selectedChannelName);
        this.objParameters = {
                            'recordIds': this.parameters.recordIds ,
                            'templateId' : this.parameters.selectedTemplateId,
                            'phoneFieldName' : this.parameters.phonefield,
                            'nameFieldName':this.parameters.nameField,
                            'objectName':this.parameters.objectName,
                            'reportId':this.parameters.reportId,
                            'channel' : this.parameters.selectedChannelName
                        }
        console.log('this.objParameters :'+JSON.stringify(this.objParameters))
        sendWhatsappMsg({mapChannelRequest :this.objParameters})
        .then((result) => {
            if(result){
                this.loader = false;

            const evt = new ShowToastEvent({
                title: MESSAGESENT,
                message: result,
                variant: 'success'
            });
            this.dispatchEvent(evt);
            this.navigateToCallingSource();
            }else{
                this.loader = false;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: ERRORENCOUNTERED,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        })
        .catch((error) => {
        });
    }

    
    navigateToCallingSource() {
        if(this.parameters.source == 'report'){
            try{
            var pkgPrefix = getPackagePrefix(); // utlils call to get pkg prefix
            let cmpDef = {
                componentDef: pkgPrefix['prefix']+':reportSelection'
               };
              let encodedDef = btoa((JSON.stringify(cmpDef)));
               this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                  url: ONEAPPLINK + encodedDef
                }
              });
            }catch(error){
                console.log('error :'+JSON.stringify(error));
            }
            
        }else{
            window.open(CONTAINSNAVIGATIONLINK+this.parameters.objectName+CONTAINSNAVIGATIONFILTERLINK,CONTAINSNAVIGATIONSELFLINK);
        }
    }

     // Showing Tost Event Error When There is no any phone field to send the message.
     emptyPhoneNumberError()
     {
         const evt = new ShowToastEvent
         ({
             title: 'Toast Error',
             message: EMPTYPHONEFIELDERRORMESSAGE,
             variant: 'error',
             mode: 'dismissable'
         });
         this.dispatchEvent(evt);
     }

     renderedCallback(){

        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, EngageCliq+'/CSS/colors.css').then(()=>{
        }).catch(error=>{
        })
}

}