import { LightningElement,api,track } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader'
import EngageCliq from '@salesforce/resourceUrl/engagecliq';

export default class LightningDataTable extends LightningElement
{
    @api columns;
    @api tabledata;

    showit
    @track message;

    handleRowAction(event)
    {
        console.log('event :'+JSON.stringify(event));
        console.log('event.detail :'+JSON.stringify(event.detail));
        try{
        const actionName = event.detail.action.name;

        this.dispatchEvent(new CustomEvent('rowaction', {
            bubbles: true, composed : true, detail: event.detail
        }));
    }catch(exception){
        console.log('error :'+JSON.stringify(exception));
    }
    }

    renderedCallback(){
        //Table row color chage script
        let styles = document.createElement('style');
        styles.innerText = '.custom-datatable-style tbody tr:nth-child(even) { background-color: #fefefe; border:none; } .custom-datatable-style tbody tr:nth-child(odd) { background-color: #f0f7ff;border:none; }';
        this.template.querySelector('.custom-datatable-style').appendChild(styles);

        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, EngageCliq+'/CSS/colors.css').then(()=>{
        }).catch(error=>{
            console.error("Error in loading the colors")
        })
}
}