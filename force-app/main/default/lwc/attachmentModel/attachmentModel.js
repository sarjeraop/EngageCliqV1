import { LightningElement,api,wire, track } from 'lwc';
import LightningModal from 'lightning/modal';
import getStaticResourceInfo from '@salesforce/apex/WhatsAppChatController.getFileUrl';
import getURL from '@salesforce/apex/WhatsAppChatController.createContentDistribution';
import FILEATTACH from "@salesforce/label/c.attach_file_label";
import SELECTFILE from "@salesforce/label/c.select_file_to_upload_label";
import FILENAME from "@salesforce/label/c.file_name_label";
import CONFIRM from "@salesforce/label/c.new_confirm_button_label";

export default class AttachmentModel extends LightningModal {
    
    @api fileFormats;
    
    @track showData = false;
    @track staticResourceInfo = [];
    @track optionList = [];
    @track customLabel = {
                    FILEATTACH,
                    SELECTFILE,
                    FILENAME,
                    CONFIRM
                };
    attachmentOptionValue;
    selectedValue;
    objTemplate;
    showCombobox = true;
    disableButton = true; // boolean value to disable confirm button on load
    tableShowObject = false;
    fileName;
    tempObjList;

    get acceptedFormats() {
       // return ['.csv', '.pdf', '.png', '.jpeg',  '.jpg', '.doc', '.docx', '.mp4', '.3gp'];
       return this.fileFormats;
    }

    get attachmentOptions() {
        return [
            { label: 'Image ', value: 'Image'},
            { label: 'Video', value: 'Video'},
            { label: 'Document', value: 'Text' }
        ];
    }
    
    get options() {
        return  this.optionList;
    }

    
    @wire(getStaticResourceInfo)
    wiredResources({ error, data }) {
        if (data) {
            if(data.data)
            this.staticResourceInfo = data.data;
        
        }
        
    }

    handleOkay() {
        this.close(this.selectedValue);
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;     
        if(uploadedFiles[0].contentVersionId){
            getURL({contentVersionId :uploadedFiles[0].contentVersionId })
            .then(result =>{
                console.log('getURL OUTPUT : '+JSON.stringify(result));
                this.showData = true;
                this. disableButton = false;
                this.selectedValue = result.data;
                this.fileName = result.data.name;                
                this.error =undefined
            })
            .catch(error =>{
            this.error =error;            
            });
        }
    }
    
    handleChange(event) {
        this.tableShowObject = false;
        this.disableButton = true;
        const selectedFileName = event.detail.value;
       this.fileName = selectedFileName;
        let tempList = [];
        if(selectedFileName.length > 0){
        this.staticResourceInfo.forEach(inputField => {
            let tempRec = Object.assign({}, inputField); 
             if(tempRec.name.toLowerCase().includes(this.fileName.toLowerCase())){
                tempRec.name = tempRec.name.replace( new RegExp( this.fileName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i' ),( name ) => `${name}` );   
                              
             tempList.push(tempRec);
             }
         });
            this.tempObjList = tempList;
            if(this.tempObjList.length > 0){
                this.tableShowObject = true;
                this.disableButton = false;
            }        
        }
        else{            
            this.selectedValue = '';            
        }
        
    }
    
// this method is for aotosuggest select option for template;
    handleSelect( event ) {
        this. disableButton = false;
        let strIndex = event.currentTarget.dataset.id;        
        let tempRecs =  this.tempObjList;
        this.objTemplate = tempRecs[ strIndex ];
        let strAccName = tempRecs[ strIndex ].name;
        this.selectedValue = tempRecs[ strIndex ];
        this.tableShowObject = false;
        this.fileName = strAccName;
    }


    handleAttachmentChange(event) {
        this.attachmentOptionValue = event.detail.value;         
    }

   
    handleConfirm() {
          this.close(this.selectedValue);
    }

}