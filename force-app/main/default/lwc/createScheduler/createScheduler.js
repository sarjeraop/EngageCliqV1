import { LightningElement,track,api,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import saveSchedule from '@salesforce/apex/ScheduleController.saveSchedule';
import ACCESSCHECK from '@salesforce/apex/ScheduleController.initialise';
import DAILY from "@salesforce/label/c.daily_label";
import ONLYONCE from "@salesforce/label/c.only_once_label";
import WEEKLY from "@salesforce/label/c.weekly_label";
import MONTHLY from "@salesforce/label/c.monthly_label";
import YEARLY from "@salesforce/label/c.yearly_label";
import DATEERROR from "@salesforce/label/c.date_error_label";
import DAYERROR from "@salesforce/label/c.day_error_label";
import INVALIDDATEERROR from "@salesforce/label/c.invalid_date_error_label";
import DATEVALIDITYERROR from "@salesforce/label/c.valid_date_error_label";
import ENDDATEERROR from "@salesforce/label/c.end_date_error_label";
import REQFIELDERROR from "@salesforce/label/c.required_field_error_label";
import SCHEDULEMESSAGE from "@salesforce/label/c.schedule_success_message_label";
import SCHEDULEERROR from "@salesforce/label/c.schedule_error_message_label";
import SCHEDULEFUTUREDATEERROR from "@salesforce/label/c.schedule_future_date_error_label";
import DATECOMBOERROR from "@salesforce/label/c.combination_date_error_label";
import FREQUENCY_FIELD from "@salesforce/schema/Schedule_Communication__c.Frequency__c";
import { getSObjectValue } from "@salesforce/apex";
import { getSchedule } from 'c/utils';

export default class CreateScheduler extends  NavigationMixin(LightningElement){

  @api scheduleData=[];
  @track schedule;
  @track startDate;
  @track isFrequencyWeekly = false;
  @track isFrequencyMonthly = false;
  @track isFrequencyYearly = false;
  @track objScheduleCommunication = { 'sobjectType': FREQUENCY_FIELD['ObjectApiName'] };
  @track minutes =null;
  @track hours = null
  daysOfMonth = null;
  @track months = '*';
  @track daysOfWeek = '*';
  @track cronExpression = '';
  @track hh;
  @track min;
  pageHasError = false;
  endDate;
  disableEndDate = false;
  showModal = true;
  showdateTimeError = false;
  dateTimeError
  recordId;
  today;
  showStartDateField = false;
  nameSpacePrefix =''

  get freq() {
    return this.objScheduleCommunication[this.schedule.frequency] ? this.objScheduleCommunication[this.schedule.frequency] : '' ;
  }

   // Apex call to get all field aceess check for user
     getAccessCheck(){
        ACCESSCHECK()
            .then((result) => {
                if(result.isSuccess === false){
                    this.showMesssage('Error',data.message,'error');
                }
            })
            .catch((error) => {
                this.error = error;
                this.data = undefined;

            });
    }

  connectedCallback()
	{
    this.schedule = getSchedule();
    this.getAccessCheck();
    this.today = new Date();
    var dd = String( this.today.getDate()).padStart(2, '0');
    var mm = String( this.today.getMonth() + 1).padStart(2, '0');
    var yyyy =  this.today.getFullYear();
    this.hh = String(this.today.getHours()).padStart(2,'0');
    this.min = String(this.today.getMinutes()).padStart(2,'0');
    this.today = yyyy + '-' + mm + '-' + dd;
    this.startDate =  this.today;
    this.showModal = true;
  }

  get hourOptions()
	{
    return [
      { label: '00', value: '0' },
      { label: '01', value: '1' },
      { label: '02', value: '2' },
      { label: '03', value: '3' },
      { label: '04', value: '4' },
      { label: '05', value: '5' },
      { label: '06', value: '6' },
      { label: '07', value: '7' },
      { label: '08', value: '8' },
      { label: '09', value: '9' },
      { label: '10', value: '10' },
      { label: '11', value: '11' },
      { label: '12', value: '12' },
      { label: '13', value: '13' },
      { label: '14', value: '14' },
      { label: '15', value: '15' },
      { label: '16', value: '16' },
      { label: '17', value: '17' },
      { label: '18', value: '18' },
      { label: '19', value: '19' },
      { label: '20', value: '20' },
      { label: '21', value: '21' },
      { label: '22', value: '22' },
      { label: '23', value: '23' },
      ];
  }

  get dayOptions()
	{
    return [
      { label: 'Monday', value: '2' },
      { label: 'Tuesday', value: '3' },
      { label: 'Wednesday', value: '4' },
      { label: 'Thursday', value: '5' },
      { label: 'Friday', value: '6' },
      { label: 'Saturday', value: '7' },
      { label: 'Sunday', value: '1' },
    ];
  }
  dayvalue = ['1'];

  get selectedValues()
	{
    return this.dayvalue.join(',');
  }

  handleDayChange(e)
	{
    this.dayvalue = e.detail.value;
    if((this.objScheduleCommunication[this.schedule.frequency] == WEEKLY) && (this.dayvalue =='' ))
		{
      let dayField = this.template.querySelector('lightning-checkbox-group');
      this.pageHasError = true
      dayField.setCustomValidity(DAYERROR);
      dayField.reportValidity();
    }else
		{
      this.pageHasError = false;
      let dayField = this.template.querySelector('lightning-checkbox-group');
      dayField.setCustomValidity('');
      dayField.reportValidity();
  	}
	}

  get options()
	{
    return [
      { label: 'Once', value: 'Only Once' },
      { label: 'Daily', value: 'Daily' },
      { label: 'Weekly', value: 'Weekly' },
      { label: 'Monthly', value: 'Monthly' },
      { label: ' Yearly', value: 'Yearly' }
    ];
  }

  get daysOfMonthOptions()
	{
  return [
    { label: '1st', value: '1' },
    { label: '2nd', value: '2' },
    { label: '3rd', value: '3' },
    { label: '4th', value: '4' },
    { label: '5th', value: '5' },
    { label: '6th', value: '6' },
    { label: '7th', value: '7' },
    { label: '8th', value: '8' },
    { label: '9th', value: '9' },
    { label: '10th', value: '10' },
    { label: '11th', value: '11' },
    { label: '12th', value: '12' },
    { label: '13th', value: '13' },
    { label: '14th', value: '14' },
    { label: '15th', value: '15' },
    { label: '16th', value: '16' },
    { label: '17th', value: '17' },
    { label: '18th', value: '18' },
    { label: '19th', value: '19' },
    { label: '20th', value: '20' },
    { label: '21th', value: '21' },
    { label: '22th', value: '22' },
    { label: '23th', value: '23' },
    { label: '24th', value: '24' },
    { label: '25th', value: '25' },
    { label: '26th', value: '26' },
    { label: '27th', value: '27' },
    { label: '28th', value: '28' },
    { label: '29th', value: '29' },
    { label: '30th', value: '30' },
    { label: '31st', value: '31' }
    ];
  }

  get monthOfYearOptions()
	{
    return [
      { label: 'Jan', value: '1' },
      { label: 'Feb', value: '2' },
      { label: 'Mar', value: '3' },
      { label: 'Apr', value: '4' },
      { label: 'May', value: '5' },
      { label: 'Jun', value: '6' },
      { label: 'Jul', value: '7' },
      { label: 'Aug', value: '8' },
      { label: 'Sep', value: '9' },
      { label: 'Oct', value: '10' },
      { label: 'Nov', value: '11' },
      { label: 'Dec', value: '12' }
      ];
  }

  get minuteOptions()
	{
    return [
      { label: '00', value: '0' },
      { label: '01', value: '1' },
      { label: '02', value: '2' },
      { label: '03', value: '3' },
      { label: '04', value: '4' },
      { label: '05', value: '5' },
      { label: '06', value: '6' },
      { label: '07', value: '7' },
      { label: '08', value: '8' },
      { label: '09', value: '9' },
      { label: '10', value: '10' },
      { label: '11', value: '11' },
      { label: '12', value: '12' },
      { label: '13', value: '13' },
      { label: '14', value: '14' },
      { label: '15', value: '15' },
      { label: '16', value: '16' },
      { label: '17', value: '17' },
      { label: '18', value: '18' },
      { label: '19', value: '19' },
      { label: '20', value: '20' },
      { label: '21', value: '21' },
      { label: '22', value: '22' },
      { label: '23', value: '23' },
      { label: '24', value: '24' },
      { label: '25', value: '25' },
      { label: '26', value: '26' },
      { label: '27', value: '27' },
      { label: '28', value: '28' },
      { label: '29', value: '29' },
      { label: '30', value: '30' },
      { label: '31', value: '31' },
      { label: '32', value: '32' },
      { label: '33', value: '33' },
      { label: '34', value: '34' },
      { label: '35', value: '35' },
      { label: '36', value: '36' },
      { label: '37', value: '37' },
      { label: '38', value: '38' },
      { label: '39', value: '39' },
      { label: '40', value: '40' },
      { label: '41', value: '41' },
      { label: '42', value: '42' },
      { label: '43', value: '43' },
      { label: '44', value: '44' },
      { label: '45', value: '45' },
      { label: '46', value: '46' },
      { label: '47', value: '47' },
      { label: '48', value: '48' },
      { label: '49', value: '49' },
      { label: '50', value: '50' },
      { label: '51', value: '51' },
      { label: '52', value: '52' },
      { label: '53', value: '53' },
      { label: '54', value: '54' },
      { label: '55', value: '55' },
      { label: '56', value: '56' },
      { label: '57', value: '57' },
      { label: '58', value: '58' },
      { label: '59', value: '59' }
      ];
  }

  handleFrequencyChange(event)
	{
    this.objScheduleCommunication[this.schedule.frequency] = event.target.value;
    if(event.target.value == ONLYONCE || event.target.value== DAILY){
      this.showStartDateField = true;
    }else{
       this.showStartDateField = false;
    }

    if(event.target.value == WEEKLY)
		{
      this.isFrequencyWeekly = true;
      this.isFrequencyMonthly = false;
      this.isFrequencyYearly = false;
    }
    else if(event.target.value == MONTHLY)
		{this.showStartDateField = true;
      this.isFrequencyWeekly = false;
      this.isFrequencyMonthly = true;
      this.isFrequencyYearly = false;
    }else if(event.target.value == YEARLY)
		{
      this.showStartDateField = true;
      this.isFrequencyMonthly = true;
      this.isFrequencyWeekly = false;
      this.isFrequencyYearly = true;
    }else
		{
      this.isFrequencyMonthly = false;
      this.isFrequencyWeekly = false;
      this.isFrequencyYearly = false;
    }
    if(event.target.value == ONLYONCE)
		{
      this.endDate = this.startDate;
      this.disableEndDate = true;
    }else
		{
      this.disableEndDate = false;
    }
  }

  handleHourChange(event){
      this.hours = event.target.value;
  }
  handleMinuteChange(event){
      this.minutes = event.target.value;
  }
  handledaysOfMonthChange(event){
      this.daysOfMonth = event.target.value;
  }
  handleMonthOfYearChange(event){
      this.months = event.target.value;
  }

    handleStartDate(){
        const startDateField = this.template.querySelector('.startDateValue')
        this.startDate = startDateField.value;
              if(this.objScheduleCommunication[this.schedule.frequency] == ONLYONCE){
            this.endDate = this.startDate;
        }
        if(this.startDate < this.today){
            this.pageHasError = true;
            startDateField.setCustomValidity(DATEERROR);
            startDateField.reportValidity()
        }else if(this.startDate >= this.today){
            this.pageHasError = false;
            startDateField.setCustomValidity('');
            startDateField.reportValidity()
            this.isValidDate = this.dateValidation();
        if(this.isValidDate){
             this.pageHasError = true;
            startDateField.setCustomValidity(DATEVALIDITYERROR);
            startDateField.reportValidity()
        }else{
            this.pageHasError = false;
            startDateField.setCustomValidity('');
            startDateField.reportValidity()
        }
        }
    }
     handleEndDate(){
        const endDateField = this.template.querySelector('.endDateValue')
        this.endDate = endDateField.value;
        this.isValidDate = this.dateValidation();
        if(this.isValidDate){
            this.pageHasError = true;
            endDateField.setCustomValidity(ENDDATEERROR);
            endDateField.reportValidity('')
        }else{
            this.pageHasError = false;
            endDateField.setCustomValidity('');
            endDateField.reportValidity('')
        }
    }
    handleSchedule(){
      const now = new Date();
      let currentHours = now.getHours();
      let currentMinutes = now.getMinutes();

        if(this.hours && this.minutes && (this.today == this.startDate) && (this.hours <= currentHours) && (this.objScheduleCommunication[this.schedule.frequency] == ONLYONCE)  && (this.minutes < currentMinutes)){
            this.showdateTimeError = true;
        }
         else if(this.hours < currentHours && (this.today == this.startDate) && (this.objScheduleCommunication[this.schedule.frequency] == ONLYONCE)){
              this.showdateTimeError = true;
         }
        else{
            this.showdateTimeError = false;
        }
        const isInputsCorrect = [...this.template.querySelectorAll('.validate')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
            if(this.showdateTimeError && isInputsCorrect){
                this.dateTimeError = INVALIDDATEERROR;
                this.pageHasError = true;
            }else if(this.showdateTimeError){
                this.pageHasError = true;
            }else{
                this.pageHasError = false;
            }
        if(!this.pageHasError && isInputsCorrect){
             if(this.objScheduleCommunication[this.schedule.frequency] == undefined || this.hours == '*' || this.minutes == '*' ){
                  this.showMesssage('Error',REQFIELDERROR,'error');
        }else{
                if(this.objScheduleCommunication[this.schedule.frequency] == WEEKLY){
                    this.cronExpression = `0 ${this.minutes} ${this.hours} ? ${this.months} ${this.dayvalue}`;
                }
                else if(this.objScheduleCommunication[this.schedule.frequency] == ONLYONCE){
                    let monthDay = new Date(this.startDate).getDate();
                    let month = new Date(this.startDate).getMonth()+1;
                     this.cronExpression = `0 ${this.minutes} ${this.hours} ${monthDay} ${month} ?`;
                }else if(this.objScheduleCommunication[this.schedule.frequency] == DAILY){
                    let monthDay = new Date(this.startDate).getDate();
                     this.cronExpression = `0 ${this.minutes} ${this.hours} ${monthDay}/1 * ?`;
                }else if(this.objScheduleCommunication[this.schedule.frequency] == MONTHLY){
                   let monthVal = new Date(this.startDate).getMonth()+1;
                   let currentMonth=  (new Date()).getMonth()+1;
                   let dayVal = new Date(this.startDate).getDate()

                  let Difference_In_Time =new Date(this.startDate).getTime() - (new Date()).getTime();
                  let Difference_In_Days = Math.round(Difference_In_Time / (1000 * 3600 * 24));
                   const startDateField = this.template.querySelector('.startDateValue');
                   if(Difference_In_Days > 30){
                      startDateField.setCustomValidity(SCHEDULEFUTUREDATEERROR);
                      startDateField.reportValidity();
                      return;
                   }else if((monthVal - currentMonth) == 1){
                      startDateField.setCustomValidity('')
                      startDateField.reportValidity();
                      this.cronExpression = `0 ${this.minutes} ${this.hours} ${dayVal} ${this.months}/1 ?`;
                   }else{
                      startDateField.setCustomValidity('')
                      startDateField.reportValidity();
                      this.cronExpression = `0 ${this.minutes} ${this.hours} ${dayVal} ${this.months} ?`;
                   }
                }else{
                   let monthVal = new Date(this.startDate).getMonth()+1;  //
                   let startyear = new Date(this.startDate).getFullYear();
                   let endYear=  (new Date(this.endDate )).getFullYear();
                   let dayVal = new Date(this.startDate).getDate()
                   this.cronExpression = `0 ${this.minutes} ${this.hours} ${dayVal} ${monthVal} ? ${startyear}-${endYear}`;
                }

                this.objScheduleCommunication[this.schedule.cronExpression] = this.cronExpression;
                this.objScheduleCommunication[this.schedule.templateId] = this.scheduleData['templateId'];
                this.objScheduleCommunication[this.schedule.reportId] = this.scheduleData['reportId'];
                this.objScheduleCommunication[this.schedule.objectName] = this.scheduleData['objectName'];
                this.objScheduleCommunication[this.schedule.phoneField] = this.scheduleData['phoneFieldName'];
                this.objScheduleCommunication[this.schedule.nameField] = this.scheduleData['nameFieldName'];
                this.objScheduleCommunication[this.schedule.channel] = this.scheduleData['channel'];
                this.objScheduleCommunication[this.schedule.endDate] = this.endDate;
                this.objScheduleCommunication[this.schedule.startDate] = this.startDate;
                this.CreateScheduleCommunication();
        }
        }
    }
    handleClose() {
        this.close('return value');
    }


   CreateScheduleCommunication(){
        saveSchedule({objScheduleCommunication :this.objScheduleCommunication ,selectedIdList : this.scheduleData['recordIds']})
        .then((result) => {
            if(result){
              if(result.isSuccess){
                this.recordId = result.data;
                this.openCommunicationRecordHandler();
                this.showMesssage('Success',SCHEDULEMESSAGE,'success');
              }else{
                  if(result.message.toLowerCase().includes('will never fire')){
                     this.showMesssage('Error',DATECOMBOERROR,'error');
                  }else{
                     this.showMesssage('Error',result.message,'error');
                  }
              }
            }else{
                this.showMesssage('Error',SCHEDULEERROR,'error');
            }
        })
        .catch((error) => {
            if(error.body.pageErrors[0].message.toLowerCase().includes('will never fire')){
                this.showMesssage('Error',DATECOMBOERROR,'error');
            }else{
                this.showMesssage('Error',error.body.pageErrors[0].message,'error');
            }  
        });
    }
    showMesssage(msgTitle,messsage,msgVarient){
        const evt = new ShowToastEvent({
            title: msgTitle,
            message: messsage,
            variant: msgVarient
        });
        this.dispatchEvent(evt);
    }
     dateValidation(){
        if(this.startDate && this.endDate && this.endDate <this.startDate  ){
           return true;
        }else{
            return false;
        }
    }
    openCommunicationRecordHandler() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        objectApiName: "Schedule_Communication__c",
        actionName: "view",
        recordId: this.recordId
      }
    });
  }
  handleClose(){
     const closepopup = new CustomEvent("close", {
      detail: false
    });
     this.dispatchEvent(closepopup);
  }

}