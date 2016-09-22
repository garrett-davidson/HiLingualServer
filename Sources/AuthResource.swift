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
    guard request.postBodyString != nil else {
        return
    }

    guard let jsonString: String = request.postBodyString else {
        print("Empty body")
        return
    }

    do {
	guard let result = try jsonString.jsonDecode() as? [String: AnyObject] else {
	    print("invalid json string")
	    return
	}

	var urlStringArray = urlString.characters.split{$0 == "/"}.map(String.init)
	do {
		guard let result = try jsonString.jsonDecode() as? Dictionary<String, AnyObject> else {
			print("invalid json string")
			return
		}
		//validate request
		guard let _ = request.header(HTTPRequestHeader.Name.authorization) else {
			print("no auth parameter")
			unauthorizedResponse(response: response)
	        return
	    }
		if urlStringArray[0] == "login" {
			loginWith(request: request, response, result)
		} else if urlStringArray[0] == "register" {
			registerWith(request: request, response, result)
		} else if urlStringArray[0] == "logout" {
			logoutWith(request: request, response, result)
		}
		response.completed()
	} catch {
		print("bad request")
		badRequestResponse(response: response)
		return
	}

	print(urlString)
	if urlString == "login" {
	    loginWith(request: request, response, result)
	} else if urlString == "register" {
	    registerWith(request: request, response, result)
	} else if urlString == "logout" {
	    logoutWith(request: request, response, result)
	}
    } catch {
	print("bad request")
	badRequestResponse(response: response)
	return
    }
}

func verifyAuthToken(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) -> Bool {
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
    guard let myUrl = URL(string: scriptURL) else {
    	return false
    }
    let request1: URLRequest = URLRequest(url: myUrl)
    do {
	var response: URLResponse?

	try NSURLConnection.sendSynchronousRequest(request1, returning: &response)
    	if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
    } catch let error as NSError {
        print(error.localizedDescription)
    }
    return false
}

func checkFacebookAuthority(_ token: String) -> Bool {
    let scriptURL = "https://graph.facebook.com/me?access_token=\(token)"
    guard let myUrl = URL(string: scriptURL) else {
    	return false
    }
    let request1: URLRequest = URLRequest(url: myUrl)
    do {
	var response: URLResponse?

        try NSURLConnection.sendSynchronousRequest(request1, returning: &response)
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
    } catch let error as NSError {
        print(error.localizedDescription)
    }
    return false
}
func loginWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
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

func logoutWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
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

func registerWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
    print("Registering new user")
    print(requestBodyDic["authority"])
    print(requestBodyDic["authorityAccountId"])
    print(requestBodyDic["authorityToken"])
    if verifyAuthToken(request: request, response, requestBodyDic) {
		guard let token = requestBodyDic["authorityToken"] as? String else {
		    print("no auth token sent")
		    return
	    	}

		guard let user = createUserWith(token: token) else {
		    print("database error")
		    return
		}

		let dict: [String: Any] = ["userId": user.getUserId(), "sessionId": user.getSessionToken()]
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
