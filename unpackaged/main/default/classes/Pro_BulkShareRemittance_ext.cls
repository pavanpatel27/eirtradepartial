/*
 * Created by Johnny in Prodigy on 22-06-2023.
 *
 * Description: Extention class for Pro_BulkShareRemittance.
 *
 * Last modified by Johnny in Prodigy on 28-06-2023.
*/
public class Pro_BulkShareRemittance_ext {
    
    public List<AcctSeed__Cash_Disbursement__c> selectedRecords {get; private set;}

    /*
    * Description: Default constructor class.
    *
    * Last modified by Johnny in Prodigy on 22-06-2023.
    */
    public Pro_BulkShareRemittance_ext(ApexPages.StandardSetController standardController) {

        selectedRecords = (List<AcctSeed__Cash_Disbursement__c>) standardController.getSelected();
    }

    /*
    * Description: Method used to send all the selected Cash Disbursements to the relevant batch class.
    *
    * Last modified by Johnny in Prodigy on 28-06-2023.
    */
    public Pagereference SendRecords() {

        Schema.DescribeSObjectResult result = AcctSeed__Cash_Disbursement__c.getSObjectType().getDescribe();

        if (selectedRecords.size() > 0) {

            UpdateRecords(selectedRecords);

            List<String> recordIds = new List<String>();

            for (AcctSeed__Cash_Disbursement__c currentDisbursement : selectedRecords) {

                    recordIds.add(currentDisbursement.Id); 
            }

            Database.executeBatch(new Pro_SendEmailBatches_btc(recordIds, 'Cash Disbursement'), 1);
        }

        Pagereference pageRef = new Pagereference('/' + result.getKeyPrefix());

        pageRef.setRedirect(true);

        return pageRef;
    }

    /*
    * Description: Method used to update the status of records that are being sent to 'In Progress'.
    *
    * Last modified by Johnny in Prodigy on 28-06-2023.
    */
    @testvisible
    static void UpdateRecords(List<AcctSeed__Cash_Disbursement__c> recordList) {
        
        Savepoint savePoint = Database.setSavePoint();

        List<Id> idList = new List<Id>();

        for (SObject currentObject : recordList) {
        
            if (Id.valueOf(currentObject.Id).getSobjectType().getDescribe().getName() == 'AcctSeed__Cash_Disbursement__c') {
                
                currentObject.put('pro_Email_Sending_Status__c', 'In Progress');
            }

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

        Pro_Utilities.ResultWrap updateResult = Pro_Utilities.UpdateRecords(recordList, savePoint);

        if (!lockedIds.isEmpty()) {

            Approval.lock( lockedIds );
        }
    }
}