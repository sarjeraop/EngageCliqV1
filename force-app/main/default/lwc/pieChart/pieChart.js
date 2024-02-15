import { LightningElement,api,track} from 'lwc';
import EngageCliq from '@salesforce/resourceUrl/engagecliq';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//importing the apex method.
import getStats from '@salesforce/apex/BulkMessageController.getSObjectRecords';


export default class PieChart extends LightningElement {
  @api loaderVariant = "base";
  @api objname;
  @api phoneFieldAPIName;
  @api nameFieldAPIName;
  @api selectedIds;
  @api optField;
  @track chartStatics =[];
  @track totalRecords;
  @track totalRecordsWithoutPhoneNo;
  @track totalRecordsWithPhoneNo;


connectedCallback() {
    console.log('objname :'+this.objname +'phoneFieldAPIName :'+this.phoneFieldAPIName+' nameFieldAPIName '+this.nameFieldAPIName+' selectedIds '+this.selectedIds)
    let param = {
        "recordIds" : this.selectedIds,
        "objectName" : this.objname,
        "nameField" : this.nameFieldAPIName,
        "phonefield":this.phoneFieldAPIName,
        "optField":this.optField
    }
     setTimeout(() => {
       //getStats({ objectName: this.objname, nameField : this.nameFieldAPIName, phonefield:this.phoneFieldAPIName, recordIds:this.selectedIds })
       getStats({ mapRequest: param }) 
       .then((result) => {
            console.log('Chart result.data :'+result.data);
            this.totalRecords = result.data.totalRecords;
            this.totalRecordsWithoutPhoneNo = result.data.totalRecordsWithoutPhoneNo;
            this.totalRecordsWithPhoneNo = result.data.totalRecordsWithPhoneNo;

            this.chartStatics = [...this.chartStatics, {label :'Total Records Without PhoneNo' ,value:this.totalRecordsWithoutPhoneNo} ];
            this.chartStatics = [...this.chartStatics, {label :'Total Records With PhoneNo' ,value:this.totalRecordsWithPhoneNo} ];

            for (var key in this.chartStatics) {
                this.updateChart(this.chartStatics[key].value, this.chartStatics[key].label);
            }

            // updated code
            const ctx = this.template
                   .querySelector("canvas.donut")
                   .getContext("2d");
            this.chart = new window.Chart(ctx, this.config);

            const totalRec = this.totalRecords;
            Chart.pluginService.register({
                afterDraw: function(chart) {
                    var width = chart.chart.width,
                        height = chart.chart.height,
                        ctx = chart.chart.ctx;
                    //ctx.restore();
                    ctx.font = "bolder 1.8rem Arial";
                    ctx.fillStyle = 'rgba(116,116,116,1)';
                    ctx.textBaseline = "middle";
                    var text = totalRec,
                        textX = Math.round((width - ctx.measureText(text).width) / 2),
                        textY = height / 2;
                    ctx.fillText(text, textX, textY);
                    ctx.save();
                    }
                });
        })
        .catch((error) => {
            console.log('Chart error :'+JSON.stringify(error));
            this.error = error;
        });
   },2500)

   Promise.all([loadScript(this, EngageCliq+'/JavaScript/ChartJs')])
           .then(() => {
               const ctx = this.template
                   .querySelector("canvas.donut")
                   .getContext("2d");
               this.chart = new window.Chart(ctx, this.config);

           })
           .catch((error) => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Error loading ChartJS",
                       message: error.message,
                       variant: "error",
                   })
               );
           });
}


    chart;
    chartjsInitialized = false;
    config = {
       type: "doughnut",
       data: {
           datasets: [
               {
                    backgroundColor: [
                    "rgb(238, 90, 74)",
                    "rgb(58, 133, 74)"
                    ],
               },
           ],
   },
    options: {
         legend: {
            display: false
         },
    },
};

   renderedCallback() {
       if (this.chartjsInitialized) {
           return;
       }
       this.chartjsInitialized = true;

   }

   updateChart(count, label) {
       this.chart.data.labels.push(label);
       this.chart.data.datasets.forEach((dataset) => {
           dataset.data.push(count);
       });
       this.chart.update();
   }

}