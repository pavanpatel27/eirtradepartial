/*
 * Created by Prodigy on 11-05-2023.
 *
 * Description: Trigger for the inscor__Release__c SObject.
 *
 * Last modified by Johnny in Prodigy on 11-05-2023.
*/
trigger Pro_Release_trg on inscor__Release__c (before insert, after insert, before update, after update, before delete, after delete) {

    if( true ){
        if( (Trigger.isInsert) && (Trigger.isBefore) ) { Pro_Release_han.OnCreate(Trigger.new, true); }
        if( (Trigger.isInsert) && (Trigger.isAfter) ) { Pro_Release_han.OnCreate(Trigger.new, false); }
    
        if( (Trigger.isUpdate) && (Trigger.isBefore) ) { Pro_Release_han.OnUpdate(Trigger.new, true, Trigger.oldMap); }
        if( (Trigger.isUpdate) && (Trigger.isAfter) ) { Pro_Release_han.OnUpdate(Trigger.new, false, Trigger.oldMap); }
    
        if( (Trigger.isDelete) && (Trigger.isBefore) ) { Pro_Release_han.OnDelete(Trigger.old, true, Trigger.oldMap); }
        if( (Trigger.isDelete) && (Trigger.isAfter) ) { Pro_Release_han.OnDelete(Trigger.old, false, Trigger.oldMap); }
    }
}