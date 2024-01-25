import { LightningElement, api, track } from 'lwc';

export default class ProCustomTotalField extends LightningElement {
    @api quantity;
    @api unitPrice;
    @api identity;
    @api includesTax;
    @api taxPercent;
    @api currencySymbol;

    totalValue;

    firstRenderedCallback = true;
    
    /*
    * Description: Fires whenever the lightning component renders.
    *
    * Last modified by Johnny in Prodigy on 03-04-2023.
    */
    renderedCallback(){
        if(! this.firstRenderedCallback ){ return; }

        this.firstRenderedCallback = false;

        if( this.includesTax == "true" ){

            if( this.taxPercent == null ){ this.taxPercent = 0; }

            this.totalValue = ( (this.quantity * this.unitPrice) * (this.taxPercent / 100) ) + (this.quantity * this.unitPrice);
        } else {

            this.totalValue = this.quantity * this.unitPrice;
        }
    }

    /*
    * Description: Fires when quantity or unit price changes.
    *
    * Last modified by Johnny in Prodigy on 03-04-2023.
    */
    @api handleValueChange(){
        if( this.includesTax == "true" ){

            if( this.taxPercent == null ){ this.taxPercent = 0; }

            this.totalValue = ( (this.quantity * this.unitPrice) * (this.taxPercent / 100) ) + (this.quantity * this.unitPrice);
        } else {

            this.totalValue = this.quantity * this.unitPrice;
        }
    }
}