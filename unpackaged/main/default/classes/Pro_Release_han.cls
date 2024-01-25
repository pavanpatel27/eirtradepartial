/*
 * Created by Prodigy on 09-05-2023.
 *
 * Description: Handler class for the Release trigger.
 *
 * Last modified by Johnny in Prodigy on 15-05-2023.
*/
public without sharing class Pro_Release_han {
    
    //
    // --- SECTION START: Public Trigger Methods
    //
    
    /*
    * Description: On Create actions (Before & After).
    *
    * Last modified by Johnny in Prodigy on 09-05-2023.
    */
    public static void OnCreate(List<SObject> records, Boolean isBefore) {
        if (isBefore) {
            // Before Create Actions 
        } else {
            // After Create Actions
        }
    }
    
    /*
    * Description: On Update Actions (Before & After).
    *
    * Last modified by Johnny in Prodigy on 09-05-2023.
    */
    public static void OnUpdate(List<SObject> records, Boolean isBefore, Map<Id, SObject> oldMap) {
        if (isBefore) {
            // Before Update Actions 
        } else {
            
            FilterReleases(records);
        }
    }
    
    /*
    * Description: On Delete Actions (Before & After).
    *
    * Last modified by Johnny in Prodigy on 09-05-2023.
    */
    public static void OnDelete(List<SObject> records, Boolean isBefore, Map<Id, SObject> oldMap) {
        if (isBefore) {
            // Before Delete Actions 
        } else {
            // After Delete Actions
        }
    }
    
    //
    // --- SECTION END: Public Trigger Methods
    //
    
    //
    // --- SECTION START: Private Trigger Methods
    //
    
    /*
    * Description: Filters the incoming release objects and sends an email dependant on the specified entry criteria.
    *
    * Last modified by Johnny in Prodigy on 15-05-2023.
    */
    @testvisible
    static void FilterReleases(List<inscor__Release__c> incomingRecords) {
        
        for (inscor__Release__c currentRecord : incomingRecords) {
            
            if ((currentRecord.inscor__Status__c == 'Shipped') && 
                (String.isNotBlank(currentRecord.SO_Contact_Email__c)) && 
                (currentRecord.pro_SO_Emailed__c == false)) {
                
                Pro_Release_con.ProcessRelease(currentRecord);
            }
        }
    }

    //
    // --- SECTION END: Private Trigger Methods
    //
}