/*
 * Created by Johnny in Prodigy on 21-06-2023.
 *
 * Description: Batch class used to send Remittance emails in bulk.
 *
 * Last modified by Johnny in Prodigy on 13-07-2023.
*/
public class Pro_SendEmailBatches_btc implements Database.Batchable<SObject> {
    
    public String Query { get; set; }
    public String RecordId { get; set; }
    public List<String> RecordIds { get; set; }
    
    
    // ******* Constructors ******* \ 
    
    /*
    * Description: Class empty constructor.
    *
    * Last modified by Johnny in Prodigy on 21-06-2023.
    */
    public Pro_SendEmailBatches_btc(String objectName) {
        this.RecordId = '';
        this.Query = GenerateQuery(objectName);
        this.RecordIds = new List<String>();
    }
    
    /*
    * Description: Class constructor with record Id.
    *
    * Last modified by Johnny in Prodigy on 21-06-2023.
    */
    public Pro_SendEmailBatches_btc(String recordId, String objectName) {
        this.RecordId = recordId;
        this.RecordIds = new List<String>();
        this.Query = GenerateQuery(objectName) + ' AND Id =: RecordId';
    }
    
    /*
    * Description: Class constructor with multiple record Ids.
    *
    * Last modified by Johnny in Prodigy on 21-06-2023.
    */
    public Pro_SendEmailBatches_btc(List<String> recordIds, String objectName) {
        this.RecordId = '';
        this.RecordIds = recordIds;
        this.Query = GenerateQuery(objectName) + ' AND Id =: RecordIds';
    }
    
    
    // ******* Batch Methods ******* \ 
    
    /*
    * Description: Batch start method (Starts the Batch by querying the Database for records).
    *
    * Last modified by Johnny in Prodigy on 21-06-2023.
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(this.Query);
    }
    
    /*
    * Description: Batch execute method (Executes the Batch to start processing records).
    *
    * Last modified by Johnny in Prodigy on 13-07-2023.
    */
    public void execute(Database.BatchableContext bc, List<SObject> scopeObjects) {

        String emailSubject, emailBody, objectApiName;

        objectApiName = String.valueOf(scopeObjects[0].getSObjectType());

        EmailTemplate emailTemplate = GetEmailTemplate(objectAPIName);

        emailSubject = emailTemplate.Subject;
        
        for (SObject currentObject : scopeObjects) {
            
            if ((!String.isBlank(String.valueOf(currentObject.getSObject('AcctSeed__Vendor__r').get('pro_Email__c'))))) {

                emailBody = GetEmailBody(emailTemplate, currentObject);

                String recipientEmailAddress = Test.isRunningTest() ? 'SFAdmin@weareprodigy.com' : String.valueOf(currentObject.getSObject('AcctSeed__Vendor__r').get('pro_Email__c')), 
                senderEmailAddress = pro_PCS__c.getInstance().pro_Remittance_Batch_Email__c,
                recordId = currentObject.Id;

                String ccEmailAddress = '';
                
                if (!String.isBlank(String.valueOf(currentObject.getSObject('AcctSeed__Vendor__r').get('pro_Remittance_CC_Email__c')))) {
                    
                    ccEmailAddress = Test.isRunningTest() ? 'SFAdmin@weareprodigy.com' : String.valueOf(currentObject.getSObject('AcctSeed__Vendor__r').get('pro_Remittance_CC_Email__c'));
                }

                System.debug('Receiver: ' + recipientEmailAddress);
                System.debug('Sender: ' + senderEmailAddress);
                System.debug('Record: ' + recordId);
                
                Boolean sendingResult = Pro_SharePdf_con.SharePDF(recipientEmailAddress, senderEmailAddress, ccEmailAddress, emailSubject, emailBody, recordId);

                System.debug('Sending Result: ' + sendingResult);
            } else {

                System.debug('Email is Blank');

                UpdateFailedRecord(currentObject);
            }
        }
    }
    
    /*
    * Description: Batch finish method (Fires when the Batch has finished processing records).
    *
    * Last modified by Johnny in Prodigy on 21-06-2023.
    */
    public void finish(Database.BatchableContext bc) {
        // insert code here
    }
    
    /*
    * Description: Generates Query for the batch class.
    *
    * Last modified by Johnny in Prodigy on 21-06-2023.
    */
    @testvisible
    static String GenerateQuery(String objectName) {

        String stringResult = 'SELECT ';

        String searchCriteria = '';
        String objectApiName = '';

        string subQuery = '';

        switch on objectName {

            when 'Cash Disbursement' {
                
                objectApiName = 'AcctSeed__Cash_Disbursement__c';
                subQuery = ', AcctSeed__Vendor__r.Name, AcctSeed__Contact__r.Name, AcctSeed__Vendor__r.pro_Email__c, AcctSeed__Vendor__r.pro_Remittance_CC_Email__c';
                searchCriteria = '(pro_Email_Sent_To_Supplier__c = false OR pro_Email_Sent_To_Supplier__c = true)';
            }
            when else {
                
            }
        }

        List<String> fieldLists = Pro_Utilities.GetObjectFields(objectApiName);
        
        stringResult += String.join(fieldLists, ',') + subQuery;
        stringResult += ' FROM ' + objectApiName;

        if (String.isNotBlank(searchCriteria)) {
            
            stringResult += ' WHERE ' + searchCriteria;
        }
        
        return stringResult;
    }

    /*
    * Description: Retrieves the Email Template from the system.
    *
    * Last modified by Johnny in Prodigy on 22-06-2023.
    */
    @testvisible
    static EmailTemplate GetEmailTemplate(String objectAPIName) {

        String emailTemplateName;

        switch on objectAPIName {

            when 'AcctSeed__Cash_Disbursement__c' {
                emailTemplateName = pro_PCS__c.getInstance().pro_Remittance_PDF__c;
            }
            when else {
                
            }
        }

        return [
            SELECT
                Id,
                Body,
                Name,
                Subject,
                IsActive,
                HtmlValue
            FROM
                EmailTemplate
            WHERE
                DeveloperName LIKE: emailTemplateName
            AND
                IsActive = true
            LIMIT 
                1
        ];
    }

    /*
    * Description: Retrieves the Email Body after Merge fields have been applied.
    *
    * Last modified by Johnny in Prodigy on 22-06-2023.
    */
    @testvisible
    static String GetEmailBody(EmailTemplate emailTemplate, SObject record) {

        String result = '';

        if ((emailTemplate != null) && (record != null)) {
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id, 
                UserInfo.getUserId(), 
                record.Id);

            result = email.getPlainTextBody();
        }

        return result;
    }

    /*
    * Description: Method used to update the record if it has failed to send.
    *
    * Last modified by Johnny in Prodigy on 13-07-2023.
    */
    @testvisible
    static void UpdateFailedRecord(SObject incomingObject) {

        System.debug('In failed update');

        Savepoint savePoint = Database.setSavePoint();

        incomingObject.put('pro_Email_Sending_Status__c', 'Blank Email');

        Boolean lockedPattern = Approval.isLocked(incomingObject.Id);

        if (lockedPattern) {
            
            Approval.unlock(incomingObject.Id);
        }

        Pro_Utilities.ResultWrap updateResult = Pro_Utilities.UpdateRecords(new List<SObject>{ incomingObject }, savePoint);

        System.debug('Result: ' + updateResult.Result);

        if (lockedPattern) {
            
            Approval.lock(incomingObject.Id);
        }
    }
}