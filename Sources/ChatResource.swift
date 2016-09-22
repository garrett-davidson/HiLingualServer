import PerfectLib
import PerfectHTTP
import AppKit

func handleChat(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>chat</title><body>Chat resource</body></html>")
    sendMessageWith(request: request, response)
    response.completed()
}

func handlePicture(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>picture</title><body>Chat resource</body></html>")
    sendPictureMessageWith(request: request, response)
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

func sendPictureMessageWith(request: HTTPRequest, _ response: HTTPResponse) {
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

    guard let uploads = request.postFileUploads, uploads.count > 0  else {
        print("no uploads")
        return
    }

    var ary = [[String:Any]]()

    if uploads.count > 1 {
        print("more than one picture")
        invalidMessage(request: request, response)
        return
    }
    ary.append([
        "fieldName": uploads[0].fieldName,
        "contentType": uploads[0].contentType,
        "fileName": uploads[0].fileName,
        "fileSize": uploads[0].fileSize,
        "tmpFileName": uploads[0].tmpFileName
        ])
    guard let image = NSImage(contentsOfFile: uploads[0].tmpFileName) else {
        print("Invalid Picture")
        return
    }
    print(ary)
    print("upload")
    print("auth=\(auth)")
    print("recipient=\(recipientString)")

    if uploads[0].fileSize > 10000000 {
        print("picture is to big")
        invalidMessage(request: request, response)
        return
    }

    guard let recipient = Int(recipientString) else {
        invalidMessage(request: request, response)
        print("invalid recipient ID")
        return
    }
    //addChatToTableAudio(auth: auth, recipient: recipient, audio: uploads)
}


func invalidMessage(request: HTTPRequest, _ response: HTTPResponse) {
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>chat</title><body>Invalid message!</body></html>")
}
