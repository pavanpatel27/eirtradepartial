import { LightningElement, api } from 'lwc';

export default class ProPromisedPaymentLine extends LightningElement {

    firstConnectedCallback = true;
    firstRenderedCallback = true;
    
    @api record;
    @api currencySymbol;
    
    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Johnny in Prodigy on 09-08-2023.
    */
    connectedCallback() {
        if(! this.firstConnectedCallback ){ return; }
        
        this.firstConnectedCallback = false;

        this.record = JSON.parse(JSON.stringify(this.record));
    }
    
    /*
    * Description: Fires after every render (re-render) of the component.
    *
    * Last modified by Johnny in Prodigy on 09-08-2023.
    */
    renderedCallback() {
        if(! this.firstRenderedCallback ){ return; }
        
        this.firstRenderedCallback = false;
    }
    
    /*
    * Description: Fires Toaster notification on the screen.
    *
    * Last modified by Johnny in Prodigy on 09-08-2023.
    */
    FireToaster(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: "sticky"
            })
        );
    }
    
    /*
    * Description: Updates the record page based on the record Id provided.
    *
    * Last modified by Johnny in Prodigy on 09-08-2023.
    */
    UpdateRecordPage(recordId) {
        
        updateRecord({ fields: { Id: recordId } });
    }
    
    /*
    * Description: Navigates to record page based on specified record Id and object api name.
    *
    * Last modified by Johnny in Prodigy on 09-06-2022.
    */
    NavigateToRecord(recordId, objectApiName) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                objectApiName: objectApiName,
                actionName: "view"
            }
        });
    }
    
    /*
    * Description: Closes the component (Used only for Quick Actions).
    *
    * Last modified by Johnny in Prodigy on 09-08-2023.
    */
    CloseComponent() {
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    /*
    * Description: Method used to dispatch the update comment event to the parent LWC.
    *
    * Last modified by Johnny in Prodigy on 15-08-2023.
    */
    UpdateLineComment(event) {

        var recordId = this.record.Id;
        var updatedComment = event.currentTarget.value;

        this.dispatchEvent(
            
            new CustomEvent('commentupdate', {
                detail : {
                    itemId : recordId,
                    updatedComment : updatedComment
                }
            })
        );
    }

    /*
    * Description: Dispatches a Remove event to the parent LWC.
    *
    * Last modified by Johnny in Prodigy on 10-08-2023.
    */
    RemoveLine() {

        var recordId = this.record.Id;

        this.dispatchEvent(

            new CustomEvent('itemremove', {
                detail : {
                    itemId : recordId
                }
            })
        );
    }

    /*
    * Description: Dispatches a Update Line value event to the parent LWC.
    *
    * Last modified by Johnny in Prodigy on 14-08-2023.
    */
    UpdateLineDate(event) {

        var recordId = this.record.Id;
        var dateValue = event.currentTarget.value;
        
        this.dispatchEvent(

            new CustomEvent('dateupdate', {
                detail : {
                    itemId : recordId,
                    updatedDate : dateValue
                }
            })
        );
    }

    /*
    * Description: Dispatches a Update Line value event to the parent LWC.
    *
    * Last modified by Johnny in Prodigy on 14-08-2023.
    */
    UpdateLineAmount(event) {

        var recordId = this.record.Id;
        var amountValue = event.currentTarget.value;

        this.dispatchEvent(

            new CustomEvent('amountupdate', {
                detail : {
                    itemId : recordId,
                    updatedAmount : amountValue
                }
            })
        );
    }
}