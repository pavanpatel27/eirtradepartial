@isTest
public class RestApi_VoucherService_Test {

	@isTest
	public static void testVoucher() {
		Account AccountRecord = new Account(Name='Test Account');
		insert AccountRecord;
		
		Contact ContactRecord = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com',AccountId = AccountRecord.Id);
		insert ContactRecord;
		
		inscor__Company__c CompanyRecord = new inscor__Company__c(
			inscor__Company_Name__c = 'Testing Company',
			inscor__Address_1__c = 'Address1',
			inscor__City__c = 'Test City',
			inscor__State__c = 'CA',
			inscor__Zip_Code__c = '12345'
		);
		insert CompanyRecord;
		
		inscor__Company_Location__c CompanyLocationRecord = new inscor__Company_Location__c(
			Name = 'Test Location',
			inscor__Company__c = CompanyRecord.Id
		);
		insert CompanyLocationRecord;

		inscor__Repair_Order__c RepairOrderRecord = new inscor__Repair_Order__c(
			inscor__Company__c = CompanyRecord.Id,
			inscor__Vendor__c = AccountRecord.Id,
			inscor__Assigned_To__c = Userinfo.getUserId(),
			inscor__Contact__c = ContactRecord.Id,
			inscor__Ship_To_Location__c = CompanyLocationRecord.Id,
			inscor__Acct__c = '1234567890'
		);
		insert RepairOrderRecord;
		
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
		
		inscor__Inventory_Line__c InventoryLineRecord = new inscor__Inventory_Line__c(
			inscor__Condition_Code__c = ConditionCodeRecord.Id,
			inscor__Product__c = ProductRecord.Id,
			inscor__Quantity__c = 100,
			inscor__Owner_Code__c = OwnerCodeRecord.Id,
			inscor__Location__c = InvLocationRecord.Id,
			inscor__Warehouse__c = WarehouseRecord.Id,
			inscor__Source__c = AccountRecord.Id
		);
		insert InventoryLineRecord;

		inscor__Repair_Order_Line__c roLine = new inscor__Repair_Order_Line__c(
			inscor__Repair_Order__c = RepairOrderRecord.Id,
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
		insert roLine;

		inscor__Release__c ReleaseRecord = new inscor__Release__c(
			inscor__Repair_Order__c = RepairOrderRecord.id,
			inscor__Status__c = 'Released',
			inscor__Requested_Ship_Date__c = system.today().addDays(5),
			inscor__Acct__c = '1234'
		);
		insert ReleaseRecord;
		
		roLine.inscor__Quantity_Shipped__c = 1;
		roLine.inscor__Quantity_Received__c = 1;
		roLine.inscor__Final_Unit_Repair_Cost__c = 100;
		update roLine;
		inscor__Receipt__c rec = new inscor__Receipt__c();
		rec.inscor__Repair_Order_Line__c = roLine.Id;
		rec.inscor__Repair_Order__c = RepairOrderRecord.Id;
		rec.inscor__Document_Type__c = 'Repair Order';
		rec.inscor__Condition_Code_Received__c = ConditionCodeRecord.Id;
		rec.inscor__Product_Received__c = ProductRecord.Id;
		rec.inscor__Quantity_Received__c = 9;
		rec.inscor__Quantity_Approved__c = 5;
		rec.inscor__Quantity_Rejected__c = 4;
		rec.inscor__Unit_Repair_Cost__c = 100;
		rec.inscor__Inventory_Line_ID__c = InventoryLineRecord.Id;
		insert rec;
		
		Test.startTest();
		// 1st
		Map<String, Object> requestBody = new Map<String, Object>{
			'rolines' => new List<String>{roLine.Name}
		};

		RestRequest req1 = new RestRequest();
		RestResponse res1 = new RestResponse();
		req1.requestURI = '/services/apexrest/v1/voucher';
		req1.requestBody = Blob.valueOf(JSON.serialize(requestBody));
		req1.httpMethod = 'POST';

		RestContext.request = req1;
		RestContext.response= res1;

		RestApi_VoucherService.initVoucherService();
		res1 = RestContext.response;
		System.assert(res1.statusCode == 422, 'Status = ' + res1.statusCode + ' Body = ' + res1.responseBody.toString());

		// 2nd
		requestBody = new Map<String, Object>{
			'rolines' => new List<String>{roLine.Name},
			'roNum' => RepairOrderRecord.Id,
			'invcDate' => '2023-12-13',
			'dueDate' => '2023-12-14'
		};

		RestRequest req2 = new RestRequest();
		RestResponse res2 = new RestResponse();
		req2.requestURI = '/services/apexrest/v1/voucher';
		req2.requestBody = Blob.valueOf(JSON.serialize(requestBody));
		req2.httpMethod = 'POST';
		RestContext.request = req2;
		RestContext.response= res2;

		RestApi_VoucherService.initVoucherService();
		res2 = RestContext.response;
		System.assert(res2.statusCode == 422, 'Status = ' + res2.statusCode + ' Body = ' + res2.responseBody.toString());

		// 3rd
		requestBody = new Map<String, Object>{
			'rolines' => new List<String>{roLine.Name},
			'roNum' => RepairOrderRecord.Id,
			'invcNum' => '123',
			'dueDate' => '2023-12-14'
		};

		RestRequest req3 = new RestRequest();
		RestResponse res3 = new RestResponse();
		req3.requestURI = '/services/apexrest/v1/voucher';
		req3.requestBody = Blob.valueOf(JSON.serialize(requestBody));
		req3.httpMethod = 'POST';
		RestContext.request = req3;
		RestContext.response= res3;

		RestApi_VoucherService.initVoucherService();
		res3 = RestContext.response;
		System.assert(res3.statusCode == 422, 'Status = ' + res3.statusCode + ' Body = ' + res3.responseBody.toString());

		// 4th
		inscor__Repair_Order_Line__c rolObj = [SELECT Name from inscor__Repair_Order_Line__c WHERE inscor__Repair_Order__c =:RepairOrderRecord.Id ];
		requestBody = new Map<String, Object>{
			'rolines' => new List<String>{rolObj.Name},
			'roNum' => RepairOrderRecord.Id,
			'invcNum' => '123',
			'invcDate' => '2023-12-13',
			'dueDate' => '2023-12-14'
		};

		RestRequest req4 = new RestRequest();
		RestResponse res4 = new RestResponse();
		req4.requestURI = '/services/apexrest/v1/voucher';
		req4.requestBody = Blob.valueOf(JSON.serialize(requestBody));
		req4.httpMethod = 'POST';
		RestContext.request = req4;
		RestContext.response= res4;

		RestApi_VoucherService.initVoucherService();

		res4 = RestContext.response;
		System.assert(res4 != null);
		
		Test.stopTest();
	}
}