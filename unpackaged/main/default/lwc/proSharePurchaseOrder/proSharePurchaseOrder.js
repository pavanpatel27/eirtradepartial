import { api, LightningElement, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";

import SeedData from '@salesforce/apex/Pro_SharePdf_con.SeedData';
import SharePDF from '@salesforce/apex/Pro_SharePdf_con.SharePDF';

export default class ProSharePurchaseOrder extends LightningElement {

    @api recordId;

    firstConnectedCallback = true;
    firstRenderedCallback = true;

    frameHeight;
    frameUrl = "";
    recordId = "";
    currentRecord = {};
    emailBodyValue = "";
    emailSubjectValue = "";

    componentTitle;

    recipientEmailAddress;

    selectedToEmailAddress;
    selectedCCEmailAddress = "";
    selectedSenderEmailAddress;

    SendEmailButtonDisabled = false;

    listOfEmails = [];
    
    /*
    * Description: Fires when the URL is set or changes to capture the current PageReference.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    @wire(CurrentPageReference)
    params( pageRef ) {
        if( pageRef ) {

            this.recordId = pageRef.state.c__recordId;
        }
    }
    
    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    connectedCallback() {
        if(! this.firstConnectedCallback ){ return; }
        
        this.firstConnectedCallback = false;

        this.GetSeedData();
    }
    
    /*
    * Description: Fires after every render (re-render) of the component.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    renderedCallback() {
        if(! this.firstRenderedCallback ){ return; }
        
        this.firstRenderedCallback = false;

        this.setSpecialHeights();
    }
    
    /*
    * Description: Fires Toaster notification on the screen.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
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
    * Description: Handles any errors fired.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    HandleError(err, title) {
        console.log( err );
        
        if( err.body ){
            this.FireToaster(
                err.body.message,
                err.body.stackTrace,
                'error'
            );
        } else {
        
            this.FireToaster(
                title,
                ' ' + err,
                'error'
            );
        }
    }
    
    /*
    * Description: Updates the record page based on the record Id provided.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
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
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    CloseComponent() {
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    /*
    * Description: Sets height of elements on the page.
    *
    * Last modified by Johnny in Prodigy on 20-03-2023.
    */
    setSpecialHeights() {
        var screenSize = window.innerHeight - 150;
        
        var art01 = this.template.querySelector(".mySpecialArticle");
        var art02 = this.template.querySelector(".full_height");

        if( (screenSize !== -150) && (art01.style.height !== screenSize + "px") ){
            art01.style.height = screenSize + "px";
            art02.style.height = screenSize + "px";
            var offset = screenSize * 0.03;
            this.frameHeight = screenSize - offset;
        }

        setTimeout(() => {
            this.setSpecialHeights();
        }, 1000);
    }

    /*
    * Description: Shares the Purchase Order with the supplier.
    *
    * Last modified by Johnny in Prodigy on 20-03-2023.
    */
    SharePurchaseOrder(){
        var recId = this.recordId;
        var body1 = this.template.querySelector('[data-var="myBody"]');
        var emailBody = body1.value;
        var subject  = this.emailSubjectValue;
        var recipientAddress = this.selectedToEmailAddress;
        var senderAddress = this.selectedSenderEmailAddress;
        var ccAddresses = this.selectedCCEmailAddress;

        if( (emailBody != '') && (subject != '') && (recipientAddress != '') && (senderAddress != '') ){
            this.template.querySelector("button[data-id='proUniqueButton']").disabled = true;

            SharePDF({ recipientEmailAddress: recipientAddress, senderEmailAddress: senderAddress, ccEmailAddresses:  ccAddresses, emailSubject: subject, emailBody: emailBody, recordId: recId }).then( res => {
                
                if( res ){
                    this.FireToaster( "Purchase Order Shared Successfully", "Purchase has been shared with supplier", "success" );

                    this.template.querySelector("button[data-id='proUniqueButton']").disabled = false;

                } else{
                    this.FireToaster( "Something went wrong", "Please contact your admin for more information", "error" );

                    this.template.querySelector("button[data-id='proUniqueButton']").disabled = false;
                }
            });
        } else {
            this.FireToaster( "Missing Fields", "To Address, Sender Address, Subject and Email Body are all required for sharing the PO with the Supplier", "warning" );
        }
    }

    /*
    * Description: Gets the Seed Data from the controller class.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    GetSeedData() {
        
        if( this.recordId ){
            this.FireToaster(
                'Data Loading',
                'Please wait...',
                'info'
            );

            SeedData({
                "recordID" : this.recordId
            }).then(res => {
                if(res) {
                    var data = JSON.parse(res);

                    var url = data.orgUrl;
                    var record = data.record;
                    var isShareable = data.userCanSharePO;
                    var subject = data.emailSubject;
                    var emailBody = data.emailBody;

                    this.recordId = record.Id;
                    this.componentTitle = record.Name;
                    this.frameUrl = url + "/apex/Pro_PurchaseOrderPDF?id=" + record.Id + "&savePDF=" + record.Id;

                    if(isShareable == false) {

                        this.SendEmailButtonDisabled = true;
                        this.template.querySelector("button[data-id='proUniqueButton']").disabled = true;
                        this.FireToaster("Purchase Order not Shareable",
                            "This record has not been approved yet.",
                            "warning");
                    }

                    var temp = JSON.parse(data.listOfEmails);

                    this.listOfEmails = temp;
                    this.selectedSenderEmailAddress = temp[0];
                    this.selectedToEmailAddress = record.pro_Supplier_Email_Address__c;
                    this.emailBodyValue = emailBody;
                    this.template.querySelector('[data-var="myBody"]').value = emailBody;
                    this.emailSubjectValue = subject;
                }
            }).catch( err => {
                if( err ){
                    this.HandleError(err, 'An error occurred while retrieving data from the Database');
                }
            });
        }
    }

    /*
    * Description: Sets the value of the Email's subject .
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    ChangeEmailSubjectvalue(evt){
        this.emailSubjectValue = evt.target.value;
    }

    /*
    * Description: Sets the Sender's Email Address.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    SetSenderEmailAddress(event) {
        this.selectedSenderEmailAddress = event.target.value;
    }

    /*
    * Description: Sets the Recipient's Email Address.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    SetRecipientEmailAddress(event) {
        this.selectedToEmailAddress = event.target.value;
    }

    /*
    * Description: Sets the CC Email Addresses.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    SetCCEmailAddress(event) {
        this.selectedCCEmailAddress = event.target.value;
    }
}