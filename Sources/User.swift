class User {
    private var userId: Int
    private var name: String
    private var displayName: String
    private var bio: String
    private var gender: Gender
    private var birthdate: Int
    private var authorityAccountId: String
    private var sessionToken: String
    private var nativeLanguages: Array<String>
    private var learningLanguages: Array<String>
    

    init() {
	self.userId = 0
	self.name = "newName"
	self.displayName = "newDisplayName"
	self.bio = "newBio"
	self.gender = Gender.NOTSET
	self.birthdate = 0
	self.authorityAccountId = "newAccountId"
	self.sessionToken = "newSessionToken"
    self.nativeLanguages = []
    self.learningLanguages = []
    }

    init(newUserId: Int, newName: String, newDisplayName: String, newBio: String, newGender: Gender, newBirthdate: Int, authorityAccountId: String = "newAccountId", sessionToken: String = "newSessionToken",nativeLanguages: Array<String> = [], learningLanguages: Array<String> = []) {
	self.userId = newUserId
	self.name = newName
	self.displayName = newDisplayName
	self.bio = newBio
	self.gender = newGender
	self.birthdate = newBirthdate
	self.authorityAccountId = authorityAccountId
	self.sessionToken = sessionToken
    self.nativeLanguages = nativeLanguages
    self.learningLanguages = learningLanguages
    }

    func getUserId() -> Int {
	return self.userId
    }

    func getName() -> String {
	return self.name
    }

    func getDisplayName() -> String {
	return self.displayName
    }

    func getBio() -> String {
	return self.bio
    }

    func getGender() -> Gender {
	return self.gender
    }

    func getBirthdate() -> Int {
	return self.birthdate
    }

    func getAuthorityAccountId() -> String {
	return self.authorityAccountId
    }

    func getSessionToken() -> String {
	return self.sessionToken
    }

    func getNativeLanguages() -> Array<String> {
    return self.nativeLanguages
    }

    func getLearningLanguages() -> Array<String> {
    return self.learningLanguages
    }

    func setUserId(newUserId: Int) {
	if self.userId == 0 {
	    self.userId = newUserId
	} else {
            print("Error: User id already set")
        }
    }

    func setName(newName: String) {
	self.name = newName
    }

    func setDisplayName(newDisplayName: String) {
	self.displayName = newDisplayName
    }

    func setBio(newBio: String) {
	self.bio = newBio
    }

    func setSessionToken(newSessionToken: String) {
	self.sessionToken = newSessionToken
    }

    func setGender(newGender: Gender) {
	self.gender = newGender
    }

    func setBirthdate(newBirthdate: Int) {
	self.birthdate = newBirthdate
    }

    func setAuthorityAccountId(newAuthorityAccountId: String) {
	self.authorityAccountId = newAuthorityAccountId
    }

    func setNativeLanguages(newNativeLanguages: Array<String>) {
    self.nativeLanguages = newNativeLanguages
    }

    func setLearningLanguages(newLearningLanguages: Array<String>) {
    self.learningLanguages = newLearningLanguages
    }

}
