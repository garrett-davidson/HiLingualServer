import XCTest
import PerfectHTTP
@testable import HiLingualServer

class UserResourceTest: XCTestCase {
    let invalidAuthCode = 401
    let invalidRequestCode = 400
    let validErrorCode = 200
    let validAuthToken = "EAAOcGlfuCWEBAAAFBYCPHj25mTYVxCAaiT0ClFAXyqnOWjyIOXvkKjkhEHPHNGTGfDYnFV3Gj3eNaLC6ZBydLwO1FtTrGgHfqWloIsfEnZCLya2yMWKAovZBQ61YCorwEshnDqnidYGF1Qzuhn9qGpkZA0Q9F26h3yPozO3oTVNB8eGYdqkI"
    let validUserId = "148313008891070"


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
    func testHandleUserUpdate() {
        let request = ShimHTTPRequest()
        let response = ShimHTTPResponse()

       //Login Request
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "1")

        var postBodyString = "{ \"userId\": \(validUserId)\",\"name\": \"testuser\",\"displayName\": \"testuserDisplay\",\"bio\": \"somebullshitbio\",\"gender\": \"Male\",\"birthdate\": \"23482\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: validErrorCode, failureString: "2")

        postBodyString = "{ \"name\": \"testuser\",\"displayName\": \"testuserDisplay\",\"bio\": \"somebullshitbio\",\"gender\": \"Male\",\"birthdate\": \"23482\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "3")

         postBodyString = "{ \"userId\": \(validUserId)\",\"displayName\": \"testuserDisplay\",\"bio\": \"somebullshitbio\",\"gender\": \"Male\",\"birthdate\": \"23482\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "4")


         postBodyString = "{ \"userId\": \(validUserId)\",\"name\": \"testuser\",\"bio\": \"somebullshitbio\",\"gender\": \"Male\",\"birthdate\": \"23482\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "5")


         postBodyString = "{ \"userId\": \(validUserId)\",\"name\": \"testuser\",\"displayName\": \"testuserDisplay\",\"gender\": \"Male\",\"birthdate\": \"23482\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "6")

         postBodyString = "{ \"userId\": \(validUserId)\",\"name\": \"testuser\",\"displayName\": \"testuserDisplay\",\"bio\": \"somebullshitbio\",\"birthdate\": \"23482\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "7")

         postBodyString = "{ \"userId\": \(validUserId)\",\"name\": \"testuser\",\"displayName\": \"testuserDisplay\",\"bio\": \"somebullshitbio\",\"gender\": \"Male\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "8")

         postBodyString = "{ \"userId\": \"baduserid\",\"name\": \"testuser\",\"displayName\": \"testuserDisplay\",\"bio\": \"somebullshitbio\",\"gender\": \"Male\",\"birthdate\": \"23482\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: validErrorCode, failureString: "9")

         postBodyString = "{ \"userId\": \"0000000\",\"name\": \"testuser\",\"displayName\": \"testuserDisplay\",\"bio\": \"somebullshitbio\",\"gender\": \"Male\",\"birthdate\": \"23482\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: validErrorCode, failureString: "10")

         postBodyString = "{ \"userId\": \"\",\"name\": \"\",\"displayName\": \"\",\"bio\": \"\",\"gender\": \"\",\"birthdate\": \"\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: validErrorCode, failureString: "11")

         postBodyString = "{ \"userId\": \"😗\",\"name\": \"😗\",\"displayName\": \"😗\",\"bio\": \"😗\",\"gender\": \"😗\",\"birthdate\": \"😗\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: validErrorCode, failureString: "12")

         postBodyString = "{ \"userId\": \"baduserid\",\"name\": \"testuser\",\"displayName\": \"testuserDisplay\",\"bio\": \"somebullshitbio\",\"gender\": \"wefw\",\"birthdate\": \"wefw\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/update"
        sendTestUserUpdateWith(request: request, response: response, expectedResponseCode: validErrorCode, failureString: "13")

    }


    func sendTestUserUpdateWith(request: ShimHTTPRequest, response: ShimHTTPResponse, expectedResponseCode: Int, failureString: String) {
        handleUserUpdate(request: request, response)
        let code = response.status.code
        print("Recieved code: \(code) expecting \(expectedResponseCode)")
        XCTAssert(code == expectedResponseCode, failureString)
    }


}














