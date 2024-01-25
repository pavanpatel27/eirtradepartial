/*
 * Created by Prodigy on 10-05-2023.
 *
 * Description: Controller class for the inscor__Release__c class.
 *
 * Last modified by Johnny in Prodigy on 21-09-2023.
*/
public class Pro_Release_con {
    
    //
    // --- SECTION START: Public Methods
    //

    /*
    * Description: Processes the incoming inscor__Release__c object.
    *
    * Last modified by Johnny in Prodigy on 29-05-2023.
    */
    public static void ProcessRelease(inscor__Release__c incomingObject) {

        List<String> recipientAddresses = new List<String>();

        recipientAddresses.add(String.valueOf(incomingObject.Salesperson__c));
        recipientAddresses.add(String.valueOf(incomingObject.SO_Contact_Email__c));

        EmailTemplate eTemplate = GetEmailTemplate();

        Messaging.SingleEmailMessage emailBody = Messaging.renderStoredEmailTemplate(eTemplate.Id,
            UserInfo.getUserId(),
            incomingObject.Id);

        Messaging.SingleEmailMessage releaseEmail = new Messaging.SingleEmailMessage();
        releaseEmail.setToAddresses(recipientAddresses);
        releaseEmail.setWhatId(incomingObject.Id);
        releaseEmail.setSaveAsActivity(true);
        releaseEmail.setPlainTextBody(emailBody.getPlainTextBody());
        releaseEmail.setSubject(emailBody.getSubject());
        
        String emailAttachment = Test.isRunningTest() ? 'Test' : GetEmailAttachment(incomingObject.inscor__Sales_Order__c);

        if (emailAttachment != '') {
            
            releaseEmail.setEntityAttachments(new List<String>{ emailAttachment });
        }

        releaseEmail.setSenderDisplayName('EirTrade');

        Messaging.SendEmailResult[] results;

        try {
            
            results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { releaseEmail }, false);
        } catch (Exception ex) {
            
            insert new pro_Error_Log__c(
                pro_Error_Message__c = ex.getMessage(),
                pro_Error_Trace__c = ex.getStackTraceString(),
                pro_Related_Records__c = incomingObject.Id
            );
        }

        if (results != null) {
            
            if (results[0].isSuccess()) {
                
                UpdateRecords(new List<inscor__Release__c>{ incomingObject });
            } else {

                List<Messaging.SendEmailError> emailErrors = results[0].getErrors();

                List<pro_Error_Log__c> errorLogs = new List<pro_Error_Log__c>();

                for (Messaging.SendEmailError currentError : emailErrors) {
                    
                    errorLogs.add(
                        new pro_Error_Log__c(
                            pro_Error_Message__c = currentError.message,
                            pro_Related_Records__c = incomingObject.Id,
                            pro_Error_Trace__c = 'Pro_Release_con.ProcessRelease line 48.'
                        )
                    );
                }

                if (!errorLogs.isEmpty()) {
                    
                    Savepoint savePoint = Database.setSavePoint();

                    Pro_Utilities.ResultWrap insertError = Pro_Utilities.InsertRecords(errorLogs, savePoint);
                }
            }
        }
    }

    //
    // --- SECTION START: Private Methods
    //

    /*
    * Description: Retrieves the relevant Email Template from the system.
    *
    * Last modified by Johnny in Prodigy on 10-05-2023.
    */
    @testvisible
    static EmailTemplate GetEmailTemplate() {

        String emailTemplateName = pro_PCS__c.getInstance().pro_Release_Email_Template__c;

        System.debug(emailTemplateName);
        
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
    * Description: Retrieves the relevant Invoice to attach to the email.
    *
    * Last modified by Johnny in Prodigy on 21-09-2023.
    */
    @testvisible
    static String GetEmailAttachment(String recordId) {

        String result = '';

        List<ContentDocumentLink> documentLinks = [
            SELECT
                Id,
                ContentDocumentId,
                LinkedEntityId,
                ContentDocument.LastModifiedDate
            FROM
                ContentDocumentLink
            WHERE
                LinkedEntityId =: recordId
        ];

        if (documentLinks.size() > 0) {
            
            Id tempDocumentId;
            Datetime tempDate = documentLinks[0].ContentDocument.LastModifiedDate;
    
            for (Integer i = 0; i < documentLinks.size(); i++) {
                
                if (documentLinks[i].ContentDocument.LastModifiedDate >= tempDate) {
                    
                    tempDate = documentLinks[i].ContentDocument.LastModifiedDate;
                    tempDocumentId = documentLinks[i].ContentDocumentId;
                }
            }

            ContentVersion documentVersion = [
                SELECT
                    Id
                FROM
                    ContentVersion
                WHERE 
                    ContentDocumentId =: tempDocumentId 
                AND 
                    IsLatest = true
                AND
                    Title LIKE '%Proforma%'
            ];

            result = documentVersion.Id;
        }

        return result;
    }

    /*
    * Description: Updates the relevant Release to indicate that the email has been sent.
    *
    * Last modified by Johnny in Prodigy on 10-05-2023.
    */
    @testvisible
    static void UpdateRecords(List<inscor__Release__c> incomingReleases) {

        Savepoint savePoint = Database.setSavePoint();

        List<Id> idList = new List<Id>();

        for (inscor__Release__c currentRelease : incomingReleases) {

            idList.add(currentRelease.Id);
        }

        List<inscor__Release__c> tempList = [
            SELECT
                Id,
                pro_SO_Emailed__c
            FROM
                inscor__Release__c
            WHERE
                Id IN: idList
        ];

        for (inscor__Release__c currentRelease : tempList) {
            
            currentRelease.pro_SO_Emailed__c = true;
        }

        Map<Id, Boolean> lockedPattern = Approval.isLocked(idList);

        List<String> lockedIds = new List<String>();

        for (Id currentId : lockedPattern.keySet()) {
            
            Boolean result = lockedPattern.get(currentId);

            if (result) {
                
                lockedIds.add(currentId);
            }
        }

        if (!lockedIds.isEmpty()) {
            
            Approval.unlock(lockedIds);
        }

        Pro_Utilities.ResultWrap updateResult = Pro_Utilities.UpdateRecords(tempList, savePoint);

        if (!lockedIds.isEmpty()) {
            
            Approval.lock(lockedIds);
        }
    }
}