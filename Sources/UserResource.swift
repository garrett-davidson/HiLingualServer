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

    // swiftlint:disable opening_brace
    var urlStringArray = urlString.characters.split{$0 == "/"}.map(String.init)

    guard request.postBodyString != nil else {
        return
    }

    guard let jsonString = request.postBodyString else {
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

        if urlStringArray[0] == "match" {
            getMatchList(request: request, response, result)
        }

    } catch {
        print("bad request")
        badRequestResponse(response: response)
    }
}

func handleUserUpdate(request: HTTPRequest, _ response: HTTPResponse) {
    guard request.postBodyString != nil else {
        return
    }

    guard let jsonString = request.postBodyString else {
        print("Empty body")
        return
    }

    do {
        guard let result = try jsonString.jsonDecode() as? [String: AnyObject] else {
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

func editUserInfo(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
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

    guard let nativeLanguage = requestBodyDic["nativeLanguages"] as? String else {
        print("bad request")
        badRequestResponse(response: response)
        return
    }
    guard let learningLanguage = requestBodyDic["learningLanguages"] as? String else {
        print("bad request")
        badRequestResponse(response: response)
        return
    }
    let user = User(newUserId: userId, newName: name, newDisplayName: displayName, newBio: bio, newGender: gender, newBirthdate: birthdate, nativeLanguage: nativeLanguage, learningLanguage: learningLanguage)

    if verifyAuthToken(request: request, response, requestBodyDic) {
        overwriteUserData(user: user)
    } else {
        errorResponse(response: response)
    }
}

func getMatchList(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
    print("Getting User matches")
    guard let userId = requestBodyDic["userId"] as? Int else {
        print("bad request")
        badRequestResponse(response: response)
        return
    }

    if verifyAuthToken(request: request, response, requestBodyDic) {
        guard let curUser = getUser(userId: userId) else {
            print("no such user")
            badRequestResponse(response: response)
            return
        }
        let age = curUser.getBirthdate()
        let nativeLanguages = curUser.getNativeLanguage()
        let learningLanguage = curUser.getLearningLanguage()
        let arrayOfMatches = getMatches(nativeLanguages: nativeLanguages, learningLanguage:learningLanguage, userBirthdate: age)

        do {
            let encodedJSON = try arrayOfMatches.jsonEncodedString()
            response.setBody(string: encodedJSON)
        } catch {
            if verbose {print(error)}
            return
        }
    } else {
        errorResponse(response: response)
    }
}
