/*
 * Created by Prodigy on 25-04-2023.
 *
 * Description: Batch class used for sending outstanding invoices and statements.
 *
 * Last modified by Johnny in Prodigy on 06-09-2023.
*/
public class Pro_SendFinancialEmails_btc implements Database.Batchable<SObject>, Schedulable {
    
    public String Query { get; set; }
    public String RecordId { get; set; }
    public List<String> RecordIds { get; set; }
    public String Type { get; set; }
    
    // ******* Constructors ******* \ 
    
    /*
    * Description: Class constructor with record type.
    *
    * Last modified by Johnny in Prodigy on 27-04-2023.
    */
    public Pro_SendFinancialEmails_btc(String recordType) {
        this.RecordId = '';
        this.Type = recordType;
        this.Query = GenerateQuery(recordType);
        this.RecordIds = new List<String>();
    }
    
    /*
    * Description: Class constructor with record Id and record type.
    *
    * Last modified by Johnny in Prodigy on 27-04-2023.
    */
    public Pro_SendFinancialEmails_btc(String recordId, String recordType) {
        this.RecordId = recordId;
        this.RecordIds = new List<String>();
        this.Type = recordType;
        this.Query = GenerateQuery(recordType) + ' AND Id =: RecordId';
    }
    
    /*
    * Description: Class constructor with multiple record Ids and record type.
    *
    * Last modified by Johnny in Prodigy on 27-04-2023.
    */
    public Pro_SendFinancialEmails_btc(List<String> recordIds, String recordType) {
        this.RecordId = '';
        this.RecordIds = recordIds;
        this.Type = recordType;
        this.Query = GenerateQuery(recordType) + ' AND Id =: RecordIds';
    }
    
        // ******* Schedulable Methods ******* \ 
    
    /*
    * Description: Schedules class to fire at certain intervals.
    *
    * Last modified by Johnny in Prodigy on 29-05-2023.
    */
    public void execute(SchedulableContext sc) {
        
        String resultString = Test.isRunningTest() ? '' : Database.executeBatch(new Pro_SendFinancialEmails_btc(this.Type), 1);
    }
    
    
    /*
    * Description: Used to invoke the Apex Scheduled class.
    *
    * Last modified by Johnny in Prodigy on 29-05-2023.
    */
    public static void StartSchedule(Boolean isBilling){

        String cronExp = '';
        String recordType = '';
        String scheduleName = 'Prodigy - ';

        if (isBilling) {
            
            cronExp = '0 5 0 1/1 * ? *'; // Default Cron Exp (Runs at 5 past midnight, everyday of the week)
            recordType = 'Billing';
            scheduleName += 'Billing Schedule';
        } else {

            cronExp = '0 0 5 1/1 * ? *'; // Default Cron Exp (Runs at 5 a.m, everyday of the week)
            recordType = 'Customer Statement';
            scheduleName += 'Customer Statement Schedule';
        }

        scheduleName += Test.isRunningTest() ? ' - TEST TEST TEST' : '';

        System.schedule(scheduleName, cronExp, new Pro_SendFinancialEmails_btc(recordType));
    }

    // ******* Batch Methods ******* \ 
    
    /*
    * Description: Batch start method (Starts the Batch by querying the Database for records).
    *
    * Last modified by Johnny in Prodigy on 26-04-2023.
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.Query);
    }
    
    /*
    * Description: Batch execute method (Executes the Batch to start processing records).
    *
    * Last modified by Johnny in Prodigy on 31-07-2023.
    */
    public void execute(Database.BatchableContext bc, List<SObject> scopeObjects) {
        
        String objectApiName = String.valueOf(scopeObjects[0].getSObjectType()); 

        Map<String,List<pro_Send_Financial_Email__mdt>> logicMap = GetEmailMetadata();

        List<SObject> eligibleRecords =  new List<SObject>();

        if (!logicMap.isEmpty()) {
            
            Boolean isEligible = false;

            if (this.Type == 'Customer Statement') {
                
                Date startDate = Date.today().toStartOfMonth();
                Date endDate = startDate.addMonths(1).addDays(-1);

                if (Date.today() == endDate || Test.isRunningTest()) {

                    for (SObject currentObject : scopeObjects) {
                    
                        Boolean isEmpty = true;

                        for (AcctSeed__Billing__c currentBilling : currentObject.getSObjects('AcctSeed__Billings__r')) {
                            
                            isEmpty = false;
                            break;
                        }

                        if (isEmpty == false) {
                            
                            eligibleRecords.add(currentObject);
                        }
                    }

                    if (!eligibleRecords.isEmpty()) {
                        
                        isEligible = true;
                    }
                }
            } else {

                eligibleRecords = scopeObjects;
                isEligible = true;
            }

            if (isEligible) {
                
                Map<Id,Account> objectAccount = GetObjectAccount(eligibleRecords);

                List<pro_Send_Financial_Email__mdt> metaDataList = logicMap.get(this.Type);
    
                List<String> templateNames = new List<String>();
    
                for (pro_Send_Financial_Email__mdt currentMetadata : metaDataList) {
                    
                    templateNames.add(currentMetadata.pro_Email_Template__c);
                }
    
                Map<String, Id> emailTemplates = GetEmailTemplate(templateNames);
    
                List<OrgWideEmailAddress> orgEmailAddresses = GetOrgEmailAddresses();
    
                List<Messaging.SingleEmailMessage> emailMessages = CreateEmail(objectAccount, emailTemplates.get(templateNames[0]), orgEmailAddresses[0], metaDataList[0].pro_Visualforce_Page__c, eligibleRecords, objectApiName, metaDataList[0].pro_Days__c);

                if (!emailMessages.isEmpty()) {
                    
                    SendEmails(emailMessages);
                } 
            }
        } 
    }
    
    /*
    * Description: Batch finish method (Fires when the Batch has finished processing records).
    *
    * Last modified by Johnny in Prodigy on 25-04-2023.
    */
    public void finish(Database.BatchableContext bc) {
        // insert code here
    }
    
    /*
    * Description: Generates Query for the batch class.
    *
    * Last modified by Johnny in Prodigy on 06-09-2023.
    */
    @testvisible
    static String GenerateQuery(String objectType) {

        String result = 'SELECT ';

        String searchCriteria = '';
        String objectApiName = '';

        String subQuery = '';
        
        switch on objectType {
            when 'Customer Statement' {
                
                objectApiName = 'Account';
                subQuery = ', (SELECT Id, AcctSeed__Balance__c, AcctSeed__Ledger__c FROM AcctSeed__Billings__r WHERE AcctSeed__Balance__c > 0)';
                searchCriteria = '(pro_Statement_Email_Address__c != NULL)';
            }
            when 'Billing' {

                objectApiName = 'AcctSeed__Billing__c';
                searchCriteria = Test.isRunningTest() ? '(AcctSeed__Balance__c > 0)' : '(AcctSeed__Balance__c > 0) AND (inscoras__Invoice__c != null) AND (AcctSeed__Customer__r.pro_Exclude_from_Invoice_Emails__c = FALSE)';   
                subQuery = ', inscoras__Invoice__r.inscor__of_Pieces__c, inscoras__Invoice__r.inscor__Shipped_Method__c, inscoras__Invoice__r.inscor__Freight_Charge__c, inscoras__Invoice__r.inscor__Total_Weight__c, inscoras__Invoice__r.inscor__AWB__c, inscoras__Invoice__r.Name';         
            }
            when else {
                
            }
        }

        List<String> fieldList = new List<String>();

        if (objectType == 'Customer Statement') {
            
            fieldList.add('Name');
            fieldList.add('AcctSeed__Alternate_Payee_Name__c');
            fieldList.add('AcctSeed__Billing_Contact__c');
            fieldList.add('AcctSeed__Billing_Contact__r.Name');
            fieldList.add('BillingStreet');
            fieldList.add('BillingCity');
            fieldList.add('BillingState');
            fieldList.add('BillingPostalCode');
            fieldList.add('BillingCountry');
            fieldList.add('CurrencyIsoCode');
        } else {

            fieldList = Pro_Utilities.GetObjectFields(objectApiName);
        }

        result += String.join(fieldList, ',') + subQuery;

        result += ' FROM ' + objectApiName;

        if (String.isNotBlank(searchCriteria)) {
            
            result += ' WHERE ' + searchCriteria;
        }

        return result;
    }

    /*
    * Description: Retrieves the metadata for coding logic.
    *
    * Last modified by Johnny in Prodigy on 31-08-2023.
    */
    @testvisible
    static Map<String, List<pro_Send_Financial_Email__mdt>> GetEmailMetadata() {

        Map<String, List<pro_Send_Financial_Email__mdt>> resultMap = new Map<String, List<pro_Send_Financial_Email__mdt>>();

        List<pro_Send_Financial_Email__mdt> result = [
            SELECT
                Id,
                pro_Days__c,
                pro_Email_Template__c,
                pro_Type__c,
                pro_Visualforce_Page__c,
                pro_Accounting_Seed_Ledger__c,
                pro_Billing_Format__c
            FROM
                pro_Send_Financial_Email__mdt
        ];

        for (pro_Send_Financial_Email__mdt currentItem : result) {
            
            List<pro_Send_Financial_Email__mdt> tempList = resultMap.get(currentItem.pro_Type__c);

            resultMap.put(currentItem.pro_Type__c, new List<pro_Send_Financial_Email__mdt>{ currentItem });

        }
        
        return resultMap;
    }

    /*
    * Description: Creates PDF document to attach to email object.
    *
    * Last modified by Johnny in Prodigy on 06-09-2023.
    */
    @testvisible
    static List<Messaging.EmailFileAttachment> CreateEmailAttachment(SObject incomingRecord, String recordType, String visualforcePage, String recordName) {

        List<Messaging.EmailFileAttachment> result = new List<Messaging.EmailFileAttachment>();
        
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();

        Pagereference pageRef = new Pagereference('/apex/' + visualforcePage);

        Savepoint savePoint = Database.setSavepoint();

        switch on recordType {
            when 'AcctSeed__Billing__c' {

                String invoiceId = Test.isRunningTest() ? '' : String.valueOf(incomingRecord.get('inscoras__Invoice__c'));
                String noOfPieces = Test.isRunningTest() ? '' : String.valueOf(incomingRecord.getSObject('inscoras__Invoice__r').get('inscor__of_Pieces__c'));
                String shippedVia = Test.isRunningTest() ? '' : String.valueOf(incomingRecord.getSObject('inscoras__Invoice__r').get('inscor__Shipped_Method__c'));
                String freightCharge = Test.isRunningTest() ? '' : String.valueOf(incomingRecord.getSObject('inscoras__Invoice__r').get('inscor__Freight_Charge__c'));
                String totalWeight = Test.isRunningTest() ? '' : String.valueOf(incomingRecord.getSObject('inscoras__Invoice__r').get('inscor__Total_Weight__c'));
                String awb = Test.isRunningTest() ? '' : String.valueOf(incomingRecord.getSObject('inscoras__Invoice__r').get('inscor__AWB__c'));
                String invoiceName = Test.isRunningTest() ? 'INVC-0001' : String.valueOf(incomingRecord.getSObject('inscoras__Invoice__r').get('Name'));

                noOfPieces = String.isEmpty(noOfPieces) ? '' : noOfPieces;
                shippedVia = String.isEmpty(shippedVia) ? '' : shippedVia;
                freightCharge = String.isEmpty(freightCharge) ? '' : freightCharge;
                totalWeight = String.isEmpty(totalWeight) ? '' : totalWeight;
                awb = String.isEmpty(awb) ? '' : awb;

                pageRef.getParameters().put('inv', invoiceId);
                pageRef.getParameters().put('noOfPieces', noOfPieces);
                pageRef.getParameters().put('shippedVia', shippedVia);
                pageRef.getParameters().put('freight', freightCharge);
                pageRef.getParameters().put('totalWeight', totalWeight);
                pageRef.getParameters().put('awb', awb);

                fileAttachment.filename = recordName + '.pdf';
            }
            when 'Account' {

                Date todaysDate = System.today();
                Date previousMonth = todaysDate.addMonths(-1);
                Date startOfPreviousMonth = previousMonth.toStartOfMonth();

                fileAttachment.filename = 'Outstanding Statement.pdf';

                List<AcctSeed__Billing__c> accountBillings = incomingRecord.getSObjects('AcctSeed__Billings__r');

                Id ledgerId = accountBillings[0].AcctSeed__Ledger__c;

                Id fomratId = GetBillingFormat(ledgerId);

                pageRef.getParameters().put('id', incomingRecord.Id);
                pageRef.getParameters().put('currencyIsoCode', String.valueOf(incomingRecord.get('CurrencyIsoCode')));
                pageRef.getParameters().put('formatId', fomratId);
                pageRef.getParameters().put('reportType', 'oustanding');
                pageRef.getParameters().put('ledgerId', ledgerId);
                pageRef.getParameters().put('startDate', String.valueOf(startOfPreviousMonth));
                pageRef.getParameters().put('endDate', String.valueOf(todaysDate));
            }
            when else {
                
            }
        }

        Blob contentBlob = Test.isRunningTest() ? Blob.valueOf('Test Content') : pageRef.getContent();

        String urlString = System.Url.getSalesforceBaseUrl().toExternalForm();
        String filePath = urlString + '/sfc/servlet.shepherd/version/download/' + fileAttachment.filename + '.pdf';

        ContentVersion cv = new ContentVersion(
            Title = fileAttachment.filename,
            VersionData = contentBlob,
            PathOnClient = filePath,
            ContentLocation = 'S');

        fileAttachment.body = contentBlob;
        fileAttachment.contenttype = 'application/pdf';

        Pro_Utilities.ResultWrap insertResult = Pro_Utilities.InsertRecords(new List<ContentVersion>{ cv }, savePoint);

        if (insertResult.Result) {
            
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
                LinkedEntityId = incomingRecord.Id,
                ContentDocumentId = cv1.ContentDocumentId
            );

            Pro_Utilities.InsertRecords(new List<ContentDocumentLink>{ cdl }, savePoint);
        }

        result.add(fileAttachment);
        
        return result;
    }

    /*
    * Description: Creates email object(s).
    *
    * Last modified by Johnny in Prodigy on 01-09-2023.
    */
    @testvisible
    static List<Messaging.SingleEmailMessage> CreateEmail(Map<Id,Account> objectAccount, Id emailTemplateId, OrgWideEmailAddress emailAddress, String visualforcePage, List<SObject> incomingObjects, String objectApiName, Decimal dateDifference) {

        List<Messaging.SingleEmailMessage> result = new List<Messaging.SingleEmailMessage>();
        
        for (SObject currentObject : incomingObjects) {

            String recordName = '';
            String recordId = '';
            Boolean isEligible = false;

            if (objectApiName == 'AcctSeed__Billing__c') {
                
                recordName = (String) currentObject.get('Name');
                recordId = (String) currentObject.get('AcctSeed__Customer__c');

                if (Date.valueOf(currentObject.get('AcctSeed__Due_Date2__c')).daysBetween(System.Date.today()) == dateDifference) {

                    isEligible = true;
                }
            } else {

                recordId = (String) currentObject.Id;
                isEligible = true;
            }

            if (isEligible) {

                if (objectApiName == 'AcctSeed__Billing__c') {

                    Boolean hasInvoice = Test.isRunningTest() ? true : !String.isBlank((String) currentObject.get('inscoras__Invoice__c'));
                    
                    if (!String.isBlank(objectAccount.get(recordId).pro_Invoice_Email__c) && hasInvoice) {

                        Messaging.SingleEmailMessage currentEmail = Messaging.renderStoredEmailTemplate(emailTemplateId, null, currentObject.Id);
                        currentEmail.setToAddresses(new List<String> { objectAccount.get(recordId).pro_Invoice_Email__c });
                        currentEmail.setSaveAsActivity(true);
                        currentEmail.setFileAttachments(CreateEmailAttachment(currentObject, objectApiName, visualforcePage, recordName));
                        currentEmail.setOrgWideEmailAddressId(emailAddress.Id);
                        currentEmail.setReplyTo(pro_PCS__c.getInstance().pro_Reply_To_Email__c);
                        currentEmail.setCcAddresses(new List<String> { pro_PCS__c.getInstance().pro_Invoice_Cc_Email__c });
            
                        result.add(currentEmail);
                    }
                } else {

                    if (!String.isBlank(objectAccount.get(recordId).pro_Statement_Email_Address__c)) {

                        Messaging.SingleEmailMessage currentEmail = Messaging.renderStoredEmailTemplate(emailTemplateId, null, currentObject.Id);
                        currentEmail.setToAddresses(new List<String> { objectAccount.get(recordId).pro_Statement_Email_Address__c });
                        currentEmail.setCcAddresses(new List<String>{ pro_PCS__c.getInstance().pro_Statement_Cc_Email__c });
                        currentEmail.setSaveAsActivity(true);
                        currentEmail.setFileAttachments(CreateEmailAttachment(currentObject, objectApiName, visualforcePage, recordName));
                        currentEmail.setOrgWideEmailAddressId(emailAddress.Id);
                        currentEmail.setReplyTo(pro_PCS__c.getInstance().pro_Reply_To_Email__c);
            
                        result.add(currentEmail);
                    }
                }

            }
        }
        
        return result;
    }

    /*
    * Description: Gets the email template for the specified record.
    *
    * Last modified by Johnny in Prodigy on 26-04-2023.
    */
    @testvisible
    static Map<String, Id> GetEmailTemplate(List<String> templateNames) {

        Map<String, Id> resultMap = new Map<String, Id>();

        List<EmailTemplate> result = [
            SELECT
                Id,
                Name,
                DeveloperName
            FROM
                EmailTemplate
            WHERE DeveloperName =: templateNames
        ];

        for (EmailTemplate currentItem : result) {
            
            resultMap.put(currentItem.DeveloperName, currentItem.Id);
        }
        
        return resultMap;
    }

    /*
    * Description: Creates a Map of the Object Id and contact information.
    *
    * Last modified by Johnny in Prodigy on 23-05-2023.
    */
    @testvisible
    static Map<Id, Account> GetObjectAccount(List<SObject> incomingObjects) {

        List<String> accountIds = new List<String>();

        for (SObject currentObject : incomingObjects) {

            switch on String.valueOf(currentObject.getSObjectType()) {
                when 'Account' {
                    
                    accountIds.add(currentObject.Id);
                }
                when 'AcctSeed__Billing__c' {

                    accountIds.add(String.valueOf(currentObject.get('AcctSeed__Customer__c')));
                }
                when else {
                    
                }
            }
        }

        Map<Id, Account> accountList = new Map<Id, Account>([
            SELECT
                Id,
                pro_Invoice_Email__c,
                pro_Statement_Email_Address__c
            FROM
                Account
            WHERE
                Id IN: accountIds
        ]);
        
        return accountList;
    }

    /*
    * Description: Retrieves the OrgWideEmailAddress.
    *
    * Last modified by Johnny in Prodigy on 25-04-2023.
    */
    @testvisible
    static List<OrgWideEmailAddress> GetOrgEmailAddresses() {

        List<OrgWideEmailAddress> result = [
            SELECT
                Id,
                Address,
                DisplayName
            FROM
                OrgWideEmailAddress
        ];
        
        return result;
    }


    /*
    * Description: Sends the emails provided.
    *
    * Last modified by Johnny in Prodigy on 26-04-2023.
    */
    @testvisible
    static void SendEmails(List<Messaging.SingleEmailMessage> incomingEmails) {

        List<String> objectIds = new List<String>();
        
        for (Messaging.SingleEmailMessage currentEmail : incomingEmails) {
            
            objectIds.add(currentEmail.getWhatId());
        }

        try {
            
            Messaging.sendEmail(incomingEmails);
        } catch (Exception ex) {
            
            insert new pro_Error_Log__c(
                pro_Error_Message__c = ex.getMessage(),
                pro_Error_Trace__c = ex.getStackTraceString(),
                pro_Related_Records__c = String.join(objectIds, ',')
            );
        }
    }
    
    /*
    * Description: Method used to retrieve the Outstanding Statement.
    *
    * Last modified by Johnny in Prodigy on 04-09-2023.
    */
    @testvisible
    static Id GetBillingFormat(Id ledgerId) {

        AcctSeed__Ledger__c retrievedLedger = [
            SELECT
                Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c
            FROM
                AcctSeed__Ledger__c
            WHERE
                Id =: ledgerId
        ];

        return retrievedLedger.AcctSeed__Billing_Outstanding_Statement_Format__c;
    }
}