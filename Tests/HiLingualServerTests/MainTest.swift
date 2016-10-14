import XCTest
@testable import HiLingualServer

class MainTests: XCTestCase {

    override func setUp() {
        DispatchQueue.global().async {
            runServer()
        }

        sleep(1)
    }
    func testSendingMessage() {

        var request = URLRequest(url: URL(string: "http://127.0.0.1:8180/chat/")!)
        var requestParameters = ["":""]
        let validToken = "fdsafdsa"

        request.httpMethod = "POST"

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestParameters, options: .init(rawValue: 0))
        request.allHTTPHeaderFields = ["Authorization": validToken]

        var expectedResponse: NSDictionary = ["":""]

        sendTest(request: request, withExpectedResponse: expectedResponse)
    }

    func testRegister() {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:8180/auth/register")!)
        let invalidAuthCode = 401
        let invalidRequestCode = 400
        let validErrorCode = 200
        let validAuthToken = "EAAOcGlfuCWEBAAAFBYCPHj25mTYVxCAaiT0ClFAXyqnOWjyIOXvkKjkhEHPHNGTGfDYnFV3Gj3eNaLC6ZBydLwO1FtTrGgHfqWloIsfEnZCLya2yMWKAovZBQ61YCorwEshnDqnidYGF1Qzuhn9qGpkZA0Q9F26h3yPozO3oTVNB8eGYdqkI"
        let validUserId = "148313008891070"

        var postBodyString: [String: Any] = [ "authority": "FACEBOOK", "authorityAccountId": 1]
        request.httpBody  = try? JSONSerialization.data(withJSONObject: postBodyString, options: .init(rawValue: 0))
        sendTestResponse(request: request, withExpectedResponse: nil, expectedResponseCode: invalidRequestCode)


        postBodyString = [ "authorityAccountId": 1, "authorityToken": 1234567890]
        request.httpBody  = try? JSONSerialization.data(withJSONObject: postBodyString, options: .init(rawValue: 0))
        sendTestResponse(request: request, withExpectedResponse: nil, expectedResponseCode: invalidRequestCode)


        postBodyString = [ "authority": "BAD", "authorityAccountId": 1, "authorityToken": 1234567890]
        request.httpBody  = try? JSONSerialization.data(withJSONObject: postBodyString, options: .init(rawValue: 0))
        sendTestResponse(request: request, withExpectedResponse: nil, expectedResponseCode: invalidAuthCode)

        postBodyString = [ "authority": "FACEBOOK", "authorityToken": 12123123]
        request.httpBody  = try? JSONSerialization.data(withJSONObject: postBodyString, options: .init(rawValue: 0))
        sendTestResponse(request: request, withExpectedResponse: nil, expectedResponseCode: invalidRequestCode)


        postBodyString = [ "authority": "FACEBOOK", "authorityAccountId": 1123123, "authorityToken": 1234567890]
        request.httpBody  = try? JSONSerialization.data(withJSONObject: postBodyString, options: .init(rawValue: 0))
        sendTestResponse(request: request, withExpectedResponse: nil, expectedResponseCode: invalidAuthCode)


        postBodyString = [ "authority": "FACEBOOK", "authorityAccountId": validUserId, "authorityToken": validAuthToken]
        request.httpBody  = try? JSONSerialization.data(withJSONObject: postBodyString, options: .init(rawValue: 0))
        sendTestResponse(request: request, withExpectedResponse: nil, expectedResponseCode: validErrorCode)


        postBodyString = [ "authority": "😗", "authorityAccountId": "😗", "authorityToken": "😗"]
        request.httpBody  = try? JSONSerialization.data(withJSONObject: postBodyString, options: .init(rawValue: 0))
        sendTestResponse(request: request, withExpectedResponse: nil, expectedResponseCode: invalidRequestCode)


        postBodyString = [ "authority": "", "authorityAccountId": "", "authorityToken": ""]
        request.httpBody  = try? JSONSerialization.data(withJSONObject: postBodyString, options: .init(rawValue: 0))
        sendTestResponse(request: request, withExpectedResponse: nil, expectedResponseCode: invalidRequestCode)




    }

    func sendTest(request: URLRequest, withExpectedResponse expectedResponse: NSDictionary) {
        sendTestResponse(request: request, withExpectedResponse: expectedResponse, expectedResponseCode: nil)
    }


    func sendTestResponse(request: URLRequest, withExpectedResponse expectedResponse: NSDictionary?, expectedResponseCode: Int?) {
        var resp: URLResponse?

        guard let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returning: &resp) else {
            XCTFail("Request did not return data: \(request)")
            return
        }

        guard let returnString = NSString(data: returnedData, encoding: String.Encoding.utf8.rawValue) else {
            XCTFail("Request did not return a string: \(request)")
            return
        }
        if expectedResponseCode != nil {
            guard let returnedDictionary = (try? JSONSerialization.jsonObject(with: returnedData, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? NSDictionary else {
                XCTFail("Response was not a dictionary: \(returnString)\nFor request: \(request)")
                return
            }
            XCTAssertEqual(returnedDictionary, expectedResponse)
        } else {
            guard let response = resp as? HTTPURLResponse else {
                XCTFail("Response was nil, \(request)")
                return
            }
            XCTAssert(response.statusCode == expectedResponseCode, "Recieved code: \(response.statusCode) expecting \(expectedResponseCode)")
        }
    }
}
