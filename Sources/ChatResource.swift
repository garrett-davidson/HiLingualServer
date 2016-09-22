import PerfectLib
import PerfectHTTP

func handleChat(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>chat</title><body>Chat resource</body></html>")
    sendMessageWith(request: request, response)
    sendAudioMessageWith(request: request, response)
    response.completed()
}

func sendMessageWith(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        print("no auth token")
        invalidMessage(request: request, response)
        return
    }

    guard let recipientString = request.param(name: "recipient") else {
        print("no recipient")
        invalidMessage(request: request, response)
        return
    }

    guard let message = request.param(name: "message") else {
        print("no message")
        invalidMessage(request: request, response)
        return
    }

    if message.characters.count > 500 {
        print("message to long")
        invalidMessage(request: request, response)
        return
    }

    print("auth=\(auth)")
    print("recipient=\(recipientString)")
    print("message=\(message)")
    guard let recipient = Int(recipientString) else {
        invalidMessage(request: request, response)
        print("invalid recipient ID")
        return
    }
    addChatToTable(auth: auth, recipient: recipient, message: message)
}

func sendAudioMessageWith(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        print("no auth token")
        invalidMessage(request: request, response)
        return
    }

    guard let recipientString = request.param(name: "recipient") else {
        print("no recipient")
        invalidMessage(request: request, response)
        return
    }

    guard let audio = request.param(name: "audio") else {
        print("no audio")
        invalidMessage(request: request, response)
        return
    }

    if audio.characters.count > 500 {
        print("audio to long")
        invalidMessage(request: request, response)
        return
    }

    print("auth=\(auth)")
    print("recipient=\(recipientString)")
    print("audio=\(audio)")
    guard let recipient = Int(recipientString) else {
        invalidMessage(request: request, response)
        print("invalid recipient ID")
        return
    }
    addChatToTableAudio(auth: auth, recipient: recipient, audio: audio)
}


func invalidMessage(request: HTTPRequest, _ response: HTTPResponse) {
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>chat</title><body>Invalid message!</body></html>")
}
