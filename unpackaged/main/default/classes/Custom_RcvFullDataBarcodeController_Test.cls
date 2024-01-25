@isTest
public class Custom_RcvFullDataBarcodeController_Test {

	@isTest
	public static void runTest(){
		inscor__Receipt__c rec = new inscor__Receipt__c();
		insert rec;

		Test.setCurrentPageReference(new PageReference('Page.Custom_EngineRemovalTagPDF'));
		System.currentPageReference().getParameters().put('recId', rec.Id);
		System.currentPageReference().getParameters().put('size', '2_2');
		System.currentPageReference().getParameters().put('copy', '10');
		System.currentPageReference().getParameters().put('width', '120');
		System.currentPageReference().getParameters().put('height', '120');

		Custom_ReceiveFullDataBarcodeController g = new Custom_ReceiveFullDataBarcodeController();
		system.assert(g.data != null);
	}

	@isTest
	public static void runTest2(){
		inscor__Company__c CompanyRecord = new inscor__Company__c(
            inscor__Company_Name__c = 'Testing Company',
            inscor__Address_1__c = 'Address1',
            inscor__City__c = 'Test City',
            inscor__State__c = 'CA',
            inscor__Zip_Code__c = '12345',
            inscor__Show_Receiving_Barcode_Feature__c = true,            
            inscor__Account_Default_CQ_Approved__c = true,
            inscor__Account_Default_PO_Approved__c = true,
            inscor__Account_Default_RFQ_Approved__c = true,
            inscor__Account_Default_RO_Approved__c = true,
            inscor__Account_Default_SO_Approved__c = true,
            inscor__Account_Default_WO_Approved__c = true,
            inscor__Account_Default_Lease_Approved__c = true
        );
        insert CompanyRecord;
        
        inscor__Company_Location__c CompanyLocationRecord = new inscor__Company_Location__c(
            Name = 'Test Location',
            inscor__Company__c = CompanyRecord.Id
        );
        insert CompanyLocationRecord;
        
        inscor__Employee__c emp = new inscor__Employee__c(
            inscor__Company__c = CompanyRecord.id,
            inscor__User__c = UserInfo.getUserId()
        );
        insert emp;
        
        inscor__Account_Terms__c AcctTermRecord = new inscor__Account_Terms__c(
            Name = 'NCC',
            inscor__Enforce_Credit_Limit__c = false
        );
        insert AcctTermRecord;
        
        Account AccountRecord = new Account(
            Name = 'Account Test Data',
            inscor__QTS_Ratio__c = 1,
            inscor__Account_Number__c = 'test',
            inscor__Account_Terms__c = AcctTermRecord.Id
        );
        insert AccountRecord;
        
        Contact ContactRecord = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'Test@test.com',
            AccountId = AccountRecord.Id,
            inscor__Contact_Options__c = 'Receive Invoice'
        );
        insert ContactRecord;
        
        inscor__Condition_Code__c ConditionCodeRecord = new inscor__Condition_Code__c(
            Name = 'TestCCTest',
            inscor__Show_in_Summary__c = true,
            inscor__Summary_Order__c = 123
        );
        insert ConditionCodeRecord;
        
        Product2 ProductRecord = new Product2(
            Name = 'Test Part Master',
            inscor__Keyword__c = 'test',
            inscor__Shelf_Life__c = true,
            inscor__Tool__c = true,
            inscor__Restrict_Sales_to_Condition_Code__c = null
        );
        insert ProductRecord;
        
        inscor__Owner_Code__c OwnerCodeRecord = new inscor__Owner_Code__c(
            Name = '1MTest',
            inscor__Company__c = CompanyRecord.Id
        );
        insert OwnerCodeRecord;
        
        inscor__Repair_Order__c RepairOrderRecord = new inscor__Repair_Order__c(
            inscor__Company__c = CompanyRecord.Id,
            inscor__Vendor__c = AccountRecord.Id,
            inscor__Assigned_To__c = UserInfo.getUserId(),
            inscor__Contact__c = ContactRecord.Id,
            inscor__Ship_To_Location__c = CompanyLocationRecord.Id,
            inscor__Acct__c = '1234567890'
        );
        insert RepairOrderRecord;
        
        inscor__Inventory_Location__c InvLocationRecord = new inscor__Inventory_Location__c(
            Name = 'Test Inv Loc',
            inscor__Company_Location__c = CompanyLocationRecord.Id
        );
        insert InvLocationRecord;
        
        inscor__Warehouse__c WarehouseRecord = new inscor__Warehouse__c(
            Name = 'Test Warehouse',
            inscor__Warehouse_Code__c = 'W123',
            inscor__Company_Location__c = CompanyLocationRecord.id
        );
        insert WarehouseRecord;
        
        inscor__Work_Order__c workOrderRecord = new inscor__Work_Order__c(
            inscor__Customer__c = AccountRecord.Id,
            inscor__Company__c = CompanyRecord.Id
        );
        insert workOrderRecord;
        
        inscor__Inventory_Line__c InventoryLineRecord = new inscor__Inventory_Line__c(
            inscor__Serial_Number__c = '123',
            inscor__Condition_Code__c = ConditionCodeRecord.Id,
            inscor__Product__c = ProductRecord.Id,
            inscor__Quantity__c = 10,
            inscor__Owner_Code__c = OwnerCodeRecord.Id,
            inscor__Repair_Order__c = RepairOrderRecord.Id,
            inscor__Location__c = InvLocationRecord.Id,
            inscor__Warehouse__c = WarehouseRecord.Id,
            inscor__Quantity_on_Exchange__c = 5,
            inscor__Work_Order__c = workOrderRecord.Id
        );
        insert InventoryLineRecord;
        
        inscor__Form_Options__c formOptionRecord = new inscor__Form_Options__c(
            Name = 'Engine Removal Tag',
            inscor__Footer__c = '<p>Test Engine Removal Tag</p>',
            inscor__VF_Reference__c = 'inscor__Custom_EngineRemovalTagPDF',
            inscor__Title__c = 'Engine Removal Tag',
            inscor__Company__c = CompanyRecord.Id,
            inscor__Form_Available__c = '',
            inscor__Line_Level_Document__c = false,
            inscor__Line_Selections_Allowed__c = false,
            inscor__Override_Screen_Required__c = false,
            inscor__Description__c = 'Uses the custom forms feature.',
            inscor__Body_1__c = '<b>Test Letterhead</b>'
        );
        insert formOptionRecord;

		Test.setCurrentPageReference(new PageReference('Page.Custom_EngineRemovalTagPDF'));
		System.currentPageReference().getParameters().put('invid', InventoryLineRecord.Id);
		System.currentPageReference().getParameters().put('size', '2_2');
		System.currentPageReference().getParameters().put('copy', '10');
		System.currentPageReference().getParameters().put('width', '120');
		System.currentPageReference().getParameters().put('height', '120');
		System.currentPageReference().getParameters().put('foId', formOptionRecord.Id);
		System.currentPageReference().getParameters().put('footer', '<p>Longggggggg tesrerdfd gfdfoodfd gfdfr rferefdfdf fd fdf df dfdfdfdfdfwfrfs swfsw fsfsfswfsf sfsf sfs</p>');

		Custom_ReceiveFullDataBarcodeController g = new Custom_ReceiveFullDataBarcodeController();
		system.assert(g.data != null);
	}
}