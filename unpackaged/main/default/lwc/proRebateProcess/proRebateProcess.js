import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import SeedData from '@salesforce/apex/Pro_RebateProcess_con.SeedData';
import CreateRecord from '@salesforce/apex/Pro_RebateProcess_con.CreateRecord';

/*
* Description: Sets a 'Last Record' property on the last line item to displat the buttons beside it.
*
* Last modified by Finbar in Prodigy on 03/01/2024.
*/
function UpdateProperties(list) {

    for(let i in list){
        list[i].LastRecord = false;
    }

    let lastIndex = list.length -1;

    if(lastIndex != -1){
        list[lastIndex].LastRecord = true;
    }

    return list;
}

export default class ProRebateProcess extends LightningElement {
    firstConnectedCallback = true;
    firstRenderedCallback = true;
    
    @api recordId;
    
    Rebate;
    RebateRates = [];
    
    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Finbar in Prodigy on 11/12/2023.
    */
    connectedCallback() {
        if(! this.firstConnectedCallback ){ return; }
        
        this.firstConnectedCallback = false;

        this.GetSeedData();
    }
    
    /*
    * Description: Fires after every render of the component.
    *
    * Last modified by Finbar in Prodigy on 11/12/2023.
    */
    renderedCallback() {
        if(! this.firstRenderedCallback ){ return; }
        
        this.firstRenderedCallback = false;
    }

    /*
    * Description: Refreshes when the rate is updated.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    RefreshRateData(evt) {
        let list = this.RebateRates;
        let lineId = evt.detail.recordId;
        let endRange = evt.detail.endRange;
        let idx = list.findIndex(x => x.Id === lineId);

        if(idx != -1){
            list[idx].pro_Range_End__c = endRange;

            this.RebateRates = UpdateProperties(list);
        }
    }

    /*
    * Description: Refreshes when the benefit is updated.
    *
    * Last modified by Finbar in Prodigy on 03/01/2024.
    */
    RefreshBenefitData(evt) {
        let list = this.RebateRates;
        let lineId = evt.detail.recordId;
        let benefit = evt.detail.benefit;

        console.log('benefit');
        console.log(benefit);
        let idx = list.findIndex(x => x.Id === lineId);

        if(idx != -1){
            list[idx].pro_Rebate_Percent__c = benefit;

            this.RebateRates = UpdateProperties(list);
        }
    }
    
    /*
    * Description: Fires Toaster notification on the screen.
    *
    * Last modified by Finbar in Prodigy on 28/11/2023.
    */
    FireToaster(title, message, variant) {
        var toast = {
            title: title,
            message: message,
            variant: variant
        };
        
        if( variant === 'error' ){
            toast.mode = "sticky";
        }
        
        this.dispatchEvent(
            new ShowToastEvent( toast )
        );
    }

    /*
    * Description: Method used to retrieve the data used to seed the LWC.
    *
    * Last modified by Finbar in Prodigy on 11/12/2023.
    */
    GetSeedData() {

        if(this.recordId) {

            this.RebateRates = [];
            
            SeedData({ 
                "recordId" : this.recordId 
            }).then(res => {

                if((res) && (res != '')) {
                    var data = JSON.parse(res);

                    this.Rebate = data.Rebate;
                    this.RebateRates = UpdateProperties(data.RebateRates);
                }
            });
        }
    }

    /*
    * Description: Creates a new record in the database when 'New Line' button is clicked, then updates list of records on UI.
    *
    * Last modified by Finbar in Prodigy on 03/01/2024.
    */
    CreateNewLine(){

        let lastRange = 0;

        if(this.RebateRates.length > 0 ){
            let index = this.RebateRates.length;
            
            let newIndex = index - 1;
            let lastNumber = this.RebateRates[ newIndex ];

            lastRange = lastNumber.pro_Range_End__c;
        }
    
        let tempObj = {
            "pro_Range_End__c": 0,
            "pro_Range_Start__c": lastRange,
            "pro_Rebate__c": this.Rebate.Id,
            "pro_Rebate_Percent__c": 0
        }

        var list = this.RebateRates;
        this.RebateRates = [];

        CreateRecord({ 
            record: tempObj
        }).then(res =>{

            var data = JSON.parse( res );

            if( data.Result == false ){
                this.FireToaster("Error creating new line.", "Please contact  your System Admin", "error");
            }
            if( data.Result == true){
                tempObj.Id = data.ErrorTitle;
                
                list.push( tempObj );
               
                this.RebateRates = UpdateProperties(list);

                this.GetSeedData();
            }
        });
    }

    /*
    * Description: Retrieves the most recent lines.
    *
    * Last modified by Finbar in Prodigy on 11/12/2023.
    */
    GetUpdatedLines() {
        this.GetSeedData();
    }
}