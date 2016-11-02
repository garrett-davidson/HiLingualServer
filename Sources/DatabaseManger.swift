import MySQL
import Foundation

let testHost = "127.0.0.1"
let testUser = "test"

let testPassword = "password"
let messagesTable = "hl_chat_messages"
let usersTable = "hl_users"
let facebookTable = "hl_facebook_data"
let googleTable = "hl_google_data"
let flashcardTable = "hl_flashcards"

let createMessagesTableQuery = "CREATE TABLE IF NOT EXISTS \(messagesTable)(" +
  "message_id BIGINT UNIQUE PRIMARY KEY AUTO_INCREMENT, " +
  "sent_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
  "edit_timestamp DATETIME, " +
  "sender_id BIGINT, " +
  "receiver_id BIGINT, " +
  "message TEXT, " +
  "edited_message TEXT, " +
  "picture TEXT, " +
  "audio TEXT);"
let createUsersTableQuery = "CREATE TABLE IF NOT EXISTS \(usersTable)(" +
  "user_id BIGINT UNIQUE PRIMARY KEY AUTO_INCREMENT, " +
  "name TINYTEXT, " +
  "displayName TINYTEXT, " +
  "bio LONGTEXT, " +
  "gender TINYTEXT, " +
  "birthdate BIGINT, " +
  "session_token LONGTEXT, " +
  "native_language LONGTEXT, " +
  "learning_language LONGTEXT, " +
  "apns_token LONGTEXT, " +
  "authority_account_id LONGTEXT);"

let createFlashcardTableQuery = "CREATE TABLE IF NOT EXISTS \(flashcardTable)(" +
    "user_id BIGINT, " +
    "setId TINYTEXT, " +
    "front TINYTEXT, " +
"back TINYTEXT);"
let createFacebookTableQuery = "CREATE TABLE IF NOT EXISTS \(facebookTable)(" +
  "user_id BIGINT UNIQUE PRIMARY KEY, " +
  "account_id VARCHAR(255), " +
  "token TEXT);"

let createGoogleTableQuery = "CREATE TABLE IF NOT EXISTS \(googleTable)a(" +
  "user_id BIGINT UNIQUE PRIMARY KEY, " +
  "account_id VARCHAR(255), " +
  "token TEXT);"

let dataMysql = MySQL()

func closeDatabase() {
    dataMysql.close()
}

func connectToMySql() -> Bool {
    print("Connecting to mysql database...")
    guard dataMysql.connect(host: testHost, user: testUser, password: testPassword) else {
        print("Failure connecting to data server \(testHost)")
        return false
    }

    return true
}

func setupMysql(forSchema schema: String) {
    if !dataMysql.selectDatabase(named: schema) {
        print("Creating database \(schema)")
        guard dataMysql.query(statement: "CREATE DATABASE \(schema)") else {
            print("Error creating databse \(schema)")
            return
        }

        print("Using database \(schema)")
        guard dataMysql.query(statement: "USE \(schema) ") else {
            print("Error connecting to \(schema)")
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
        print("Creating table \(createFlashcardTableQuery)")
        guard dataMysql.query(statement: "\(createFlashcardTableQuery)") else {
            print("Error creating flashcardTable table")
            return
        }
    } else {
        print("Using database \(schema)")
        guard dataMysql.query(statement: "USE \(schema) ") else {
            print("Error connecting to \(schema)")
            return
        }
    }
}

func addMessageToTable(sender: Int, recipient: Int, message: String) {
    guard let encodedMessage = message.toBase64() else {
        print("Unable to encode message")
        return
    }
    guard dataMysql.query(statement: "INSERT INTO hl_chat_messages VALUE (NULL,NULL,NULL,\(sender),\(recipient),\"\(encodedMessage)\",NULL,NULL,NULL);") else {
        print("Error inserting into hl_chat_messages")
        return
    }
    print("added message to table")
}

func addAudioMessageToTable(sender: Int, recipient: Int, audio: String) {
    guard dataMysql.query(statement: "INSERT INTO hl_chat_messages VALUE (NULL,NULL,NULL,\(sender),\(recipient),NULL,NULL,NULL,\"\(audio)\");") else {
        print("Error inserting into hl_chat_messages with audio")
        return
    }
    print("added to audio message to table")

}
func addPictureMessageToTable(sender: Int, recipient: Int, picture: String) {
    guard dataMysql.query(statement: "INSERT INTO hl_chat_messages VALUE (NULL,NULL,NULL,\(sender),\(recipient),NULL,NULL,\"\(picture)\",NULL);") else {
        print("Error inserting into hl_chat_messages with audio")
        return
    }
    print("added to picture message to table")

}

func overwriteUserData(user: User) {
    var name: String
    var displayName: String
    var bio: String
    if let n  = user.getName().toBase64() {
        name = "\"\(n)\""
    } else {
        name = "NULL"
    }
    if let d = user.getDisplayName().toBase64() {
        displayName = "\"\(d)\""
    } else {
        displayName = "NULL"
    }
    if let b = user.getBio().toBase64() {
        bio = "\"\(b)\""
    } else {
        bio = "NULL"
    }
    let query = "UPDATE hl_users SET name = \(name), displayName = \(displayName), gender = \"\(user.getGender())\", birthdate = \(user.getBirthdate()), native_language = \"\(user.getNativeLanguage())\", learning_language = \"\(user.getLearningLanguage())\" WHERE user_id = \(user.getUserId());"
    print(query)
    guard dataMysql.query(statement: query) else {
        print("Error updating user")
        return
    }
    print("updated user to table")
}

func createUserWith(token: String, authorityAccountId: String) -> User? {
    // make sure no user has registered with authority_account_id
    guard dataMysql.query(statement: "SELECT COUNT(*) from hl_users WHERE authority_account_id = \"\(authorityAccountId)\";") else {
        print("databse error")
        return nil
    }
    guard let firstResults = dataMysql.storeResults() else {
        return nil
    }
    guard firstResults.numRows() == 1 else {
        print("no rows found")
        return nil
    }
    guard let row1 = firstResults.next() else {
        return nil
    }
    guard let column1 = row1.first else {
        return nil
    }
    guard let column2 = column1 else {
        return nil
    }
    guard let numpeople = Int(column2) else {
        return nil
    }
    guard numpeople < 1 else {
        print("user already exists")
        return nil
    }




    guard dataMysql.query(statement: "INSERT INTO hl_users (session_token, authority_account_id) VALUES(\"\(token)\", \"\(authorityAccountId)\");") else {
        print("Error inserting into hl_users")
        return nil
    }
    guard dataMysql.query(statement: "SELECT MAX(user_id) from hl_users;") else {
        print("Mysql error")
        return nil
    }
    guard let results = dataMysql.storeResults() else {
        print("no results")
        return nil
    }
    guard results.numRows() == 1 else {
        print("no rows found")
        return nil
    }

    guard let row = results.next() else {
        print("no next row")
        return nil
    }
    guard let col1 = row.first else {
        print("no first col")
        return nil
    }
    guard let col2 = col1 else {
        print("cant unpack first col")
        return nil
    }
    guard let newUserId = Int(col2) else {
        print("cant cast col to user id (int)")
        return nil
    }
    return getUser(userId: newUserId)
}

@discardableResult func logoutUserWith(userId: Int, sessionId: String) -> Bool {
    print("logging out")
    guard dataMysql.query(statement: "SELECT COUNT(*) from hl_users WHERE session_token = \"\(sessionId)\";") else {
        print("databse error")
        return false
    }
    guard let firstResults = dataMysql.storeResults() else {
        return false
    }
    guard firstResults.numRows() == 1 else {
        print("no rows found")
        return false
    }
    guard let row1 = firstResults.next() else {
        return false
    }
    guard let column1 = row1.first else {
        return false
    }
    guard let column2 = column1 else {
        return false
    }
    guard let numpeople = Int(column2) else {
        return false
    }
    guard numpeople == 1 else {
        print("session doesn't exist")
        return false
    }

    guard dataMysql.query(statement: "UPDATE hl_users SET session_token = \"\(sessionId)\" WHERE session_token = \"\(sessionId)\";") else {
        return false
    }
    return true
}

@discardableResult func loginUserWith(authAccountId: String, sessionId: String) -> User? {
    print("logging in user")
    guard dataMysql.query(statement: "SELECT * from hl_users WHERE authority_account_id = \"\(authAccountId)\";") else {
        print("Error in selecting user for logout")
        return nil
    }
    guard let results = dataMysql.storeResults() else {
        print("databse error")
        return nil
    }
    guard results.numRows() == 1 else {
        print("databse error")
        return nil
    }
    guard let row = results.next() else {
        print("databse error")
        return nil
    }
    guard let tempUser = convertRowToUserWith(row: row) else {
        print("convert user to row error")
        return nil
    }
    print(tempUser.getAuthorityAccountId())
    print(authAccountId)
    if tempUser.getAuthorityAccountId() == authAccountId {
        guard dataMysql.query(statement: "UPDATE hl_users SET session_token =\"\(sessionId)\" WHERE authority_account_id = \"\(authAccountId)\"") else {
            return nil
        }
        return tempUser
    } else {
        return nil
    }
}

func isValid(userId: Int) -> Bool {
    guard dataMysql.query(statement: "SELECT * from hl_users WHERE user_id = \(userId)") else {
        return false
    }

    dataMysql.storeResults()

    return true
}

func convertRowToFlashcard(row: [String?]) -> Flashcard? {
    guard row.count == 4 else {
        return nil
    }
    guard let front = row[2] else {
        return nil
    }
    guard let back = row[3] else {
        return nil
    }
    let newFlashcard = Flashcard()
    guard let newFront = front.fromBase64() else {
        print("Unable to encode message")
        return nil
    }
    guard let newBack = back.fromBase64() else {
        print("Unable to encode message")
        return nil
    }

    newFlashcard.setFront(newFront: newFront)
    newFlashcard.setBack(newBack: newBack)
    return newFlashcard


}

func convertRowToUserWith(row: [String?]) -> User? {
    let newUser = User()

    //userid
    if let a = row[0] {
        if let userId = Int(a) {
            newUser.setUserId(newUserId: userId)
        }
    }

    if let name = row[1]?.fromBase64() {
        newUser.setName(newName: name)
    }

    if let displayName = row[2]?.fromBase64() {
        newUser.setDisplayName(newDisplayName: displayName)
    }

    if let bio = row[3]?.fromBase64() {
        newUser.setBio(newBio: bio)
    }

    if let genderString = row[4] {
        if let gender = Gender(rawValue: genderString) {
            newUser.setGender(newGender: gender)
        } else {
            newUser.setGender(newGender: Gender.NOTSET)
        }
    }
    if let b = row[5] {
        if let birthdate = Int(b) {
            newUser.setBirthdate(newBirthdate: birthdate)
        }
    }

    if let sessionToken = row[6] {
        if verbose {
            print("sessiontoken: " + sessionToken)
        }
        newUser.setSessionToken(newSessionToken: sessionToken)
    }
    if let nativeLanguage = row[7] {
        newUser.setNativeLanguage(newNativeLanguage: nativeLanguage)
    }

    if let learningLanguage = row[8] {
        newUser.setLearningLanguage(newLearningLanguage: learningLanguage)
    }

    if let authAccountId = row[10] {
        newUser.setAuthorityAccountId(newAuthorityAccountId: authAccountId)
    }

    return newUser
}

func lookupUserWith(sessionToken: String) -> User? {
    guard dataMysql.query(statement: "SELECT * FROM hl_users WHERE session_token = \"\(sessionToken)\";") else {
        if verbose {
            print("User with given session token does not exist")
            print("Given session token: \(sessionToken)")
            print(dataMysql.errorCode())
            print(dataMysql.errorMessage())
        }
        return nil
    }
    guard let results = dataMysql.storeResults() else {
        if verbose {
            print("no results")
        }
        return nil
    }
    guard results.numRows() == 1 else {
        if verbose {
            print("results != 1")
        }
        return nil
    }
    guard let row = results.next() else {
        if verbose {
            print("results.next() doesn't exist")
        }
        return nil
    }
    guard let tempUser = convertRowToUserWith(row: row) else {
        if verbose {
            print("cannot convert to user")
        }
        return nil
    }

    return tempUser.getSessionToken() == sessionToken ? tempUser : nil
}

func getMatches(nativeLanguage: String, learningLanguage: String, userBirthdate: Int) -> [Int] {
    var listOfMatches = [User]()
    let learningArray = learningLanguage.components(separatedBy: ",")
    let nativeArray = nativeLanguage.components(separatedBy: ",")
    print(nativeLanguage)
    print(learningLanguage)
    print(nativeArray)
    print(learningArray)
    for learning in learningArray {
        for native in nativeArray {
            print(learning)
            print(native)
            guard dataMysql.query(statement: "SELECT * from hl_users WHERE native_language LIKE \"%\(learning)%\" AND learning_language LIKE \"%\(native)%\"") else {
                continue
            }
            guard let results = dataMysql.storeResults() else {
                continue
            }
            if results.numRows() >= 1 {
                while true {
                    guard let row = results.next() else {
                        break
                    }
                    guard let tempUser = convertRowToUserWith(row: row) else {
                        break
                    }
                    print("appending: " + learning + " " + native)
                    listOfMatches.append(tempUser)
                }
            } else {
                print("less than 1: " + learning + " " + native)
            }
        }
    }

    let sortedArray = listOfMatches.sorted {abs($0.getBirthdate() - userBirthdate) < abs($1.getBirthdate() - userBirthdate)}
    var finalArray = [Int]()
    for user in sortedArray {
        finalArray.append(user.getUserId())
    }
    return finalArray
}

func getFlashcards(userId: Int, setId: String) -> [Flashcard]? {
    var listOfFlashcards = [Flashcard]()
    guard let encodedSetId = setId.toBase64() else {
        print("Unable to encode message")
        return nil
    }
    guard dataMysql.query(statement: "SELECT * from hl_flashcards WHERE setId = \"\(encodedSetId)\"") else {
        if verbose {
            print("none1")
        }
        return nil
    }
    guard let results = dataMysql.storeResults() else {
        if verbose {
            print("none2")
        }
        return nil
    }
    while true {
        guard let row = results.next() else {
            break
        }
        guard let tempFlashcard = convertRowToFlashcard(row: row) else {
            break
        }
        listOfFlashcards.append(tempFlashcard)
    }
    return listOfFlashcards
}

func getUser(userId: Int) -> User? {
    guard dataMysql.query(statement: "SELECT * from hl_users WHERE user_id = \(userId)") else {
        print("databse error select user. getUser()")
        return nil
    }
    guard let results = dataMysql.storeResults() else {
        print("no results in getUser()")
        return nil
    }
    guard results.numRows() == 1 else {
        print("More than one user returned getUser()")
        return nil
    }
    guard let row = results.next() else {
        return nil
    }
    guard let tempUser = convertRowToUserWith(row: row) else {
        print("Error converting row to user getUser()")
        return nil
    }
    if tempUser.getUserId() == userId {
        return tempUser
    } else {
        return nil
    }
}

func getMessages(withSessionToken token: String, forUser receivingUserId: Int) -> [Message]? {

    guard let requestingUser = lookupUserWith(sessionToken: token) else {
        return nil
    }

    let requestingUserId = requestingUser.getUserId()

    // todo: Limit number of results
    guard dataMysql.query(statement: "SELECT * FROM hl_chat_messages WHERE (sender_id = \(requestingUserId) AND receiver_id = \(receivingUserId)) OR (sender_id = \(receivingUserId) AND receiver_id = \(requestingUserId));") else {
        return nil
    }

    var messages = [Message]()

    let results = dataMysql.storeResults()
    print(results)
    while let row = results?.next() {
        if let message = messageFrom(row: row) {
            messages.append(message)
        }
    }

    return messages
}

func checkFlashcards(setId: String, userId: Int) -> Bool {
    guard let encodedSetId = setId.toBase64() else {
        print("Unable to encode message")
        return false
    }
    guard dataMysql.query(statement: "SELECT * from hl_flashcards WHERE user_id = \(userId) AND setId = \"\(encodedSetId)\";" ) else {
        return false
    }
    guard let results = dataMysql.storeResults() else {
        print("dataMysql is nil")
        return false
    }
    return results.numRows() > 0

}

func editFlashcards(setId: String, userId: Int, flashcards: [Flashcard]) {
    guard let encodedSetId = setId.toBase64() else {
        print("Unable to encode message")
        return
    }
    guard dataMysql.query(statement: "DELETE FROM hl_flashcards WHERE user_id = \(userId) AND setId = \"\(encodedSetId)\";") else {
        print("Error editing into hl_flashcards")
        return
    }
    for flashcard in flashcards {
        guard let encodedFront = flashcard.getFront().toBase64() else {
            print("Unable to encode message")
            return
        }
        guard let encodedBack = flashcard.getBack().toBase64() else {
            print("Unable to encode message")
            return
        }
        guard dataMysql.query(statement: "INSERT INTO hl_flashcards VALUE (\(userId),\"\(encodedSetId)\", \"\(encodedFront)\",\"\(encodedBack)\");") else {
            print("Error inserting into hl_flashcards")
            return
        }
        if verbose {
            print("added flashcard to hl_flashcards to table")
        }
    }

}

func storeFlashcards(setId: String, userId: Int, flashcards: [Flashcard]) {
    guard let encodedSetId = setId.toBase64() else {
        print("Unable to encode message")
        return
    }
    for flashcard in flashcards {
        guard let encodedFront = flashcard.getFront().toBase64() else {
            print("Unable to encode message")
            return
        }
        guard let encodedBack = flashcard.getBack().toBase64() else {
            print("Unable to encode message")
            return
        }
        guard dataMysql.query(statement: "INSERT INTO hl_flashcards VALUE (\(userId),\"\(encodedSetId)\", \"\(encodedFront)\",\"\(encodedBack)\");") else {
            print("Error inserting into hl_flashcards")
            return
        }
        if verbose {
            print("added flashcard to hl_flashcards to table")
        }
    }
}

func messageFrom(row: [String?]) -> Message? {
    guard row.count >= 7 else {
        if verbose {
            print("Not enough columns for message")
        }

        return nil
    }

    guard let idString = row[0], let id = Int(idString) else {
        if verbose {
            print("Invalid message id")
        }

        return nil
    }

    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "GMT")!
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
    guard let sentTimestampString = row[1],
          let sentTimestamp = dateFormatter.date(from: sentTimestampString) else {
        if verbose {
            print("Invalid sent timestamp")
        }
        return nil
    }
    print(sentTimestamp)

    let editTimestamp: Date?

    if let editTimestampString = row[2], let editTimestampInterval = Double(editTimestampString) {
        editTimestamp = Date(timeIntervalSince1970: editTimestampInterval)
    } else {
        editTimestamp = nil
    }

    guard let senderIdString = row[3], let senderId = Int(senderIdString) else {
        if verbose {
            print("Invalid sender id")
        }
        return nil
    }

    guard let receiverIdString = row[4], let receiverId = Int(receiverIdString) else {
        if verbose {
            print("Invalid receiver id")
        }
        return nil
    }
    var message = row[5]?.fromBase64()
    if message == nil {
        message = row[7]
        if  message == nil {
            if verbose {
                print("No audio body")
            }
            message = row[8]
            if message == nil {
                if verbose {
                    print("No picture body")
                }
                return nil
            }
            let splitMessage = message!.characters.split {$0 == "/"}.map(String.init)
            message = "picture: " + splitMessage[splitMessage.count-1]
        } else {
            let splitMessage = message!.characters.split {$0 == "/"}.map(String.init)
            message = "audio: " + splitMessage[splitMessage.count-1]
        }
        if verbose {
            print("No message body")
        }
    }

    let editedMessage = row[6]?.fromBase64()

    return Message(messageId: id, sentTimestamp: sentTimestamp, editTimestamp: editTimestamp, sender: senderId, receiver: receiverId, body: message!, editedBody: editedMessage)
}

func apnsToken(forUser user: Int) -> String? {
    guard dataMysql.query(statement: "SELECT apns_token FROM hl_users WHERE user_id = \(user);") else {
        if verbose {
            print("Query failed")
        }
        return nil
    }

    guard let result = dataMysql.storeResults()?.next() else {
        if verbose {
            print("Unable to find apns token for user: \(user)")
        }
        return nil
    }

    return result.first ?? nil
}

extension String {
    func toBase64() -> String? {
        return data(using: String.Encoding.utf8)?.base64EncodedString()
    }

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
