//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//      Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import MySQL
import PerfectHTTPServer

// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
var routes = Routes()


routes.add(method: .get, uri: "/user/**", handler: handleUser)
routes.add(method: .get, uri: "/auth/**", handler: handleAuth)
routes.add(method: .get, uri: "/asset/**", handler: handleAsset)
routes.add(method: .get, uri: "/chat/**", handler: handleChat)

// Add the routes to the server.
server.addRoutes(routes)

// Set a listen port of 8180
server.serverPort = 8180

setupMysql()

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)
do {
        // Launch the HTTP server.
        try server.start()
} catch PerfectError.networkError(let err, let msg) {
        print("Network error thrown: \(err) \(msg)")
}
