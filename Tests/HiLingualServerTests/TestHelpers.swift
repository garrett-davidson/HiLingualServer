import XCTest
import PerfectNet
import PerfectLib
import PerfectHTTP

// Based on from PerfectHTTPRequests.swift
class ShimHTTPRequest: HTTPRequest {
    var method = HTTPMethod.get
    var path = "/"
    var queryParams = [(String, String)]()
    var protocolVersion = (1, 1)
    var remoteAddress = (host: "127.0.0.1", port: 8000 as UInt16)
    var serverAddress = (host: "127.0.0.1", port: 8282 as UInt16)
    var serverName = "my_server"
    var documentRoot = "./webroot"
    var connection = NetTCP()
    var urlVariables = [String:String]()
    var scratchPad = [String:Any]()
    func header(_ named: HTTPRequestHeader.Name) -> String? { return nil }
    func addHeader(_ named: HTTPRequestHeader.Name, value: String) {}
    func setHeader(_ named: HTTPRequestHeader.Name, value: String) {}
    var headers = AnyIterator<(HTTPRequestHeader.Name, String)> { return nil }
    var postParams = [(String, String)]()
    var postBodyBytes: [UInt8]? = nil
    var postBodyString: String? = nil
    var postFileUploads: [MimeReader.BodySpec]? = nil
}

class ShimHTTPResponse: HTTPResponse {
    public var body: [String: Any]?
    var request: HTTPRequest = ShimHTTPRequest()
    var status: HTTPResponseStatus = .ok
    var isStreaming = false
    var bodyBytes = [UInt8]()
    func header(_ named: HTTPResponseHeader.Name) -> String? { return nil }
    func addHeader(_ named: HTTPResponseHeader.Name, value: String) {}
    func setHeader(_ named: HTTPResponseHeader.Name, value: String) {}
    var headers = AnyIterator<(HTTPResponseHeader.Name, String)> { return nil }
    func addCookie(_: PerfectHTTP.HTTPCookie) {}
    func appendBody(bytes: [UInt8]) {}
    func appendBody(string: String) {}
    func setBody(json: [String:Any]) throws {
        body = json
    }

    func push(callback: @escaping (Bool) -> ()) {}
    func completed() {}
}
