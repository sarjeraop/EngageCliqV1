import { LightningElement, wire, track} from 'lwc';
//import testMetadataFinder from '@salesforce/apex/ChatController.testMetadataFinder';
import createMetadataRecord from '@salesforce/apex/MetadataController.createMetadataRecord';
import getMetadata from '@salesforce/apex/MetadataController.getMetadata';
import { refreshApex } from "@salesforce/apex";
import {getPackagePrefix} from "c/utils";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const actions = [
  { label: 'Edit', name: 'Edit' },
];

export default class TestMetaData extends LightningElement {

  @track isOpenPopUp = false;
  @track pkgPrefix;
  @track apikeyProperty;
  @track businessIdProperty;
  @track phoneNoidProperty;
  @track endPointUrlProperty;
  @track reportError;
  @track _wiredData;

  data = [];
  columns = [];
  filterList = [];
  keyIndex = 0;

  connectedCallback(){
    this.pkgPrefix = getPackagePrefix(); // utlils call to get pkg prefix
    this.apikeyProperty =  this.pkgPrefix['PKGPREFIX']+'API_key__c';
    this.businessIdProperty = this.pkgPrefix['PKGPREFIX']+'Business_ID__c';
    this.phoneNoidProperty = this.pkgPrefix['PKGPREFIX']+'PhoneNo_Id__c';
    this.endPointUrlProperty = this.pkgPrefix['PKGPREFIX']+'Endpoint_URL__c';

    this.columns = [
    { label: 'Name', fieldName: 'DeveloperName' },
    { label: 'API KEY', fieldName: this.apikeyProperty},
    { label: 'Business Id', fieldName: this.businessIdProperty},
    { label: 'Phone No Id', fieldName: this.phoneNoidProperty},
    { label: 'End Point URL', fieldName: this.endPointUrlProperty},
    {
      type: 'action',
      typeAttributes: { rowActions: actions },
    }, 
    ];
  }
  

  recChannelConfig = {
    DeveloperName : '',
    [this.apikeyProperty] : '',
    [this.businessIdProperty] :'' ,
    [this.phoneNoidProperty] :'' ,
    [this.endPointUrlProperty] : ''
}

handleRowAction(event){
  const action = event.detail.action;

  const row = event.detail.row;
  console.log('row === '+JSON.stringify(row));

  this.recChannelConfig.DeveloperName = row.DeveloperName;
  this.recChannelConfig.API_key__c = row[this.apikeyProperty];
  this.recChannelConfig.Business_ID__c = row[this.businessIdProperty];
  this.recChannelConfig.PhoneNo_Id__c = row[this.phoneNoidProperty];
  this.recChannelConfig.Endpoint_URL__c = row[this.endPointUrlProperty];
  this.isOpenPopUp = true;
}



//@wire(getRecord, { recordId: "$recordId", fields: "$filedSet"})
  @wire(getMetadata)
  getChannelConfigMetadata(wireResult) {
        const {data, error } = wireResult;
        this._wiredData = wireResult;
        console.log('Inside wire');
        if (data) {
          console.log('data === '+JSON.stringify(this.data));
          this.data = data; 
        }    
        else if (error) {
          console.log('error === '+JSON.stringify(error));
            this.error = error; 
            this.data = undefined;           
        }
    }

    handleNewClick(){
      this.isOpenPopUp = true;  
    }

    hideModalBox(){
      this.isOpenPopUp = false;
    }

    handelCancle(){
      this.isOpenPopUp = false;
      this.recChannelConfig.DeveloperName = '';
      this.recChannelConfig[this.apikeyProperty] = '';
      this.recChannelConfig[this.businessIdProperty] = '';
      this.recChannelConfig[this.phoneNoidProperty] = '';
      this.recChannelConfig[this.endPointUrlProperty] = '';
    }

    /*handleChange(event){
      console.log('Name : '+event.target.name);
      this.recChannelConfig[event.target.name] = event.target.value;
    }*/
    handelNamechange(event){     
      this.recChannelConfig.DeveloperName = event.target.value;
    }

    handelAPIKEYchange(event){   
      this.recChannelConfig[this.apikeyProperty] = event.target.value;
    }

    handelBUSINESSIDchange(event){  
      this.recChannelConfig[this.businessIdProperty] = event.target.value;
    }

    handelPHONENOIDchange(event){     
      this.recChannelConfig[this.phoneNoidProperty] = event.target.value;
    }

    handelENDURLchange(event){      
      this.recChannelConfig[this.endPointUrlProperty] = event.target.value;
    }


  handelSave() {  
    const isInputsCorrect = [...this.template.querySelectorAll('.validate')]
          .reduce((validSoFar, inputField) => {
              inputField.reportValidity();
              return validSoFar && inputField.checkValidity();
          }, true);
     
    if(isInputsCorrect){  
      console.log('this.recChannelConfig === '+JSON.stringify(this.recChannelConfig));
 
      this.recChannelConfig[this.apikeyProperty] = this.template.querySelector('.api').value; 
      this.recChannelConfig[this.businessIdProperty] = this.template.querySelector('.bsi').value;
      this.recChannelConfig[this.phoneNoidProperty] = this.template.querySelector('.phi').value;
      this.recChannelConfig[this.endPointUrlProperty] = this.template.querySelector('.epu').value;


    createMetadataRecord({ lstMetadata: this.recChannelConfig})
    .then((result) =>{
      console.log('result after save === '+JSON.stringify(result));
      if(result.isSuccess === true){
        refreshApex(this._wiredData);
        this.showNotification('Success',result.message,'success');
        this.isOpenPopUp = false;       
      }
      })
      .catch((error) => {
        this.error = error; 
        console.log('error === ',error);
        refreshApex(this._wiredData);
        this.data = undefined;   
    });
  } 
     
    
    
  this.recChannelConfig.DeveloperName = '';
  this.recChannelConfig[this.apikeyProperty] = '';
  this.recChannelConfig[this.businessIdProperty] = '';
  this.recChannelConfig[this.phoneNoidProperty] = '';
  this.recChannelConfig[this.endPointUrlProperty] = ''; 
  }

   //show toast message
   showNotification
    (title,message,variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}