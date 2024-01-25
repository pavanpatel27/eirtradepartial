@isTest
public class Custom_ReleaseCertPDFController_Test {
	@isTest
	public static void Test_ReleaseCertificatePDFController() {
		//Setup Data
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
        
        inscor__Employee__c emp = new inscor__Employee__c(
            inscor__Company__c = CompanyRecord.id,
            inscor__User__c = UserInfo.getUserId()
        );
        insert emp;
        
        //Setup Data
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
        
        inscor__Company_Location__c CompanyLocationRecord = new inscor__Company_Location__c(
            Name = 'Test Location',
            inscor__Company__c = CompanyRecord.Id
        );
        insert CompanyLocationRecord;

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
        
        inscor__Inventory_Line__c InventoryLineRecord = new inscor__Inventory_Line__c(
            inscor__Serial_Number__c = '123',
            inscor__Condition_Code__c = ConditionCodeRecord.Id,
            inscor__Product__c = ProductRecord.Id,
            inscor__Quantity__c = 10,
            inscor__Owner_Code__c = OwnerCodeRecord.Id,
            inscor__Repair_Order__c = RepairOrderRecord.Id,
            inscor__Location__c = InvLocationRecord.Id,
            inscor__Warehouse__c = WarehouseRecord.Id,
            inscor__Quantity_on_Exchange__c = 5
        );
        insert InventoryLineRecord;
 
        inscor__Sales_Order__c SalesOrderRecord = new inscor__Sales_Order__c(
            inscor__Customer__c = AccountRecord.Id,
            inscor__Assigned_To__c = UserInfo.getUserId(),
            inscor__Company__c = CompanyRecord.Id,
            inscor__Contact__c = ContactRecord.id
        );
        insert SalesOrderRecord;
        
        SalesOrderRecord.inscor__Company__c = CompanyRecord.Id;
        update SalesOrderRecord;
        
        inscor__Sales_Order_Line__c SalesOrderLineRecord = new inscor__Sales_Order_Line__c(
            inscor__Line_Number__c = 1,
            inscor__Order__c = SalesOrderRecord.Id,
            inscor__Quantity_Ordered__c = 500,
            inscor__Price__c =  1,
            inscor__Condition_Code__c = ConditionCodeRecord.Id,
            inscor__Product__c = ProductRecord.Id
        );
        insert SalesOrderLineRecord;
        
        inscor__Allocation__c AllocationRecord = new inscor__Allocation__c(
            inscor__Sales_Order__c = SalesOrderRecord.Id,
            inscor__Sales_Order_Line__c = SalesOrderLineRecord.Id,
            inscor__Allocation_Type__c = 'Stock',
            inscor__Inventory_Line__c = InventoryLineRecord.Id,
            inscor__Quantity_Allocated__c = 100,
            inscor__Quantity_Shipped__c = 0,
            inscor__Status__c = 'Allocated'
        );
        insert AllocationRecord;

         inscor__Release__c ReleaseRecord = new inscor__Release__c(
            inscor__Sales_Order__c = SalesOrderRecord.id,
            inscor__Status__c = 'Released',
            inscor__Requested_Ship_Date__c = system.today().addDays(-5),
            inscor__Acct__c = '1234',
            inscor__Release_Type__c = 'Sales Order'
        );
        insert ReleaseRecord;

        inscor__Release_Line__c RLineRecord =  new inscor__Release_Line__c(
            inscor__Release__c = ReleaseRecord.id,
            inscor__Status__c = 'Released',
            inscor__Allocation__c = AllocationRecord.Id,
            inscor__Sales_Order_Line__c = SalesOrderLineRecord.Id,
            inscor__Price__c = 10
        );
        insert RLineRecord;
        
        SalesOrderRecord.inscor__Company__c = CompanyRecord.Id;
        update SalesOrderRecord;

		Pagereference pgref = Page.Custom_ReleaseCertificate;
		pgref.getParameters().put('id', RLineRecord.Id);
		pgref.getParameters().put('autosigncert', 'true');
		pgref.getParameters().put('active1417', 'false');
		pgref.getParameters().put('active1821', 'false');
		pgref.getParameters().put('showLastOperator', 'true');
		pgref.getParameters().put('gsata', 'true');
		Test.setCurrentPage(pgref);
		System.debug('CompanyRecord.Id: ' + CompanyRecord.Id);
		Custom_ReleaseCertificatePDFController inst_RCPC = new Custom_ReleaseCertificatePDFController();
		system.assert(inst_RCPC.objRL != null);
	}
	@isTest
	public static void Test_ReleaseCertificatePDFController1() {
		//Setup Data
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
        
        inscor__Company_Location__c CompanyLocationRecord = new inscor__Company_Location__c(
            Name = 'Test Location',
            inscor__Company__c = CompanyRecord.Id
        );
        insert CompanyLocationRecord;
        
		inscor__Repair_Order__c ro = new inscor__Repair_Order__c(
            inscor__Company__c = CompanyRecord.Id,
            inscor__Vendor__c = AccountRecord.Id,
            inscor__Assigned_To__c = UserInfo.getUserId(),
            inscor__Contact__c = ContactRecord.Id,
            inscor__Ship_To_Location__c = CompanyLocationRecord.Id,
            inscor__Acct__c = '1234567890'
        );
        insert ro;
        
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
        
        inscor__Repair_Order__c RepairOrderRecord = new inscor__Repair_Order__c(
            inscor__Company__c = CompanyRecord.Id,
            inscor__Vendor__c = AccountRecord.Id,
            inscor__Assigned_To__c = UserInfo.getUserId(),
            inscor__Contact__c = ContactRecord.Id,
            inscor__Ship_To_Location__c = CompanyLocationRecord.Id,
            inscor__Acct__c = '1234567890'
        );
        insert RepairOrderRecord;
        
        inscor__Inventory_Line__c InventoryLineRecord = new inscor__Inventory_Line__c(
            inscor__Serial_Number__c = '123',
            inscor__Condition_Code__c = ConditionCodeRecord.Id,
            inscor__Product__c = ProductRecord.Id,
            inscor__Quantity__c = 10,
            inscor__Owner_Code__c = OwnerCodeRecord.Id,
            inscor__Repair_Order__c = RepairOrderRecord.Id,
            inscor__Location__c = InvLocationRecord.Id,
            inscor__Warehouse__c = WarehouseRecord.Id,
            inscor__Quantity_on_Exchange__c = 5
        );
        insert InventoryLineRecord;
        
        inscor__Repair_Order_Line__c rol = new inscor__Repair_Order_Line__c(
            inscor__Repair_Order__c = ro.Id,
            inscor__Line_Number__c = 1,
            inscor__Expected_Part_Condition__c = ConditionCodeRecord.Id,
            inscor__Expected_Product__c = ProductRecord.Id,
            inscor__Original_Product__c = ProductRecord.Id,
            inscor__Original_Inventory_Line__c = InventoryLineRecord.Id,
            inscor__Quantity_to_Repair__c = 1,
            inscor__Repair_Type_New__c = 'OEM',
            inscor__Expected_Part_Warehouse__c = WarehouseRecord.Id,
            inscor__Quantity_Shipped__c = 0,
            inscor__Quantity_Allocated__c = 0
        );
        insert rol;
		inscor__Release__c r1 = new inscor__Release__c(
			inscor__Status__c = 'Released',
			inscor__Release_Type__c = 'Repair Order',
			inscor__Repair_Order__c = ro.Id,
			inscor__Requested_Ship_Date__c = system.today().addDays(-5),
			inscor__Freight_Charge__c = 200,
			inscor__Acct__c = '1234'
		);
		insert r1;
		inscor__Release_Line__c rl1 = new inscor__Release_Line__c(
			inscor__Release__c = r1.id,
			inscor__Status__c = 'Released',
			inscor__Repair_Order_Line__c = rol.id
		);
		insert rl1;
        
        ro.inscor__Company__c = CompanyRecord.Id;
        update ro;

		Pagereference pgref = Page.Custom_ReleaseCertificate;
		pgref.getParameters().put('id', rl1.Id);
		pgref.getParameters().put('autosigncert', 'true');
		pgref.getParameters().put('active1417', 'false');
		pgref.getParameters().put('active1821', 'false');
		pgref.getParameters().put('showLastOperator', 'true');
		Test.setCurrentPage(pgref);

		Custom_ReleaseCertificatePDFController inst_RCPC = new Custom_ReleaseCertificatePDFController();
		system.assert(inst_RCPC.objRL != null);
	}
	@isTest
	public static void Test_ReleaseCertificatePDFController2() {
		//Setup Data
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
        
        inscor__Company_Location__c CompanyLocationRecord = new inscor__Company_Location__c(
            Name = 'Test Location',
            inscor__Company__c = CompanyRecord.Id
        );
        insert CompanyLocationRecord;
        
        inscor__Warehouse__c WarehouseRecord = new inscor__Warehouse__c(
            Name = 'Test Warehouse',
            inscor__Warehouse_Code__c = 'W123',
            inscor__Company_Location__c = CompanyLocationRecord.id
        );
        insert WarehouseRecord;
        
        inscor__Purchase_Order__c po = new inscor__Purchase_Order__c(
            inscor__Company__c = CompanyRecord.Id,
            inscor__PO_Type__c = 'Spec',
            inscor__Ship_To_Location__c = CompanyLocationRecord.Id,
            inscor__Vendor__c = AccountRecord.Id,
            inscor__Assigned_To__c = UserInfo.getUserId(),
            inscor__Contact__c = ContactRecord.Id
        );
        insert po;
        inscor__Purchase_Order_Line__c pol = new inscor__Purchase_Order_Line__c(
            inscor__PO_Number__c = po.Id,
            inscor__Line_Number__c = 1,
            inscor__Condition_Code__c = ConditionCodeRecord.Id,
            inscor__Product__c = ProductRecord.Id,
            inscor__Quantity__c = 9,
            inscor__Price__c = 100,
            inscor__Owner_Code__c = OwnerCodeRecord.Id,
            inscor__Warehouse__c = WarehouseRecord.Id,
            inscor__Type_Quoted__c = 'Outright'
        );
        insert pol;
		inscor__Release__c r1 = new inscor__Release__c(
			inscor__Status__c = 'Released',
			inscor__Release_Type__c = 'Purchase Order',
			inscor__Purchase_Order__c = po.Id,
			inscor__Requested_Ship_Date__c = system.today().addDays(-5),
			inscor__Freight_Charge__c = 200,
			inscor__Acct__c = '1234'
		);
		insert r1;
		inscor__Release_Line__c rl1 = new inscor__Release_Line__c(
			inscor__Release__c = r1.id,
			inscor__Status__c = 'Released',
			inscor__Purchase_Order_Line__c = pol.id
		);
		insert rl1;

		Pagereference pgref = Page.Custom_ReleaseCertificate;
		pgref.getParameters().put('id', rl1.Id);
		pgref.getParameters().put('autosigncert', 'true');
		pgref.getParameters().put('active1417', 'false');
		pgref.getParameters().put('active1821', 'false');
		pgref.getParameters().put('showLastOperator', 'true');
		Test.setCurrentPage(pgref);

		Custom_ReleaseCertificatePDFController inst_RCPC = new Custom_ReleaseCertificatePDFController();
		system.assert(inst_RCPC.objRL != null);
	}
	@isTest
	public static void Test_ReleaseCertificatePDFController3() {
		//Setup Data
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
        
        inscor__Work_Order__c wo = new inscor__Work_Order__c(
            inscor__Customer__c = AccountRecord.Id,
            inscor__Company__c = CompanyRecord.Id
        );
        insert wo;
		inscor__Release__c r1 = new inscor__Release__c(
			inscor__Status__c = 'Released',
			inscor__Release_Type__c = 'Work Order',
			inscor__Work_Order__c = wo.id,
			inscor__Requested_Ship_Date__c = system.today().addDays(-5),
			inscor__Freight_Charge__c = 200
		);
		insert r1;
		inscor__Release_Line__c rl1 = new inscor__Release_Line__c(
			inscor__Release__c = r1.id,
			inscor__Status__c = 'Released'
		);
		insert rl1;

		Pagereference pgref = Page.Custom_ReleaseCertificate;
		pgref.getParameters().put('id', rl1.Id);
		pgref.getParameters().put('autosigncert', 'true');
		pgref.getParameters().put('active1417', 'false');
		pgref.getParameters().put('active1821', 'false');
		pgref.getParameters().put('showLastOperator', 'true');
		Test.setCurrentPage(pgref);

		Custom_ReleaseCertificatePDFController inst_RCPC = new Custom_ReleaseCertificatePDFController();
		system.assert(inst_RCPC.objRL != null);
	}
	@isTest
	public static void Test_ReleaseCertificatePDFController4() {
		//Setup Data
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
        
        inscor__Company_Location__c CompanyLocationRecord = new inscor__Company_Location__c(
            Name = 'Test Location',
            inscor__Company__c = CompanyRecord.Id
        );
        insert CompanyLocationRecord;
        
        inscor__Warehouse__c WarehouseRecord = new inscor__Warehouse__c(
            Name = 'Test Warehouse',
            inscor__Warehouse_Code__c = 'W123',
            inscor__Company_Location__c = CompanyLocationRecord.id
        );
        insert WarehouseRecord;
        
        inscor__Inventory_Location__c InvLocationRecord = new inscor__Inventory_Location__c(
            Name = 'Test Inv Loc',
            inscor__Company_Location__c = CompanyLocationRecord.Id
        );
        insert InvLocationRecord;
        
        inscor__Repair_Order__c RepairOrderRecord = new inscor__Repair_Order__c(
            inscor__Company__c = CompanyRecord.Id,
            inscor__Vendor__c = AccountRecord.Id,
            inscor__Assigned_To__c = UserInfo.getUserId(),
            inscor__Contact__c = ContactRecord.Id,
            inscor__Ship_To_Location__c = CompanyLocationRecord.Id,
            inscor__Acct__c = '1234567890'
        );
        insert RepairOrderRecord;
        
        inscor__Purchase_Order__c po = new inscor__Purchase_Order__c(
            inscor__Company__c = CompanyRecord.Id,
            inscor__PO_Type__c = 'Spec',
            inscor__Ship_To_Location__c = CompanyLocationRecord.Id,
            inscor__Vendor__c = AccountRecord.Id,
            inscor__Assigned_To__c = UserInfo.getUserId(),
            inscor__Contact__c = ContactRecord.Id
        );
        insert po;
        inscor__Purchase_Order_Line__c pol = new inscor__Purchase_Order_Line__c(
            inscor__PO_Number__c = po.Id,
            inscor__Line_Number__c = 1,
            inscor__Condition_Code__c = ConditionCodeRecord.Id,
            inscor__Product__c = ProductRecord.Id,
            inscor__Quantity__c = 9,
            inscor__Price__c = 100,
            inscor__Owner_Code__c = OwnerCodeRecord.Id,
            inscor__Warehouse__c = WarehouseRecord.Id,
            inscor__Type_Quoted__c = 'Outright'
        );
        insert pol;        
        inscor__Inventory_Line__c InventoryLineRecord = new inscor__Inventory_Line__c(
            inscor__Serial_Number__c = '123',
            inscor__Condition_Code__c = ConditionCodeRecord.Id,
            inscor__Product__c = ProductRecord.Id,
            inscor__Quantity__c = 10,
            inscor__Owner_Code__c = OwnerCodeRecord.Id,
            inscor__Repair_Order__c = RepairOrderRecord.Id,
            inscor__Location__c = InvLocationRecord.Id,
            inscor__Warehouse__c = WarehouseRecord.Id,
            inscor__Quantity_on_Exchange__c = 5
        );
        insert InventoryLineRecord;
        
		inscor__Inventory_Transfer__c it = new inscor__Inventory_Transfer__c();
		it.inscor__Company__c = CompanyRecord.Id;
		it.inscor__Ending_Company_Location__c = CompanyLocationRecord.Id;
		insert it;

		inscor__Inventory_Transfer_Line__c itl = new inscor__Inventory_Transfer_Line__c();
		itl.inscor__Inventory_Transfer__c = it.Id;
		itl.inscor__Inventory_Line__c = InventoryLineRecord.Id;
		itl.inscor__Inventory_Owner__c = itl.inscor__Inventory_Line__r.inscor__Owner_Code__r.Id;
		itl.inscor__Value__c = 2000;
		itl.inscor__Quantity_Allocated__c = 2;
		insert itl;

		inscor__Release__c r1 = new inscor__Release__c(
			inscor__Status__c = 'Released',
			inscor__Release_Type__c = 'Inventory Transfer',
			inscor__Inventory_Transfer__c = it.id,
			inscor__Requested_Ship_Date__c = system.today().addDays(-5),
			inscor__Freight_Charge__c = 200
		);
		insert r1;
		inscor__Release_Line__c rl1 = new inscor__Release_Line__c(
			inscor__Release__c = r1.id,
			inscor__Status__c = 'Released',
			inscor__Inventory_Transfer_Line__c = itl.id
		);
		insert rl1;

		Pagereference pgref = Page.Custom_ReleaseCertificate;
		pgref.getParameters().put('id', rl1.Id);
		pgref.getParameters().put('autosigncert', 'true');
		pgref.getParameters().put('active1417', 'false');
		pgref.getParameters().put('active1821', 'false');
		pgref.getParameters().put('showLastOperator', 'true');
        pgref.getParameters().put('remark', '<p>Test remark</p>');
		Test.setCurrentPage(pgref);

		Custom_ReleaseCertificatePDFController inst_RCPC = new Custom_ReleaseCertificatePDFController();
		system.assert(inst_RCPC.objRL != null);
	}
}