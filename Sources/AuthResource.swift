import PerfectLib
import Foundation
import PerfectHTTP

extension String {
    var isAlphanumeric: Bool {
        return range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) != nil
    }
}
let verbose = true

func handleAuth(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    //response.setHeader(.contentType, value: "text/html")
    if verbose {print("starter")}
    defer {
        response.completed()
    }

    guard var urlString = request.urlVariables[routeTrailingWildcardKey] else {
        if verbose {print("bad request, no urlstring")}
        badRequestResponse(response: response)
        return
    }

    //deserialize request JSON body to Dictionary
    guard let jsonString = request.postBodyString else {
        if verbose {
            print("Empty body")
            print("bad request, nojson body")
        }
        badRequestResponse(response: response)
        return
    }

    // swiftlint:disable opening_brace
    var urlStringArray = urlString.characters.split{$0 == "/"}.map(String.init)
    do {
        guard let result = try jsonString.jsonDecode() as? [String: AnyObject] else {
            if verbose {print("invalid json string")}
            return
        }
        //validate request
        if urlStringArray[0] == "login" {
            loginWith(request: request, response, result)
        } else if urlStringArray[0] == "register" {
            registerWith(request: request, response, result)
        } else if urlStringArray[0] == "logout" {
            logoutWith(request: request, response, result)
        } else {
            badRequestResponse(response: response)
        }
        response.completed()
    } catch {
        if verbose {print("bad request, invalid json syntax")}
        badRequestResponse(response: response)
        return
    }
}

func verifyAuthToken(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) -> Bool {
    //https://graph.facebook.com/me?access_token=xxxxxxxxxxxxxxxxx     FACEBOOK URL
    //
    guard let token = requestBodyDic["authorityToken"] as? String else {
        if verbose {print("no auth token sent")}
        badRequestResponse(response: response)
        return false
    }
    guard let auth = requestBodyDic["authority"] as? String else {
        if verbose {print("no authority sent")}
        return false
    }
    if auth == "FACEBOOK" {
        if checkFacebookAuthority(token) {
            return true
        }
        unauthorizedResponse(response: response)
    } else if auth == "GOOGLE" {
        if checkGoogleAuthority(token) {
            return true
        }
        unauthorizedResponse(response: response)
    } else {
        if verbose {print("bad authority sent")}
        unauthorizedResponse(response: response)
    }
    return false
}

func checkGoogleAuthority(_ token: String) -> Bool {
    let scriptURL = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=\(token)"
    guard let myUrl = URL(string: scriptURL) else {
        return false
    }
    let request1 = URLRequest(url: myUrl)
    do {
        var response: URLResponse?

        try NSURLConnection.sendSynchronousRequest(request1, returning: &response)
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
    } catch let error as NSError {
        if verbose {print(error.localizedDescription)}
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
        if verbose {print(error.localizedDescription)}
    }
    return false
}

func loginWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
    if verbose {
        print("Logging in user")
        print(requestBodyDic["authority"])
        print(requestBodyDic["authorityAccountId"])
        print(requestBodyDic["authorityToken"])
    }
    guard let _ = requestBodyDic["authority"] as? String else {
        badRequestResponse(response: response)
        return
    }
    guard let authorityAccountId = requestBodyDic["authorityAccountId"] as? String else {
        if verbose {print("no authID sent")}
        badRequestResponse(response: response)
        return
    }
    guard let authorityToken = requestBodyDic["authorityToken"] as? String else {
        if verbose {print("no auth token sent")}
        badRequestResponse(response: response)
        return
    }
    if verifyAuthToken(request: request, response, requestBodyDic) {
        print("attempting to login user")
        guard loginUserWith(authAccountId: authorityAccountId, sessionId: authorityToken) != nil else{
            print("database error or user does not exist")
            badRequestResponse(response: response)
            return
        }
    }
}

func logoutWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
    if verbose {print("Logging out user")}
    guard let auth = request.header(HTTPRequestHeader.Name.authorization) else {
        if verbose {print("no auth parameter")}
        badRequestResponse(response: response)
        return
    }
    guard let userId = requestBodyDic["user_id"] as? String, let userIdInt = Int(userId) else {
        if verbose { print("no authID sent")}
        badRequestResponse(response: response)
        return
    }
    if verifyAuthToken(request: request, response, requestBodyDic) {
        if !logoutUserWith(userId: userIdInt, sessionId: auth) {
        	badRequestResponse(response: response)
        }
    } else {
        print("Could not verifyAuthToken")
    }
}

func registerWith(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
    if verbose {
        print("Registering new user")
        print(requestBodyDic["authority"])
        print(requestBodyDic["authorityAccountId"])
        print(requestBodyDic["authorityToken"])
    }
    guard let _ = requestBodyDic["authority"] as? String else {
        badRequestResponse(response: response)
        return
    }
    guard let _ = requestBodyDic["authorityAccountId"] as? String else {
        badRequestResponse(response: response)
        return
    }
    guard let _ = requestBodyDic["authorityToken"] as? String else {
        badRequestResponse(response: response)
        return
    }
    if verifyAuthToken(request: request, response, requestBodyDic) {
        guard let token = requestBodyDic["authorityToken"] as? String else {
            if verbose {print("no auth token sent")}
            return
        }
        guard let authorityAccountId = requestBodyDic["authorityAccountId"] as? String else {
            if verbose {print("no auth account id sent")}
            return
        }

        guard let user = createUserWith(token: token, authorityAccountId: authorityAccountId) else {
            if verbose {print("database error or user exists")}
            badRequestResponse(response: response)
            return
        }
        print("userid: " + String(user.getUserId()) + " token: " + user.getSessionToken())
        let dict: [String: Any] = ["userId": user.getUserId(), "sessionToken": user.getSessionToken()]
        do {
            try response.setBody(json: dict)
        } catch {
            if verbose {print(error)}
        }
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
