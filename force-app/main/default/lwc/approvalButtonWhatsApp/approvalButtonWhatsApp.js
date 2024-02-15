import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import sendApprovalWhatsApp from '@salesforce/apex/WhatsAppTemplateController.sendWhatsAppTemplateForApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getWhatsAppTemplate} from "c/utils";
import CONTACTSYSTEMADMIN from "@salesforce/label/c.contact_system_admin_label";
import ACCESSCHECK from '@salesforce/apex/WhatsAppTemplateController.initialiseWhatsAppTemplateForApprovalButton';
import WHATSAPPAPPROVAL from "@salesforce/label/c.whatsapp_approval_label";
export default class ApprovalButtonWhatsApp extends LightningElement {

    @api recordId//='a0H5g000006wa94EAA';
    @track objWhatsAppTemplate = { 'sobjectType': 'WhatsApp_Template__c' };
    whatsAppTemp
    connectedCallback(){
         this.checkForAccess();
         this.whatsAppTemp = getWhatsAppTemplate();

    }
    checkForAccess(){
        ACCESSCHECK()
                .then((result) => {
                    if(result.isSuccess === false){
                        this.showToast('Error',result.message,'error','dismissable');
                    }else{
                        this.sendForApproval();
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.data = undefined;
                });
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

     async sendForApproval(){
        console.log('recordId :'+this.recordId);
        await sendApprovalWhatsApp({whatsAppTemplaterecordId: this.recordId})
                .then((result)=>{
                    var resultmap = result.data;
                    console.log('resultmap :'+JSON.stringify(resultmap));
                    console.log('templateId :'+resultmap['statusCode']);
                    if(resultmap['statusCode']=='200'){
                        console.log('templateId :'+resultmap['templateId']);
                        this.showSuccessToast();
                       }else{
                        if(resultmap['error_user_msg']){
                            let err = resultmap['error_user_msg'];
                        console.log('error :'+err);
                        this.showErrorToast(err);
                        }else if(resultmap['error']){
                            let err = resultmap['error'];
                        console.log('error :'+err);
                        this.showErrorToast(err);
                        }
                        
                    }
                })
                .catch((error) =>{
                    this.error = error;
                    console.log('error :'+JSON.stringify(error));
                    this.showErrorToast(CONTACTSYSTEMADMIN);
                });
                this.closeQuickAction();
     }

     showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: WHATSAPPAPPROVAL,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showErrorToast(errorMessage) {
    const evt = new ShowToastEvent({
        title: 'Error',
        message: errorMessage,
        variant: 'error',
        mode: 'sticky'
    });
    this.dispatchEvent(evt);
    }
}