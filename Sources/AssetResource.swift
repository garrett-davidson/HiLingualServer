import PerfectLib
import PerfectHTTP

func handleAsset(request: HTTPRequest, _ response: HTTPResponse) {

	//parse uri and call relevant funtion
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>no</title><body>Asset endpoint</body></html>")
	print(request.urlVariables[routeTrailingWildcardKey])
	response.completed()
}
