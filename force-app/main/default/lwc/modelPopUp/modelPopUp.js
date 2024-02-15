import { LightningElement,api,wire, track } from 'lwc';
import LightningModal from 'lightning/modal';
import whatsappTemplateFinder from '@salesforce/apex/WhatsAppChatController.approvedWhatsAppTemplate';
import getQuickTextList from '@salesforce/apex/WhatsAppChatController.getQuickTextList';
import { NavigationMixin } from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex';
import {getPackagePrefix} from "c/utils";
import QUICKTEXTNAME from "@salesforce/label/c.quick_text_name_label";
import TEMPLATENAME from "@salesforce/label/c.template_name_label";
import CLOSE from "@salesforce/label/c.close_label";
import REFRESH from "@salesforce/label/c.refresh_label";
import NONE from "@salesforce/label/c.none_label";
import CONFIRM from "@salesforce/label/c.new_confirm_button_label";
import CANCEL from "@salesforce/label/c.newbutton_label";

export default class modelPopUp extends  NavigationMixin(LightningModal,LightningElement) {
    
    @api componentData;

    @track templateOptions =[]; // List  of template to show in dropdown
    @track quickTextOptions = []; // option to show in dropdown for quickText
    @track attachmentOptions = []; // option to show in dropdown for attchment
    @track tempObjList = [];
    @track label = {        
                    CLOSE,
                    REFRESH,
                    CONFIRM,
                    CANCEL
                };

    recordId; // hold the value of Id  comming from parent
    isActive;  // boolean value for approved template comming from parent
    objectNameAPI; // api name comming from parent
    @api compoName; // hold the name of component from parent
    holderValue; // hold the placeholder of component from parent
    newButtonVisibility;
    _wiredQuickTex;
    PlaceHolder;
    isShowModal = true;
    tableShowObject = false;
    disableButton = true; // boolean value to disable confirm button on load
    templateList =[]; // list of template  avialable for given object
    quickTextList =[]; // list of quick  avialable for given object
    attachmentList =[]; // list of template  avialable for given object
    templateRecord={}; // hold the selected template record data
    staticResourceInfo = []; // list  of attchment retrive from org
    namePrefix;

    


    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  

        this.isShowModal = false;
        const selectEvent = new CustomEvent('popupmodelevent', {
            detail: this.templateRecord
        });
       this.dispatchEvent(selectEvent);
    }
    
    handleOkay() {
        this.close(this.recordId);
    }

   connectedCallback(){
    if(this.componentData != undefined){
        this.isActive = this.componentData.active;
        this.objectNameAPI = this.componentData.objectName;
        this.namePrefix = getPackagePrefix();
    }
    
   }
    

    @wire(whatsappTemplateFinder, { active: '$isActive' , objectName: '$objectNameAPI'})
    wiredData({data,error}){
        if(data){
            data.data.forEach(element => {
                
                this.templateOptions = [...this.templateOptions ,{ id : element.id,label: element[this.namePrefix['PKGPREFIX']+'Name__c'], value: element[this.namePrefix['PKGPREFIX']+'Message_Body__c']}];
                
            });

            this.templateOptions = [...this.templateOptions,{label :NONE}];
            this.templateList = data.data;
        }
        if(error){
            this.error = error;
        }
    }
    
    @wire(getQuickTextList)
    wiredRecord({ error, data }){
        
        if(data){
            
           for (var i = 0; i < data.data.length; i++) {
                this.quickTextOptions = [...this.quickTextOptions ,{label: data.data[i].Name , value: data.data[i].Message}];
            }
            this.quickTextOptions = [...this.quickTextOptions,{label :NONE}];
            this.quickTextList = data.data;
        }
        if(error){
        this.error = error;
        }
        }
    

    get modelOptions(){
        if(this.componentData.compoName === TEMPLATENAME){
        return this.templateOptions;
        }
        if(this.componentData.compoName === QUICKTEXTNAME){
            return this.quickTextOptions;
        }
        
    }

    refreshTable(){
        //refreshApex(this._wiredQuickTex);
    }

   
    handleModelChange(event) {
        this.disableButton =true;
        if(this.componentData.compoName === QUICKTEXTNAME)
        {
           
            const selectedQuickTextName = event.detail.value;
            
            if(selectedQuickTextName.length > 0){
            this.tableShowObject = true;
            this.fileName = selectedQuickTextName;
            let tempList = [];
            this.quickTextOptions.forEach(inputField => {
    
                let tempRec = Object.assign({}, inputField); 
                
                 if(tempRec.label.toLowerCase().includes(this.fileName.toLowerCase())){
                   
                 tempRec.label = tempRec.label.replace( new RegExp( this.fileName, 'i' ),( label ) => `${label}` );                    
                 tempList.push(tempRec);
                 }
             });
             this.tempObjList = tempList;
             this.tempObjList = tempList;
            if(this.tempObjList.length > 0){
                this.tableShowObject = true;
                //this.disableButton = false;
            }  
            }
            else{
                this.selectedValue = '';
                this.tableShowObject = false;
            }
            
        }

        if(this.componentData.compoName === TEMPLATENAME) {
            
            const selectedTemplateName = event.detail.value;
            if(selectedTemplateName.length > 0){
            this.tableShowObject = true;
            this.fileName = selectedTemplateName;
            let tempList = [];
            this.templateOptions.forEach(inputField => {
                
                let tempRec = Object.assign({}, inputField); 
                
                
                 if(tempRec.label.toLowerCase().includes(this.fileName.toLowerCase())){
                 tempRec.label = tempRec.label.replace( new RegExp( this.fileName, 'i' ),( label ) => `${label}` );  
                                  
                 tempList.push(tempRec);
                 }
            
             });
             this.tempObjList = tempList;
             if(this.tempObjList.length > 0){
                this.tableShowObject = true;
                //this.disableButton = false;
            } 
            }
            
            else{
                this.selectedValue = '';
                this.tableShowObject = false;
            } 
        }
                
    }
    

    objTemplate;
    // this method is for aotosuggest select option for template;
    handleSelect( event ){
            this. disableButton = false;
            let strIndex = event.currentTarget.dataset.id;
            
            let tempRecs =  this.tempObjList;
            this.objTemplate = tempRecs[ strIndex ];
            let strAccName = tempRecs[ strIndex ].label;
            this.selectedValue = tempRecs[ strIndex ];
            this.tableShowObject = false;
            this.templateRecord = strAccName;
            this.fileName = strAccName

            if(this.componentData.compoName === TEMPLATENAME){
                
                let selectedRoom = this.templateList.find(element => element[this.namePrefix['PKGPREFIX']+'Name__c'] === this.fileName);
                
                    if(selectedRoom == undefined)
                    {
                        this.templateRecord = '';
                         
                    }else
                    {
                    this.templateRecord = selectedRoom; 
                    }  
                }
                if(this.componentData.compoName === QUICKTEXTNAME){
                   
                        let selectedRoom = this.quickTextList.find(element => element.Name === this.fileName);
                    if(selectedRoom == undefined)
                    {
                        this.templateRecord = '';
                         
                    }else
                    {
                    this.templateRecord = selectedRoom; 
                    }                                        
                }
    
        }


    onClickNewButton(){
        
      
        this[NavigationMixin.GenerateUrl]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: 'QuickText',
                actionName: 'new'
            }
            
        })
        .then(GenerateUrl => {
            
            window.open(GenerateUrl);
        });
        
    } 

    selectMessageBody() {        
          this.close(this.templateRecord);
    }

    getSelectedRecMessage(){
        var childData = {sourceData:this.templateRecord, name:this.componentData.compoName};
        const selectEvent = new CustomEvent('popupmodelevent', {
            detail: childData
        });
       this.dispatchEvent(selectEvent);
        
        this.isShowModal = false;
        this.close(this.templateRecord);
    }
    
}