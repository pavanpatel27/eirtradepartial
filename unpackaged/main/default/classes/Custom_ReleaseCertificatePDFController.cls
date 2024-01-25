public with sharing class Custom_ReleaseCertificatePDFController {
	/* Test Class Custom_ReleaseCertPDFController_Test */
	public inscor__Release_Line__c objRL{get;set;}
	public inscor__Company__c objCompany{get;set;}
	public String ref{get;set;}
	public String sellercontract{get;set;}
	public String buyerpo{get;set;}
	public String item{get;set;}
	public String appcode{get;set;}
	public String serial{get;set;}
	public String status{get;set;}
	public String remark{get;set;}
	public String traceable{get;set;}
	public String lastcerti{get;set;}
	public String certstatus{get;set;}
	public String name1{get;set;}
	public String date1{get;set;}
	public String name2{get;set;}
	public String date2{get;set;}
	public Boolean autosigncert{get;set;}
	public Boolean active1417{get;set;}
	public Boolean active1821{get;set;}
	public Boolean show1417{get;set;}
	public Boolean show1821{get;set;}
	public inscor__Employee__c emp{get;set;}
	public inscor__Form_Options__c fo{get;set;}
	public String invTagRef{get;set;}
	public String lastOperator{get;set;}
	public boolean showLastOperator{get;set;}
	public boolean showESN{get;set;}
	public boolean lifeLimited{get;set;}
	public String esn{get;set;}
	public boolean showTagInv{get;set;}
	public Integer noOfLines{get;set;}
	public String invTraceName{get;set;}
	public String LastOperatorLabel{get;set;}
	public String tagInvLabel{get;set;}
	public String yourParts{get;set;}
	public String description{get;set;}
	public String manParts{get;set;}
	public String gsata{get;set;}
	public String serialNums{get;set;}
	public String tsn{get;set;}
	public String csn{get;set;}
	public Decimal qtyOverride{get;set;}
    
    static final Set<String> HTML_WHITELIST = new Set<String>{
		'<a>','</a>','<area>','</area>','<b>','</b>','<div>','</div>','<em>','</em>','<h1>','</h1>',
		'<h2>','</h2>','<h3>','</h3>','<h4>','</h4>','<h5>','</h5>','<h6>','</h6>','<i>','</i>',
		'<img>','</img>','<li>','</li>','<map>','</map>','<ol>','</ol>','<p>','</p>','<s>','</s>',
		'<span>','</span>','<strong>','</strong>','<table>','</table>','<tbody>','</tbody>','<td>','</td>',
		'<th>','</th>','<thead>','</thead>','<tfoot>','</tfoot>','<tr>','</tr>','<u>','</u>','<ul>','</ul>',
		'<br/>'
	};

	public Custom_ReleaseCertificatePDFController() {
		LastOperatorLabel = 'Last Operator: ';
		tagInvLabel = 'Tag Ref: ';
		serialNums = '';

		String land = ApexPages.currentPage().getParameters().get('land');

		String formName = (land == 'yes'? 'ASA Certificate (LandScape)': 'ASA Certificate');

		Id releaseLineId = ApexPages.currentPage().getParameters().get('id');
		ref = ApexPages.currentPage().getParameters().get('ref');
		sellercontract = ApexPages.currentPage().getParameters().get('sellercontract');
		buyerpo = ApexPages.currentPage().getParameters().get('buyerpo');
		item = ApexPages.currentPage().getParameters().get('item');
		appcode = ApexPages.currentPage().getParameters().get('appcode');
		serial = ApexPages.currentPage().getParameters().get('serial');
		status = ApexPages.currentPage().getParameters().get('status');
		remark = ApexPages.currentPage().getParameters().get('remark');
		if (remark != null && remark != '') {
			remark = remark.replaceAll('</p>', '</p>\r\n');
			remark = sanitizeHTML(remark);
			remark = remark.replaceAll('<[^>]+>',' ');
		}
		traceable = ApexPages.currentPage().getParameters().get('traceable');
		lastcerti = ApexPages.currentPage().getParameters().get('lastcerti');
		name1 = ApexPages.currentPage().getParameters().get('name1');
		date1 = ApexPages.currentPage().getParameters().get('date1');
		name2 = ApexPages.currentPage().getParameters().get('name2');
		date2 = ApexPages.currentPage().getParameters().get('date2');
		lastOperator = ApexPages.currentPage().getParameters().get('lastOperator');
		certstatus = ApexPages.currentPage().getParameters().get('certstatus');
		invTagRef = ApexPages.currentPage().getParameters().get('invTagRef');
		description = ApexPages.currentPage().getParameters().get('asadesc');
		manParts = ApexPages.currentPage().getParameters().get('manpart');
		gsata = ApexPages.currentPage().getParameters().get('gsata');
		String avfoId = ApexPages.currentPage().getParameters().get('avfoid');

		try {
			noOfLines = Integer.valueOf(ApexPages.currentPage().getParameters().get('noOfLines'));
		} catch (Exception e) {
			system.debug('-Casting error for noOfLines-'+e+'-'+e.getStackTraceString());
			noOfLines = 0;
		}
		try {
			qtyOverride = Decimal.valueOf(ApexPages.currentPage().getParameters().get('asaqty'));
		} catch (Exception e) {
			system.debug('-Casting error for asaqty-'+e+'-'+e.getStackTraceString());
			qtyOverride = 0;
		}

		autosigncert = false;
		active1417 = false;
		active1821 = false;
		show1417 = false;
		show1821 = false;
		showLastOperator = false;
		showTagInv = false;
		String autosigncertStr = ApexPages.currentPage().getParameters().get('autosigncert');
		String active1417Str = ApexPages.currentPage().getParameters().get('active1417');
		String active1821Str = ApexPages.currentPage().getParameters().get('active1821');
		String showLastOperatorStr = ApexPages.currentPage().getParameters().get('lastOperatorChk');
		String showTagInvStr = ApexPages.currentPage().getParameters().get('invTagRefChk');
		String showTagInvRelease = ApexPages.currentPage().getParameters().get('showTagInv');
		String showLastOperatorRelease = ApexPages.currentPage().getParameters().get('showLastOperator');

		if ((showLastOperatorStr != null && showLastOperatorStr.trim().tolowercase() == 'true') || (showLastOperatorRelease != null && showLastOperatorRelease.trim().tolowercase() == 'true')) {
			showLastOperator = true;
		}

		if ((showTagInvStr != null && showTagInvStr.trim().tolowercase() == 'true') ||(showTagInvRelease != null && showTagInvRelease.trim().tolowercase() == 'true')) {
			showTagInv = true;
		}

		emp = new inscor__Employee__c();
		if (autosigncertStr != null && autosigncertStr.trim().tolowercase() == 'true') {
			autosigncert = true;
			String [] AccessFields = new String [] {
				'Id','inscor__Signature__c','inscor__User__c'
			};
			inscor.PermissionCheck.checkAccessibility(AccessFields, inscor.PermissionCheck.emp);

			List<inscor__Employee__c> empList = [
				SELECT
					Id,inscor__Signature__c
				FROM inscor__Employee__c
				WHERE inscor__User__c = :UserInfo.getUserId()
				WITH SECURITY_ENFORCED
			];

			if (empList.size() > 0) {
				emp = empList.get(0);
			}
		}
		if (active1417Str != null && active1417Str.trim().tolowercase() == 'true') {
			active1417 = true;
		}
		if (active1821Str != null && active1821Str.trim().tolowercase() == 'true') {
			active1821 = true;
		}

		if ((active1417 && active1821) || (!active1417 && !active1821)) {
			show1417 = true;
			show1821 = true;
		} else {
			if (active1417) {
				show1417 = true;
			}
			if (active1821) {
				show1821 = true;
			}
		}

		if (releaseLineId!=null) {
			String [] relLineAccessFields = new String [] {
				'Id','Name','inscor__Release__c','inscor__Status__c','inscor__Allocation__c',
				'inscor__Sales_Order_Line__c','inscor__Repair_Order_Line__c','inscor__Inventory_Transfer_Line__c'
			};
			inscor.PermissionCheck.checkAccessibility(relLineAccessFields, inscor.PermissionCheck.relLine);

			objRL = [
				SELECT
					Id,Name,inscor__Release__r.inscor__Release_Type__c,
					inscor__Sales_Order_Line__r.inscor__Condition_Code__r.Name, inscor__Sales_Order_Line__r.Name, 
					inscor__Repair_Order_Line__r.inscor__Expected_Part_Condition__r.Name,
					inscor__Sales_Order_Line__r.inscor__Condition_Code__r.inscor__Description__c,
					inscor__Sales_Order_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c,
					inscor__Repair_Order_Line__r.inscor__Expected_Part_Condition__r.inscor__Description__c,
					inscor__Allocation__r.inscor__Quantity_Allocated__c,inscor__Release__r.Name,
					inscor__Allocation__r.inscor__Quantity_Shipped__c,
					inscor__Repair_Order_Line__r.inscor__Quantity_to_Repair__c,
					inscor__Release__r.inscor__Sales_Order__r.inscor__Company__c,
					inscor__Release__r.inscor__Repair_Order__r.inscor__Company__c,
					inscor__Release__r.inscor__Sales_Order__r.Name,
					inscor__Release__r.inscor__Repair_Order__r.Name,
					inscor__Release__r.inscor__Sales_Order__r.inscor__Customer_PO_Number__c,
					inscor__Status__c,inscor__Allocation__r.inscor__Status__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.Name,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Description__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Quantity__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Serial_Number__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Conversion_Tag_Agency__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Source__r.Name,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__ESN_Text__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Tag_Reference__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Trace__r.Name,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__MFR_Name__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__CSN__c,
					inscor__Allocation__r.inscor__Inventory_Line__r.inscor__TSN__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__r.Name,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__r.inscor__Serialized__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__r.inscor__Description__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Quantity__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Serial_Number__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Tag_Agency__r.Name,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Conversion_Tag_Agency__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Source__r.Name,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__r.inscor__Keyword__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c, 
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__ESN_Text__c, 
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Tag_Reference__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Trace__r.Name,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__MFR_Name__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__CSN__c,
					inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__TSN__c,
					inscor__Release__r.inscor__Purchase_Order__r.inscor__Company__c,
					inscor__Release__r.inscor__Purchase_Order__r.Name,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__ESN_Text__c, 
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Serial_Number__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Source__r.Name,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Trace__r.Name,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Conversion_Tag_Agency__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Tag_Reference__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Product__r.Name,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__MFR_Name__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__CSN__c,
					inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__TSN__c,
					inscor__Purchase_Order_Line__r.inscor__Quantity__c,
					inscor__Release__r.inscor__Work_Order__r.inscor__Company__c,
					inscor__Release__r.inscor__Work_Order__r.Name,
					inscor__Release__r.inscor__Inventory_Transfer__r.inscor__Company__c,
					inscor__Release__r.inscor__Inventory_Transfer__r.Name,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__ESN_Text__c, 
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Serial_Number__c,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Source__r.Name,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Trace__r.Name,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Conversion_Tag_Agency__c,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Tag_Reference__c,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Product__r.Name,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__MFR_Name__c,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__ESN_Text__c, 
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Serial_Number__c,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Source__r.Name,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Trace__r.Name,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Conversion_Tag_Agency__c,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Tag_Reference__c,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.Name,
					inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__MFR_Name__c,
					inscor__Quantity__c,
					inscor__RO_Issue__c,inscor__RO_Issue__r.Name, inscor__RO_Issue__r.inscor__Inventory_Line__c,
					inscor__RO_Issue__r.inscor__Part_Number__c,inscor__RO_Issue__r.inscor__Quantity_Issued__c,
					inscor__RO_Issue__r.inscor__Quantity_Restocked__c,inscor__RO_Issue__r.inscor__Quantity_to_Issue__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.Name,inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Serial_Number__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.Name,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__r.Name,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__r.inscor__Engine_Serial_Number__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__r.inscor__Owner_Code_Description__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__r.inscor__Owner_Group__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Location__r.Name,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Sub_Location__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Grouping_Enabled__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.Name,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Source__r.Name,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Warehouse__r.Name,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__ESN_Text__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Trace__r.Name,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__MFR_Name__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__CSN__c,
					inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__TSN__c,
					inscor__PO_Issue__c,inscor__PO_Issue__r.Name, inscor__PO_Issue__r.inscor__Inventory_Line__c,
					inscor__PO_Issue__r.inscor__Part_Number__c,inscor__PO_Issue__r.inscor__Quantity_Issued__c,
					inscor__PO_Issue__r.inscor__Quantity_Restocked__c,inscor__PO_Issue__r.inscor__Quantity_to_Issue__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.Name,inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Serial_Number__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.Name,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__r.Name,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__r.inscor__Engine_Serial_Number__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__r.inscor__Owner_Code_Description__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Owner_Code__r.inscor__Owner_Group__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Location__r.Name,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Sub_Location__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Grouping_Enabled__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.Name,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Source__r.Name,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Warehouse__r.Name,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__ESN_Text__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Trace__r.Name,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__MFR_Name__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__CSN__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__TSN__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Tag_Reference__c,
					inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Conversion_Tag_Agency__c,
					inscor__Inventory_Transfer_Line__r.inscor__Inventory_Transfer__r.inscor__Company__c
				FROM inscor__Release_Line__c
				WHERE Id=:releaseLineId
				WITH SECURITY_ENFORCED
			];

			if (objRL != null) {
				String companyId = '';
				String documentName = '';
				String docStatus = '';
				String docBuyerpo = '';
				String docSerial = '';
				String docTraceable = '';
				String docLastcerti = '';
				String prodId = '';
				boolean isSerialized = false;
				if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Sales Order') {
					companyId = objRL.inscor__Release__r.inscor__Sales_Order__r.inscor__Company__c;
					documentName = objRL.inscor__Release__r.inscor__Sales_Order__r.Name;
					docStatus = objRL.inscor__Sales_Order_Line__r.inscor__Condition_Code__r.inscor__Description__c;
					docBuyerpo = objRL.inscor__Release__r.inscor__Sales_Order__r.inscor__Customer_PO_Number__c;
					docSerial = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Serial_Number__c;
					docTraceable = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Source__r.Name;
					docLastcerti = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name;
					invTraceName = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Trace__r.Name;
					isSerialized = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c;
					prodId = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__c;
					description = String.isNotBlank(description) ? 
						description : 
						objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c;
					if (String.isBlank(manParts)) {
						manParts = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.Name;
						manParts += String.isNotBlank(objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__MFR_Name__c) ?
							'<br> ' + objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__MFR_Name__c : '';
					}
					qtyOverride = qtyOverride > 0 ? 
						qtyOverride : 
					nullValue(objRL.inscor__Allocation__r.inscor__Quantity_Allocated__c) + nullValue(objRL.inscor__Allocation__r.inscor__Quantity_Shipped__c);
					show1417 = active1417 == true ||  (active1821 == false && objRL.inscor__Sales_Order_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '18-21');
					show1821 = active1821 == true ||  (active1417 == false && objRL.inscor__Sales_Order_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '14-17');
					esn = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__ESN_Text__c;
					lifeLimited = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c;
					csn = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__CSN__c;
					tsn = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__TSN__c;
				} else if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Repair Order') {
					companyId = objRL.inscor__Release__r.inscor__Repair_Order__r.inscor__Company__c;
					documentName = objRL.inscor__Release__r.inscor__Repair_Order__r.Name;
					docStatus = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c;
					docSerial = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Serial_Number__c;
					docTraceable = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Source__r.Name;
					docLastcerti = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Tag_Agency__r.Name;
					invTraceName = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Trace__r.Name;
					isSerialized = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__r.inscor__Serialized__c;
					prodId = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__c;
					description = String.isNotBlank(description) ? 
						description : 
						objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__r.inscor__Keyword__c;
					if (String.isBlank(manParts) && objRL.inscor__RO_Issue__c == null) {
						manParts = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__r.Name;
						manParts += String.isNotBlank(objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__MFR_Name__c) ? 
							'<br/> ' + objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__MFR_Name__c : '';
					}
					qtyOverride = qtyOverride > 0 ? 
						qtyOverride : 
					nullValue(objRL.inscor__Repair_Order_Line__r.inscor__Quantity_to_Repair__c);
					show1417 = active1417 == true ||  
						(active1821 == false && 
						 objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '18-21');
					show1821 = active1821 == true ||  
						(active1417 == false && 
						 objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '14-17');
					esn = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__ESN_Text__c;
					lifeLimited = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c;
					csn = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__CSN__c;
					tsn = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__TSN__c;
					if (objRL.inscor__RO_Issue__c != null) {
						docStatus = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c;
						docSerial = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Serial_Number__c;
						docTraceable = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Source__r.Name;
						docLastcerti = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name;
						invTraceName = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Trace__r.Name;
						isSerialized = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c;
						prodId = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Product__c;
						description = String.isNotBlank(description) ? 
							description : 
							objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c;
						if (String.isBlank(manParts)) {
							manParts = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.Name;
							manParts += String.isNotBlank(objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__MFR_Name__c) ? 
								'<br/> ' + objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__MFR_Name__c : '';
						}
						qtyOverride = qtyOverride > 0 ? 
							qtyOverride : 
							nullValue(objRL.inscor__RO_Issue__r.inscor__Quantity_to_Issue__c);
						show1417 = active1417 == true ||  
							(active1821 == false && 
							 objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '18-21');
						show1821 = active1821 == true ||  
							(active1417 == false && 
							 objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '14-17');
						esn = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__ESN_Text__c;
						lifeLimited = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c;
						csn = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__CSN__c;
						tsn = objRL.inscor__RO_Issue__r.inscor__Inventory_Line__r.inscor__TSN__c;
					}
				} else if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Purchase Order') {
					companyId = objRL.inscor__Release__r.inscor__Purchase_Order__r.inscor__Company__c;
					documentName = objRL.inscor__Release__r.inscor__Purchase_Order__r.Name;
					
					docStatus = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c;
					docSerial = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Serial_Number__c;
					docTraceable = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Source__r.Name;
					docLastcerti = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name;
					invTraceName = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Trace__r.Name;
					isSerialized = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c;
					prodId = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Product__c;
					description = String.isNotBlank(description) ? 
						description : 
						objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c;
					if (String.isBlank(manParts) && objRL.inscor__PO_Issue__c != null) {
						manParts = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.Name;
						manParts += String.isNotBlank(objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__MFR_Name__c) ? 
							'<br/> ' + objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__MFR_Name__c : '';
					}
					qtyOverride = qtyOverride > 0 ? 
						qtyOverride : 
						nullValue(objRL.inscor__PO_Issue__r.inscor__Quantity_to_Issue__c);
					show1417 = active1417 == true ||  
						(active1821 == false && 
						 objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '18-21');
					show1821 = active1821 == true ||  
						(active1417 == false && 
						 objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '14-17');
					esn = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__ESN_Text__c;
					lifeLimited = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c;
					csn = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__CSN__c;
					tsn = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__TSN__c;
					if (objRL.inscor__PO_Issue__c == null) {
						docStatus = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c;
						docSerial = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Serial_Number__c;
						docTraceable = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Source__r.Name;
						docLastcerti = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name;
						invTraceName = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Trace__r.Name;
						isSerialized = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c;
						prodId = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Product__c;
						description = String.isNotBlank(description) ? 
							description : 
							objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c;
						if (String.isBlank(manParts)) {
							manParts = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Product__r.Name;
							manParts += String.isNotBlank(objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__MFR_Name__c) ? 
								'<br/> ' + objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__MFR_Name__c : '';
						}
						qtyOverride = qtyOverride > 0 ? 
							qtyOverride : 
							nullValue(objRL.inscor__Purchase_Order_Line__r.inscor__Quantity__c);
						show1417 = active1417 == true ||  
							(active1821 == false && 
							 objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '18-21');
						show1821 = active1821 == true ||  
							(active1417 == false && 
							 objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '14-17');
						esn = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__ESN_Text__c;
						lifeLimited = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Life_Limited__c;
						csn = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__CSN__c;
						tsn = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__TSN__c;
					}
				} else if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Work Order') {
					companyId = objRL.inscor__Release__r.inscor__Work_Order__r.inscor__Company__c;
					documentName = objRL.inscor__Release__r.inscor__Work_Order__r.Name;
					docStatus = objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c;
					docSerial = objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Serial_Number__c;
					docTraceable = objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Source__r.Name;
					docLastcerti = objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name;
					invTraceName = objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Trace__r.Name;
					isSerialized = objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c;
					prodId = objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Product__c;
					description = String.isNotBlank(description) ? 
						description : 
						objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c;
					if (String.isBlank(manParts)) {
						manParts = objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Product__r.Name;
						manParts += String.isNotBlank(objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__MFR_Name__c) ? 
							'<br/> ' + objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__MFR_Name__c : '';
					}
					qtyOverride = qtyOverride > 0 ? 
						qtyOverride : 
						nullValue(objRL.inscor__Quantity__c);
					show1417 = active1417 == true ||  
						(active1821 == false && 
						 objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '18-21');
					show1821 = active1821 == true ||  
						(active1417 == false && 
						 objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '14-17');
					esn = objRL.inscor__Work_Order_Allocation__r.inscor__Inventory_Line__r.inscor__ESN_Text__c;
				} else if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Inventory Transfer') {
					companyId = objRL.inscor__Release__r.inscor__Inventory_Transfer__r.inscor__Company__c;
					documentName = objRL.inscor__Release__r.inscor__Inventory_Transfer__r.Name;
					docStatus = objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Description__c;
					docSerial = objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Serial_Number__c;
					docTraceable = objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Source__r.Name;
					docLastcerti = objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Tag_Agency__r.Name;
					invTraceName = objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Trace__r.Name;
					isSerialized = objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Serialized__c;
					prodId = objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Product__c;
					description = String.isNotBlank(description) ? 
						description : 
						objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Product__r.inscor__Keyword__c;
					if (String.isBlank(manParts)) {
						manParts = objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Product__r.Name;
						manParts += String.isNotBlank(objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__MFR_Name__c) ? 
							'<br/> ' + objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__MFR_Name__c : '';
					}
					qtyOverride = qtyOverride > 0 ? 
						qtyOverride : 
						nullValue(objRL.inscor__Quantity__c);
					show1417 = active1417 == true ||  
						(active1821 == false && 
						 objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '18-21');
					show1821 = active1821 == true ||  
						(active1417 == false && 
						 objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__Condition_Code__r.inscor__Material_Cert_Active_Side__c != '14-17');
					esn = objRL.inscor__Inventory_Transfer_Line__r.inscor__Inventory_Line__r.inscor__ESN_Text__c;
				}

				if (String.isNotBlank(companyId)) {
                    System.debug('companyId: ' + companyId);
					if (String.isNotBlank(avfoId)) {
						fo = inscor.FormOptionUtil.fetchFormOptions(avfoId);
					} else {
						fo = inscor.FormOptionUtil.fetchCompFormOption(formName, companyId);
					}
					String [] compAccessFields = new String [] {
						'Id','Name','inscor__Company_Name__c','inscor__Address_1__c','inscor__Address_2__c',
						'inscor__City__c','inscor__State__c','inscor__Zip_Code__c','inscor__Fax_Number__c',
						'inscor__Phone_Number__c','inscor__Website__c','inscor__Use_Conversion_Tag_Agency_on_Certs__c',
						'inscor__Cert_Status__c','inscor__Cert_SITA_Wire_Code__c'
					};
					inscor.PermissionCheck.checkAccessibility(compAccessFields, inscor.PermissionCheck.comp);

					objCompany = [
						SELECT
							Name,inscor__Company_Name__c,inscor__Address_1__c,inscor__Address_2__c,
							inscor__City__c,inscor__State__c,inscor__Zip_Code__c,
							inscor__Fax_Number__c,inscor__Website__c,inscor__Phone_Number__c,
							inscor__Use_Conversion_Tag_Agency_on_Certs__c,inscor__Cert_Status__c,
							inscor__Cert_SITA_Wire_Code__c
						FROM inscor__Company__c
						WHERE Id=:companyId
						WITH SECURITY_ENFORCED
					];
				}

				if (objCompany != null && objCompany.inscor__Use_Conversion_Tag_Agency_on_Certs__c &&
				   (docLastcerti == null || docLastcerti.trim() == '')) {
					if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Sales Order') {
						docLastcerti = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Conversion_Tag_Agency__c;
					} else if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Repair Order') {
						docLastcerti = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Conversion_Tag_Agency__c;
					} else if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Purchase Order') {
						docLastcerti = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Conversion_Tag_Agency__c;
						if (objRL.inscor__PO_Issue__c == null) {
							docLastcerti = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Conversion_Tag_Agency__c;
						}
					}
				}

				if (invTagRef == null || invTagRef.trim() == '') {
					if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Sales Order') {
						invTagRef = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Tag_Reference__c;
					} else if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Repair Order') {
						invTagRef = objRL.inscor__Repair_Order_Line__r.inscor__Original_Inventory_Line__r.inscor__Tag_Reference__c;
					} else if (objRL.inscor__Release__r.inscor__Release_Type__c == 'Purchase Order') {
						invTagRef = objRL.inscor__PO_Issue__r.inscor__Inventory_Line__r.inscor__Tag_Reference__c;
						if (objRL.inscor__PO_Issue__c == null) {
							invTagRef = objRL.inscor__Purchase_Order_Line__r.inscor__Inventory_Line__r.inscor__Tag_Reference__c;
						}
					}
				} else {
					tagInvLabel = '';
				}

				if (lastOperator == null || lastOperator.trim() == '') {
					lastOperator = invTraceName;
				} else {
					LastOperatorLabel = '';
				}

				if (ref == null || ref.trim() == '') {
					ref = objRL.inscor__Release__r.Name+'-'+objRl.Name;
					if (gsata == 'true' && String.isNotBlank(objRL.inscor__Sales_Order_Line__r.Name)) {
						ref = objRL.inscor__Release__r.Name+'-'+objRL.inscor__Sales_Order_Line__r.Name;
					}
				}
				if (gsata == 'true' && String.isNotBlank(objRL.inscor__Sales_Order_Line__r.Name)) {
					List<String> snList = new List<String>();
					String tagName = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Tag_Agency__c;
					String trace = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Trace__c;
					String source = objRL.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Source__c;
					for (inscor__Release_Line__c soRl : [
						SELECT inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Serial_Number__c 
						FROM inscor__Release_Line__c
						WHERE inscor__Sales_Order_Line__c = :objRL.inscor__Sales_Order_Line__c AND 
						inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Tag_Agency__c = :tagName AND
						inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Trace__c = :trace AND 
						inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Source__c = :source
					]) {
						if (String.isNotBlank(soRl.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Serial_Number__c)) {
							snList.add(soRl.inscor__Allocation__r.inscor__Inventory_Line__r.inscor__Serial_Number__c);
						}
					}
					serialNums = String.join(snList, ', ');
					serial = 'See Block 13A';
					qtyOverride = snList.size();
				}

				if (sellercontract == null || sellercontract.trim()=='') {
					sellercontract = documentName;
				}
				if (buyerpo == null || buyerpo.trim()=='') {
					buyerpo = docBuyerpo;
				}
				if (item == null || item.trim()=='') {
					item = '1';
				}
				if (serial == null || serial.trim()=='') {
					serial = docSerial;
				}
				if (serial == null || serial.trim()=='') {
				   serial = 'N/A';
				}
				if (status == null || status.trim()=='') {
					status = docStatus;
				}
				if (traceable == null || traceable.trim()=='') {
					traceable = invTraceName;
				}
				if (lastcerti == null || lastcerti.trim()=='') {
					lastcerti = docLastcerti;
				}
				if (name1 == null || name1.trim()=='') {
					name1 = UserInfo.getName();
				}
				appcode = String.isBlank(appcode) ? 'TBV' : appcode;
				if (date1 == null || date1.trim()=='') {
					Date dToday = Date.today();
					DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
					date1=dt.format('dd/MMM/yyyy');
				}
				if (name2 == null || name2.trim()=='') {
					name2 = UserInfo.getName();
				}
				if (date2 == null || date2.trim()=='') {
					Date dToday = Date.today();
					DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
					date2=dt.format('dd/MMM/yyyy');
				}
				if (certstatus == null || certstatus.trim() == '') {
					certstatus = objCompany.inscor__Cert_Status__c;
				}
				if (prodId != null) {
					List<inscor__Account_Part_Master__c> custParts = [
						SELECT Id, inscor__Customer_Part_Number__r.Name 
						FROM inscor__Account_Part_Master__c 
						WHERE inscor__Part_Number__c = :prodId
						WITH SECURITY_ENFORCED
					];
					List<String> custProds = new List<String>();
					for (inscor__Account_Part_Master__c apm : custParts) {
						custProds.add(apm.inscor__Customer_Part_Number__r.Name);
					}
					yourParts = String.join(custProds, ', ');
				}
			}
		}
		showESN = fo != null && fo.inscor__Show_ESN_on_Mat_Cert__c == true && String.isNotBlank(esn);
        
		
		manParts = sanitizeHTML(manParts);
	}
	public static Decimal nullValue(Decimal value) {
		return value == null? 0 : value;
	}
    public static String sanitizeHTML(String htmlString) {
		if (htmlString == null) {
			return null;
		}
		htmlString = htmlString.unescapeHtml4();

		Pattern p = Pattern.compile('<[^>]*>');
		Matcher m = p.matcher(htmlString);

		Set<String> badTags = new Set<String>();
		while(m.find()) {
			String tag = m.group(0);
			tag = tag.replaceAll('style="[^>]*"', '');
			tag = tag.deleteWhitespace();

			if (!HTML_WHITELIST.contains(tag)) {
				badTags.add(tag);
			}
		}

		for (String tag : badTags) {
			htmlString = htmlString.replace(tag, '');
		}

		return htmlString;
	}
}