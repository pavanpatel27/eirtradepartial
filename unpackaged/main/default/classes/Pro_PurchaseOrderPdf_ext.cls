/*
 * Created by Prodigy on 15-03-2023.
 *
 * Description: Extention class for Pro_PurchaseOrderPDF.
 *
 * Last modified by Johnny in Prodigy on 16-03-2023.
*/
public without sharing class Pro_PurchaseOrderPdf_ext {

    public String HeaderLogo { get; set; }
    public String CurrencyFormat { get; set; }
    public String CurrencySymbol { get; set; }

    public AcctSeed__Ledger__c Ledger { get; set; }
    public AcctSeed__Billing_Format__c PdfFormat { get; set; }
    public pro_Purchase_Order__c PurchaseOrder { get; set; }
    
    public List<pro_Purchase_Order_Line__c> Lines { get; set; }

    //
    // --- SECTION: Constructor(s)
    //
    
    /*
    * Description: Empty Constructor.
    *
    * Last modified by Johnny in Prodigy on 15-03-2023.
    */
    public Pro_PurchaseOrderPdf_ext(){
        this.HeaderLogo = '';
        this.CurrencyFormat = '';
        this.CurrencySymbol = '';
    }
    
    /*
    * Description: ApexPages Constructor.
    *
    * Last modified by Johnny in Prodigy on 15-03-2023.
    */
    public Pro_PurchaseOrderPdf_ext(ApexPages.StandardController sc){

        Id poId = sc.getId();

        List<String> poFields = new List<String>{
            'Owner.Name',
            'pro_Shipping_Contact__r.Name',
            'pro_Supplier_Account__r.Name',
            'pro_Supplier_Account__r.pro_Email__c',
            'Owner.Phone',
            'Owner.Email'
        };

        String extraFields = String.join(poFields, ',');

        this.PurchaseOrder = (pro_Purchase_Order__c) Pro_Utilities.GetRecords('pro_Purchase_Order__c', new List<String>{ poId }, 'Id', extraFields)[0];
        

        Id ledgerId = this.PurchaseOrder.pro_Ledger_Lookup__c;
        this.CurrencySymbol = this.PurchaseOrder.CurrencyIsoCode;

        this.Ledger = (AcctSeed__Ledger__c)Pro_Utilities.GetRecords('AcctSeed__Ledger__c', new List<String>{ ledgerId }, 'Id', null)[0];

        if( this.Ledger != null ){
            Id pdfFormatId = this.Ledger.AcctSeed__Default_Purchase_Order_Format__c;
            
            this.PdfFormat = (AcctSeed__Billing_Format__c)Pro_Utilities.GetRecords('AcctSeed__Billing_Format__c', new List<String>{ pdfFormatId }, 'Id', null)[0];

            if (String.isNotBlank( this.PdfFormat.AcctSeed__Currency_Format__c)) {
                List<String> curr = this.PdfFormat.AcctSeed__Currency_Format__c.split(';');
                
                this.CurrencyFormat = '{0, number, ' + this.CurrencySymbol + ' ' + curr[0] + '}';
            }
            
            if( this.PdfFormat != null){
                if (String.isNotBlank(this.PdfFormat.AcctSeed__Image__c)) {

                    String firstSub = this.PdfFormat.AcctSeed__Image__c.substringBetween('<img', 'img>');
                    
                    if( firstSub != null ){
                        String secondSub = firstSub.substringBetween('src="', '"');
                        
                        this.HeaderLogo = secondSub.replace('amp;', '');
                    }
                }
            }
        }

        this.Lines = Pro_Utilities.GetRecords('pro_Purchase_Order_Line__c', new List<String>{ poId }, 'pro_Purchase_Order__c', null);
    }   

    //
    // --- SECTION: Public Method(s)
    //

    /*
    * Description: Attaches PDF to Purchase Order record.
    *
    * Last modified by Johnny in Prodigy on 16-03-2023.
    */
    public static void SavePDF() {
        
        String savePDF = ApexPages.currentPage().getParameters().get('savePDF');

        if (savePDF == null) {
            
            String recordId = ApexPages.currentPage().getParameters().get('id');

            Pagereference pdf = Page.Pro_PurchaseOrderPDF;
            pdf.getParameters().put('id', recordId);
            pdf.getParameters().put('savePDF', recordId);

            Savepoint save = Database.setSavepoint();

            Blob data;

            Datetime currentDateTime = Datetime.Now();
            String fileName = 'Purchase Order: ' + currentDateTime.format('dd-MM-yyyy @ HH:mm');

            String url = System.Url.getSalesforceBaseUrl().toExternalForm();
            String path = url + '/sfc/servlet.shepherd/version/download/' + fileName + '.pdf';
            
            if( Test.isRunningTest() ){ data = Blob.valueOf('This is a test'); } else{ data = pdf.getContent(); }

            ContentVersion cv = new ContentVersion(
                Title = fileName,
                VersionData = data,
                PathOnClient = path,
                ContentLocation = 'S'
            );

            Pro_Utilities.ResultWrap ans = Pro_Utilities.InsertRecords( new List<ContentVersion>{ cv } , save);

            if( ans.Result ){
                ContentVersion cv1 = [
                    SELECT
                        Id,
                        ContentDocumentId
                    FROM
                        ContentVersion
                    WHERE
                        Id =: cv.Id
                    LIMIT 1
                ];

                ContentDocumentLink cdl = new ContentDocumentLink(
                    ShareType = 'V',
                    LinkedEntityId = recordId,
                    ContentDocumentId = cv1.ContentDocumentId
                );

                Pro_Utilities.InsertRecords( new List<ContentDocumentLink>{ cdl } , save);
            }
        }
    }
}