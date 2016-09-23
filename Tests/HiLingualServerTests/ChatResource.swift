import XCTest
@testable import HiLingualServer

class ChatResourceTests: XCTestCase {
    let invalidMessageBody = "<html><title>chat</title><body>Invalid message!</body></html>"

    func testSendMessageWithRequest() {
        var request = ShimHTTPRequest()
        var response = ShimHTTPResponse()

        sendMessageWith(request: request, response)
        guard let bodyDict = response.body else {
            XCTFail()
            return
        }

        guard let body = bodyDict["string"] as? String else {
            XCTFail()
            return
        }
        XCTAssertEqual(body, invalidMessageBody)
    }
}
