import PerfectLib
import Foundation
import PerfectHTTP

func handleFlashcard(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>Flashcard</title><body>Flashcards resource</body></html>")
    requestFlashcards(request: request, response)
    response.completed()
}

func requestFlashcards(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        print("no auth token")
        invalidFlashcard(request: request, response)
        return
    }
    guard let setId = request.param(name: "setid") else {
        print("no setId")
        invalidFlashcard(request: request, response)
        return
    }
    //Check to see auth is good
    //get user id
    guard let requestingUser = lookupUserWith(sessionToken: auth) else {
        print("invalid auth")
        invalidFlashcard(request: request, response)
        return
    }
    let flashcardRings = getFlashcards(userId: requestingUser.getUserId(), setId: setId)
    if flashcardRings.count < 1 {
        print("no flashcard with that name")
        invalidFlashcard(request: request, response)
        return
    }
    response.setBody(string: "{ \"\(setId)\":[")
    for flashcard in flashcardRings {
        response.appendBody(string: flashcard.description)
        if flashcard.description != flashcardRings[flashcardRings.count - 1].description {
            response.appendBody(string: ",")
        }
    }
    response.appendBody(string: "]}")


}
func handleFlashcardUpdate(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>Flashcard</title><body>Flashcard resource</body></html>")
    newFlashcards(request: request, response)
    response.completed()

}
func newFlashcards(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        print("no auth token")
        invalidFlashcard(request: request, response)
        return
    }
    if verbose {
        print(auth)
    }
    guard let requestingUser = lookupUserWith(sessionToken: auth) else {
        print("invalid auth")
        invalidFlashcard(request: request, response)
        return
    }

    guard request.postBodyString != nil else {
        invalidFlashcard(request: request, response)
        return
    }

    guard let jsonString: String = request.postBodyString else {
        print("Empty body")
        invalidFlashcard(request: request, response)
        return
    }
    do {
        guard let result = try jsonString.jsonDecode() as? [String: AnyObject] else {
            print("invalid json string")
            invalidFlashcard(request: request, response)
            return
        }
        let ringname = result.keys
        if ringname.count > 1 {
            print("to many arrays")
            invalidFlashcard(request: request, response)
            return
        }
        guard let setId = ringname.first else {
            print("no ID")
            invalidFlashcard(request: request, response)
            return
        }
        var flashcardRing = [Flashcard]()
        guard let newFlashcards = result[setId] as? NSArray else {
            print("improper formating")
            invalidFlashcard(request: request, response)
            return
        }
        for flashcard in newFlashcards {
            guard let flashcard = flashcard as? NSDictionary else {
                print("not formated")
                invalidFlashcard(request: request, response)
                return
            }
            guard let back = flashcard["back"] as? String else {
                print("no back")
                invalidFlashcard(request: request, response)
                return
            }
            guard let front = flashcard["front"] as? String else {
                print("no front")
                invalidFlashcard(request: request, response)
                return
            }
            if front.characters.count > 50 || back.characters.count > 50 {
                print("to many characters")
                invalidFlashcard(request: request, response)
                return
            }
            let newFlashcard = Flashcard(newFront: front, newBack: back)
            flashcardRing.append(newFlashcard)

        }
        let real = checkFlashcards(setId: setId, userId: requestingUser.getUserId())
        if real {
            print("Editing Flashcards")
            editFlashcards(setId: setId, userId: requestingUser.getUserId(), flashcards: flashcardRing)
        } else {
            print("Storing Flashcards")
            storeFlashcards(setId: setId, userId: requestingUser.getUserId(), flashcards: flashcardRing)
        }

    } catch {
        print("bad request")
        invalidFlashcard(request: request, response)
        return
    }

}
func invalidFlashcard(request: HTTPRequest, _ response: HTTPResponse) {
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>Flashcard</title><body>Invalid flashcard!</body></html>")
}
