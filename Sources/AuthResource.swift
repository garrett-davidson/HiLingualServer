import PerfectLib
import Foundation
import PerfectHTTP

func handleAuth(request: HTTPRequest, _ response: HTTPResponse) {
	//parse uri and call relevant funtion
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>no</title><body>Auth endpoint</body></html>")
	defer {
		response.completed()
	}
	guard var urlString = request.urlVariables[routeTrailingWildcardKey] else {
		return
	}
	urlString.remove(at: urlString.startIndex)
	print(urlString)
	if urlString == "login" {
		loginWith(request: request, response)
	} else if urlString == ""
	guard let auth = request.param(name: "auth") else {
		print("no auth parameter")
        return
    }
}
func loginWith(request: HTTPRequest, _ response: HTTPResponse){

}