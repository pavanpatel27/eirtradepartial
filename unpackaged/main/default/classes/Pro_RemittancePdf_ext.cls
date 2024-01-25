/*
 * Created by Prodigy on 21-03-2023.
 *
 * Description: Extention class for Pro_RemittancePDF.
 *
 * Last modified by Johnny in Prodigy on 21-03-2023.
*/
public without sharing class Pro_RemittancePdf_ext {

    public String HeaderLogo { get; set; }
    public String CurrencyFormat { get; set; }
    public String CurrencySymbol { get; set; }

    public AcctSeed__Ledger__c Ledger { get; set; }
    public AcctSeed__Billing_Format__c PdfFormat { get; set; }
    public AcctSeed__Cash_Disbursement__c CashDisbursement { get; set; }
    
    public List<AcctSeed__AP_Disbursement__c> Lines { get; set; }

    //
    // --- SECTION: Constructor(s)
    //

    /*
    * Description: Empty Constructor.
    *
    * Last modified by Johnny in Prodigy on 21-03-2023.
    */
    public Pro_RemittancePdf_ext() {

        this.HeaderLogo = '';
        this.CurrencyFormat = '';
        this.CurrencySymbol = '';
    }

    /*
    * Description: ApexPages Constructor.
    *
    * Last modified by Johnny in Prodigy on 21-03-2023.
    */
    public Pro_RemittancePdf_ext(ApexPages.StandardController controller) {

        Id disbursementId = controller.getId();

        List<String> disbursementFields = new List<String> {
            'AcctSeed__Vendor__r.Name',
            'AcctSeed__Contact__r.Name',
            'AcctSeed__Vendor__r.pro_Email__c'
        };

        String extraFields = String.join(disbursementFields, ',');

        this.CashDisbursement = (AcctSeed__Cash_Disbursement__c)Pro_Utilities.GetRecords('AcctSeed__Cash_Disbursement__c',
            new List<String>{ disbursementId }, 
            'Id', 
            extraFields)[0];

        Id ledgerId = this.CashDisbursement.AcctSeed__Ledger__c;
        this.CurrencySymbol = this.CashDisbursement.CurrencyIsoCode;

        this.Ledger = (AcctSeed__Ledger__c)Pro_Utilities.GetRecords('AcctSeed__Ledger__c', 
            new List<String>{ ledgerId }, 
            'Id', 
            null)[0];

        if (this.Ledger != null) {
            
            Id pdfRemittanceId = this.Ledger.pro_Default_Remittance_PDF__c;

            this.PdfFormat = (AcctSeed__Billing_Format__c)Pro_Utilities.GetRecords('AcctSeed__Billing_Format__c', 
                new List<String>{ pdfRemittanceId }, 
                'Id', 
                null)[0];
            
            if (String.isNotBlank(this.PdfFormat.AcctSeed__Currency_Format__c)) {
                
                List<String> currencyFormats = this.PdfFormat.AcctSeed__Currency_Format__c.split(';');

                this.CurrencyFormat = '{0, number, ' + this.CurrencySymbol + ' ' + currencyFormats[0] + '}';
            }

            if (this.PdfFormat != null) {
                
                if (String.isNotBlank(this.PdfFormat.AcctSeed__Image__c)) {
                    
                    String firstSub = this.PdfFormat.AcctSeed__Image__c.substringBetween('<img', 'img>');

                    if (firstSub != null) {
                        
                        String secondSub = firstSub.substringBetween('src="', '"');

                        this.HeaderLogo = secondSub.replace('amp;', '');
                    }
                }
            }
        }

        this.Lines = Pro_Utilities.GetRecords('AcctSeed__AP_Disbursement__c', 
            new List<String>{ disbursementId }, 
            'AcctSeed__Cash_Disbursement__c', 
            null);
    }   

    //
    // --- SECTION: Public Method(s)
    //

    /*
    * Description: Attaches PDF to Cash Disbursement record.
    *
    * Last modified by Johnny in Prodigy on 21-03-2023.
    */
    public static void SavePDF() {

        String savePDF = ApexPages.currentPage().getParameters().get('savePDF');

        if (savePDF == null) {
            
            String recordId = ApexPages.currentPage().getParameters().get('id');

            Pagereference pdf = Page.Pro_RemittancePDF;
            pdf.getParameters().put('id', recordId);
            pdf.getParameters().put('savePDF', recordId);

            Savepoint savePoint = Database.setSavepoint();

            Blob data;

            Datetime currentDateTime = DateTime.Now();
            String fileName = 'Remittance: ' + currentDateTime.format('dd-MM-yyyy @ HH:mm');

            String url = System.Url.getSalesforceBaseUrl().toExternalForm();
            String path = url + '/sfc/servlet.shepherd/version/download/' + fileName + '.pdf';

            if (Test.isRunningTest()) {
                
                data = Blob.valueOf('This is a test');
            } else {

                data = pdf.getContent();
            }

            ContentVersion cv = new ContentVersion(
                Title = fileName,
                VersionData = data,
                PathOnClient = path,
                ContentLocation = 'S'
            );

            Pro_Utilities.ResultWrap result = Pro_Utilities.InsertRecords(new List<ContentVersion>{ cv }, savePoint);

            if (result.Result) {

                ContentVersion cv1 = [
                    SELECT
                        Id,
                        ContentDocumentId
                    FROM
                        ContentVersion
                    WHERE
                        Id =: cv.Id
                    LIMIT
                        1
                ];

                ContentDocumentLink cdl = new ContentDocumentLink(
                    ShareType = 'V',
                    LinkedEntityId = recordId,
                    ContentDocumentId = cv1.ContentDocumentId
                );

                Pro_Utilities.InsertRecords(new List<ContentDocumentLink>{ cdl }, savePoint);
            }
        }
    }
}