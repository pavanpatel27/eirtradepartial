import { api, LightningElement, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";

import SeedData from '@salesforce/apex/Pro_SharePdf_con.SeedData';
import SharePDF from '@salesforce/apex/Pro_SharePdf_con.SharePDF';
import SavePDF from '@salesforce/apex/Pro_SharePdf_con.SavePDF';

export default class ProShareVendorRemittance extends NavigationMixin(LightningElement) {

    firstConnectedCallback = true;
    firstRenderedCallback = true;
    
    @api recordId;

    frameHeight;
    frameUrl = "";
    recordId = "";
    currentRecord = {};
    emailBodyValue = "";
    emailSubjectValue = "";
    recordType = "";
    visualforcePage = "";
    recordName = "";

    componentTitle;

    recipientEmailAddress;

    selectedToEmailAddress;
    selectedCCEmailAddress = "";
    selectedSenderEmailAddress;

    SendEmailButtonDisabled = false;

    listOfEmails = [];

    IconName = "";
    
    /*
    * Description: Fires when the URL is set or changes to capture the current PageReference.
    *
    * Last modified by Johnny in Prodigy on 24-03-2023.
    */
    @wire(CurrentPageReference)
    params( pageRef ) {
        if( pageRef ) {

            this.recordId = pageRef.state.c__recordId;

            this.GetSeedData();
        }
    }
    
    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Johnny in Prodigy on 24-03-2023.
    */
    connectedCallback() {
        if(! this.firstConnectedCallback ){ return; }
        
        this.firstConnectedCallback = false;
        
    }
    
    /*
    * Description: Fires after every render (re-render) of the component.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    renderedCallback() {
        if(! this.firstRenderedCallback ){ return; }
        
        this.firstRenderedCallback = false;

        this.setSpecialHeights();
    }
    
    /*
    * Description: Fires Toaster notification on the screen.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
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
    * Last modified by Johnny in Prodigy on 23-03-2023.
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
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    UpdateRecordPage(recordId) {
        
        updateRecord({ fields: { Id: recordId } });
    }
    
    /*
    * Description: Navigates to record page based on specified record Id and object api name.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
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
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    CloseComponent() {
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    /*
    * Description: Sets height of elements on the page.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
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
    * Description: Shares the record with the supplier.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    ShareRecord(){
        var recId = this.recordId;
        var body1 = this.template.querySelector('[data-var="myBody"]');
        var emailBody = body1.value;
        var subject  = this.emailSubjectValue;
        var recipientAddress = this.selectedToEmailAddress;
        var senderAddress = this.selectedSenderEmailAddress;
        var ccAddresses = this.selectedCCEmailAddress;
        var recordType = this.recordType;

        if( (emailBody != '') && (subject != '') && (recipientAddress != '') && (senderAddress != '') ){
            this.template.querySelector("button[data-id='proShareButton']").disabled = true;

            SharePDF({ recipientEmailAddress: recipientAddress, senderEmailAddress: senderAddress, ccEmailAddresses:  ccAddresses, emailSubject: subject, emailBody: emailBody, recordId: recId }).then( res => {
                
                if( res ){
                    this.FireToaster( recordType + " Shared Successfully", recordType + " has been shared with the relevant parties", "success" );

                    this.template.querySelector("button[data-id='proShareButton']").disabled = false;

                } else{
                    this.FireToaster( "Something went wrong", "Please contact your admin for more information", "error" );

                    this.template.querySelector("button[data-id='proShareButton']").disabled = false;
                }
            });
        } else {
            this.FireToaster( "Missing Fields", "To Address, Sender Address, Subject and Email Body are all required for sharing the PDF with the relevant parties", "warning" );
        }
    }

    /*
    * Description: Saves the PDF to the record.
    *
    * Last modified by Johnny in Prodigy on 24-03-2023.
    */
    SavePDF() {

        var recordId = this.recordId;

        this.template.querySelector("button[data-id='proSaveButton']").disabled = true;

        SavePDF({recordId : recordId}).then( res =>{

            if(res) {

                var data = JSON.parse(res);

                var result = data.Result;
                var resultType = data.Type;
                var resultTitle = data.ErrorTitle;
                var resultMessage = data.ErrorMessage;
                var recordType = this.recordType;


                if(result = true) {

                    this.FireToaster(
                        "PDF Saved Successfully",
                        recordType + " PDF has been saved successfully",
                        "success"
                    );

                    this.template.querySelector("button[data-id='proSaveButton']").disabled = false;
                } else {

                    this.FireToaster(
                        "PDF Failed to Save",
                        resultMessage,
                        "error"
                    );

                    this.template.querySelector("button[data-id='proSaveButton']").disabled = false;
                }
            } else {

                this.FireToaster( "Something went wrong", "Please contact your admin for more information", "error" );

                this.template.querySelector("button[data-id='proSaveButton']").disabled = false;
            }
        }).catch( err => {

            if(err) {

                this.HandleError(err, 'An error has occured whilst attempting to save the PDF to the record');
            }
        });
    }

    /*
    * Description: Gets the Seed Data from the controller class.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
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
                    var recordType = data.recordType;
                    var visualforcePage = data.visualforcePage;
                    var recordName = data.record.Name;

                    this.recordId = record.Id;
                    this.componentTitle = recordType;
                    this.frameUrl = url + "/apex/" + visualforcePage + "?id=" + record.Id + "&savePDF=" + record.Id;

                    if(recordType == 'Purchase Order') {

                        this.IconName = 'custom:custom16';
                    } else {

                        this.IconName = 'custom:custom41';
                    }

                    if(isShareable == false) {

                        this.SendEmailButtonDisabled = true;
                        this.template.querySelector("button[data-id='proShareButton']").disabled = true;
                        this.FireToaster(recordType + " not Shareable",
                            "This record has not been approved yet.",
                            "warning");
                    }

                    var temp = JSON.parse(data.listOfEmails);

                    this.listOfEmails = temp;
                    this.selectedSenderEmailAddress = temp[0];
                    this.selectedToEmailAddress = record.pro_Supplier_Email_Address__c;
                    this.selectedCCEmailAddress = record.pro_Supplier_CC_Email_Address__c;
                    this.emailBodyValue = emailBody;
                    this.template.querySelector('[data-var="myBody"]').value = emailBody;
                    this.emailSubjectValue = subject;
                    this.recordName = recordName;
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
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    ChangeEmailSubjectvalue(evt){
        this.emailSubjectValue = evt.target.value;
    }

    /*
    * Description: Sets the Sender's Email Address.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    SetSenderEmailAddress(event) {
        this.selectedSenderEmailAddress = event.target.value;
    }

    /*
    * Description: Sets the Recipient's Email Address.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    SetRecipientEmailAddress(event) {
        this.selectedToEmailAddress = event.target.value;
    }

    /*
    * Description: Sets the CC Email Addresses.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    SetCCEmailAddress(event) {
        this.selectedCCEmailAddress = event.target.value;
    }

    /*
    * Description: Navigates back to the record.
    *
    * Last modified by Johnny in Prodigy on 06-04-2023.
    */
    NavigateBack(event) {

        var recordType = this.recordType;
        var objectApiName;

        if(recordType == 'Purchase Order') {

            objectApiName = 'pro_Purchase_Order__c';
        } else {

            objectApiName = 'AcctSeed__Cash_Disbursement__c';
        }

        this.NavigateToRecord(this.recordId, objectApiName);
    }
}