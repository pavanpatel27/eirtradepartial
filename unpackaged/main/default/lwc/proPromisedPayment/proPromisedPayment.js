import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';

import BillingObject from '@salesforce/schema/AcctSeed__Billing__c';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';

import SeedData from '@salesforce/apex/Pro_PromisedPayment_con.SeedData';
import SaveBillings from '@salesforce/apex/Pro_PromisedPayment_con.SaveBillings';

/*
* Description: Method used to ensure that all the relevant fields have been populated.
*
* Last modified by Johnny in Prodigy on 22-08-2023.
*/
function CheckFields(recordList) {

    var result = true;

    for(let i = 0; i < recordList.length; i++) {

        if((recordList[i].pro_PP_Amount__c == null) || (recordList[i].pro_PP_Amount__c === 0)) {

            result = false;
        }

        if((recordList[i].pro_PP_Comment__c == null) || (recordList[i].pro_PP_Amount__c === undefined)) {

            result = false;
        }

        if((recordList[i].pro_PP_Date__c == null) || (recordList[i].pro_PP_Date__c === undefined)) {

            result = false;
        }
    }

    return result;
}

export default class ProPromisedPayment extends LightningElement {

    firstConnectedCallback = true;
    firstRenderedCallback = true;

    /*
    *
    * -- Section: Properties
    * 
    */

    SelectedBillingRecords = [];
    ChangedBillingRecords = [];
    CurrencySymbol = "";

    /*
    *
    * -- Section: Titles, Icons and Field Labels
    * 
    */

    BillingIcon = "";
    BillingTitle = "";
    BillingNameLabel = "";
    BillingBalanceLabel = "";
    BillingPPDateLabel = "";
    BillingPPAmountLabel = "";
    BillingPPCommentDateLabel = "";
    BillingPPCommentLabel = "";
    BillingPONumberLabel = "";
    BillingBillingDateLabel = "";
    
    @api recordId;

    objectApiNames = [BillingObject];

    /*
    * Description: Method used to retrieve and set the titles, field labels and icons.
    *
    * Last modified by Johnny in Prodigy on 09-08-2023.
    */
    @wire(getObjectInfos, {objectApiNames : '$objectApiNames'})
    LabelInfo({data, error}) {

        if(data) {

            var objectArray = data.results;
            var billingResult = objectArray[0].statusCode;

            if(billingResult == 200) {

                var fields = objectArray[0].result.fields;

                this.BillingIcon = 'custom:custom42';
                this.BillingTitle = 'Billing';

                this.BillingNameLabel = fields.Name.label;
                this.BillingBalanceLabel = fields.AcctSeed__Balance__c.label;
                this.BillingPPDateLabel = fields.pro_PP_Date__c.label;
                this.BillingPPAmountLabel = fields.pro_PP_Amount__c.label;
                this.BillingPPCommentLabel = fields.pro_PP_Comment__c.label;
                this.BillingPONumberLabel = fields.AcctSeed__PO_Number__c.label;
                this.BillingBillingDateLabel = fields.AcctSeed__Date__c.label;
            }
        }

        if(error) {

            if(error.body) {

                var body = error.body;

                this.FireToaster(
                    body.message,
                    body.stackTrace,
                    'error'
                );
            } else {

                this.FireToaster(
                    'An error occured whilst setting the labels for the page',
                    ' ' + error,
                    'error'
                );
            }
        }
    }

    /*
    * Description: Fires when the URL is set or changes to capture the current PageReference.
    *
    * Last modified by Johnny in Prodigy on 21-08-2023.
    */
    @wire(CurrentPageReference)
    params( pageRef ) {

        if( pageRef ) {
            
            this.SelectedBillingRecords = [];
            this.ChangedBillingRecords = [];
            this.recordId = pageRef.state.recordId;

            this.GetSeedData();
        }
    }
    
    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Johnny in Prodigy on 08-08-2023.
    */
    connectedCallback() {
        if(! this.firstConnectedCallback ){ return; }
        
        this.firstConnectedCallback = false;
    }
    
    /*
    * Description: Fires after every render (re-render) of the component.
    *
    * Last modified by Johnny in Prodigy on 08-08-2023.
    */
    renderedCallback() {
        if(! this.firstRenderedCallback ){ return; }
        
        this.firstRenderedCallback = false;
    }
    
    /*
    * Description: Fires Toaster notification on the screen.
    *
    * Last modified by Johnny in Prodigy on 08-08-2023.
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
    * Last modified by Johnny in Prodigy on 08-08-2023.
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
    * Last modified by Johnny in Prodigy on 08-08-2023.
    */
    CloseComponent() {
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    /*
    * Description: Method used to Save the changes made to the Billing records.
    *
    * Last modified by Johnny in Prodigy on 22-08-2023.
    */
    SaveUpdates() {

        var recordList = this.ChangedBillingRecords;
        var checkerVar = CheckFields(recordList);

        var jsonString = JSON.stringify(recordList);

        if(checkerVar === false) {

            this.FireToaster('Fields missing value',
                'Please ensure that all Promised Payment fields have been populated',
                'warning');
        } else {

            SaveBillings({ "incomingRecords" : jsonString}).then(result => {

                if((result) && (result != '')) {

                    var data = JSON.parse(result);

                    if(data === true) {

                        this.FireToaster('Billings have been updated',
                        'The Billing records have been updated with the Promised Payment information',
                        'success');
                    } else {

                        this.FireToaster('Billings failed to update',
                        'The Billing records could not be updated with the Promised Payment information',
                        'error');
                    }
                } else{

                    this.FireToaster('Unable to update Promised Payment fields on the relevant Billings',
                    'Result from controller was blank',
                    'error');
                }
            })
        }
    }

    /*
    * Description: Method used to retrieve the data used to seed the LWC.
    *
    * Last modified by Johnny in Prodigy on 18-08-2023.
    */
    GetSeedData() {

        if(this.recordId) {

            SeedData({ "recordId" : this.recordId }).then(result => {

                if((result) && (result != '')) {

                    var data = JSON.parse(result);
                    var hasAccess = data.hasAccess;

                    if(hasAccess === true) {

                        this.SelectedBillingRecords = data.billingList;
                    } else {

                        this.FireToaster("Insufficient Access",
                            "You do not have the required access to perform this action.",
                            "warning");
                    }
                }
            });
        }
    }

    /*
    * Description: Method used to navigate the user back to the Account Record Page.
    *
    * Last modified by Johnny in Prodigy on 09-08-2023.
    */
    NavigateBackToAccount() {

        var recordId = this.recordId;
        var objectApiName = 'Account';

        this.NavigateToRecord(recordId, objectApiName);
    }

    /*
    * Description: Method used to remove the Billig that triggered the event from the Selection of Billing Records.
    *
    * Last modified by Johnny in Prodigy on 21-08-2023.
    */
    RemoveItem(event) {

        var itemId = event.detail.itemId;

        var list = this.SelectedBillingRecords;
        var chosenList = this.ChangedBillingRecords;

        var indexVar = list.findIndex(x => x.Id === itemId);
        var chosenIndexVar = chosenList.findIndex(x => x.Id === itemId);

        if(indexVar != -1) {

            list.splice(indexVar, 1);

            this.SelectedBillingRecords = [];
            this.SelectedBillingRecords = list;
        } 

        if(chosenIndexVar != -1) {

            chosenList.splice(chosenIndexVar, 1);

            this.ChangedBillingRecords = [];
            this.ChangedBillingRecords = chosenList;
        }
    }

    /*
    * Description: Method used to update the Promised Payment Comment on the Billing record.
    *
    * Last modified by Johnny in Prodigy on 21-08-2023.
    */
    UpdateComment(event) {

        var itemId = event.detail.itemId;
        var updatedComment = event.detail.updatedComment;

        var list = this.SelectedBillingRecords;
        var chosenList = this.ChangedBillingRecords;

        var indexVar = list.findIndex(x => x.Id === itemId);
        var chosenIndexVar = chosenList.findIndex(x => x.Id === itemId);

        if(indexVar != -1) {

            list[indexVar].pro_PP_Comment__c = updatedComment;
            this.SelectedBillingRecords = list;
        }

        if(chosenIndexVar != -1) {

            chosenList[chosenIndexVar].pro_PP_Comment__c = updatedComment;
            this.ChangedBillingRecords = chosenList;
        } else {

            list[indexVar].pro_PP_Comment__c = updatedComment;
            chosenList.push(list[indexVar]);
            this.ChangedBillingRecords = chosenList;
        }
    }

    /*
    * Description: Method used to update the Promised Payment Date on the Billing Record.
    *
    * Last modified by Johnny in Prodigy on 21-08-2023.
    */
    UpdateDate(event) {

        var itemId = event.detail.itemId;
        var updatedDate = event.detail.updatedDate;

        var list = this.SelectedBillingRecords;
        var indexVar = list.findIndex(x => x.Id === itemId);

        var chosenList = this.ChangedBillingRecords;
        var chosenIndexVar = chosenList.findIndex(x => x.Id === itemId);

        if(indexVar != -1) {

            list[indexVar].pro_PP_Date__c = updatedDate;
            this.SelectedBillingRecords = list;
        }

        if(chosenIndexVar != -1) {

            chosenList[chosenIndexVar].pro_PP_Date__c = updatedDate;
            this.ChangedBillingRecords = chosenList;
        } else {

            list[indexVar].pro_PP_Date__c = updatedDate;
            chosenList.push(list[indexVar]);
            this.ChangedBillingRecords = chosenList;
        }
    }

    /*
    * Description: Method used to update the Promised Payment Amount on the Billing Record.
    *
    * Last modified by Johnny in Prodigy on 21-08-2023.
    */
    UpdateAmount(event) {

        var itemId = event.detail.itemId;
        var updatedAmount = event.detail.updatedAmount;

        var list = this.SelectedBillingRecords;
        var indexVar = list.findIndex(x => x.Id === itemId);

        var chosenList = this.ChangedBillingRecords;
        var chosenIndexVar = chosenList.findIndex(x => x.Id === itemId);

        if(indexVar != -1) {

            list[indexVar].pro_PP_Amount__c = updatedAmount;
            this.SelectedBillingRecords = list;
        }

        if(chosenIndexVar != -1) {

            chosenList[indexVar].pro_PP_Amount__c = updatedAmount;
            this.ChangedBillingRecords = chosenList;
        } else {

            list[indexVar].pro_PP_Amount__c = updatedAmount;
            chosenList.push(list[indexVar]);
            this.ChangedBillingRecords = chosenList;
        }
    }

    /*
    * Description: Method used to close the Lightning Web Component.
    *
    * Last modified by Johnny in Prodigy on 15-08-2023.
    */
    CloseLWC() {

        this.dispatchEvent(new CloseActionScreenEvent());
    }
}