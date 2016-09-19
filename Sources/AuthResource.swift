import PerfectLib
import Foundation
import PerfectHTTP

func handleAuth(request: HTTPRequest, _ response: HTTPResponse) {
	//parse uri and call relevant funtion
	//response.setHeader(.contentType, value: "text/html")
	defer {
		response.completed()
	}
	guard var urlString = request.urlVariables[routeTrailingWildcardKey] else {
		return
	}

	//deserialize request JSON body to Dictionary
	var jsonString: String! = request.postBodyString
	do {
		guard let result = try jsonString.jsonDecode() as? Dictionary<String, AnyObject> else {
			return
		}

		//validate request
		guard let auth = request.header(HTTPRequestHeader.Name.authorization) else {
			print("no auth parameter")
			unauthorizedResponse(response: response)
	        return
	    }


		//parse uri
		urlString.remove(at: urlString.startIndex)
		print(urlString)	
		if urlString == "login" {
			loginWith(request: request, response, result)
		} else if urlString == "register" {
			registerWith(request: request, response,result)
		} else if urlString == "logout" {
			logoutWith(request: request, response,result)
		}
		response.completed()
	} catch {
		//invalid json
		badRequestResponse(response: response)
		return
	}

}
func loginWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>){
	print("Logging in user")
	print(requestBodyDic["authority"])
	print(requestBodyDic["authorityAccountId"])
	print(requestBodyDic["authorityToken"])
	//TODO: validate auth token
	//create session/session token with hilingual
	//respond to user
}

func logoutWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>){
	print("Logging out user")
	print(requestBodyDic["authority"])
	print(requestBodyDic["authorityAccountId"])
	print(requestBodyDic["authorityToken"])
	//TODO: revoke hilingual session
	//respond to user
}
func registerWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>){
	print("Registering new user")
	print(requestBodyDic["authority"])
	print(requestBodyDic["authorityAccountId"])
	print(requestBodyDic["authorityToken"])
	//create new user in database
	//respond to user
}
func badRequestResponse(response: HTTPResponse) {
	//400 code
	response.setHeader(.contentType, value: "text/html")
	response.status = HTTPResponseStatus.badRequest;
}
func unauthorizedResponse(response: HTTPResponse) {
	//401 code
	response.setHeader(.contentType, value: "text/html")
	response.status = HTTPResponseStatus.unauthorized;
}
func errorResponse(response: HTTPResponse) {
	//500 code
	response.setHeader(.contentType, value: "text/html")
	response.status = HTTPResponseStatus.unauthorized;
}