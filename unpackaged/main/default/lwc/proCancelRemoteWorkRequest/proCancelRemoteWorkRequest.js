import { LightningElement, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { updateRecord } from 'lightning/uiRecordApi';

import CancelRemoteWorkRequest from '@salesforce/apex/Pro_CancelRemoteWorkRequest_con.CancelRemoteWorkRequest';

export default class ProCancelRemoteWorkRequest extends LightningElement {
    firstConnectedCallback = true;
    firstRenderedCallback = true;

    @api recordId;
    
    /*
    * Description: Fires when the URL is set or changes to capture the current PageReference.
    *
    * Last modified by Finbar in Prodigy on 19/10/2023.
    */
    @wire(CurrentPageReference)
    params( pageRef ) {
        if( pageRef ) {
            this.recordId = pageRef.state.recordId;
        }
    }
    
    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Finbar in Prodigy on 19/10/2023.
    */
    connectedCallback() {
        if(! this.firstConnectedCallback ){ return; }
        
        this.firstConnectedCallback = false;
    }
    
    /*
    * Description: Fires after every render (re-render) of the component.
    *
    * Last modified by Finbar in Prodigy on 19/10/2023.
    */
    renderedCallback() {
        if(! this.firstRenderedCallback ){ return; }
        
        this.firstRenderedCallback = false;
    }
    
    /*
    * Description: Fires Toaster notification on the screen.
    *
    * Last modified by Finbar in Prodigy on 19/10/2023.
    */
    FireToaster(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }
    
    /*
    * Description: Updates the record page based on the record Id provided.
    *
    * Last modified by Finbar in Prodigy on 19/10/2023.
    */
    UpdateRecordPage(recordId) {
        
        updateRecord({ fields: { Id: recordId } });
    }

    /*
    * Description: Are you sure pop up.
    *
    * Last modified by Finbar in Prodigy on 19/10/2023.
    */
    Cancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /*
    * Description: Cancels time Off request.
    *
    * Last modified by Finbar in Prodigy on 19/10/2023.
    */
    Recall() {
        CancelRemoteWorkRequest( { recordId: this.recordId } ).then( res => {
            if( res == true ){
                this.FireToaster( 'Success', 'Remote Work Request cancelled successfully', 'success' );
                this.dispatchEvent(new CloseActionScreenEvent());

                setTimeout(() => {
                    this.refreshPage();
                }, 3000);

                
            }else{
                this.FireToaster( 'Something went wrong', 'Please contact system admin for more information', 'error' );
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        } )
    }

    /*
    * Description: Method used to navigate the user back to the Account Record Page.
    *
    * Last modified by Finbar in Prodigy on 19/10/2023.
    */
    refreshPage() {
        location.reload();
    }
}