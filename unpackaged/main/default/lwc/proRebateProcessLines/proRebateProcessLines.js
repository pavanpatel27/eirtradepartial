import { LightningElement, api } from 'lwc';

import UpdateEndRange from '@salesforce/apex/Pro_RebateProcess_con.UpdateEndRange';
import UpdateBenefit from '@salesforce/apex/Pro_RebateProcess_con.UpdateBenefit';
import DeleteRecord from '@salesforce/apex/Pro_RebateProcess_con.DeleteRecord';

export default class ProRebateProcessLines extends LightningElement {

    firstConnectedCallback = true;
    firstRenderedCallback = true;
    
    @api record;
    
    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Finbar in Prodigy on 29/11/2023.
    */
    connectedCallback() {
        if(! this.firstConnectedCallback ){ return; }
        
        this.firstConnectedCallback = false;      

        this.record = JSON.parse(JSON.stringify(this.record));
    }
    
    /*
    * Description: Fires after every render of the component.
    *
    * Last modified by Finbar in Prodigy on 29/11/2023.
    */
    renderedCallback() {
        if(! this.firstRenderedCallback ){ return; }
        
        this.firstRenderedCallback = false;
    }
    
    /*
    * Description: Fires Toaster notification on the screen.
    *
    * Last modified by Finbar in Prodigy on 29/11/2023.
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
    * Description: Changes the end range in the database.
    *
    * Last modified by Finbar in Prodigy on 03/01/2024.
    */
    ChangeEndRange(evt){
        var newEndRange = evt.currentTarget.value;
        var recId = this.record.Id;

        this.dispatchEvent(
            new CustomEvent('endrangeupdate', {
                detail:{
                    recordId: recId,
                    endRange: newEndRange
                }
            })
        );

        UpdateEndRange({ 
            recordId: recId,
            range: newEndRange
        }).then(res =>{
            var data = JSON.parse( res );

            if( data.Result == false ){
                this.FireToaster("Could not update End Range", "Please contact  your system Admin", "error");
            }
        });
    }

    /*
    * Description: Changes the end range in the database.
    *
    * Last modified by Finbar in Prodigy on 03/01/2024.
    */
    ChangeBenefit(evt){
        var newPercentage = evt.currentTarget.value;
        var recId = this.record.Id;

        UpdateBenefit({ 
            recordId: recId,
            percentage: newPercentage
        }).then(res =>{
            var data = JSON.parse( res );

            if( data.Result == false ){
                this.FireToaster("Could not update Benefit", "Please contact  your system Admin", "error");
            }  
        });
    }

    /*
    * Description: Deletes Rebate Line record.
    *
    * Last modified by Finbar in Prodigy on 03/01/2024.
    */
    RemoveLine(){

        DeleteRecord({ 
            recordId : this.record.Id
        }).then(res =>{

            var data = JSON.parse( res );
            
            if( data.Result === false ){
                this.FireToaster("Could not delete line", "Please contact  your system Admin", "error");
            }
            if( data.Result === true){
                this.dispatchEvent(
                    new CustomEvent(
                        'refreshparent'
                    )
                );
            }
        });
    }
}