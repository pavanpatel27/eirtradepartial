/*
 * Created by Prodigy on 21-03-2023.
 *
 * Description: Controller class used for sharing PDF documents.
 *
 * Last modified by Johnny in Prodigy on 04-08-2023.
*/
public without sharing class Pro_SharePdf_con {
    
    //
    // --- SECTION: Public Method(s)
    //

    /*
    * Description: Returns Seed Data to the specified LWC.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    @AuraEnabled
    public static String SeedData(String recordID){
     
        String jsonResult = '';

        if ((recordID != null) && (String.isNotBlank(recordID))) {

            Pro_SharePdf_con.SeedWrap seedWrapper = new Pro_SharePdf_con.SeedWrap();
            seedWrapper.orgUrl = System.Url.getSalesforceBaseUrl().toExternalForm();

            String objectApiName = Id.valueOf(recordID).getSobjectType().getDescribe().getName();
            String objectLabelName = Id.valueOf(recordID).getSobjectType().getDescribe().getLabel();

            seedWrapper.recordType = objectLabelName;
            seedWrapper.visualforcePage = GetVisualforcePage(objectAPIName);

            SObject record = (SObject) Pro_Utilities.GetRecords(objectApiName,
                new List<String>{ recordID }, 
                'Id', 
                '') [0];
            
            seedWrapper.record = record;

            seedWrapper.userCanSharePdf = IsRecordShareable(record, objectApiName);

            EmailTemplate emailTemplate = GetEmailTemplate(objectApiName);

            if (emailTemplate != null) {
                
                seedWrapper.emailSubject = emailTemplate.Subject;

                String emailBody = GetEmailBody(emailTemplate, record);

                seedWrapper.emailBody = emailBody;
            }

            seedWrapper.listOfEmails = GetOrgEmails();

            jsonResult = JSON.serialize( seedWrapper );
        }

        return jsonResult;
    }

    /*
    * Description: Shares (Sends) the PDF to Vendor.
    *
    * Last modified by Johnny in Prodigy on 26-06-2023.
    */
    @AuraEnabled
    public static Boolean SharePDF(String recipientEmailAddress, String senderEmailAddress, String ccEmailAddresses,
        String emailSubject, String emailBody, String recordId){
        
        Boolean result = true;

        Savepoint savePoint = Database.setSavePoint();

        String objectAPIName = Id.valueOf(recordId).getSobjectType().getDescribe().getName();

        if ((!String.isBlank(recordId)) && (!String.isBlank(recipientEmailAddress)) && (!String.isBlank(emailSubject)) && (!String.isBlank(senderEmailAddress))) {
            
            SObject record = (SObject) Pro_Utilities.GetRecords(objectAPIName,
                new List<String>{ recordId }, 
                'Id', 
                null) [0];

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ recipientEmailAddress });
            email.setWhatId(recordId);
            email.setSaveAsActivity(true);
            email.setPlainTextBody(emailBody);

            String fileName = '';

            if (objectAPIName == 'AcctSeed__Cash_Disbursement__c') {
                
                fileName = (String)record.get('AcctSeed__Reference__c');
            } else {

                fileName = (String)record.get('Name');
            }

            Pro_Utilities.ResultWrap file = AttachPDF(recordId, fileName, savePoint, objectAPIName);

            if (file.Result) {
                
                email.setEntityAttachments(new List<Id>{ file.ErrorTitle });
            } else {

                result = false;
            }

            List<OrgWideEmailAddress> orgWideEmail = GetOrgWideEmailAddressId(senderEmailAddress);

            if (!orgWideEmail.isEmpty()) {
                
                email.setOrgWideEmailAddressId(orgWideEmail[0].Id);
            } else {

                email.setSenderDisplayName('EirTrade');
            }

            if ((!String.isEmpty(ccEmailAddresses)) && (ccEmailAddresses != null)) {
                
                List<String> ccEmails = ccEmailAddresses.split(';');
                email.setCcAddresses(ccEmails);
            }

            email.setSubject(emailSubject);

            Messaging.SendEmailResult[] results;

            if (result) {
                
                try {
                
                    results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email }, false);
                } catch (Exception ex) {
                    
                    insert new pro_Error_Log__c(
                        pro_Error_Message__c = ex.getMessage(),
                        pro_Error_Trace__c = ex.getStackTraceString(),
                        pro_Related_Records__c = recordId
                    );
                }
    
                if (results != null) {
                    
                    if (results[0].isSuccess()) {
                        
                        result = true;
                        UpdateRecords(new List<SObject> { record }, savePoint);
                    } else {
    
                        List<Messaging.SendEmailError> errors = results[0].getErrors();
    
                        List<pro_Error_Log__c> errorLogs = new List<pro_Error_Log__c>();
    
                        for (Messaging.SendEmailError currentError : errors) {
                            
                            errorLogs.add(
                                new pro_Error_Log__c(
                                    pro_Error_Message__c = currentError.message,
                                    pro_Related_Records__c = recordId,
                                    pro_Error_Trace__c = 'Pro_SharePdf_con.SharePDF line 135.'
                                )
                            );

                            if (Id.valueOf(record.Id).getSobjectType().getDescribe().getName() == 'AcctSeed__Cash_Disbursement__c') {
                                
                                UpdateRecordsFailed(new List<SObject> { record }, savePoint);
                            }
                        }
    
                        if (!errorLogs.isEmpty()) {
    
                            Pro_Utilities.ResultWrap insertError = Pro_Utilities.InsertRecords(errorLogs, savePoint);
                        }
                    }
                }
            }            
        }

        return result;
    }

    /*
    * Description: Method used for saving of the PDF document to the record.
    *
    * Last modified by Johnny in Prodigy on 24-03-2023.
    */
    @AuraEnabled
    public static string SavePDF(String recordId){

        String result = '';

        Savepoint savePoint = Database.setSavepoint();

        if (String.isNotBlank(recordId)) {
            
            String objectAPIName = Id.valueOf(recordId).getSobjectType().getDescribe().getName();

            SObject record = (SObject) Pro_Utilities.GetRecords(objectAPIName,
                new List<String>{ recordId }, 
                'Id', 
                null) [0];

            String recordName;

            switch on objectAPIName {
                when 'pro_Purchase_Order__c' {
                    recordName = 'Purchase Order';
                }
                when 'AcctSeed__Cash_Disbursement__c' {
                    recordName = 'Remittance';
                }
                when else {
                    
                }
            }

            Pro_Utilities.ResultWrap attachmentResult = AttachPDF(recordId, recordName, savePoint, objectAPIName);

            result = JSON.serialize(attachmentResult);
        }

        return result;
    }

    //
    // --- SECTION: Private Method(s)
    //

    /*
    * Description: Attaches the PDF to the relevant record.
    *
    * Last modified by Johnny in Prodigy on 24-03-2023.
    */
    @testvisible
    static Pro_Utilities.ResultWrap AttachPDF(String recordId, String recordName, Savepoint savePoint, String objectAPIName) {
        
        Pro_Utilities.ResultWrap result = new Pro_Utilities.ResultWrap();

        Pagereference pageRef;

        switch on objectAPIName {
            when 'pro_Purchase_Order__c' {
                pageRef = Page.Pro_PurchaseOrderPDF;
            }
            when 'AcctSeed__Cash_Disbursement__c' {
                pageRef = Page.Pro_RemittancePDF;
            }
            when else {
                
            }
        }

        pageRef.getParameters().put('id', recordId);
        pageRef.getParameters().put('savePDF', recordId);

        Blob contentBlob;

        if (!Test.isRunningTest()) {
            
            contentBlob = pageRef.getContent();
        } else {

            contentBlob = Blob.valueOf('This is a test');
        }

        Datetime currentDateTime = DateTime.Now();
        String fileName = recordName + ': ' + currentDateTime.format('dd-MM-yyyy @ HH:mm');

        String baseUrl = Url.getSalesforceBaseUrl().toExternalForm();
        String filePath = baseUrl + '/sfc/servlet.shepherd/version/download/' + fileName + '.pdf';

        ContentVersion cv = new ContentVersion(
            ContentLocation = 'S',
            Title = fileName + '.pdf',
            VersionData = contentBlob,
            PathOnClient = filePath,
            Description = recordId
        );

        result = Pro_Utilities.InsertRecords(new List<ContentVersion>{ cv }, 
            savePoint);

        if (result.Result) {

            ContentVersion cv2 = [
                SELECT
                    Id,
                    ContentDocumentId,
                    Description
                FROM
                    ContentVersion
                WHERE
                    Id =: cv.Id
            ];

            ContentDocumentLink cdl = new ContentDocumentLink(
                ShareType = 'V',
                LinkedEntityId = recordId,
                ContentDocumentId = cv2.ContentDocumentId
            );

            result = Pro_Utilities.InsertRecords(new List<ContentDocumentLink> { cdl }, 
                savePoint);

            if (result.Result) {

                result.ErrorTitle = cv.Id;
            }
        }

        return result;
    }

    /*
    * Description: Verifies whether the Record has been approved or not.
    *
    * Last modified by Johnny in Prodigy on 21-03-2023.
    */
    @testvisible
    static Boolean IsRecordShareable(Sobject record, String objectAPIName) {

        Boolean result = false;
        
        if (record != null) {

            switch on objectAPIName {
                when 'pro_Purchase_Order__c' {

                    String status = (String) record.get('pro_Status__c');

                    if ((status != null) && (status == 'Approved')) {
                        
                        result = true;
                    }
                }
                when else {
                    
                    result = true;
                }
            }
            

        }
        
        return result;
    }

    /*
    * Description: Retrieves the Email Template from the system.
    *
    * Last modified by Johnny in Prodigy on 21-03-2023.
    */
    @testvisible
    static EmailTemplate GetEmailTemplate(String objectAPIName) {

        String emailTemplateName;

        switch on objectAPIName {
            when 'pro_Purchase_Order__c' {
                emailTemplateName = pro_PCS__c.getInstance().pro_Purchase_Order_PDF__c;
            }
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
    * Description: Retrieves the Visualforce PDF page from the system.
    *
    * Last modified by Johnny in Prodigy on 23-03-2023.
    */
    @testvisible
    static String GetVisualforcePage(String objectAPIName) {
        
        String result = '';
        
        switch on objectAPIName {
            when 'pro_Purchase_Order__c' {
                result = pro_PCS__c.getInstance().pro_Purchase_Order_Visualforce_Page__c;
            }
            when 'AcctSeed__Cash_Disbursement__c' {
                result = pro_PCS__c.getInstance().pro_Remittance_Visualforce_Page__c;
            }
            when else {
                
            }
        }
        
        return result;
    }

    /*
    * Description: Retrieves All Org Wide Email Addresses in the Org.
    *
    * Last modified by Johnny in Prodigy on 21-03-2023.
    */
    @testvisible
    static String GetOrgEmails() {

        List<String> emailAddresses = new List<String>();

        emailAddresses.add( UserInfo.getUserEmail() );
        
        for (OrgWideEmailAddress currentEmail : [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress] ) {

            emailAddresses.add(currentEmail.Address);
        }

        return JSON.serialize(emailAddresses);
    }

    /*
    * Description: Retrieves Org Wide Email Address Id if Org Wide email is used.
    *
    * Last modified by Johnny in Prodigy on 21-03-2023.
    */
    @testvisible
    static List<OrgWideEmailAddress> GetOrgWideEmailAddressId( String emailFromAddress ) {

        return [
            SELECT
                Id,
                Address,
                DisplayName
            FROM
                OrgWideEmailAddress
            WHERE
                Address =: emailFromAddress
            LIMIT
                1
        ];
    }

    /*
    * Description: Retrieves the Email Body after Merge fields have been applied.
    *
    * Last modified by Johnny in Prodigy on 21-03-2023.
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
    * Description: Updates the records that the email has been sent to the relevant parties.
    *
    * Last modified by Johnny in Prodigy on 28-06-2023.
    */
    @testvisible
    static void UpdateRecords(List<SObject> recordsList, Savepoint savePoint) {

        List<Id> idList = new List<Id>();

        for (SObject currentObject : recordsList) {
        
            if (Id.valueOf(currentObject.Id).getSobjectType().getDescribe().getName() == 'AcctSeed__Cash_Disbursement__c') {
                
                currentObject.put('pro_Email_Sending_Status__c', 'Sent');
            }

            currentObject.put('pro_Email_Sent_To_Supplier__c', true);
            idList.add(currentObject.Id);
        }

        Map<Id,Boolean> lockedPattern = Approval.isLocked( idList );

        List<String> lockedIds = new List<String>();

        for (Id currentId : lockedPattern.keySet()) {

            Boolean result = lockedPattern.get(currentId);

            if (result) {
                
                lockedIds.add(currentId);
            }
        }

        if (!lockedIds.isEmpty()) {

            Approval.unlock( lockedIds );
        }

        Pro_Utilities.ResultWrap updateResult = Pro_Utilities.UpdateRecords(recordsList, savePoint);

        if (!lockedIds.isEmpty()) {

            Approval.lock( lockedIds );
        }   
    }

    /*
    * Description: Updates the records that the email has failed to send to the relevant parties.
    *
    * Last modified by Johnny in Prodigy on 28-06-2023.
    */
    @testvisible
    static void UpdateRecordsFailed(List<SObject> recordList, Savepoint savePoint) {

        List<Id> idList = new List<Id>();

        for (SObject currentRecord : recordList) {
            
            currentRecord.put('pro_Email_Sending_Status__c', 'Failed');
            idList.add(currentRecord.Id);
        }

        Map<Id,Boolean> lockedPattern = Approval.isLocked( idList );

        List<String> lockedIds = new List<String>();

        for (Id currentId : lockedPattern.keySet()) {

            Boolean result = lockedPattern.get(currentId);

            if (result) {
                
                lockedIds.add(currentId);
            }
        }

        if (!lockedIds.isEmpty()) {

            Approval.unlock( lockedIds );
        }

        Pro_Utilities.ResultWrap updateResult = Pro_Utilities.UpdateRecords(recordList, savePoint);

        if (!lockedIds.isEmpty()) {

            Approval.lock( lockedIds );
        }
    }

    //
    // --- SECTION: Wrapper Class(es)
    //

    /*
    * Description: Wrapper class for returning Seed Data.
    *
    * Last modified by Johnny in Prodigy on 21-03-2023.
    */
    @testvisible
    class SeedWrap{

        public String orgUrl { get; set; }
        public String emailBody { get; set; }
        public String emailSubject { get; set; }
        public String listOfEmails { get; set; }
        public Boolean userCanSharePdf { get; set; }
        public SObject record { get; set; }
        public String recordType { get; set; }
        public String visualforcePage { get; set; }
    }
}