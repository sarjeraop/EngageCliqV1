import { LightningElement,api,track } from 'lwc';

export default class MessagePreview extends LightningElement{

    @api templateParameters;
    currenttime;
 
    connectedCallback(){
        console.log('Message Body === '+JSON.stringify(this.templateParameters));

        var d = new Date();
        this.currenttime = d.toLocaleTimeString(navigator.language, {
            hour: '2-digit',
            minute:'2-digit'
        });      
    }

}