//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
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

let testHost = "127.0.0.1"
let testUser = "test"
// PLEASE change to whatever your actual password is before running these tests
let testPassword = "password"
let testSchema = "HiLingualDB"
let createMessagesTableQuery = "CREATE TABLE IF NOT EXISTS hl_chat_messages(" +
                "message_id BIGINT UNIQUE PRIMARY KEY AUTO_INCREMENT, " +
                "sent_timestamp TIMESTAMP, " +
                "edit_timestamp TIMESTAMP, " +
                "sender_id BIGINT, " +
                "receiver_id BIGINT, " +
                "message VARCHAR(500), " +
                "edited_message VARCHAR(500), " +
                "audio VARCHAR(500));"
let createUsersTableQuery = "CREATE TABLE IF NOT EXISTS hl_users(" +
                "user_id BIGINT UNIQUE PRIMARY KEY AUTO_INCREMENT, " +
                "user_name TINYTEXT, " +
                "birth_date DATE, " +
                "known_languages LONGTEXT, " +
                "learning_languages LONGTEXT);"
let createFacebookTableQuery = "CREATE TABLE IF NOT EXISTS hl_facebook_data(" +
                "user_id BIGINT UNIQUE PRIMARY KEY, " +
                "account_id VARCHAR(255), " +
                "token TEXT);"

let createGoogleTableQuery = "CREATE TABLE IF NOT EXISTS hl_google_data(" +
                "user_id BIGINT UNIQUE PRIMARY KEY, " +
                "account_id VARCHAR(255), " +
                "token TEXT);"


let dataMysql = MySQL()

routes.add(method: .get, uri: "/user/**", handler: handleUser)
routes.add(method: .get, uri: "/auth/**", handler: handleAuth)
routes.add(method: .get, uri: "/asset/**", handler: handleAsset)
routes.add(method: .get, uri: "/chat/**", handler: handleChat)


// Add the routes to the server.
server.addRoutes(routes)

// Set a listen port of 8180
server.serverPort = 8180

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = "./webroot"

public func useMysql() {

    // need to make sure something is available.
    guard dataMysql.connect(host: testHost, user: testUser, password: testPassword ) else {
        Log.info(message: "Failure connecting to data server \(testHost)")
        return
    }

    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    if dataMysql.selectDatabase(named: testSchema) {

	} else {
		guard dataMysql.query(statement: "CREATE DATABASE \(testSchema) ") else {
			print("Error creating db")
			return
		}
    	guard dataMysql.query(statement: "USE \(testSchema) ") else {
    		print("Error creating table1")
			return
    	}
    	guard dataMysql.query(statement: "\(createUsersTableQuery)") else {
    		print("Error creating table2")
			return
    	}
    	guard dataMysql.query(statement: "\(createMessagesTableQuery)") else {
    		print("Error creating table3")
			return
    	}

		guard dataMysql.query(statement: "\(createFacebookTableQuery)") else {
			print("Error creating table")
			return
		}

		guard dataMysql.query(statement: "\(createGoogleTableQuery)") else {
			print("Error creating table")
			return
		}




	}



}
useMysql()

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
