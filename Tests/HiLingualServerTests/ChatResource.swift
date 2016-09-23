import XCTest
import PerfectHTTP
@testable import HiLingualServer

class ChatResourceTests: XCTestCase {
    let invalidMessageBody = "<html><title>chat</title><body>Invalid message!</body></html>"
    let validMessageBody = "<html><title>chat</title><body>Chat resource Message</body></html>"
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

        //PICTURE MESSAGE

        // Empty request

        // Successful request

        // Too large of picture

        // More than 1 picture

        // Extra fields

        // Invalid session token

        // Invalid recipient

        // Message to self

        // Nonexistent recipient

        // Empty picture

        // Invalid picture

        // No picture


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
}
