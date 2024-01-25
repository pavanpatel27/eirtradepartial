import { LightningElement, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";

import SearchRecordsDynamic from '@salesforce/apex/Pro_CustomLookupField_con.SearchRecordsDynamic';

export default class ProCustomLookupFieldDynamic extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api gtPlaceHolder;
    @api searchFields;
    @api searchCriteria;
    @api selectedRecordName;
    @api selectedRecordId;
    @api fieldLabel;
    @api notChangeable;
    @api iconName;
    @api navigable;

    firstConnectedCallback = true;

    isBlank = true;
    listOfRecords = [];

    noResultsFound = false;
    showResults = false;

    blankLabel = false;

    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    connectedCallback(){
        if(! this.firstConnectedCallback ){ return; }

        this.firstConnectedCallback = false;

        if( this.selectedRecordName ){ this.isBlank = false; }

        if( this.fieldLabel == "" || this.fieldLabel == null ) { this.blankLabel = true; }

        if( this.notChangeable == null ){ this.notChangeable = false; }

        if( this.iconName == null ){ this.iconName = "standard:reward"; }

        if( this.navigable == null || this.navigable == "" ){ this.navigable = false; }
    }

    /*
    * Description: Fires after every render of the component.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    renderedCallback(){
        if( this.selectedRecordName ){ this.isBlank = false; }
    }

    /*
    * Description: Searches for records based on search value.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    handleChange(evt){
        var val = evt.target.value;

        var localThis = this;

        this.listOfRecords = [];

        if( (val != '') && (val.length > 2) ){
            SearchRecordsDynamic({ searchValue: val, objectApiName: this.objectApiName, searchFields: this.searchFields, searchCriteria: this.searchCriteria }).then(res => {
                if( res != '' ){
                    var temp = JSON.parse(res);

                    localThis.noResultsFound = false;
                    localThis.showResults = true;
                    localThis.listOfRecords = temp;
                } else { 

                    localThis.noResultsFound = true;
                    localThis.showResults = true;
                    localThis.listOfRecords = [];
                }
            });

        } else {

            localThis.listOfRecords = [];
            localThis.showResults = false;
        }
    }

    /*
    * Description: Fires when a product is selected.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    glSelectItem(evt){
        var itemId = evt.currentTarget.dataset.ind;

        var tempList = this.listOfRecords;

        var idx = tempList.findIndex(x => x.Value === itemId );

        if( idx != -1 ){
            var record = tempList[idx];

            this.noResultsFound = false;
            this.showResults = false;
            this.isBlank = false;

            this.selectedRecordId = record.Value;
            this.selectedRecordName = record.Label;

            const myEvent = new CustomEvent('itemselection', {
                detail: { recordName: record.Label, recordId: record.Value }
            });
            this.dispatchEvent(myEvent);
        }
    }

    /*
    * Description: Fire whenever the Lightning Pill 'Remove' is clicked.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    pillRemove(){
        this.isBlank = true;

        this.selectedRecordId = "";
        this.selectedRecordName = "";

        const myEvent = new CustomEvent('itemremoval', {
            detail: { itemRemoved: true }
        });
        this.dispatchEvent(myEvent);
    }

    /*
    * Description: Fires when input field loses focus.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    blurResults(evt){
        this.showResults = false;
    }

    /*
    * Description: Navigate to specified record.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    NavigateToRecord() {
        if( (this.selectedRecordId) && (this.objectApiName) ){
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.selectedRecordId,
                    objectApiName: this.objectApiName,
                    actionName: "view"
                }
            });
        }
    }

    /*
    * Description: Refreshes the component.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    @api refreshComponent() {
        this.isBlank = true;

        this.selectedRecordId = "";
        this.selectedRecordName = "";
    }

}