import { LightningElement,track,api, wire} from 'lwc';
import getBusinessId from "@salesforce/apex/WhatsAppAPIService.getBusinessId";
import getApprovedTemplate from "@salesforce/apex/WhatsAppTemplateController.getAllApprovedWhatsAppTemplate";

const columns = [
    { label: 'WhatsApp Approved Templates', fieldName: 'Name' } 
];
 
export default class ApprovedTemplates extends LightningElement {
 
    @api isShowModal 
    @api templates
 
    @track approvedTemplateOptions = [];
    @track selectedapprovedTemplatename;
    @track whatsAppBusinessId;
    @track jsonTemplate;
    @track isNextDisable = false;
    @track nextURL;
    @track selectedRows;
    @track selectedapprovedTemplate;
    @track disableButton = true;
 
    handelConfirm(event){
        console.log('event on click confirm === '+ event.detail);
        console.log('selecetd Approved template === '+ this.selectedapprovedTemplatename);
        this.isShowModal = false;  
        const passEvent = new CustomEvent('templateselection', {
            detail:{data:this.selectedapprovedTemplate} 
       });
       this.dispatchEvent(passEvent);
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    onClickCancle(){
        this.isShowModal = false; 
    }

   async connectedCallback(){
       if(this.whatsAppBusinessId != undefined && this.whatsAppBusinessId){
        this.totalApprovedTemplate = await this.getApprovedTemplateData();
       }
    } 

 totalApprovedTemplate =[];
   async getApprovedTemplateData(){ 
        try{   
            if(this.jsonTemplate !=null) {
        await getApprovedTemplate({templatejson:this.jsonTemplate})
          .then((result) => {
              if(result.data){ 
                this.approvedTemplateOptions = [];
                
               console.log(result.data.hasOwnProperty('nextURL'));
                if(result.data.hasOwnProperty('nextURL')){
                    
                if(result.data.nextURL['nextURL'] != undefined && result.data.nextURL['nextURL'].includes('after')){
                    var jsonNextUrl = result.data.nextURL['nextURL'];
                    
                    if(jsonNextUrl.includes("after")){
                        this.jsonTemplate = result.data.nextURL['nextURL'];
                    }
                    else{
                        console.log('not after');
                        this.jsonTemplate =null;
                    }
                }
            }
            else{
                
                this.jsonTemplate =null;
            }
                for (var key in result.data) {
                    this.IsInclude = this.totalApprovedTemplate.includes(key);
                    
                    if(this.IsInclude == false){ 
                    if(key !=='nextURL') {    
                        let template =  {Name: key , Value: result.data[key]};                  
                        //this.approvedTemplateOptions = [...this.approvedTemplateOptions ,{Name: key , Value: result.data[key]}]; 
                        this.approvedTemplateOptions.push(template);
                    } 
                }          
                }
           
               
               
               }
               this.error = undefined;
                })
          .catch((error) => {
            console.log("error ==="+ JSON.stringify(error.message));
                    this.error = error;
                    this.data = undefined;
    
                });
            }else{
                this.approvedTemplateOptions = undefined;
            }
        }
            catch (error) {
                log('ERROR '+error.message )
                this.approvedTemplateOptions = undefined;
            }
                finally{
                    //console.log('approved templae list lenght === '+this.approvedTemplateOptions.length);
                    return this.approvedTemplateOptions;
                }
      }

      @wire(getBusinessId)
      wiredData({ error, data }) {
        if (data) {
            console.log()
            this.whatsAppBusinessId = data;
            this.jsonTemplate = 'https://graph.facebook.com/v17.0/' + this.whatsAppBusinessId + '/message_templates?fields=id,name,status,category,language,components&status=APPROVED';
          this.error = undefined;
        } else if (error) {
          this.error = error;
          this.whatsAppBusinessId = undefined;
        }
      }
   


// Lazy Loading
columns = columns;
rowLimit =20;
rowOffSet=0;

   async loadMoreData(event){
       
        const currentRecord = this.totalApprovedTemplate;
        const { target } = event;
        target.isLoading = true;
        this.rowOffSet = this.rowOffSet + this.rowLimit;
         
        console.log('NEXT URL @@@ '+ this.jsonTemplate);
        let template = await this.getApprovedTemplateData();
        if(template != undefined){
        this.totalApprovedTemplate = [...this.totalApprovedTemplate, ...template];
        }

       // console.log('List Size === '+ this.totalApprovedTemplate.length);
        target.isLoading = false;
        //target.isLoading = false;   
        
    } 

 
    
    getSelectedName(event){
        
        try{
            this.disableButton = false;
            this.selectedRows = event.detail.selectedRows;
            this.selectedapprovedTemplatename = this.selectedRows[0]['Name'];
            this.selectedapprovedTemplate = this.selectedRows[0]['Value'];
        }catch(e){
            console.log(e.message);
        }
    }
    
}