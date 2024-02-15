import { LightningElement, track, api } from 'lwc';

export default class InteractiveButton extends LightningElement {
    maxLength = 20;
    disableButton = true; // add button visibility
    @api disableFields = false; // Holds the value of boolean variable for disabling  edit for all field
    actionSelected='None'; // default selected action for radio button

    @api templateCategory ='Marketing'; // whatsApp template Category
    @api interactiveValue='None';   // Holds the value of interactive button selected
    @api  buttonList; // Holds the list of button or action selected by user

    @track keyIndex = 0; // Holds the index for iterator for quick action and quick reply
    @track  buttonlabel = 'Add'; // label for add next row
    @track objFlag = {
                        isAddButtonVisible : false,
                        comboboxDisableFlag : false,
                        addButtonFlag : false,
                        quickReplyButton : false,
                        quickActioyButton : false,
                        interactiveButtonOption : false,
                    }; // Object to store all  flag value for conditional rendering
    @track showButtonTextField = false;

    get interactiveOptions() {
        return [

            { label: 'Call to action', value: 'calltoaction'},
            { label: 'Quick reply', value: 'quickreply'}
        ];
    }

    get actionOptions() {
        return [
            { label: 'Call to phone number', value: 'PHONE_NUMBER'},
            { label: 'Visit website', value: 'URL'}
        ];
    }

    get quickReplyOptions() {
        return [
            //{ label: 'Marketing opt-out', value: 'marketingOpt'},
            { label: 'Custom', value: 'custom'}
        ];
    }

    connectedCallback(){
        console.log('connectedCallback List ==> '+JSON.stringify(this.buttonList));
    if(this.buttonList.length >= 1){
        
        if(this.interactiveValue == 'quickreply'){
                this.objFlag.quickReplyButton = true;
                this.objFlag.interactiveButtonOption = true;
                this.objFlag.addButtonFlag = true;
                this.objFlag.isAddButtonVisible = true;
                this.objFlag.comboboxDisableFlag = false;
                //this.disableFields= true;

            }

        if ((this.interactiveValue == 'calltoaction')){
                this.objFlag.quickActioyButton = true;
                this.objFlag.interactiveButtonOption = true;
                this.objFlag.addButtonFlag = true;
                this.objFlag.isAddButtonVisible = true;
                this.showButtonTextField = true;
                this.objFlag.comboboxDisableFlag = true;
                //this.disableFields= true;
            }
        if ((this.interactiveValue == 'None')){
                this.disableFields = false;
        }
    }
    else{
        this.disableFields = false;
    }
    if (this.interactiveValue && this.interactiveValue == 'calltoaction' && this.buttonList && this.buttonList.length > 1) {
                        this.disableButton = true;
                    } else if (this.interactiveValue && this.interactiveValue == 'quickreply' && this.buttonList && this.buttonList.length > 2) {
                        this.disableButton = true;

                    }
                    else{
                        this.disableButton = false;
    }
}

    // method to handle interActive radio button  change
    handleInteractiveChange(event){

        this.interactiveValue = event.target.value;
        if(this.templateCategory === 'Utility'){
                    this.objFlag.comboboxDisableFlag = true;
          }

        if (this.interactiveValue == 'None') {
                    this.buttonList =
                        [
                            {
                                id:0,
                                interActiveType: this.interActiveValue,
                                type: "",
                                text: "",
                                phone_number_OR_url: ""
                            }
                        ];
                        this.objFlag.isAddButtonVisible = false;
            }

         if ((this.interactiveValue == 'calltoaction')){
                    this.objFlag.quickReplyButton = false;
                    this.objFlag.quickActioyButton = true;
                    this.objFlag.interactiveButtonOption = true;
                    this.objFlag.addButtonFlag = true;
                    this.buttonList =
                    [
                        {
                            id:0,
                            type: "",
                            interActiveType: this.interActiveValue,
                            text: "",
                            phone_number_OR_url: ""
                        }
                    ];
                    this.objFlag.isAddButtonVisible = true;
            }
        if(this.interactiveValue == 'quickreply'){
                    this.objFlag.quickReplyButton = true;
                    this.objFlag.quickActioyButton = false;
                    this.objFlag.interactiveButtonOption = true;
                    this.buttonList =
                    [
                        {
                            id:0,
                            type: "",
                            interActiveType: this.interActiveValue,
                            text: "",
                            phone_number_OR_url: ""
                        }
                    ];
                    this.objFlag.isAddButtonVisible = true;
                    this.objFlag.addButtonFlag = true;
                }
            }

    // method for handling onclick  for Add Button
    addRow() {

                let newEntry = {
                    interActiveType: this.interActiveValue,
                    type : '',
                    text : '',
                    phone_number_OR_url : '',
                    id: ++this.keyIndex
                 };

                if ( this.buttonList ) {

                    this.buttonList = [...this.buttonList, newEntry];

                } else {

                    this.buttonList = [ newEntry ];

                    }
                this.disableButton = true;
                const selectedEvent = new CustomEvent("selectedrow", { detail: this.buttonList });

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);

            }

    // method for onchange event on Input field and radio button
   bindFieldValue(event){
        let index = event.target.accessKey;
        let fieldName = event.target.name;
        let value = event.target.value;

            
        
        if(event.target.value != null){
            if(event.target.value == 'URL'){
                this.maxLength = 2000;
            }
            if(event.target.value == 'PHONE_NUMBER'){
                this.maxLength = 20;
            }

            this.showButtonTextField = true;
        }
        else
        {
                this.showButtonTextField = false;
        }
       
        try{
            let tempRecords = JSON.parse(JSON.stringify(this.buttonList));

                for(let i = 0; i < tempRecords.length; i++) {

                    if(tempRecords[i].id === parseInt(index)) {

                            if(this.interactiveValue == 'quickreply' &&  fieldName == 'typeAction'){
                                    value = 'QUICK_REPLY';
                                    fieldName ='type';
                                }

                            if(this.interactiveValue == 'quickreply' && this.templateCategory =='Utility'){
                                    tempRecords[index]['type'] = 'QUICK_REPLY';
                                }
                            tempRecords[i]['interActiveType'] = this.interactiveValue;
                            tempRecords[i][fieldName] = value;
                    }
                }
                this.buttonList = tempRecords;
        }
        catch(error){
        }

        if((event.target.value != ''&& (event.target.name != 'type' || event.target.name != 'typeAction')&& event.target.name == 'text') &&
            (this.interactiveValue == 'calltoaction' || this.interactiveValue == 'quickreply')){
                 if (this.interactiveValue && this.interactiveValue == 'calltoaction' && this.buttonList && this.buttonList.length > 1) {
                        this.disableButton = true;
                    } else if (this.interactiveValue && this.interactiveValue == 'quickreply' && this.buttonList && this.buttonList.length > 2) {
                        this.disableButton = true;

                    }
                    else{
                        this.disableButton = false;
                    }

            }
        else if(event.target.name !== 'phone_number_OR_url'){
                    this.disableButton = true;
            }
            console.log('List ==> '+JSON.stringify(this.buttonList));
        }

// method to send generated button list to caller
    @api sendDataToParent(){
        return this.buttonList;
    }

}