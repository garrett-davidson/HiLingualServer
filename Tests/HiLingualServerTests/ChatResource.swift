import XCTest
@testable import HiLingualServer

class ChatResourceTests: XCTestCase {
    let invalidMessageBody = "<html><title>chat</title><body>Invalid message!</body></html>"

    func testSendMessageWithRequest() {
        let request = ShimHTTPRequest()
        let response = ShimHTTPResponse()

        handleChat(request: request, response)
        guard let body = response.body else {
            XCTFail("Response has no body")
            return
        }

        XCTAssertEqual(body, invalidMessageBody)
    }
}
