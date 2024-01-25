import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";

import PayableLineObject from '@salesforce/schema/AcctSeed__Account_Payable_Line__c';
import PayableObject from '@salesforce/schema/AcctSeed__Account_Payable__c';
import PurchaseOrderLineObject from '@salesforce/schema/pro_Purchase_Order_Line__c';
import PurchaseOrderObject from '@salesforce/schema/pro_Purchase_Order__c';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';

import SeedData from '@salesforce/apex/Pro_PurchaseOrderToPayable_con.SeedData';
import CreatePayableRecord from '@salesforce/apex/Pro_PurchaseOrderToPayable_con.CreatePayableRecord';

    /*
    *
    * -- Section: Function
    *
    */

    /*
    * Description: Converts a Payable Line to a New Payable Line.
    *
    * Last modified by Johnny in Prodigy on 10-07-2023.
    */
    function ConvertToNewPayableLine(lineItem) {

        var newLine = {

            "AcctSeed__Product__c": lineItem.pro_Product__c,
            "AcctSeed__Invoice_Comment__c" : lineItem.pro_Comment__c,
            "AcctSeed__Quantity__c" : lineItem.pro_Quantity__c,
            "AcctSeed__Unit_Cost__c" : lineItem.pro_Unit_Price__c,
            "pro_Purchase_Order_Line__c" : lineItem.Id,
            "AcctSeed__Expense_GL_Account__c" : lineItem.pro_Expense_GL_Account__c,
            "Comments__c" : lineItem.pro_Comment__c
        }

        return newLine;
    }


export default class ProPurchaseOrderToPayable extends NavigationMixin(LightningElement) {

    firstConnectedCallback = true;
    firstRenderedCallback = true;

    /*
    *
    * -- Section: Properties
    *
    */

    PurchaseOrder = {};
    PurchaseOrderLines = [];
    PurchaseOrderName = "";
    PurchaseOrderSupplier = "";
    PurchaseOrderLedger = "";
    PurchaseOrderDate = "";
    PurchaseOrderReference = "";
    PurchaseOrderTotal = "";

    PayableReference = "";

    SelectedPurchaseOrderLines = [];

    PostingDate = "";
    IssueDate = "";
    TotalAPAmount = "";
    DueDate = "";

    OutstandingAmount = 0;

    CurrencySymbol = "";

    PurchaseOrderIcon = "";
    PurchaseOrderTitle = "";

    PayableIcon = "";
    PayableTitle = "";

    /*
    *
    * -- Section: Field Labels
    *
    */

    //Payable Line Field Labels
    PayableLineQuantityLabel = "";
    PayableLineUnitPriceLabel = "";
    PayableLineProductLabel = "";
    PayableLineDescriptionLabel = "";
    PayableLineTotalAmountLabel = "";

    //Purchase Order Line Field Labels
    PurchaseOrderLineQuantityLabel = "";
    PurchaseOrderLineUnitPriceLabel = "";
    PurchaseOrderLineProductLabel = "";
    PurchaseOrderLineDescriptionLabel = "";
    PurchaseOrderLineTotalAmountLabel = "";

    //Purchase Order Field Labels
    PurchaseOrderSupplierLabel = "";
    PurchaseOrderReferenceLabel = "";
    PurchaseOrderDateLabel = "";
    PurchaseOrderLedgerLabel = "";
    PurchaseOrderTotalLabel = "";
    PurchaseOrderAPTotalLabel = "";

    //Payable Field Labels
    PayablePostingDateLabel = "";
    PayableReferenceLabel = "";
    PayableIssueDateLabel = "";
    
    @api recordId;

    objectApiNames = [PayableLineObject, PayableObject, PurchaseOrderLineObject, PurchaseOrderObject];
    
    /*
    * Description: Retrieves and sets the field labels of the retrieved objects.
    *
    * Last modified by Johnny in Prodigy on 29-03-2023.
    */
    @wire(getObjectInfos, {objectApiNames : '$objectApiNames'})
    LabelInfo({data, error}) {

        if(data) {

            var objectArray = data.results;

            //Payable Line Object field labels
            var result1 = objectArray[0].statusCode;
            //Payable Object field labels
            var result2 = objectArray[1].statusCode;
            //Purchase Order Line Object field labels
            var result3 = objectArray[2].statusCode;
            //Purchase Order Object field labels
            var result4 = objectArray[3].statusCode;

            //Payable Line
            if(result1 == 200) {

                var fields = objectArray[0].result.fields;

                this.PayableLineQuantityLabel = fields.AcctSeed__Quantity__c.label;
                this.PayableLineTotalAmountLabel = fields.AcctSeed__Amount__c.label;
                this.PayableLineUnitPriceLabel = fields.AcctSeed__Unit_Cost__c.label;
                this.PayableLineProductLabel = fields.AcctSeed__Product__c.label;
                this.PayableLineDescriptionLabel = fields.AcctSeed__Invoice_Comment__c.label;
            }

            //Payable
            if(result2 == 200) {

                var fields = objectArray[1].result.fields;

                this.PayableReferenceLabel = fields.AcctSeed__Payee_Reference__c.label;
                this.PayableIssueDateLabel = fields.AcctSeed__Date__c.label;
            }

            //Purchase Order Line
            if(result3 == 200) {

                var fields = objectArray[2].result.fields;

                this.PurchaseOrderLineQuantityLabel = fields.pro_Quantity__c.label;
                this.PurchaseOrderLineTotalAmountLabel = fields.pro_Total_Amount__c.label;
                this.PurchaseOrderLineUnitPriceLabel = fields.pro_Unit_Price__c.label;
                this.PurchaseOrderLineProductLabel = fields.pro_Product__c.label;
                this.PurchaseOrderLineDescriptionLabel = fields.pro_Comment__c.label;
            }

            //Purchase Order
            if(result4 == 200) {

                var fields = objectArray[3].result.fields;

                this.PurchaseOrderSupplierLabel = fields.pro_Supplier_Account__c.label;
                this.PurchaseOrderDateLabel = fields.pro_Purchase_Order_Date__c.label;
                this.PurchaseOrderLedgerLabel = fields.pro_Ledger_Lookup__c.label;
                this.PurchaseOrderTitle = 'Purchase Order - Overhead';
                this.PurchaseOrderIcon = 'custom:custom16';
                this.PurchaseOrderTotalLabel = 'Total Amount';

                if(this.PurchaseOrderLedgerLabel == null) {

                    this.PurchaseOrderLedgerLabel = 'Ledger';
                }
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
    * Last modified by Johnny in Prodigy on 04-04-2023.
    */
    @wire(CurrentPageReference)
    params( pageRef ) {

        if( pageRef ) {
            this.SelectedPurchaseOrderLines = [];
            this.PurchaseOrderLines = [];

            this.recordId = pageRef.state.c__recordId;

            this.GetSeedData();
        }
    }
    
    /*
    * Description: Fires when a component is inserted into the DOM.
    *
    * Last modified by Johnny in Prodigy on 27-03-2023.
    */
    connectedCallback() {
        if(! this.firstConnectedCallback ){ return; }
        
        this.firstConnectedCallback = false;
    }
    
    /*
    * Description: Fires after every render (re-render) of the component.
    *
    * Last modified by Johnny in Prodigy on 31-03-2023.
    */
    renderedCallback() {
        if(! this.firstRenderedCallback ){ return; }
        
        this.firstRenderedCallback = false;

        this.SetHeights();
    }
    
    /*
    * Description: Fires Toaster notification on the screen.
    *
    * Last modified by Johnny in Prodigy on 27-03-2023.
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
    * Last modified by Johnny in Prodigy on 27-03-2023.
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
    * Last modified by Johnny in Prodigy on 27-03-2023.
    */
    CloseComponent() {
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    /*
    * Description: Retrieves Seed Data from the Database.
    *
    * Last modified by Johnny in Prodigy on 25-09-2023.
    */
    GetSeedData() {

        if(this.recordId) {  

            SeedData({ "recordId" : this.recordId }).then(result => {

                if((result) && (result != '')) {

                    var data = JSON.parse(result);

                    var totalAmount = 0;

                    var purchaseOrder = data.PurchaseOrder;

                    this.IssueDate = data.TodaysDate;
                    this.CurrencySymbol = data.CurrencySymbol;
                    this.DueDate = data.TodaysDate;

                    if(purchaseOrder.pro_Status__c === 'Approved') {
                       
                        this.PurchaseOrder = purchaseOrder;

                        this.PurchaseOrderTitle = 'Purchase Order';

                        //this.PurchaseOrderTotal = purchaseOrder.pro_Total_Amount__c;
                        this.PurchaseOrderLedger = purchaseOrder.pro_Ledger_Lookup__r.Name;
                        this.PurchaseOrderReference = purchaseOrder.pro_Description__c;
                        this.PurchaseOrderDate = purchaseOrder.pro_Purchase_Order_Date__c;
                        this.PurchaseOrderSupplier = purchaseOrder.pro_Supplier_Account__r.Name;

                        this.PayableReference = '';

                        this.PurchaseOrderLines = data.PurchaseOrderLines;

                        for(let i in data.PayableLines) {

                            if (data.PayableLines[i].pro_Remaining_Balance__c > 0) {

                                data.PayableLines[i].pro_Quantity__c = data.PayableLines[i].pro_Remaining_Balance__c;
                                this.SelectedPurchaseOrderLines.push(data.PayableLines[i]);

                                totalAmount += data.PayableLines[i].pro_Total_Amount__c;
                            }
                        }

                        //this.SelectedPurchaseOrderLines = data.PayableLines;

                        this.PurchaseOrderTotal = totalAmount;
                        this.PurchaseOrderName = purchaseOrder.Name;
                    } else {

                        this.FireToaster("Purchase Order not Approved",
                            "The Purchase Order needs to be 'Approved' before it can converted to a Payable",
                            "warning");

                        this.template.querySelector("button[data-id='proCreateButton']").disabled = true;
                    }
                }
            });
        }
    }

    /*
    * Description: Sets the heights of elements on the page.
    *
    * Last modified by Johnny in Prodigy on 06-04-2023.
    */
    SetHeights() {

        var screenSize = window.innerHeight - 150;

        var headerArticle = this.template.querySelector(".PurchaseOrderArticle");

        var detailArticle = this.template.querySelector(".PurchaseOrderLineArticle");
        var detailHeader = this.template.querySelector(".proDetailHeader");
        var detailBody = this.template.querySelector(".proDetailBody");
        var detailFooter = this.template.querySelector(".proDetailFooter");

        var lineArticle = this.template.querySelector(".PayableLineArticle");
        var lineHeader = this.template.querySelector(".proLineHeader");
        var lineBody = this.template.querySelector(".proLineBody");
        var lineFooter = this.template.querySelector(".proLineFooter");

        var page_bottom = (screenSize) - headerArticle.offsetHeight;
        var page_bottom_body = (page_bottom - (lineHeader.offsetHeight + lineFooter.offsetHeight)) - 40;

        var page_top = headerArticle.offsetHeight;
        var page_top_body = (page_top - (detailHeader.offsetHeight + detailFooter.offsetHeight)) - 30;

        if((page_bottom !== -40) && (lineArticle.style.height !== page_bottom + "px")) {

            detailArticle.style.height = headerArticle.offsetHeight + "px";
            lineArticle.style.height = page_bottom + "px";
            lineBody.style.height = page_bottom_body + "px";
            detailBody.style.height = page_top_body + "px";
        }

        setTimeout(() => {
            this.SetHeights();
        }, 1000);
    }

    /*
    * Description: Navigates back to the Purchase Order record page.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    NavigateBackToPurchaseOrder() {

        var recordId = this.PurchaseOrder.Id;
        var objectApiName = 'pro_Purchase_Order__c';

        this.NavigateToRecord(recordId, objectApiName);
    }

    /*
    * Description: Method used to refresh the data on the page.
    *
    * Last modified by Johnny in Prodigy on 10-07-2023.
    */
    RefreshPurchaseOrder() {

        this.SelectedPurchaseOrderLines = [];

        this.GetSeedData();
    }

    /*
    * Description: Method used to remove the selected Purchase Order from the Selected List.
    *
    * Last modified by Johnny in Prodigy on 31-03-2023.
    */
    RemoveFromSelection(event) {

        var lineId = event.currentTarget.dataset.id;

        var purchaseOrderLines = this.SelectedPurchaseOrderLines;

        var indexId = purchaseOrderLines.findIndex(x => x.Id === lineId);

        if(indexId != -1) {

            var tempArray = [];

            for(var i in purchaseOrderLines) {

                if(lineId != purchaseOrderLines[i].Id) {

                    tempArray.push(purchaseOrderLines[i]);
                }
            }

            this.SelectedPurchaseOrderLines = tempArray;
        } else {
            
            this.FireToaster(
                "Purchase Order Line not selected",
                "This line has not been added to the list of selected lines",
                "warning"
            );
        }
    }

    /*
    * Description: Creates a Payable record with line items.
    *
    * Last modified by Johnny in Prodigy on 10-07-2023.
    */
    CreatePayable() {

        var purchaseOrderLines = this.SelectedPurchaseOrderLines;
        var amountPaid = this.TotalAPAmount;
        var purchaseOrder = this.PurchaseOrder;
        var payableReference = this.PayableReference;
        var postingDate = this.PostingDate;
        var issueDate = this.IssueDate;
        var dueDate = this.DueDate;

        console.log('Issue Date: ' + issueDate);
        console.log('Due Date: ' + dueDate);

        this.template.querySelector("button[data-id='proCreateButton']").disabled = true;

        if((payableReference != null) && (payableReference != "")) {

            if((postingDate != null) && (issueDate != null)) {

                if(purchaseOrderLines.length > 0) {

                    var totalLineAmount = 0;

                    for(var currentLine in purchaseOrderLines) {

                        totalLineAmount += purchaseOrderLines[currentLine].AcctSeed__Amount__c;
                    }

                    totalLineAmount += amountPaid;

                    if((payableReference != null) && (payableReference != "")) {

                        this.FireToaster(
                            "Payable is being created",
                            "Please wait...",
                            "info"
                        );

                        var purchaseOrderString = JSON.stringify(purchaseOrder);

                        var tempArray = [];

                        var linesBoolean = true;

                        for(var i in purchaseOrderLines) {

                            if(purchaseOrderLines[i].pro_Quantity__c > purchaseOrderLines[i].pro_Remaining_Balance__c) {

                                linesBoolean = false;

                                this.FireToaster(
                                    "Unable to create Payable",
                                    "Please review quantities to be converted as they cannot be more than the remaining quantity.",
                                    "error"
                                );

                                this.template.querySelector("button[data-id='proCreateButton']").disabled = false;
                            } else {

                                tempArray.push(ConvertToNewPayableLine(purchaseOrderLines[i]));
                            }
                        }
                        
                        console.log(linesBoolean);

                        if(linesBoolean == true) {

                            var linesString = JSON.stringify(tempArray);

                            CreatePayableRecord({
                                "purchaseOrderRecord" : purchaseOrderString,
                                "payableLines" : linesString,
                                "payableReference" : payableReference,
                                "issueDate" : issueDate,
                                "dueDate" : dueDate
                            }).then(result => {
    
                                if(result) {
    
                                    var jsonResult = JSON.parse(result);
    
                                    if(jsonResult.Result == true) {
    
                                        this.FireToaster(
                                            "Payable Created Successfully",
                                            "The Payable record was created successfully",
                                            "success"
                                        );
    
                                        this.template.querySelector("button[data-id='proCreateButton']").disabled = false;
    
                                        this.NavigateToRecord(jsonResult.RecordId, 'AcctSeed__Account_Payable__c');
                                    } else {
    
                                        this.FireToaster(
                                            "Failed to Create Payable",
                                            jsonResult.ErrorMessage,
                                            "error"
                                        )
                                    }
                                } else {
    
                                    this.FireToaster(
                                        "Something has gone wrong",
                                        jsonResult.ErrorMessage,
                                        "error"
                                    );
    
                                    this.template.querySelector("button[data-id='proCreateButton']").disabled = false;
                                }
                            }).catch(error => {
    
                                if(error) {
    
                                    var errorBody = error.body;
    
                                    this.FireToaster(
                                        errorBody.message,
                                        errorBody.stackTrace,
                                        'error'
                                    );
                                }
                            });
                        }                        
                    } else {

                        this.FireToaster(
                            "Missing Payable Reference", 
                            "A unique Reference is required for the Payables", 
                            "warning"
                        );

                        this.template.querySelector("button[data-id='proCreateButton']").disabled = false;
                    }
                } else {

                    this.FireToaster(
                        "Missing Line Items", 
                        "At least 1 Payable line is required to create a Payable", 
                        "warning"
                    );

                    this.template.querySelector("button[data-id='proCreateButton']").disabled = false;
                }
            } else {

                this.FireToaster(
                    "Missing Dates", 
                    "Posting Date and Issue Dates are required", 
                    "warning"
                );

                this.template.querySelector("button[data-id='proCreateButton']").disabled = false;
            }
        } else {

            this.FireToaster(
                "Missing Payable Reference", 
                "Payable Reference is required", 
                "warning"
            );

            this.template.querySelector("button[data-id='proCreateButton']").disabled = false;
        }
    }

    /*
    * Description: Updates the current line item with a new Quantity & Unit Price and re-calculates the Tax Amount and Total.
    *
    * Last modified by Johnny in Prodigy on 03-04-2023.
    */
    UpdatePayableTotal(event) {

        var data = event.currentTarget.dataset;
        var lineId = data.id;
        var type = data.type;
        var value = event.currentTarget.value;
        var list = this.SelectedPurchaseOrderLines;
        var indexVar = list.findIndex(x => x.Id === lineId);

        if(indexVar != -1) {

            var item = list[indexVar];

            if(type == 'quantity') {

                item.AcctSeed__Quantity__c = value;
                var unit = item.AcctSeed__Unit_Cost__c;
                var total = (value * unit);
                item.AcctSeed__Amount__c = total;
            } else {

                item.AcctSeed__Unit_Cost__c = value;
                var quantity = item.AcctSeed__Quantity__c;
                var total = (value * quantity);
                item.AcctSeed__Amount__c = total;
            }

            var tempArray = [];

            for(var currentItem in list) {

                if(list[currentItem].Id === lineId) {

                    tempArray.push(item);
                } else {

                    tempArray.push(list[currentItem]);
                }
            }

            this.SelectedPurchaseOrderLines = tempArray;

            setTimeout(() => {
                this.template.querySelector('c-pro-custom-total-field[data-id="' + lineId + '"]').handleValueChange();
            }, 200);
        }
    }
    
    /*
    * Description: Sets/Updates the Payable Reference.
    *
    * Last modified by Johnny in Prodigy on 03-04-2023.
    */
    SetPayableReference(event) {

        this.PayableReference = event.target.value;
    }

    /*
    * Description: Adds a new Payable Line.
    *
    * Last modified by Johnny in Prodigy on 03-04-2023.
    */
    CreateLine() {

        var purchaseOrderLines = this.SelectedPurchaseOrderLines;
        var count = purchaseOrderLines.length;

        var currentLine = {
            "Id" : "newline" + count,
            "AcctSeed__Product__r" : {
                "Name" : ""
            },
            "AcctSeed__Product__c" : "",
            "AcctSeed__Invoice_Comment__c" : "",
            "AcctSeed__Quantity__c" : 1,
            "AcctSeed__Unit_Cost__c" : 0
        };

        purchaseOrderLines.push(currentLine);
        this.SelectedPurchaseOrderLines = [];
        this.SelectedPurchaseOrderLines = purchaseOrderLines;
    }

    /*
    * Description: Sets the Product of the current Purchase Order Line.
    *
    * Last modified by Johnny in Prodigy on 03-04-2023.
    */
    SetProduct(event) {

        var purchaseOrderLines = this.SelectedPurchaseOrderLines;
        var recordDetails = event.detail.recordId;
        var lineId = event.target.dataset.id;
        var indexVariable = purchaseOrderLines.findIndex(x => x.Id === lineId);

        if(indexVariable != -1) {

            purchaseOrderLines[indexVariable].AcctSeed__Product__c = recordDetails;
            this. SelectedPurchaseOrderLines = purchaseOrderLines;
        }
    }

    /*
    * Description: Sets/Updates the Issue Date.
    *
    * Last modified by Johnny in Prodigy on 03-04-2023.
    */
    SetIssueDate(event) {

        this.IssueDate = event.target.value;
    }

    /*
    * Description: Sets/Updates the Due Date.
    *
    * Last modified by Johnny in Prodigy on 12-07-2023.
    */
    SetDueDate(event) {

        this.DueDate = event.target.value;
    }

    /*
    * Description: Removes line from SelectedPurchaseOrderLines.
    *
    * Last modified by Johnny in Prodigy on 25-09-2023.
    */
    RemoveItem(event) {
        
        var itemId = event.detail.itemId;

        var list = this.SelectedPurchaseOrderLines;

        var indexVar = list.findIndex(x => x.Id === itemId);
        //var totalAmount = this.PurchaseOrderTotal;

        if(indexVar != -1) {

            //totalAmount -= list[indexVar].pro_Total_Amount__c;
            list.splice(indexVar, 1);

            this.SelectedPurchaseOrderLines = [];
            this.SelectedPurchaseOrderLines = list;
        }

        this.UpdateConversionTotal();
        //this.PurchaseOrderTotal = totalAmount;
    }

    /*
    * Description: Updates the description of the relevant line in the SelectedPurchaseOrderLines.
    *
    * Last modified by Johnny in Prodigy on 11-04-2023.
    */
    UpdateDescription(event) {

        var itemId = event.detail.itemId;
        var updatedDescription = event.detail.updatedDescription;

        var list = this.SelectedPurchaseOrderLines;

        var indexVar = list.findIndex(x => x.Id === itemId);

        if(indexVar != -1) {

            list[indexVar].pro_Comment__c = updatedDescription;

            this.SelectedPurchaseOrderLines = list;
        }
    }

    /*
    * Description: Updates the total amount of the relevant line in the SelectedPurchaseOrderLines.
    *
    * Last modified by Johnny in Prodigy on 11-07-2023.
    */
    UpdateLineTotal(event) {

        var itemId = event.detail.itemId;
        var itemType = event.detail.type;
        var itemValue = event.detail.value;

        var list = this.SelectedPurchaseOrderLines;

        var indexVar = list.findIndex(x => x.Id === itemId);

        if(indexVar != -1) {

            if(itemType == 'quantity') {

                list[indexVar].pro_Quantity__c = itemValue;
            } else {

                list[indexVar].pro_Unit_Price__c = itemValue;
            }

            this.SelectedPurchaseOrderLines = list;

            setTimeout(() => {
                this.template.querySelector('c-pro-custom-total-field[data-id="' + itemId + '"]').handleValueChange();
            }, 200);
        }

        this.UpdateConversionTotal();
    }

    /*
    * Description: Updates the Total Amount of the lines that are to be converted.
    *
    * Last modified by Johnny in Prodigy on 05-10-2023.
    */
    UpdateConversionTotal() {

        var list = this.SelectedPurchaseOrderLines;
        var totalAmount = 0;

        list.forEach(currElement => {
            
            totalAmount += (currElement.pro_Quantity__c * currElement.pro_Unit_Price__c);
        });

        this.PurchaseOrderTotal = totalAmount;
    }
}