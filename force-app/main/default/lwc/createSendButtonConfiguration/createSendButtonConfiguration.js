import { LightningElement,track,wire, api} from 'lwc';
//import all apex methods
import initializeComponent from  '@salesforce/apex/SendButtonConfigurationController.initializeComponent';
import getAllObjects from  '@salesforce/apex/SendButtonConfigurationController.getAllObjects';
import getAllSBCs from  '@salesforce/apex/SendButtonConfigurationController.getExistingSBCs';
import createSendButtonConfigurations from  '@salesforce/apex/SendButtonConfigurationController.createSendButtonConfiguration';
import UpdateSendButtonConfigurations from  '@salesforce/apex/SendButtonConfigurationController.updateSendButtonConfiguration';
import prepareVFPage from  '@salesforce/apex/SendButtonConfigurationController.prepareVFPage';
import getfields from  '@salesforce/apex/SendButtonConfigurationController.getfields';
import SBCSTICKYNOTE from "@salesforce/label/c.sticky_note_on_send_configuration";
import VFPAGEERROR from "@salesforce/label/c.vf_page_creation_error";
import PHONEFIELDERROR from "@salesforce/label/c.phone_field_error_msg_in_sbc";
import BOOLEANFIELDERROR from "@salesforce/label/c.boolean_field_error_msg_in_sbc";
import SUCCESMESSAGE from "@salesforce/label/c.button_configuration_success_msg";
import MANDATORYFIELDERROR from "@salesforce/label/c.mandatory_field_error_msg_in_sbc";
import GETRECORDDATA from  '@salesforce/apex/SendButtonConfigurationController.getRecordData';
import GETALLVFPAGES from  '@salesforce/apex/SendButtonConfigurationController.getAllVfPages';
import {getPackagePrefix} from "c/utils";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';

export default class CreateSendButtonConfiguration extends NavigationMixin(LightningElement) {
   
  @track objectNameOptions = [];
  @track allExistingSBCs = [];
  @track tableShowFields = false;
  @track tableShowObject = false;
  @track showSpinner = false;

  @track newSBCObject = {};

  @track selectedObjectName;
  @track selectedNameField;
  @track selectedPhoneFields = [];
  selectedphoneApiNames;
  @track selectedOptinOutField;

  @track fieldPhoneOptions = [];
  @track fieldNameOptions = [];
  @track fieldOptInOutOptions = [];
  @track isOptInOutDisabled = true;
  @track isNameFieldDisabled = true;
  @track isPhoneFieldDisabled = true;

  @track temObject = [];
  @track sendConfigurationLabel;
  @api recordId;
  @track pkgPrefix;
  @track createSBC;
  @track vfpageData;

  connectedCallback(){
    this.recordId;
    console.log('record Id === '+this.recordId);
    if(this.recordId != undefined)
    {
      this.GETRECORDDATA(this.recordId);
      this.sendConfigurationLabel = 'Edit Send Configuration';
    }else{
      this.sendConfigurationLabel = 'New Send Configuration';
    } 
    this.pkgPrefix = getPackagePrefix(); // utlils call to get pkg prefix 
    this.showSpinner = true;
    let  msg = SBCSTICKYNOTE;
    this.showStickyToast(msg,'info');
  }

  getVfPages(){
    GETALLVFPAGES({objName: this.objectApiName})
    .then((result) => {
      this.vfpageData = result;
      console.log('vf page result === '+this.vfpageData);
      this.createSBC = true;
    })
    .catch((error) => {
        this.error = error; 
        this.data = undefined;       
    }); 
  }
       
GETRECORDDATA(recordId){
  GETRECORDDATA({recId:recordId})
  .then((data) =>{
    if(data)
    {
      console.log('Data === '+JSON.stringify(data));
      this.temObject = data;

      this.selectedObjectName = data[0][this.pkgPrefix['PKGPREFIX']+'Object_Name__c'];
      this.selectedPhoneFields = data[0][this.pkgPrefix['PKGPREFIX']+'Phone_Fields__c'];
      this.selectedNameField = data[0][this.pkgPrefix['PKGPREFIX']+'Name_Field__c'];
      this.selectedOptinOutField = data[0][this.pkgPrefix['PKGPREFIX']+'Consent_Field__c'];
    }
    });
}

@wire(initializeComponent)
  initializeComponent ({error, data}) {
    this.showSpinner = false;
    if (error) {
      var message;
      if (Array.isArray(error.body)) {
        message = error.body.map(e => e.message).join(', ');
      } else if (typeof error.body.message === 'string') {
        message = error.body.message;
      }
      this.showNotification('Error',message,'error');
      this.closeModal();
    }
  }
  //Get all SBC records. Will be required to display error message if user selects duplicate object name to create SBC record.
  @wire(getAllSBCs)
  getAllSBConfigs ({error, data}) {
      if (error) {
        var message;
        if (Array.isArray(error.body)) {
          message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
          message = error.body.message;
        }
        this.showNotification('Error',message,'error');
      } else if (data) {

        var result = data.data;
        this.allExistingSBCs = result.toString();
      }
  }

  //get all objects from objects to show in picklist
  @wire(getAllObjects)
  wiredData({ data, error }) {
    this.showSpinner = false;
      if (data) {
        this.tableShowObject = true;

        //elemenate the options which are already added
        let objMap = new Map(Object.entries(data));
        for (const key of objMap.keys()) {
          if(this.temObject && this.temObject.length>0){
            this.objectNameOptions = [...this.objectNameOptions ,{value: key , label: data[key]} ];
          }
          if(this.allExistingSBCs.includes(key)){
         continue;
          }else{
            this.objectNameOptions = [...this.objectNameOptions ,{value: key , label: data[key]} ];
        }
        }
      } else if (error) {
        var message;
        if (Array.isArray(error.body)) {
          message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
          message = error.body.message;
        }
        this.showNotification('Error',message,'error');
      }
  }


 // Updated code by sarjerao on 20-12-23
// get all fields of selected object
@wire(getfields,{objectname:'$selectedObjectName'})
getAllFields({error,data}){
  if(data){
    console.log('Inside get fields');
    this.fieldPhoneOptions = [];
    this.fieldNameOptions = [];
    this.fieldOptInOutOptions = [];
    this.selectedNameField = '';
    this.selectedOptinOutField = '';
    this.selectedPhoneFields = '';
    this.tableShowFields = true;
    let fieldsInfos = new Object(data);
      for(let  i =0; i<fieldsInfos.length; i++ ){
      let fieldInfo = fieldsInfos[i];
      if(fieldInfo['DataType']=='Phone' || fieldInfo['DataType']=='Fax' ||  ((fieldInfo['QualifiedApiName'].includes('__c')) && (fieldInfo['DataType'].includes('Text')))){
        this.fieldPhoneOptions = [...this.fieldPhoneOptions ,{value: fieldInfo['QualifiedApiName'] , label: fieldInfo['Label']} ];
        if(this.isPhoneFieldDisabled)
        this.isPhoneFieldDisabled = false;
      }
      if(fieldInfo['DataType'] == 'Checkbox' || fieldInfo['DataType'].includes('Checkbox')){
        this.fieldOptInOutOptions = [...this.fieldOptInOutOptions ,{value: fieldInfo['QualifiedApiName'] , label: fieldInfo['Label']} ];
         if(this.isOptInOutDisabled)
           this.isOptInOutDisabled = false;
      }
      if(fieldInfo['DataType']=='Text'|| fieldInfo['DataType'].includes('Text') || fieldInfo['DataType']=='Name'){
        this.fieldNameOptions = [...this.fieldNameOptions ,{value: fieldInfo['QualifiedApiName'] , label: fieldInfo['Label']} ];
        this.isNameFieldDisabled = false;
      }
    }
    if(this.fieldPhoneOptions.length <= 0 && this.recordId === undefined){
      this.showNotification('Error', PHONEFIELDERROR ,'error');
      this.isPhoneFieldDisabled = true;
    }
    if(this.isOptInOutDisabled.length <= 0){
      this.showNotification('Error',BOOLEANFIELDERROR,'error');
      this.isPhoneFieldDisabled = true;
    }
    //this.getValues(this.recordId);
  }else if(error){
     var message;
    if (Array.isArray(error.body)) {
      message = error.body.map(e => e.message).join(', ');
    } else if (typeof error.body.message === 'string') {
      message = error.body.message;
    }
    this.showNotification('Error',message,'error');
  }
  if(this.temObject.length>0)
  {
    this.selectedObjectName = this.temObject[0][this.pkgPrefix['PKGPREFIX']+'Object_Name__c'];

    let phoneTemp = this.temObject[0][this.pkgPrefix['PKGPREFIX']+'Phone_Fields__c'];   
    this.selectedPhoneFields = phoneTemp.split(",");
    
    // this.selectedPhoneFields = this.temObject[0]['Phone_Fields__c'];
    this.selectedNameField = this.temObject[0][this.pkgPrefix['PKGPREFIX']+'Name_Field__c'];
    this.selectedOptinOutField = this.temObject[0][this.pkgPrefix['PKGPREFIX']+'Consent_Field__c'];
  }
  }

  // called after change of Object name field change
  handleObjectNameChange(event){
    this.selectedObjectName = event.detail.value;
  }

  //called after change of name field change
  handleNameFieldChange(event){
    this.selectedNameField = event.detail.value;
  }

  //called after change of Phone field change
  handlePhoneChange(event){
    this.selectedPhoneFields = event.detail.value;
  }

  //called after change of Opt in opt out field change
  handleOptInOutFieldChange(event){
    this.selectedOptinOutField = event.detail.value;
  }

  //called after click of Save button.
  handleSaveClick(){
    if(this.recordId == undefined){
    if(this.selectedNameField == null || this.selectedNameField == '' ||
      this.selectedObjectName == null || this.selectedObjectName == '' ||
      this.selectedPhoneFields == null || this.selectedPhoneFields == '' ||
      this.selectedOptinOutField == null || this.selectedOptinOutField == ''){
      this.showNotification('Error',MANDATORYFIELDERROR,'error');
    }else{
      this.getVfPages();
      this.showSpinner = true;
      prepareVFPage({objectAPIName :this.selectedObjectName})
      .then((data) =>{
        if(data.isSuccess || this.createSBC === true){
          //after success creation of VF page, create SBC record .          
          console.log('vf page is created');
          this.createSendButtonConfigurations(this.selectedObjectName, this.selectedPhoneFields.toString(),this.selectedNameField,this.selectedOptinOutField) 
        }else{
          this.showNotification('Error', VFPAGEERROR ,'error');
          this.closeModal();
        }
      });
    }
    }else{
      console.log('@@@ else called ');
      this.updateSBC();
  }
  }

  updateSBC(){
    UpdateSendButtonConfigurations({recId:this.recordId, objName:this.selectedObjectName , phoneFields:this.selectedPhoneFields.toString(), nameField:this.selectedNameField, selectedConsent:this.selectedOptinOutField})
      .then((result) =>{
      console.log('Result +> '+result);
      this.showNotification('Success','Record Successfully Updated','success');
      this.closeModal();
      })
      .catch((error) => {
        console.log('error :'+JSON.stringify(error));   
             
    });
  }
  
  createSendButtonConfigurations(objectName,phoneFields,nameField,optInField){
    createSendButtonConfigurations({objectName:objectName, phoneFields :phoneFields, nameField :nameField, optInField :optInField})
    .then((data) =>{
      this.showSpinner = false;
      if(data.isSuccess){
        this.showNotification('Success',SUCCESMESSAGE,'success');
        this.closeModal();
      }
      });  
}

  //show toast message
  showNotification(title,message,variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  // After Click On Close Button Of opup Template Nevigate on Standdard List View Page(All)
  closeModal() {
    var prefix = getPackagePrefix(); // utils call to get prefix

    this[NavigationMixin.Navigate]({
      type: 'standard__navItemPage',
      attributes: {
          apiName: prefix['PKGPREFIX']+'EngageCliq_Configurations',
      },
  });
    this.isModalOpen = false;
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