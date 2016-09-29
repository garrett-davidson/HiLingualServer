import XCTest
@testable import HiLingualServer

class MainTests: XCTestCase {
    func testSendingMessage() {
        DispatchQueue.global().async {
            runServer()
        }

        sleep(1)

        var request = URLRequest(url: URL(string: "http://127.0.0.1:8180/chat/")!)
        var requestParameters = ["":""]
        let validToken = "fdsafdsa"

        request.httpMethod = "POST"

        request.httpBody = try! JSONSerialization.data(withJSONObject: requestParameters, options: .init(rawValue: 0))
        request.allHTTPHeaderFields = ["Authorization": validToken]

        var expectedResponse: NSDictionary = ["":""]

        sendTest(request: request, withExpectedResponse: expectedResponse)
    }

    func sendTest(request: URLRequest, withExpectedResponse expectedResponse: NSDictionary) {
        var resp: URLResponse?

        guard let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returning: &resp) else {
            XCTFail("Request did not return data: \(request)")
            return
        }

        guard let returnString = NSString(data: returnedData, encoding: String.Encoding.utf8.rawValue) else {
            XCTFail("Request did not return a string: \(request)")
            return
        }

        guard let returnedDictionary = (try? JSONSerialization.jsonObject(with: returnedData, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? NSDictionary else {
            XCTFail("Response was not a dictionary: \(returnString)\nFor request: \(request)")
            return
        }

        XCTAssertEqual(returnedDictionary, expectedResponse)
    }
}
