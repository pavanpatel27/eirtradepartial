import { LightningElement, api } from 'lwc';

export default class ProPurchaseOrderToPayableLine extends LightningElement {

    firstConnectedCallback = true;
    firstRenderedCallback = true;
    
    @api record;
    @api isEditable = false;
    @api currencySymbol;
    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Johnny in Prodigy on 06-04-2023.
    */
    connectedCallback() {
        if(! this.firstConnectedCallback ){ return; }

        this.firstConnectedCallback = false;      

        this.record = JSON.parse(JSON.stringify(this.record));
    }
    
    /*
    * Description: Fires after every render (re-render) of the component.
    *
    * Last modified by Johnny in Prodigy on 06-04-2023.
    */
    renderedCallback() {
        if(! this.firstRenderedCallback ){ return; }
        
        this.firstRenderedCallback = false;
    }
    
    /*
    * Description: Fires Toaster notification on the screen.
    *
    * Last modified by Johnny in Prodigy on 06-04-2023.
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
    * Last modified by Johnny in Prodigy on 06-04-2023.
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
    * Last modified by Johnny in Prodigy on 06-04-2023.
    */
    CloseComponent() {
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    /*
    * Description: Dispatches remove event to parent lwc.
    *
    * Last modified by Johnny in Prodigy on 06-04-2023.
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
    * Description: Dispatches update description event to parent lwc.
    *
    * Last modified by Johnny in Prodigy on 11-04-2023.
    */
    UpdateLineDescription(event) {

        var recordId = this.record.Id;
        var updatedDescription = event.currentTarget.value;

        this.dispatchEvent(
            new CustomEvent('descriptionupdate', {
                detail : {
                    itemId : recordId,
                    updatedDescription : updatedDescription
                }
            })
        );
    }

    /*
    * Description: Dispatches update line total event to lwc.
    *
    * Last modified by Johnny in Prodigy on 10-07-2023.
    */
    UpdateLineTotal(event) {

        var recordId = this.record.Id;

        var record = this.record;

        var data = event.currentTarget.dataset;
        var type = data.type;
        var value = event.currentTarget.value;

        if(type == 'quantity') {

            record.pro_Quantity__c = parseFloat(value, 10);
        } else {

            record.pro_Unit_Price__c = parseFloat(value, 10);
        }

        this.record = record;

        setTimeout(() => {
            this.template.querySelector('c-pro-custom-total-field[data-id="' + recordId + '"]').handleValueChange();
        }, 200);

        this.dispatchEvent(
            new CustomEvent('totalupdate', {
                detail : {
                    itemId : recordId,
                    type : type,
                    value : parseFloat(value, 10)
                }
            })
        );
    }
}