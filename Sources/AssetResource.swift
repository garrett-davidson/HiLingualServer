import PerfectLib
import PerfectHTTP
import AppKit

func handleAsset(request: HTTPRequest, _ response: HTTPResponse) {

    defer {
        response.completed()
    }

    //parse uri and call relevant funtion
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>no</title><body>Asset endpoint</body></html>")
    print(request.urlVariables[routeTrailingWildcardKey])
    print(request.path)

    let components = request.path.components(separatedBy: "/")
    print(components)
    guard components.count == 4 else {
        assetError(request: request, response)
        return
    }

    let path: String

    switch components[2] {
    case "image":
        path = FileManager.default.currentDirectoryPath + "/Resources/Pictures/\(components[3])"
        response.addHeader(.contentType, value: "image/png")
    case "audio":
        path = FileManager.default.currentDirectoryPath + "/Resources/Audio/\(components[3])"
        response.addHeader(.contentType, value: "audio/mpeg")
    default:
        assetError(request: request, response)
        return
    }

    print("Retrieving asset from \(path)")

    let pathURL = URL(fileURLWithPath: path)

    guard let data = try? Data(contentsOf: pathURL) else {
        if verbose {
            print("Unable to read file")
        }

        assetError(request: request, response)
        return
    }

    response.bodyBytes = data.toArray()

}

func assetError(request: HTTPRequest, _ response: HTTPResponse) {
    print("Asset retrieval error")
}

extension Data {
    func toArray() -> [UInt8] {
        return self.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: self.count))
        }
    }
}
