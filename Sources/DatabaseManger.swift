import MySQL
import Foundation
let testHost = "127.0.0.1"
let testUser = "test"

let testPassword = "password"
let testSchema = "HiLingualDB"

let createMessagesTableQuery = "CREATE TABLE IF NOT EXISTS hl_chat_messages(" +
    "message_id BIGINT UNIQUE PRIMARY KEY AUTO_INCREMENT, " +
    "sent_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
    "edit_timestamp DATETIME, " +
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

func setupMysql() {
    guard dataMysql.connect(host: testHost, user: testUser, password: testPassword ) else {
        print("Failure connecting to data server \(testHost)")
        return
    }

    if !dataMysql.selectDatabase(named: testSchema) {

        guard dataMysql.query(statement: "CREATE DATABASE \(testSchema) ") else {
            print("Error creating db")
            return
        }

        guard dataMysql.query(statement: "USE \(testSchema) ") else {
            print("Error creating table1")
            return
        }

        guard dataMysql.query(statement: "\(createUsersTableQuery)") else {
            print("Error creating user table")
            return
        }

        guard dataMysql.query(statement: "\(createMessagesTableQuery)") else {
            print("Error creating message table")
            return
        }

        guard dataMysql.query(statement: "\(createFacebookTableQuery)") else {
            print("Error creating facebook auth table")
            return
        }

        guard dataMysql.query(statement: "\(createGoogleTableQuery)") else {
            print("Error creating google auth table")
            return
        }
    }
}
func addChatToTable(auth: String, recipient: Int, message: String) {
    guard dataMysql.query(statement: "INSERT INTO hl_chat_messages VALUE (NULL,NULL,NULL,1,\(recipient),\"\(message)\",NULL,NULL);") else {
        print("Error inserting into hl_chat_messages")
        return
    }

}
