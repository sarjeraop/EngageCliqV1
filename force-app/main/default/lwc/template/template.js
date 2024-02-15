import { LightningElement, api, wire,track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { getSObjectValue } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import NAME_FIELD from "@salesforce/schema/Template__c.Name__c";
import TARGETSOURCE_FIELD from "@salesforce/schema/Template__c.Target_Source__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Template__c.Description__c";
import ID from "@salesforce/schema/Template__c.Id";
import ENGAGECLIQ_RESOURCES from '@salesforce/resourceUrl/engagecliq';
import retrieveChannelData from '@salesforce/apex/TemplateController.retrieveChannelData';
import getAllObjects from '@salesforce/apex/TemplateController.getAllObjects';
import getTemplates from '@salesforce/apex/TemplateController.getTemplate';
import {getPackagePrefix} from "c/utils";
import {getTemplate} from "c/utils";
import accessCheck from '@salesforce/apex/TemplateController.initialiseTemplate';
export default class template extends LightningElement {
  @api disabled = false;
  isChannel = true;
  @api mode;
  @api recordId;
  @api temp;

  childProps =
              {
                 Name__c: undefined,
                 Description__c: undefined ,
                 Id : undefined,
                 Target_Source__c : undefined,
                 recordId : undefined
                };
  componentConstructor;
  resourceUrl = ENGAGECLIQ_RESOURCES;
  @track channels;
  @track items;

  _recordId;

  objectMap; // holds the map of label value  for all object
  objList = []; // holds the list of object for autosuggest
  tableShow= false; // boolean flag to show and hide auto suggested table
  objNameLabel; // holds the selected object label
  templateStatus = 'New Template' // hold the value edit or new template to show on UI
namePrefix ={};
  get name() {
    return this.childProps ? getSObjectValue(this.childProps, NAME_FIELD) : "";
  }
  get description(){
    return this.childProps ? getSObjectValue(this.childProps, DESCRIPTION_FIELD) : "";
  }
  get parameters(){
    return {
      'name': this.childProps ? getSObjectValue(this.childProps, NAME_FIELD) : "",
      'description' : this.childProps ? getSObjectValue(this.childProps, NAME_FIELD) : "",
      'objectName' : this.objNameLabel
      };
}
// access check for fields
  getAccessCheck(){
        accessCheck()
                .then((result) => {
                    if(result.isSuccess === false){
                        this.showErrorToast(result.message);
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.data = undefined;

                });
    }

  @wire(getRecord, {
    recordId: '$recordId',
    fields: [NAME_FIELD, TARGETSOURCE_FIELD, DESCRIPTION_FIELD,ID],
  })


  wiredRecord({ error, data }) {
    if (data) {
        for (var key in data.fields) {
        if (data.fields.hasOwnProperty(key)) {
              var childPropsKey = key.replace(this.namePrefix['PKGPREFIX'],'');
              this.childProps[childPropsKey] = data.fields[key].value;
            }
          }
          this.objNameLabel = this.childProps['Target_Source__c'];
          console.log('childProps ',this.childProps);
        this.error = undefined;
    } else if (error) {
        this.error = error;
        this.data = undefined;
    }
  }
getObjectData(){
  getAllObjects()
    .then((result) => {
      
          if(result.isSuccess){
              this.objectMap = new Map(Object.entries(result.data));
          }
          else{
            this.showErrorToast(data.message);
          }
          
      })
      .catch((error) => {
          this.error = error;
          this.data = undefined;

      });

}
getTemplateData(){
    getTemplates()
    .then((result) => {
          if(result.isSuccess){
              this.templateList = result.data;
          }
          else{
            this.showErrorToast(result.message);
          }
      })
      .catch((error) => {
          this.error = error;
          this.data = undefined;

      })
}
templateList =[];
  constructor() {
    super();
    if (this._recordId) {
      this.disabled = true;
    }
  }

  connectedCallback() {
    this.namePrefix = getPackagePrefix();
    this.getObjectData();
    this.getTemplateData();
    this.getAccessCheck();
    this.temp = getTemplate();
    if (this.mode && this.mode == 'edit') {
      this.disabled = true;
      this.templateStatus = 'Edit Template'
    }
    retrieveChannelData
      ({
      templateId : this.recordId
      })
      .then((result) => {
        debugger;
        const rows = [];
        const mapChannel = new Map(Object.entries(result.data));
        mapChannel.forEach((value, key, map)=>{
          const channelLogo = key.split(":");
           // Object.assign | This method allows to easily copy values from one object to another.
           const channelObj = Object.assign({}, value, {
            key : channelLogo[0],
            //Logo : this.resourceUrl+''+channelLogo[1],
            Logo : channelLogo[1]+':'+channelLogo[2],
            Id : value.Id,
            Name : value.Name,
            Template_ID__c: value.Template_ID__c
        })

        rows.push(channelObj);
      })
      this.channels = rows;
    })
      .catch((error) => {
        this.error = error;
      });

  }

  handleChange(event) {
    console.log('Value '+event.target.value);
      this.childProps[event.currentTarget.dataset.name] = event.target.value;
    if(event.currentTarget.dataset.name === 'Target_Source__c'){
      this.objectFinder(event.target.value);
    }
    if(event.currentTarget.dataset.name === 'Name__c'){
      this.temaplateFinder(event.target.value);
    }
  }

  temaplateFinder(temaplateName){
    let inputCmp = this.template.querySelector('.nameinput');
    inputCmp.setCustomValidity('');
    inputCmp.reportValidity();
    this.templateList.forEach(inputField => {
      if(inputField[this.temp.name].toLowerCase() === temaplateName.toLowerCase().trim()){

            inputCmp.setCustomValidity('Tempalte with name '+temaplateName+' already exist ');
            inputCmp.reportValidity();

      }

  });

  }


  objectFinder(objName){
    let tempList =[];
    try{
    this.objectMap.forEach((value, key, map)=>{
      if(value.toLowerCase().includes(objName.toLowerCase())){
        tempList.push({label : value,  value: key});
          }
    });
  }
  catch(e){
    console.log('Error'+e.message);
  }
  this.objList = tempList;
  if(tempList.length > 0) {
      if(objName.length > 0){
          this.tableShow = true;
      }
      else{
          this.tableShow = false;
      }
    }
  else{
          this.tableShow = false;

    }
}

handleSelect( event ) {
var objectApiName;
this.objNameLabel = event.target.value;
this.tableShow = false;
this.objectMap.forEach((value, key, map)=>{

  if(value === event.target.value){
    objectApiName = key;
      }
});
this.childProps['Target_Source__c'] =  objectApiName;

}

  redirectChannel(event) {
    this.tableShow = false;

    const isInputsCorrect = [...this.template.querySelectorAll('.validate')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (isInputsCorrect) {
         if(this.objectMap.has(this.childProps[this.temp.targetSource]) || this.objectMap.has(this.childProps['Target_Source__c'])){
          this.isChannel = false;
          var childTemplateId = event.target.dataset.id;
          if (childTemplateId) {
            this.childProps["recordId"] = childTemplateId;
          }
              var templateName = event.target.dataset.name;
              var dynamicTemplate = this.namePrefix['prefix'] +'/'+templateName+'Template';
              import(dynamicTemplate) // 👍: Statically analyzable
              .then(({ default: ctor }) => (this.componentConstructor = ctor))
              .catch((err) => console.log("Error importing component"));
          }

        else{

            this.showErrorToast('Please select valid object');
        }
        inputCmp.reportValidity();
       }
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

}