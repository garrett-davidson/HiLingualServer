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
		/*if result["authority"] as! String == "FACEBOOK" {
			print("ildsfhalkdf")
		}
	*/
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
		return
	}

}
func loginWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>){
	print("in login")
	print(requestBodyDic["authority"])
}

func logoutWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>){
	print("in logout")
	print(requestBodyDic["authority"])
}
func registerWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>){
	print("in register")
	print(requestBodyDic["authority"])
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