import MySQL
import Foundation
let testHost = "127.0.0.1"
let testUser = "test"

let testPassword = "password"
let testSchema = "HiLingualDB"
let messagesTable = "hl_chat_messages"
let usersTable = "hl_users"
let facebookTable = "hl_facebook_data"
let googleTable = "hl_google_data"

let createMessagesTableQuery = "CREATE TABLE IF NOT EXISTS \(messagesTable)(" +
    "message_id BIGINT UNIQUE PRIMARY KEY AUTO_INCREMENT, " +
    "sent_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
    "edit_timestamp DATETIME, " +
    "sender_id BIGINT, " +
    "receiver_id BIGINT, " +
    "message VARCHAR(500), " +
    "edited_message VARCHAR(500), " +
"audio VARCHAR(500));"
let createUsersTableQuery = "CREATE TABLE IF NOT EXISTS \(usersTable)(" +
    "user_id BIGINT UNIQUE PRIMARY KEY AUTO_INCREMENT, " +
    "user_name TINYTEXT, " +
    "birth_date DATE, " +
    "known_languages LONGTEXT, " +
    "session_token LONGTEXT, " +
"learning_languages LONGTEXT);"
let createFacebookTableQuery = "CREATE TABLE IF NOT EXISTS \(facebookTable)(" +
    "user_id BIGINT UNIQUE PRIMARY KEY, " +
    "account_id VARCHAR(255), " +
"token TEXT);"

let createGoogleTableQuery = "CREATE TABLE IF NOT EXISTS \(googleTable)a(" +
    "user_id BIGINT UNIQUE PRIMARY KEY, " +
    "account_id VARCHAR(255), " +
"token TEXT);"

let dataMysql = MySQL()

func setupMysql() {
    print("Connecting to mysql database...")
    guard dataMysql.connect(host: testHost, user: testUser, password: testPassword )  else {
        print("Failure connecting to data server \(testHost)")
        return
    }


    if !dataMysql.selectDatabase(named: testSchema) {
        print("Creating database \(testSchema)")
        guard dataMysql.query(statement: "CREATE DATABASE \(testSchema)") else {
            print("Error creating databse \(testSchema)")
            return
        }

        print("Using database \(testSchema)")
        guard dataMysql.query(statement: "USE \(testSchema) ") else {
            print("Error connecting to \(testSchema)")
            return
        }
        print("Creating table \(createUsersTableQuery)")
        guard dataMysql.query(statement: "\(createUsersTableQuery)") else {
            print("Error creating table \(createUsersTableQuery)")
            return
        }
        print("Creating table \(createMessagesTableQuery)")
        guard dataMysql.query(statement: "\(createMessagesTableQuery)") else {
            print("Error creating table ")
            return
        }
        print("Creating table \(createFacebookTableQuery)")
        guard dataMysql.query(statement: "\(createFacebookTableQuery)") else {
            print("Error creating facebook auth table")
            return
        }
        print("Creating table \(createGoogleTableQuery)")
        guard dataMysql.query(statement: "\(createGoogleTableQuery)") else {
            print("Error creating google auth table")
            return
        }
    } else {
        print("Using database \(testSchema)")
        guard dataMysql.query(statement: "USE \(testSchema) ") else {
            print("Error connecting to \(testSchema)")
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
func addChatToTableAudio(auth: String, recipient: Int, audio: String) {
    guard dataMysql.query(statement: "INSERT INTO hl_chat_messages VALUE (NULL,NULL,NULL,1,\(recipient),NULL,NULL,\"\(audio)\");") else {
        print("Error inserting into hl_chat_messages")
        return
    }

}
func createUserWith(token: String) -> User? {
    let newUser = User()
    guard dataMysql.query(statement: "INSERT INTO hl_users (session_token) VALUES(\"\(token)\");") else {
        print("Error inserting into hl_users")
        return newUser
    }
    guard dataMysql.query(statement: "SELECT MAX(user_id) from hl_users;") else {
        print("Mysql error")
        return newUser
    }
    guard let results = dataMysql.storeResults() else {
        return nil
    }
    guard results.numRows() == 1 else {
        print("no rows found")
        return newUser
    }

    guard let row = results.next() else {
        return nil
    }
    guard let col1 = row.first else {
        return nil
    }
    guard let col2 = col1 else {
        return nil
    }
    guard let newUserId = Int(col2) else {
        return nil
    }
    newUser.setUserId(newId: newUserId)
    return newUser
}
func logoutUserWith(authAccountId: String, sessionId: String) {
    print("logging out")
}
func loginUserWith(authAccountId: String, sessionId: String) {
    print("logging out user")
}
