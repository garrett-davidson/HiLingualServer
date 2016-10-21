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
        if urlStringArray[0] == "match" {
            getMatchList(request: request, response, result)
        } else if urlStringArray[0] == "update" {
            if verifyAuthToken(request: request, response, result) {
                print("worked")
                editUserInfo(request: request, response, result)
            } else {
                print("got wrecked")
                unauthorizedResponse(response: response)
            }
        } else {
            print("bad request")
            badRequestResponse(response: response)
            return
        }

    } catch {
        print("Could not parse JSON request")
        badRequestResponse(response: response)
        return
    }

}

func editUserInfo(request: HTTPRequest, _ response: HTTPResponse, _ requestBodyDic: [String: AnyObject]) {
    print("Editing User")
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


    if let name = requestBodyDic["name"] as? String {
        curUser.setName(newName: name)
    }
    if let displayName = requestBodyDic["displayName"] as? String {
       curUser.setDisplayName(newDisplayName:displayName)
    }
    if let bio = requestBodyDic["bio"] as? String {
        curUser.setBio(newBio:bio)
    }
    if let gender = requestBodyDic["gender"] as? String {
        var inGender: Gender
        if gender == "MALE" {
            inGender = Gender.MALE
        } else if gender == "FEMALE" {
            inGender = Gender.FEMALE
        } else {
            inGender = Gender.NOTSET
        }
        curUser.setGender(newGender:inGender)
    }
    if let birthdate = requestBodyDic["birthdate"] as? Int {
        curUser.setBirthdate(newBirthdate:birthdate)
    }
    if let nativeLanguage = requestBodyDic["nativeLanguages"] as? String {
        curUser.setNativeLanguage(newNativeLanguage:nativeLanguage)
    }
    if let learningLanguage = requestBodyDic["learningLanguages"] as? String {
       curUser.setLearningLanguage(newLearningLanguage:learningLanguage)
    }
    overwriteUserData(user: curUser)

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
        let nativeLanguage = curUser.getNativeLanguage()
        let learningLanguage = curUser.getLearningLanguage()
        let arrayOfMatches = getMatches(nativeLanguage: nativeLanguage, learningLanguage:learningLanguage, userBirthdate: age).unique
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
