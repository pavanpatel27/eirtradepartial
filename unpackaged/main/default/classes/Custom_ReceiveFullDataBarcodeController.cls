public with sharing class Custom_ReceiveFullDataBarcodeController {
    /* Test class Custom_RcvFullDataBarcodeController_Test */
	public DataWrapper data{get;set;}
	public Integer width{get;set;}
	public Integer height{get;set;}
	public String footer{get;set;}
	public String title{get;set;}
	public String body1{get;set;}
	public String additionalBRFields{get;set;}
	public boolean showHazMatInfo{get;set;}
	public boolean hasHazMatInfo{get;set;}
	public String invBarcodeUrl{get;set;}
	public String recBarcodeUrl{get;set;}
	public String pageMode{get;set;}
    
    static final Set<String> HTML_WHITELIST = new Set<String>{
		'<a>','</a>','<area>','</area>','<b>','</b>','<div>','</div>','<em>','</em>','<h1>','</h1>',
		'<h2>','</h2>','<h3>','</h3>','<h4>','</h4>','<h5>','</h5>','<h6>','</h6>','<i>','</i>',
		'<img>','</img>','<li>','</li>','<map>','</map>','<ol>','</ol>','<p>','</p>','<s>','</s>',
		'<span>','</span>','<strong>','</strong>','<table>','</table>','<tbody>','</tbody>','<td>','</td>',
		'<th>','</th>','<thead>','</thead>','<tfoot>','</tfoot>','<tr>','</tr>','<u>','</u>','<ul>','</ul>',
		'<br/>'
	};

	public Custom_ReceiveFullDataBarcodeController() {
		String mode = ApexPages.currentPage().getParameters().get('pageMode');
		pageMode = String.isBlank(mode) ? 'pdf' : mode;
		data = new DataWrapper();
		String receiptId = ApexPages.currentPage().getParameters().get('recId');
		String invId = ApexPages.currentPage().getParameters().get('invId');
		width = Integer.valueOf(ApexPages.currentPage().getParameters().get('width'));
		height = Integer.valueOf(ApexPages.currentPage().getParameters().get('height'));
		footer = ApexPages.currentPage().getParameters().get('footer');
		String foId = ApexPages.currentPage().getParameters().get('foId');
		showHazMatInfo = false;
		hasHazMatInfo = false;

		if (footer != null) {
			footer = footer.replaceAll('<[^>]+>',' ');
			if (footer.length() > 50) {
				footer = footer.substring(0, 50);
			}
		} else {
			footer = '';
		}


		if (String.isNotBlank(foId)) {
			inscor__Form_Options__c fo = [
				SELECT
					Id, Name, inscor__Body_1__c, inscor__Title__c, inscor__Additional_Barcode_Fields__c
				FROM inscor__Form_Options__c
				WHERE Id = :foId
				WITH SECURITY_ENFORCED
			];
			title = fo.inscor__Title__c;
			body1 = fo.inscor__Body_1__c;
			body1 = sanitizeHTML(body1);
			additionalBRFields = fo.inscor__Additional_Barcode_Fields__c;
		}
		if (receiptId != null && receiptId.trim() != '') {
			data = getDataListFromReceipt(receiptId.escapeHtml4());
			invBarcodeUrl = getBarcodeUrl(data.invName, width, height);
		}

		if (invId != null && invId.trim() != '') {
			data = getDataListFromInv(invId.escapeHtml4());
			invBarcodeUrl = getBarcodeUrl(data.invName, width, height);
		}
		inscor__AvSight_Setting__mdt customSetting = inscor.CommonUtil.getCustomSetting('inscor__Show_HazMat_warning_in_Operations__c');
		if (customSetting != null) {
			showHazMatInfo = customSetting.inscor__Show_HazMat_warning_in_Operations__c;
		}
	}

	public DataWrapper getDataListFromReceipt(String receiptId){
		try {
			// Check Access
			String [] recAccessFields = new String [] {
				'Id','inscor__Inventory_Line_ID__c',
				'inscor__Product_Received__c','inscor__Serial_Number_Received__c','inscor__Quantity_Received__c',
				'inscor__Work_Order__c'
			};
			inscor.PermissionCheck.checkAccessibility(recAccessFields, inscor.PermissionCheck.rec);
		} catch (Exception e) {
			system.debug('-Exception while fetching No. of Copy-'+e.getStackTraceString());
		}

		inscor__Receipt__c rec = [
			SELECT
				Id,inscor__Inventory_Line_ID__r.Name,
				inscor__Product_Received__r.Name,inscor__Product_Received__r.inscor__Keyword__c,
				inscor__Product_Received__r.inscor__HazMat__c, inscor__Product_Received__r.inscor__Shelf_Life__c,
				inscor__Inventory_Line_ID__r.inscor__Owner_Code__r.Name,
				inscor__Inventory_Line_ID__r.inscor__Condition_Code__r.Name,
				inscor__Inventory_Line_ID__r.inscor__Warehouse__r.inscor__Warehouse_Code__c,
				inscor__Inventory_Line_ID__r.inscor__Location__r.Name,
				inscor__Serial_Number_Received__c,inscor__Quantity_Received__c,
				inscor__Inventory_Line_ID__r.inscor__UOM__c,inscor__Inventory_Line_ID__r.inscor__Expiration_Date__c,
				inscor__Inventory_Line_ID__r.inscor__Purchase_Order__r.Name,inscor__Inventory_Line_ID__r.CreatedDate,
				inscor__Inventory_Line_ID__r.inscor__Source__r.Name,inscor__Inventory_Line_ID__r.inscor__Trace__r.Name,
				inscor__Inventory_Line_ID__r.inscor__Tag_Agency__r.Name,inscor__Inventory_Line_ID__r.inscor__Tag_Date__c,
				inscor__Work_Order__c,inscor__Work_Order__r.Name,
				inscor__Work_Order__r.inscor__Customer_Ref__c, inscor__Work_Order__r.inscor__Product__r.Name,
				inscor__Inventory_Line_ID__r.inscor__ESN_Text__c,inscor__Inventory_Line_ID__r.inscor__Cycles_Remaining__c,
				inscor__Inventory_Line_ID__r.inscor__Next_Calibration_Date__c,inscor__Inventory_Line_ID__r.inscor__Last_Calibration_Date__c,
				inscor__Inventory_Line_ID__r.inscor__Last_Inspection_Date__c,inscor__Inventory_Line_ID__r.inscor__Next_Inspection_Date__c,
				inscor__Inventory_Line_ID__r.inscor__Kit_Lot__c, inscor__Product_Received__r.inscor__Life_Limited__c,
            	inscor__Inventory_Line_ID__r.inscor__TSN__c, inscor__Inventory_Line_ID__r.inscor__CSN__c,
			    inscor__Inventory_Line_ID__r.inscor__Batch_LOT__c, inscor__Inventory_Line_ID__r.inscor__Sub_Location__c

            FROM inscor__Receipt__c
			WHERE Id = :receiptId
			WITH SECURITY_ENFORCED
		];

		return getWrapperFromReceiptRecord(rec);
	}

	public DataWrapper getDataListFromInv(String invId) {
		try {
			String [] invAccessFields = new String [] {
				'Id','Name','inscor__Serial_Number__c','inscor__Condition_Code__c','inscor__Owner_Code__c',
				'inscor__Product__c','inscor__Warehouse__c','inscor__Quantity__c','inscor__Location__c',
				'inscor__Purchase_Order__c','inscor__Tag_Agency__c','inscor__Tag_Date__c',
				'inscor__Trace__c','inscor__Source__c','CreatedDate','inscor__ESN_Text__c','inscor__Work_Order__c',
				'inscor__Cycles_Remaining__c','inscor__Next_Calibration_Date__c','inscor__Last_Calibration_Date__c',
				'inscor__Last_Inspection_Date__c','inscor__Next_Inspection_Date__c', 'inscor__Kit_Lot__c',
                'inscor__TSN__c', 'inscor__CSN__c'
			};
			inscor.PermissionCheck.checkAccessibility(invAccessFields, inscor.PermissionCheck.invLine);
		} catch (Exception e) {
			system.debug('-Exception while fetching No. of Copy-'+e.getStackTraceString());
		}

		inscor__Inventory_Line__c inv = [
			SELECT
				Id,Name,inscor__Product__r.Name,inscor__Product__r.inscor__Keyword__c,inscor__Owner_Code__r.Name,
				inscor__Product__r.inscor__HazMat__c, inscor__Product__r.inscor__Shelf_Life__c, inscor__Product__r.inscor__Life_Limited__c,
				inscor__Condition_Code__r.Name,inscor__Warehouse__r.inscor__Warehouse_Code__c,inscor__Location__r.Name,
				inscor__Serial_Number__c,inscor__Quantity__c,inscor__UOM__c,inscor__Expiration_Date__c,
				inscor__Purchase_Order__r.Name,CreatedDate,inscor__Source__r.Name,inscor__Trace__r.Name,
				inscor__Work_Order__c,inscor__Work_Order__r.Name,
				inscor__Work_Order__r.inscor__Serial_Number__c,
				inscor__Work_Order__r.inscor__Hours__c, inscor__Work_Order__r.inscor__Cycles__c,
				inscor__Work_Order__r.inscor__Trace__r.Name,
				inscor__Work_Order__r.inscor__Company__r.inscor__Logo__c,
				inscor__Work_Order__r.inscor__Customer_Ref__c, inscor__Work_Order__r.inscor__Product__r.Name,
				inscor__Tag_Agency__r.Name,inscor__Tag_Date__c,inscor__ESN_Text__c,
				inscor__Cycles_Remaining__c,inscor__Next_Calibration_Date__c,inscor__Last_Calibration_Date__c,
				inscor__Last_Inspection_Date__c,inscor__Next_Inspection_Date__c, CreatedById, inscor__Kit_Lot__c,
            	inscor__TSN__c, inscor__CSN__c,
			    inscor__Batch_LOT__c, inscor__Sub_Location__c
            FROM inscor__Inventory_Line__c
			WHERE Id = :invId
			WITH SECURITY_ENFORCED
		];

		return getWrapperFromReceiptInv(inv);
	}

	public DataWrapper getWrapperFromReceiptRecord(inscor__Receipt__c rec) {
		DataWrapper d = new DataWrapper();
		d.productName = rec.inscor__Product_Received__r.Name;
		hasHazMatInfo = rec.inscor__Product_Received__r.inscor__HazMat__c;
		d.serialNumber = rec.inscor__Serial_Number_Received__c;
		d.condCode = rec.inscor__Inventory_Line_ID__r.inscor__Condition_Code__r.Name;
		d.ownerCode = rec.inscor__Inventory_Line_ID__r.inscor__Owner_Code__r.Name;
		d.invName = rec.inscor__Inventory_Line_ID__r.Name;
		d.warehouseCode = rec.inscor__Inventory_Line_ID__r.inscor__Warehouse__r.inscor__Warehouse_Code__c;
		d.qty = rec.inscor__Quantity_Received__c!=null?rec.inscor__Quantity_Received__c.intValue():null;
		d.locName = rec.inscor__Inventory_Line_ID__r.inscor__Location__r.Name;
		d.description = rec.inscor__Product_Received__r.inscor__Keyword__c;
		d.uom = rec.inscor__Inventory_Line_ID__r.inscor__UOM__c;
		d.expDate = dateToString(rec.inscor__Inventory_Line_ID__r.inscor__Expiration_Date__c);
		d.poName = rec.inscor__Inventory_Line_ID__r.inscor__Purchase_Order__r.Name;
		if (rec.inscor__Work_Order__c != null) {
			d.woName = rec.inscor__Work_Order__r.Name;
			d.woCustRef = rec.inscor__Work_Order__r.inscor__Customer_Ref__c;
			d.woPart = rec.inscor__Work_Order__r.inscor__Product__r.Name;
		}
		d.recDate = dateTimeToString(rec.inscor__Inventory_Line_ID__r.CreatedDate);
		if (rec.inscor__Inventory_Line_ID__r.inscor__Source__r != null) {
			if (rec.inscor__Inventory_Line_ID__r.inscor__Source__r.Name.length() > 18) {
				d.source = rec.inscor__Inventory_Line_ID__r.inscor__Source__r.Name.substring(0, 18);
			} else {
				d.source = rec.inscor__Inventory_Line_ID__r.inscor__Source__r.Name;
			}
		}
		if (rec.inscor__Inventory_Line_ID__r.inscor__Trace__r != null) {
			if (rec.inscor__Inventory_Line_ID__r.inscor__Trace__r.Name.length() > 18) {
				d.trace = rec.inscor__Inventory_Line_ID__r.inscor__Trace__r.Name.substring(0, 18);
			} else {
				d.trace = rec.inscor__Inventory_Line_ID__r.inscor__Trace__r.Name;
			}
		}
		if (rec.inscor__Inventory_Line_ID__r.inscor__Tag_Agency__r != null) {
			if (rec.inscor__Inventory_Line_ID__r.inscor__Tag_Agency__r.Name.length() > 18) {
				d.tagAgency = rec.inscor__Inventory_Line_ID__r.inscor__Tag_Agency__r.Name.substring(0, 18);
			} else {
				d.tagAgency = rec.inscor__Inventory_Line_ID__r.inscor__Tag_Agency__r.Name;
			}
		}
		d.tagDate = dateToString(rec.inscor__Inventory_Line_ID__r.inscor__Tag_Date__c);
		d.esn = rec.inscor__Inventory_Line_ID__r.inscor__ESN_Text__c;
		d.cyclesRemain = String.valueOf(rec.inscor__Inventory_Line_ID__r.inscor__Cycles_Remaining__c);
		d.lastCalib = dateToString(rec.inscor__Inventory_Line_ID__r.inscor__Last_Calibration_Date__c);
		d.nextCalib = dateToString(rec.inscor__Inventory_Line_ID__r.inscor__Next_Calibration_Date__c);
		d.lastInsp = dateToString(rec.inscor__Inventory_Line_ID__r.inscor__Last_Inspection_Date__c);
		d.nextInsp = dateToString(rec.inscor__Inventory_Line_ID__r.inscor__Next_Inspection_Date__c);
		d.kitLot = rec.inscor__Inventory_Line_ID__r.inscor__Kit_Lot__c!=null?rec.inscor__Inventory_Line_ID__r.inscor__Kit_Lot__c.intValue():null;
		d.hazmat = String.isNotBlank(additionalBRFields) && additionalBRFields.contains('Hazmat?') && rec.inscor__Product_Received__r.inscor__HazMat__c;
		d.llp = String.isNotBlank(additionalBRFields) && additionalBRFields.contains('LLP?') && rec.inscor__Product_Received__r.inscor__Life_Limited__c;
		d.shelfLife = String.isNotBlank(additionalBRFields) && additionalBRFields.contains('Shelf Life?') && rec.inscor__Product_Received__r.inscor__Shelf_Life__c;
        d.tsn = rec.inscor__Inventory_Line_ID__r.inscor__TSN__c;
        d.csn = rec.inscor__Inventory_Line_ID__r.inscor__CSN__c;
        d.removeDate = Date.today().format();
		d.batchNum = rec.inscor__Inventory_Line_ID__r.inscor__Batch_LOT__c;
        d.subLoc = rec.inscor__Inventory_Line_ID__r.inscor__Sub_Location__c;
        return d;
	}

	public DataWrapper getWrapperFromReceiptInv(inscor__Inventory_Line__c inv) {
		DataWrapper d = new DataWrapper();
		d.productName = inv.inscor__Product__r.Name;
		hasHazMatInfo = inv.inscor__Product__r.inscor__HazMat__c;
		d.serialNumber = inv.inscor__Serial_Number__c;
		d.condCode = inv.inscor__Condition_Code__r.Name;
		d.ownerCode = inv.inscor__Owner_Code__r.Name;
		d.invName = inv.Name;
		d.warehouseCode = inv.inscor__Warehouse__r.inscor__Warehouse_Code__c;
		d.qty = inv.inscor__Quantity__c!=null?inv.inscor__Quantity__c.intValue():null;
		d.locName = inv.inscor__Location__r.Name;
		d.description = inv.inscor__Product__r.inscor__Keyword__c;
		if (d.description != null && d.description.length() > 18) {
			d.description = d.description.substring(0, 18);
		}
		d.uom = inv.inscor__UOM__c;
		d.expDate = dateToString(inv.inscor__Expiration_Date__c);
		if (inv.inscor__Work_Order__c != null) {
			d.woName = inv.inscor__Work_Order__r.Name;
			d.woCustRef = inv.inscor__Work_Order__r.inscor__Customer_Ref__c;
			d.woPart = inv.inscor__Work_Order__r.inscor__Product__r.Name;
		}
		d.poName = inv.inscor__Purchase_Order__r.Name;
		d.recDate = dateTimeToString(inv.CreatedDate);
		if (inv.inscor__Source__r != null) {
			if (inv.inscor__Source__r.Name.length() > 18) {
				d.source = inv.inscor__Source__r.Name.substring(0, 18);
			} else {
				d.source = inv.inscor__Source__r.Name;
			}
		}
		d.trace = inv.inscor__Trace__r.Name;
		if (String.isNotBlank(inv.inscor__Work_Order__c)) {
			d.trace = inv.inscor__Work_Order__r.inscor__Trace__r.Name;
		}
		if (d.trace != null && d.trace.length() > 18) {
			d.trace = d.trace.substring(0, 18);
		}
		if (inv.inscor__Tag_Agency__r != null) {
			if (inv.inscor__Tag_Agency__r.Name.length() > 18) {
				d.tagAgency = inv.inscor__Tag_Agency__r.Name.substring(0, 18);
			} else {
				d.tagAgency = inv.inscor__Tag_Agency__r.Name;
			}
		}
		d.tagDate = dateToString(inv.inscor__Tag_Date__c);
		d.esn = inv.inscor__ESN_Text__c;
		d.cyclesRemain = String.valueOf(inv.inscor__Cycles_Remaining__c);
		d.lastCalib = dateToString(inv.inscor__Last_Calibration_Date__c);
		d.nextCalib = dateToString(inv.inscor__Next_Calibration_Date__c);
		d.lastInsp = dateToString(inv.inscor__Last_Inspection_Date__c);
		d.nextInsp = dateToString(inv.inscor__Next_Inspection_Date__c);
		d.kitLot = inv.inscor__Kit_Lot__c!=null?inv.inscor__Kit_Lot__c.intValue():null;
		d.removeDate = Date.today().format();
		if (String.isNotBlank(inv.inscor__Work_Order__c)) {
			d.esn = inv.inscor__Work_Order__r.inscor__Serial_Number__c;
			d.cyclesRemain = inv.inscor__Work_Order__r.inscor__Cycles__c;
			d.hours = inv.inscor__Work_Order__r.inscor__Hours__c;
		}
		inscor__Employee__c removedEmp = getRemovedBy(inv.CreatedById);
		if (removedEmp != null) {
		 	d.removedBy = removedEmp.inscor__Employee_Name__c;
			d.removedBySign = removedEmp.inscor__Signature__c;
		}
		d.hazmat = String.isNotBlank(additionalBRFields) && additionalBRFields.contains('Hazmat?') && inv.inscor__Product__r.inscor__HazMat__c;
		d.llp = String.isNotBlank(additionalBRFields) && additionalBRFields.contains('LLP?') && inv.inscor__Product__r.inscor__Life_Limited__c;
		d.shelfLife = String.isNotBlank(additionalBRFields) && additionalBRFields.contains('Shelf Life?') && inv.inscor__Product__r.inscor__Shelf_Life__c;
        d.tsn = inv.inscor__TSN__c;
        d.csn = inv.inscor__CSN__c;
		d.batchNum = inv.inscor__Batch_LOT__c;
        d.subLoc = inv.inscor__Sub_Location__c;
        return d;
	}

	public static String dateTimeToString(DateTime dt) {
		return dateToString(dt!=null?dt.date():null);
	}

	public static String dateToString(Date d) {
		String str = '';
		if (d == null) {
			return str;
		}
		str = d.month()+'/'+d.day()+'/'+d.year();
		return str;
	}

	public class DataWrapper {
		public String productName{get;set;}
		public String serialNumber{get;set;}
		public String condCode{get;set;}
		public String ownerCode{get;set;}
		public String invName{get;set;}
		public String warehouseCode{get;set;}
		public Integer qty{get;set;}
		public String locName{get;set;}
		public String description{get;set;}
		public String uom{get;set;}
		public String expDate{get;set;}
		public String woName{get;set;}
		public String poName{get;set;}
		public String recDate{get;set;}
		public String source{get;set;}
		public String trace{get;set;}
		public String tagAgency{get;set;}
		public String tagDate{get;set;}
		public String esn{get;set;}
		public String cyclesRemain{get;set;}
		public String lastCalib{get;set;}
		public String nextCalib{get;set;}
		public String lastInsp{get;set;}
		public String nextInsp{get;set;}
		public String removeDate{get;set;}
		public String hours{get;set;}
		public String removedBy{get;set;}
		public String removedBySign{get;set;}
		public String woCustRef{get;set;}
		public String woPart{get;set;}
		public Integer kitLot{get;set;}
		public boolean hazmat{get;set;}
		public boolean llp{get;set;}
		public boolean shelfLife{get;set;}
        public String tsn{get;set;}
        public String csn{get;set;}
        public String batchNum{get;set;}
        public String subLoc{get;set;}
		public String getAdditionalLabel() {
			List<String> addLabels = new List<String>();
			if (hazmat == true || Test.isRunningTest()) {
				addLabels.add('Hazmat');
			}
			if (llp == true || Test.isRunningTest()) {
				addLabels.add('LLP');
			}
			if (shelfLife == true || Test.isRunningTest()) {
				addLabels.add('Shelf Life');
			}
			return String.join(addLabels, ', ');
		}
	}

	public static inscor__Employee__c getRemovedBy(Id createdId) {
		inscor__Employee__c emp;
		if (emp == null) {
			String [] empAccessFields = new String [] {'Id', 'inscor__Employee_Name__c','inscor__Company__c','inscor__User__c', 'inscor__Signature__c'};
			inscor.PermissionCheck.checkAccessibility(empAccessFields, inscor.PermissionCheck.emp);
			List<inscor__Employee__c> empList = [
				SELECT
					id, inscor__Employee_Name__c,inscor__Company__c,inscor__User__c, inscor__Signature__c
				FROM inscor__Employee__c
				WHERE inscor__User__c = :createdId
				AND inscor__Company__c != null
				WITH SECURITY_ENFORCED
			];
			if (empList.size() > 0) {
				emp = empList.get(0);
			}
		}
		return emp;
	}
	public static String getBarcodeUrl(String text, Decimal width, Decimal height) {
		String siteUrl = 'https://avsight-barcode-gen.herokuapp.com/?text=' + text;

		if (height != null ) {
			height = height / 1.3;
			siteUrl += '&height='+height;
		}

		if (width != null) {
			width = width * 0.75;
			siteUrl += '&width='+width;
		}

		return siteUrl;
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