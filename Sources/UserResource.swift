import PerfectLib
import PerfectHTTP

func handleUser(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    //response.setHeader(.contentType, value: "text/html")
    print("start")

    defer {
	response.completed()
    }

    guard var urlString = request.urlVariables[routeTrailingWildcardKey] else {
	return
    }

    //swiftlint:disable opening_brace
    var urlStringArray = urlString.characters.split{$0 == "/"}.map(String.init)

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
	//validate badRequestResponse
	guard let _ = request.header(HTTPRequestHeader.Name.authorization) else {
	    print("no auth parameter")
	    unauthorizedResponse(response: response)
	    return
	}

	if urlStringArray[0] == "search" {
	    loginWith(request: request, response, result)
	} else if urlStringArray[0] == "match" {
	    registerWith(request: request, response, result)
	}

    } catch {
	print("bad request")
	badRequestResponse(response: response)
	return
    }
}

func handleUserUpdate(request: HTTPRequest, _ response: HTTPResponse) {
    guard request.postBodyString != nil else {
        return
    }
    guard let jsonString: String = request.postBodyString else {
        print("Empty body")
        return
    }

    do {
	guard let result = try jsonString.jsonDecode() as? Dictionary<String, AnyObject> else {
	    print("invalid json string")
	    return
	}
	guard let _ = request.header(HTTPRequestHeader.Name.authorization) else {
	    print("no auth parameter")
	    unauthorizedResponse(response: response)
	    return
	}
	editUserInfo(request: request, response, result)
    } catch {
	print("bad request")
	badRequestResponse(response: response)
	return
    }

}

func editUserInfo(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: Dictionary<String, AnyObject>) {
    print("Editing User")
    guard let userId = requestBodyDic["userId"] as? Int else {
    	print("bad request")
    	badRequestResponse(response: response)
    	return
    }
    guard let name = requestBodyDic["name"] as? String else {
    	print("bad request")
    	badRequestResponse(response: response)
    	return
    }
    guard let displayName = requestBodyDic["displayName"] as? String else {
    	print("bad request")
    	badRequestResponse(response: response)
    	return
    }
    guard let bio = requestBodyDic["bio"] as? String else {
    print("bad request")
    	badRequestResponse(response: response)
    	return
    }
    guard let gender = requestBodyDic["gender"] as? Gender else {
    	print("bad request")
    	badRequestResponse(response: response)
    	return
    }
    guard let birthdate = requestBodyDic["birthdate"] as? Int else {
    	print("bad request")
    	badRequestResponse(response: response)
    	return
    }
    let user = User(newUserId: userId, newName: name, newDisplayName: displayName, newBio: bio, newGender: gender, newBirthdate: birthdate)


    if verifyAuthToken(request: request, response, requestBodyDic) {
    	overwriteUserData(user: user)
    } else {
	   errorResponse(response: response)
    }
}
