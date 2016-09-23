import XCTest
import PerfectHTTP
@testable import HiLingualServer
typealias ShimBodySpec = MimeReader.BodySpec

class ChatResourceTests: XCTestCase {
    let invalidMessageBody = "<html><title>chat</title><body>Invalid message!</body></html>"
    let validMessageBody = "<html><title>chat</title><body>Chat resource Message</body></html>"
    let validPictureBody = "<html><title>picture</title><body>Chat resource Picture</body></html>"
    let validAuthToken = "1234567890"
    let validUserId = "1"
    override func setUp() {
        super.setUp()
        // Create user with valid id, auth token
        let testDatabase = "TestHiLingualDB"

        guard connectToMySql() else {
            print("Cannot loging to mysql")
            XCTFail()
            return
        }
        let _ = dataMysql.query(statement: "drop database \(testDatabase);")
        setupMysql(forSchema: testDatabase)
        guard dataMysql.query(statement: "INSERT INTO hl_users (session_token) VALUES(\"testsessiontoken\");") else {
            print("Error inserting into hl_users")
            XCTFail()
            return
        }

    }

    override func tearDown() {
        super.tearDown()

        dataMysql.close()
    }

    func testSendMessageWithRequest() {
        let request = ShimHTTPRequest()
        let response = ShimHTTPResponse()

        // Empty request
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody, failureString: "Allowed empty request")

        // Successful request
        request.postParams = [("auth", validAuthToken),
                              ("recipient", validUserId),
                              ("message", "a")]
        sendTestChatWith(request: request, response: response, expectedResponseString: validMessageBody, failureString: "Did not send successful request")

        // Too long message
        request.postParams = [("auth", validAuthToken),
                              ("recipient", validUserId),
                              ("message", String(repeating: "a", count: 501))]
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody, failureString: "Allowed too long message")

        // Invalid session token

        // Invalid recipient
        request.postParams = [("auth", validAuthToken),
                              ("recipient", "fdsa"),
                              ("message", "a")]
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody, failureString: "Allowed sending to invalid recipient")

        // Nonexistent recipient
        request.postParams = [("auth", validAuthToken),
                              ("recipient", "3"),
                              ("message", "a")]
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody, failureString: "Allowed sending to nonexistent recipient")

        // Empty message
        request.postParams = [("auth", validAuthToken),
                              ("recipient", "3"),
                              ("message", "")]
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody, failureString: "Allowed sending chat with empty message")

        // No message
        request.postParams = [("auth", validAuthToken),
                              ("recipient", "3")]
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody, failureString: "Allowed sening chat with no message")
    }

    func testSendPictureMessageWithRequest() {

        let request = ShimHTTPRequest()
        let response = ShimHTTPResponse()
        request.method = HTTPMethod.post
        // Empty request

        // Successful request

        request.postParams = [("auth", validAuthToken),
                              ("recipient", validUserId)]
        sendTestPictureWith(request: request, response: response, fileName: "cantaloupe-melon", size: 731245, expectedResponseString: validPictureBody, failureString: "Could not send Picture")

        // Too large of picture

        request.postParams = [("auth", validAuthToken),
                              ("recipient", validUserId)]
        sendTestPictureWith(request: request, response: response, fileName: "11mb", size: 11534222, expectedResponseString: invalidMessageBody, failureString: "Picture is over 10MB")

        // More than 1 picture

        // Extra fields

        // Invalid session token

        // Invalid recipient

        // Message to self

        // Nonexistent recipient

        // Empty picture

        // Invalid picture

        // No picture
    }
    func testSendAudioMessageWithRequest() {

        //AUDIO MESSAGE

        // Empty request

        // Successful request

        // Too large of audio file

        // More than one audio file

        // Extra fields

        // Invalid session token

        // Invalid recipient

        // Message to self

        // Nonexistent recipient

        // Empty audio file

        // Invalid audio

        // No audio
    }

    func sendTestChatWith(request: ShimHTTPRequest, response: ShimHTTPResponse, expectedResponseString: String, failureString: String) {
        handleChat(request: request, response)
        guard let body = response.body else {
            XCTFail("Test failure: Response has no body")
            return
        }
        XCTAssertEqual(body, expectedResponseString, "Test failure: " + failureString)
    }

    func sendTestPictureWith(request: ShimHTTPRequest, response: ShimHTTPResponse, fileName: String, size: Int, expectedResponseString: String, failureString: String) {
        let fileManager = FileManager.default
        let boundaryString = "gfdshtershagarseaha"
        let mimeReader = MimeReader("multipart/form-data; boundary=" + boundaryString, tempDir: fileManager.currentDirectoryPath)
        do {
            try fileManager.copyItem(atPath: fileManager.currentDirectoryPath + "/Tests/HiLingualServerTests/\(fileName).jpg", toPath: fileManager.currentDirectoryPath + "/Tests/HiLingualServerTests/\(fileName)Duplicate.jpg")
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
            if error.code != 516 {
                XCTFail("No picture \(fileName).jpg found")
            }
        }
        let filePath = fileManager.currentDirectoryPath + "/Tests/HiLingualServerTests/\(fileName)Duplicate.jpg"

        var bytes = [UInt8]()

        do {
            let imageData = try Data(contentsOf: URL(fileURLWithPath: filePath))
            var data = Data()
            data.append("--\(boundaryString)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=body\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n".data(using: .utf8)!)

            var buffer = [UInt8](repeating: 0, count: data.count)
            data.copyBytes(to: &buffer, count: data.count)
            bytes = buffer

            mimeReader.addToBuffer(bytes: bytes)

            let picture = mimeReader.bodySpecs.last!
            picture.fieldName = "body"
            picture.contentType = "image/jpg"
            picture.fileName = fileName + ".jpg"
            picture.fileSize = size
            picture.tmpFileName = fileManager.currentDirectoryPath + "/Tests/HiLingualServerTests/\(fileName)Duplicate.jpg"
            request.postFileUploads = [picture]
        } catch {
            XCTFail("Could not read image")
        }

        handlePicture(request: request, response)
        guard let body = response.body else {
            XCTFail("Test failure: Response has no body")
            return
        }
        XCTAssertEqual(body, expectedResponseString, "Test failure: " + failureString)
    }
}
