@RestResource(urlMapping='/v1/voucher/*')
global with sharing class RestApi_VoucherService {

	@HttpPost
	global static void initVoucherService() {
		RestRequest request = RestContext.request;
		RestResponse response = Restcontext.response;
		response.addHeader('Content-type','application/json');
		try {
			String roNum, invcNum, invcDate, dueDate;
			String reqBody = '';

			if (RestContext.request.requestBody != null) {
				reqBody = RestContext.request.requestBody.toString();
			}
			if (String.isBlank(reqBody)) {
				throw new RestApiUtils.RestApiException(422, 'Invalid request body');
			}

			Map<String, Object> reqBodyMap = (Map<String, Object>)JSON.deserializeUntyped(reqBody);
			List<Object> rolLines = (List<Object>)reqBodyMap.get('rolines');
			List<String> rolValues = new List<String>();
			for(Object obj : rolLines) {
				rolValues.add((String)obj);
			}
			
			roNum = (String)reqBodyMap.get('roNum');
			invcNum = (String)reqBodyMap.get('invcNum');
			invcDate = (String)reqBodyMap.get('invcDate');
			dueDate = (String)reqBodyMap.get('dueDate');

			if (String.isBlank(roNum)) {
				throw new RestApiUtils.RestApiException(422, 'RO number is required.');
			}
			if (String.isBlank(invcNum)) {
				throw new RestApiUtils.RestApiException(422, 'Invoice number is required.');
			}
			if (String.isBlank(invcDate)) {
				throw new RestApiUtils.RestApiException(422, 'Invoice date is required.');
			}
			if (String.isBlank(dueDate)) {
				throw new RestApiUtils.RestApiException(422, 'Due date is required.');
			}

			Date invcTempDt = Date.valueof(invcDate);
			Date dueTempDt = Date.valueof(dueDate);
			if  (invcTempDt > dueTempDt) {
				throw new RestApiUtils.RestApiException(422, 'Due date must be greater than Invoice date.');
			}

			String roPrefix = inscor__Repair_Order__c.SObjectType.getDescribe().getKeyPrefix();
			String queryField = (roNum.startsWith(roPrefix)) ? 'ID' : 'Name';
			String query = 'SELECT ID FROM inscor__Repair_Order__c WHERE ' + queryField + ' = :roNum WITH SECURITY_ENFORCED';
			List<inscor__Repair_Order__c> roObjList = Database.query(query);

			if (roObjList.size() > 0 ) {
				List<inscor.VoucherPostService.LineDetails> rolwrp = new List<inscor.VoucherPostService.LineDetails>();

				if (rolValues.size() > 0) {
					List<inscor__Repair_Order_Line__c> roLineList = [ SELECT Id FROM inscor__Repair_Order_Line__c 
						WHERE Name IN :rolValues AND inscor__Repair_Order__c = :roObjList[0].Id WITH SECURITY_ENFORCED 
					];

					if(roLineList.isEmpty()) {
						throw new RestApiUtils.RestApiException(422, 'Repair order line not found.');
					}

					for (inscor__Repair_Order_Line__c rol : roLineList) {
						inscor.VoucherPostService.LineDetails wrp = new inscor.VoucherPostService.LineDetails(rol.Id, null, null);
						rolwrp.add(wrp);
					}
				}
				inscor.VoucherPostService.voucherROSelectedLine(roObjList[0].Id, invcNum, invcDate, dueDate, rolwrp, null);
				response.statusCode = 200;
				response.responseBody = Blob.valueOf(JSON.serialize('SUCCESS'));
			} else {
				throw new RestApiUtils.RestApiException(422, 'Repair Order not found.');
			}
		} catch (NoAccessException e) {
			response.statusCode = 403;
			response.responseBody = Blob.valueOf(JSON.serialize(new RestApiUtils.RestApiErrorResponse(e)));
		} catch (RestApiUtils.RestApiException e) {
			response.statusCode = e.statusCode;
			response.responseBody = Blob.valueOf(JSON.serialize(new RestApiUtils.RestApiErrorResponse(e)));
		} catch (Exception e) {
			response.statusCode = 500;
			response.responseBody = Blob.valueOf(JSON.serialize(new RestApiUtils.RestApiErrorResponse(e)));
		}
	}
}