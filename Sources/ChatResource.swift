import PerfectLib
import PerfectHTTP
import AppKit
import AVFoundation
import Foundation

func handleChat(request: HTTPRequest, _ response: HTTPResponse) {
    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>chat</title><body>Chat resource Message</body></html>")
    print("Appending body")
    sendMessageWith(request: request, response)
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

    addMessageToTable(auth: auth, recipient: recipient, message: message)
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
        return
    }
    print(ary)
    print("upload")
    print("auth=\(auth)")
    print("recipient=\(recipientString)")

    if uploads[0].fileSize > 10000000 {
        print("picture is too big")
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

    if let picture = storePicture(atPath: uploads[0].tmpFileName) {
        addPictureMessageToTable(auth: auth, recipient: recipient, picture: picture)
    } else {
        response.setHeader(.contentType, value: "text/html")
        response.setBody(string: "<html><title>chat</title><body>Unable to save picture</body></html>")
    }
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
    } catch let error as NSError {
        print(error)
    }
    print("upload")
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

    if let audio = storePicture(atPath: uploads[0].tmpFileName) {
        addAudioMessageToTable(auth: auth, recipient: recipient, audio: audio)
    } else {
        response.setHeader(.contentType, value: "text/html")
        response.setBody(string: "<html><title>chat</title><body>Unable to save audio</body></html>")
    }
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
            print("could not store picture")
            if error.code == 516 {
                count += 1
                continue
            }
            print(error)
            return nil
        }
    }
}

func storeAudio(atPath srcPath: String) -> String? {
    do {
        let fileManager = FileManager.default
        guard let fileName = srcPath.components(separatedBy: "/").last else {
            print("no path")
            return nil
        }
        let path = fileManager.currentDirectoryPath + "/Resources/Audio/"

        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        try fileManager.moveItem(atPath: srcPath, toPath: path + fileName)
        return path + fileName
    } catch let error as NSError {
        print("could not store Audio")
        print(error)
        return nil
    }
}

func invalidMessage(request: HTTPRequest, _ response: HTTPResponse) {
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "<html><title>chat</title><body>Invalid message!</body></html>")
}
