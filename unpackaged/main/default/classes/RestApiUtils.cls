global with sharing class RestApiUtils {

	global class RestApiException extends Exception {
		global Integer statusCode;
		global RestApiException (Integer statusCode, String error) {
			this.setMessage(error);
			this.statusCode = statusCode;
		}
	}

	global class RestApiErrorResponse {
		global String error;
		global RestApiErrorResponse(Exception ex) {
			this.error = ex.getMessage();
		}
	}
}