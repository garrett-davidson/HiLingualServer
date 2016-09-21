import PerfectLib
import Foundation
import PerfectHTTP

func handleAuth(request: HTTPRequest, _ response: HTTPResponse) {
	//parse uri and call relevant funtion
	//response.setHeader(.contentType, value: "text/html")
	print("start")
	defer {
		response.completed()
	}
	guard var urlString = request.urlVariables[routeTrailingWildcardKey] else {
		return
	}

	//deserialize request JSON body to Dictionary
	let jsonString: String! = request.postBodyString
	do {
		guard let result = try jsonString.jsonDecode() as? Dictionary<String, AnyObject> else {
			print("invalid json string")
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
			registerWith(request: request, response, result)
		} else if urlString == "logout" {
			logoutWith(request: request, response, result)
		}
		response.completed()
	} catch {
		print("bad request")
		badRequestResponse(response: response)
		return
	}
	response.completed()

}
func verifyAuthToken(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>) -> Bool {
	//https://graph.facebook.com/me?access_token=xxxxxxxxxxxxxxxxx     FACEBOOK URL
	//
    guard let token = requestBodyDic["authorityToken"] as? String else {
   		print("no auth token sent")
   		return false
    }
    guard let auth = requestBodyDic["authority"] as? String else {
   		print("no authority sent")
   		return false
    }
    if auth == "FACEBOOK" {
    	return checkFacebookAuthority(token)
    } else if auth == "GOOGLE" {
    	return checkGoogleAuthority(token)
	} else {
		print("bad authority sent")
   		return false
	}
}
func checkGoogleAuthority(_ token: String) -> Bool {
    let scriptURL = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=\(token)"
    let myUrl = URL(string: scriptURL)
    guard let request1: URLRequest = URLRequest(url: myUrl!) else {
    	return false
    }
    do {
	     var response: URLResponse?

        let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returning: &response)
            do {
            	if let httpResponse = response as? HTTPURLResponse {
	                if httpResponse.statusCode == 200 {
	            		return true
	            	} else {
	            		return false
	            	}
	            }
            } catch let error as NSError {
                print(error.localizedDescription)
            }

    } catch let error as NSError {
         print(error.localizedDescription)
    }
    return false
}
func checkFacebookAuthority(_ token: String) -> Bool {
    let scriptURL = "https://graph.facebook.com/me?access_token=\(token)"
    let myUrl = URL(string: scriptURL)
    guard let request1: URLRequest = URLRequest(url: myUrl!) else {
    	return false
    }
    do {
	    var response: URLResponse?

        let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returning: &response)
            do {
                if let httpResponse = response as? HTTPURLResponse {
                	if httpResponse.statusCode == 200 {
	            		return true
	            	} else {
	            		return false
	            	}
            	}
            } catch let error as NSError {
                print(error.localizedDescription)
            }
    } catch let error as NSError {
         print(error.localizedDescription)
    }
    return false
}
func loginWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>) {
	print("Logging in user")
	print(requestBodyDic["authority"])
	print(requestBodyDic["authorityAccountId"])
	print(requestBodyDic["authorityToken"])
	if verifyAuthToken(request: request, response, requestBodyDic) {
		guard let token = requestBodyDic["authorityToken"] as? String else {
	   		print("no auth token sent")
	   		badRequestResponse(response: response)
	   		return
    	}
    	guard let authID = requestBodyDic["authorityAccountId"] as? String else {
	   		print("no authID sent")
	   		badRequestResponse(response: response)
	   		return
    	}
    	loginUserWith(authAccountId: authID, sessionId: token)
	} else {
		errorResponse(response: response)
	}
}

func logoutWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>) {
	print("Logging out user")
	print(requestBodyDic["authority"])
	print(requestBodyDic["authorityAccountId"])
	print(requestBodyDic["authorityToken"])
	if verifyAuthToken(request: request, response, requestBodyDic) {
		guard let token = requestBodyDic["authorityToken"] as? String else {
	   		print("no auth token sent")
	   		badRequestResponse(response: response)
	   		return
    	}
    	guard let authID = requestBodyDic["authorityAccountId"] as? String else {
	   		print("no authID sent")
	   		badRequestResponse(response: response)
	   		return
    	}
    	logoutUserWith(authAccountId: authID, sessionId: token)
	} else {
		errorResponse(response: response)
	}
}
func registerWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>) {
	print("Registering new user")
	print(requestBodyDic["authority"])
	print(requestBodyDic["authorityAccountId"])
	print(requestBodyDic["authorityToken"])
	if verifyAuthToken(request: request, response, requestBodyDic) {
		guard let token = requestBodyDic["authorityToken"] as? String else {
	   		print("no auth token sent")
	   		return
    	}
		var user = createUserWith(token: token)
		var dict = ["userId": user.getUserId(), "sessionId": user.getSessionToken()]
		do {
			try response.setBody(json: dict)
		} catch {
			print(error)
		}
	} else {
		unauthorizedResponse(response: response)
	}

	//create new user in database
	//respond to user
}

func badRequestResponse(response: HTTPResponse) {
	//400 code
	response.setHeader(.contentType, value: "text/html")
	response.status = HTTPResponseStatus.badRequest
}
func unauthorizedResponse(response: HTTPResponse) {
	//401 code
	response.setHeader(.contentType, value: "text/html")
	response.status = HTTPResponseStatus.unauthorized
}
func errorResponse(response: HTTPResponse) {
	//500 code
	response.setHeader(.contentType, value: "text/html")
	response.status = HTTPResponseStatus.internalServerError
}
