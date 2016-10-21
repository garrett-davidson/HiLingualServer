import PerfectLib
import PerfectHTTP
import AppKit
import AVFoundation
import Foundation

struct Message {
    let messageId: Int
    let sentTimestamp: Date
    let editTimestamp: Date?
    let sender: Int
    let receiver: Int
    let body: String
    let editedBody: String?
}

func handleChat(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>chat</title><body>Chat resource Message</body></html>")
    print("Appending body")
    sendMessageWith(request: request, response)
    response.completed()
}

func handleChatGet(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>chat</title><body>Chat resource Message</body></html>")
    print("Appending body")
    getMessageWith(request: request, response)
    response.completed()
}

func handlePicture(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>picture</title><body>Chat resource Picture</body></html>")
    sendPictureMessageWith(request: request, response)
    response.completed()
}

func handleAudio(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>Audio</title><body>Chat resource Audio</body></html>")
    sendAudioMessageWith(request: request, response)
    response.completed()
}

func handleTranslation(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>Audio</title><body>Chat resource Audio</body></html>")
    translateMessageWith(request: request, response)
    response.completed()
}

func translateMessageWith(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        print("no auth token")
        invalidAuth(request: request, response)
        return
    }

    guard let language = request.param(name: "language") else {
        print("no language")
        invalidMessage(request: request, response)
        return
    }

    guard let _ = lookupUserWith(sessionToken: auth) else {
        print("Invalid auth")
        invalidAuth(request: request, response)
        return
    }

    guard let message = request.param(name: "message"), message.characters.count > 0 else {
        print("no message")
        invalidMessage(request: request, response)
        return
    }

    if message.characters.count > 500 {
        print("message too long")
        invalidMessage(request: request, response)
        return
    }
    guard let translatedString = translateMessage(message: message, language: language) else {
        print("invalid translation")
        invalidMessage(request: request, response)
        return
    }
    response.setBody(string: translatedString)
}

func translateMessage(message: String, language: String) -> String? {
    let scriptURL = "Http://api.microsofttranslator.com/V2/Http.svc/Translate"
    guard let myUrl = URL(string: scriptURL) else {
        return nil
    }
    var request: URLRequest = URLRequest(url: myUrl)
    let body = ["appid":"", "text": message, "to":language, "contentType":"text/plain", "category":"general"]
    request.httpBody = try? JSONSerialization.data(withJSONObject: NSDictionary(dictionary:body), options: JSONSerialization.WritingOptions(rawValue: 0))
    guard let token = getTranslateToken() else {
        print("token failed")
        return nil
    }
    let header = ["Authrization":token]
    request.allHTTPHeaderFields = header
    if verbose {
        print(request)
    }
    var response: URLResponse?
    if let responseData = try? NSURLConnection.sendSynchronousRequest(request, returning: &response) {
        if verbose {
            print(responseData)
            print(response)
        }

        if let returnString = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue) {
            return returnString as String
        }
    }
    return nil

}


func getMessageWith(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        print("no auth token")
        invalidAuth(request: request, response)
        return
    }

    guard let recipientString = request.param(name: "recipient") else {
        print("no recipient")
        invalidMessage(request: request, response)
        return
    }

    guard let recipient = Int(recipientString) else {
        invalidMessage(request: request, response)
        print("invalid recipient ID")
        return
    }

    guard isValid(userId: recipient) else {
        invalidMessage(request: request, response)
        print("Invalid recipient ID")
        return
    }

    guard let sender = lookupUserWith(sessionToken: auth) else {
        print("Invalid auth")
        invalidAuth(request: request, response)
        return
    }

    if recipient == sender.getUserId() {
        print("Can't receive messages from your self")
        invalidMessage(request: request, response)
        return
    }

    guard let messages = getMessages(withSessionToken: auth, forUser: recipient) else {
        print("failed to get messages from database")
        invalidMessage(request: request, response)
        return
    }

    if messages.count < 1 {
        print("no messages with that id")
        response.setBody(string: "{ \"Messages\":[]}")
        return
    }

    response.setBody(string: "{ \"Messages\":[")
    for message in messages {
        response.appendBody(string: "{ \"messageId\":\"\(message.messageId)\",")
        response.appendBody(string: " \"sentTimestamp\":\"\(message.sentTimestamp)\",")
        response.appendBody(string: " \"sender\":\"\(message.sender)\",")
        response.appendBody(string: " \"receiver\":\"\(message.receiver)\",")
        response.appendBody(string: " \"body\":\"\(message.body)\"}")
        if message.messageId != messages[messages.count - 1].messageId {
            response.appendBody(string: ",")
        }

    }
    response.appendBody(string: "]}")

}

func sendMessageWith(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        print("no auth token")
        invalidAuth(request: request, response)
        return
    }

    guard let recipientString = request.param(name: "recipient") else {
        print("no recipient")
        invalidMessage(request: request, response)
        return
    }

    guard let message = request.param(name: "message"), message.characters.count > 0 else {
        print("no message")
        invalidMessage(request: request, response)
        return
    }

    if message.characters.count > 500 {
        print("message too long")
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

    guard isValid(userId: recipient) else {
        invalidMessage(request: request, response)
        print("Invalid recipient ID")
        return
    }

    guard let sender = lookupUserWith(sessionToken: auth) else {
        print("Invalid auth")
        invalidAuth(request: request, response)
        return
    }

    if recipient == sender.getUserId() {
        print("Can't send to self")
        invalidMessage(request: request, response)
        return
    }

    addMessageToTable(sender: sender.getUserId(), recipient: recipient, message: message)
    let notification = NSNotification(name: NSNotification.Name(rawValue: "Received message"), object: nil, userInfo: ["Sender": sender, "Recipient": recipient, "Message": message])
    send(notification: notification, toUser: recipient)
}

func sendPictureMessageWith(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        print("no auth token")
        invalidAuth(request: request, response)
        return
    }

    guard let recipientString = request.param(name: "recipient") else {
        print("no recipient")
        invalidMessage(request: request, response)
        return
    }

    guard let uploads = request.postFileUploads, uploads.count > 0  else {
        print("no uploads")
        invalidMessage(request: request, response)
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
    guard let _ = NSImage(contentsOfFile: uploads[0].tmpFileName) else {
        print("Invalid Picture")
        invalidMessage(request: request, response)
        return
    }
    print("upload picture")
    print("auth=\(auth)")
    print("recipient=\(recipientString)")

    if uploads[0].fileSize > 10000000 {
        print("picture is too big")
        invalidMessage(request: request, response)
        return
    }

    guard let recipient = Int(recipientString) else {
        invalidMessage(request: request, response)
        print("Invalid recipient ID")
        return
    }

    guard isValid(userId: recipient) else {
        invalidMessage(request: request, response)
        print("Invalid recipient ID")
        return
    }

    guard let sender = lookupUserWith(sessionToken: auth) else {
        print("Invalid auth")
        invalidAuth(request: request, response)
        return
    }

    if recipient == sender.getUserId() {
        print("Can't send to self")
        invalidMessage(request: request, response)
        return
    }

    if let picture = storePicture(atPath: uploads[0].tmpFileName) {
        addPictureMessageToTable(sender: sender.getUserId(), recipient: recipient, picture: picture)
    } else {
        response.setHeader(.contentType, value: "text/html")
        response.setBody(string: "<html><title>chat</title><body>Unable to save picture</body></html>")
    }

    let notification = NSNotification(name: NSNotification.Name(rawValue: "Received picture message"), object: nil, userInfo: ["Sender": sender, "Recipient": recipient])
    send(notification: notification, toUser: recipient)
}

func sendAudioMessageWith(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        print("no auth token")
        invalidAuth(request: request, response)
        return
    }

    guard let recipientString = request.param(name: "recipient") else {
        print("no recipient")
        invalidMessage(request: request, response)
        return
    }

    guard let uploads = request.postFileUploads, uploads.count > 0  else {
        print("no uploads")
        invalidMessage(request: request, response)
        return
    }

    var ary = [[String:Any]]()

    if uploads.count > 1 {
        print("more than one audio file")
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
    let fileUrl = URL(fileURLWithPath: uploads[0].tmpFileName)
    do {
        let _ = try AVAudioPlayer(contentsOf: fileUrl)
    } catch {
        invalidMessage(request: request, response)
        print("Invalid Audio")
        return
    }
    print("upload audio")
    print("auth=\(auth)")
    print("recipient=\(recipientString)")

    if uploads[0].fileSize > 10000000 {
        print("Audio is too big")
        invalidMessage(request: request, response)
        return
    }

    guard let recipient = Int(recipientString) else {
        invalidMessage(request: request, response)
        print("Invalid recipient ID")
        return
    }

    guard isValid(userId: recipient) else {
        invalidMessage(request: request, response)
        print("Invalid recipient ID")
        return
    }

    guard let sender = lookupUserWith(sessionToken: auth) else {
        print("Invalid auth")
        invalidAuth(request: request, response)
        return
    }

    if recipient == sender.getUserId() {
        print("Can't send to self")
        invalidMessage(request: request, response)
        return
    }

    if let audio = storeAudio(atPath: uploads[0].tmpFileName) {
        addAudioMessageToTable(sender: sender.getUserId(), recipient: recipient, audio: audio)
    } else {
        response.setHeader(.contentType, value: "text/html")
        response.setBody(string: "<html><title>chat</title><body>Unable to save audio</body></html>")
    }

    let notification = NSNotification(name: NSNotification.Name(rawValue: "Received audio message"), object: nil, userInfo: ["Sender": sender, "Recipient": recipient])
    send(notification: notification, toUser: recipient)
}

func storePicture(atPath srcPath: String) -> String? {
    var count = 0

    while true {
        do {
            let fileManager = FileManager.default
            guard let fileName = srcPath.components(separatedBy: "/").last else {
                print("no path")
                return nil
            }
            let path = fileManager.currentDirectoryPath + "/Resources/Pictures/"
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)

            try fileManager.moveItem(atPath: srcPath, toPath: path + fileName + "\(count)")
            return path + fileName + "\(count)"
        } catch let error as NSError {
            if error.code == 516 {
                count += 1
            } else {
                print("could not store picture")
                print(error)
                return nil
            }
        }
    }
}

func storeAudio(atPath srcPath: String) -> String? {
    var count = 0

    while true {
        do {
            let fileManager = FileManager.default
            guard let fileName = srcPath.components(separatedBy: "/").last else {
                print("no path")
                return nil
            }
            let path = fileManager.currentDirectoryPath + "/Resources/Audio/"
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)

            try fileManager.moveItem(atPath: srcPath, toPath: path + fileName + "\(count)")
            return path + fileName + "\(count)"
        } catch let error as NSError {
            if error.code == 516 {
                count += 1
            } else {
                print("could not store audio")
                print(error)
                return nil
            }
        }
    }
}

func invalidAuth(request: HTTPRequest, _ response: HTTPResponse) {
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>chat</title><body>Invalid authentication!</body></html>")
}

func invalidMessage(request: HTTPRequest, _ response: HTTPResponse) {
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>chat</title><body>Invalid message!</body></html>")
}

@discardableResult func send(notification: NSNotification, toUser userId: Int) -> Bool {
    guard let token = apnsToken(forUser: userId) else {
        if verbose {
            print("Unable to retrieve apns token")
        }
        return false
    }

    print("Sending notification to \(userId) with token \(token)")
    print(notification)
    return true
}
