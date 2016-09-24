import XCTest
import PerfectHTTP
@testable import HiLingualServer

class AuthResourceTests: XCTestCase {
    let invalidAuthCode = 401
    let invalidRequestCode = 400
    let validErrorCode = 200
    let validAuthToken = "EAAOcGlfuCWEBABdmliDTLxZA6rylW2DBRcgjWmaOSnmnbsBl4jShscJSf8oRsgHBqhlNRnEWaMRxYPxKKJiY1nH3xgwIpG5TFxXrW3QZCDf14STNJRAkNjT6rVpNAzJkjQa5jiCbBUZBx0GuNaZBO3BeZCkqyYoWl2KAZBIfwKxZC0YxMS85Pwk"
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

    func testHandleAuth() {
        let request = ShimHTTPRequest()
        let response = ShimHTTPResponse()

       //Login Request
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "1")

         var   postBodyString = "{ \"authority\": \"FACEBOOK\",\"authorityAccountId\": \"1\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/login"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "2")

        postBodyString = "{ \"authorityAccountId\": \"1\",\"authorityToken\": \"1234567890\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/login"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "3")


          postBodyString = "{ \"authority\": \"BAD\",\"authorityAccountId\": \"1\",\"authorityToken\": \"1234567890\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/login"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidAuthCode, failureString: "4")

        postBodyString = "{ \"authority\": \"FACEBOOK\",\"authorityToken\": \"12123123\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/login"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "5")


            postBodyString = "{ \"authority\": \"FACEBOOK\",\"authorityAccountId\": \"1123123\",\"authorityToken\": \"1234567890\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/login"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidAuthCode, failureString: "6")


        postBodyString = "{ \"authority\": \"FACEBOOK\",\"authorityAccountId\": \"\(validUserId)\",\"authorityToken\": \(validAuthToken)\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/login"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: validErrorCode, failureString: "7")


            postBodyString = "{ \"authority\": \"😗\",\"authorityAccountId\": \"😗\",\"authorityToken\": \"😗\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/login"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "8")


        postBodyString = "{ \"authority\": \"\",\"authorityAccountId\": \"\",\"authorityToken\": \"\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/login"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "9")








//Register user
        postBodyString = "{ \"authority\": \"FACEBOOK\",\"authorityAccountId\": \"1\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/register"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "10")


        postBodyString = "{ \"authorityAccountId\": \"1\",\"authorityToken\": \"1234567890\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/register"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "11")


            postBodyString = "{ \"authority\": \"BAD\",\"authorityAccountId\": \"1\",\"authorityToken\": \"1234567890\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/register"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidAuthCode, failureString: "12")

        postBodyString = "{ \"authority\": \"FACEBOOK\",\"authorityToken\": \"12123123\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/register"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "13")


            postBodyString = "{ \"authority\": \"FACEBOOK\",\"authorityAccountId\": \"1123123\",\"authorityToken\": \"1234567890\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/register"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidAuthCode, failureString: "14")


        postBodyString = "{ \"authority\": \"FACEBOOK\",\"authorityAccountId\": \"\(validUserId)\",\"authorityToken\": \(validAuthToken)\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/register"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: validErrorCode, failureString: "15")


            postBodyString = "{ \"authority\": \"😗\",\"authorityAccountId\": \"😗\",\"authorityToken\": \"😗\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/register"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "16")


        postBodyString = "{ \"authority\": \"\",\"authorityAccountId\": \"\",\"authorityToken\": \"\"}"
        request.postBodyString = postBodyString
        request.urlVariables[routeTrailingWildcardKey] = "/register"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "17")


        request.postParams = [("auth", "123123123")]
        request.urlVariables[routeTrailingWildcardKey] = "/logout"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "19")

        request.postParams = [("auth", "")]
        request.urlVariables[routeTrailingWildcardKey] = "/logout"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "20")

        request.postParams = [("auth", "😗")]
        request.urlVariables[routeTrailingWildcardKey] = "/logout"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "21")

        request.postParams = [("auth", "134234234234234298189512410481098309`830918249018490181284812094180248")]
        request.urlVariables[routeTrailingWildcardKey] = "/logout"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: invalidRequestCode, failureString: "22")

        request.postParams = [("auth", validAuthToken)]
        request.urlVariables[routeTrailingWildcardKey] = "/logout"
        sendTestAuthWith(request: request, response: response, expectedResponseCode: validErrorCode, failureString: "23")


        // Too long message

    }


    func sendTestAuthWith(request: ShimHTTPRequest, response: ShimHTTPResponse, expectedResponseCode: Int, failureString: String) {
        handleAuth(request: request, response)
        let code = response.status.code
        print("Recieved code: \(code) expecting \(expectedResponseCode)")
        XCTAssert(code == expectedResponseCode, failureString)
    }
}
