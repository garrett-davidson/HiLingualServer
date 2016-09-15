import PerfectLib
import PerfectHTTP

func handleChat(request: HTTPRequest, _ response: HTTPResponse) {

	//parse uri and call relevant funtion
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>no</title><body>Chat resource</body></html>")
	print(request.urlVariables[routeTrailingWildcardKey])
	response.completed()
}


