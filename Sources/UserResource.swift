import PerfectLib
import PerfectHTTP

func handleUserUpdate(request: HTTPRequest, _ response: HTTPResponse) {


      defer {
        response.completed()
    }

    guard var urlString = request.urlVariables[routeTrailingWildcardKey] else {
        return
    }
    var urlStringArray = urlString.characters.split {$0 == "/"}.map(String.init)

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

        if (verbose) {
            print("Read JSON string")
        }

        if urlStringArray[0] == "match" {
            getMatchList(request: request, response, result)
        } else {
            if verifyAuthToken(request: request, response, result) {
                editUserInfo(request: request, response, result)
            } else {
                errorResponse(response: response)
            }
        }

    } catch {
        print("Could not parse JSON request")
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

    overwriteUserData(user: user)

}

func getMatchList(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
    print("Getting User matches")
    guard let authToken = requestBodyDic["authorityToken"] as? String else {
        print("bad auth token")
        badRequestResponse(response: response)
        return
    }
    guard let curUser = lookupUserWith(sessionToken: authToken) else {
        print("failed to lookup user")
        badRequestResponse(response: response)
        return
    }

    if verifyAuthToken(request: request, response, requestBodyDic) {
        let age = curUser.getBirthdate()
        let nativeLanguages = curUser.getNativeLanguage()
        let learningLanguage = curUser.getLearningLanguage()
        let arrayOfMatches = getMatches(nativeLanguages: nativeLanguages, learningLanguage:learningLanguage, userBirthdate: age).unique
        do {
            let encodedJSON = try Array(arrayOfMatches.prefix(20)).jsonEncodedString()
            response.setBody(string: encodedJSON)
        } catch {
            if verbose {print(error)}
            return
        }
    } else {
        errorResponse(response: response)
    }
}


extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}
