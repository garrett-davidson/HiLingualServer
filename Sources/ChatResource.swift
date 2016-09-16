import PerfectLib
import PerfectHTTP

func handleChat(request: HTTPRequest, _ response: HTTPResponse) {
	//parse uri and call relevant funtion
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>no</title><body>Chat resource</body></html>")
	print(request.urlVariables[routeTrailingWildcardKey])
    sendMessageWith(request: request, response)
	response.completed()
}

func sendMessageWith(request: HTTPRequest, _ response: HTTPResponse) {
    guard let auth = request.param(name: "auth") else {
        return
    }

    guard let recipient = request.param(name: "recipient") else {
        return
    }

    guard let message = request.param(name: "message") else {
        return
    }
    print("auth=\(auth)")
    print("recipient=\(recipient)")
    print("message=\(message)")
}
