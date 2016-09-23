import XCTest
import PerfectHTTP
@testable import HiLingualServer

class ChatResourceTests: XCTestCase {
    let invalidMessageBody = "<html><title>chat</title><body>Invalid message!</body></html>"
    let validMessageBody = "<html><title>chat</title><body>Chat resource Message</body></html>"

    func testSendMessageWithRequest() {
        let request = ShimHTTPRequest()
        let response = ShimHTTPResponse()

        let validAuthToken = "1234567890"
        let validUserId = "1"

        // Empty request
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody)

        // Successful request

        // Too long message
        request.postParams = [("auth", validAuthToken),
                              ("recipient", validUserId),
                              ("message", String(repeating: "a", count: 501))]
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody)

        // Invalid session token

        // Invalid recipient
        request.postParams = [("auth", validAuthToken),
                              ("recipient", "fdsa"),
                              ("message", "a")]
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody)

        // Nonexistent recipient
        request.postParams = [("auth", validAuthToken),
                              ("recipient", "3"),
                              ("message", "a")]
        sendTestChatWith(request: request, response: response, expectedResponseString: invalidMessageBody)

        // Empty message

        // No message
    }

    func sendTestChatWith(request: ShimHTTPRequest, response: ShimHTTPResponse, expectedResponseString: String) {
        handleChat(request: request, response)
        guard let body = response.body else {
            XCTFail("Response has no body")
            return
        }
        XCTAssertEqual(body, expectedResponseString)
    }
}
