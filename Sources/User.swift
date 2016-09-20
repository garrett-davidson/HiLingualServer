class User {
	private var userId: Int
	private var name: String
	private var displayName: String
	private var bio: String
	private var gender: Gender
	private var birthdate: Int
	private var authorityAccountId: Int
	private var sessionToken: Int

	init() {
		self.userId = 0
		self.name = "newName"
		self.displayName = "newDisplayName"
		self.bio = "newBio"
		self.gender = Gender.NOTSET
		self.birthdate = 0
		self.authorityAccountId = 0
		self.sessionToken = 0
	}
	init(newUserId: Int, newName: String, newDisplayName: String, newBio: String, newGender: Gender, newBirthdate: Int, authorityAccountId: Int, sessionToken: Int) {
		self.userId = newUserId
		self.name = newName
		self.displayName = newDisplayName
		self.bio = newBio
		self.gender = newGender
		self.birthdate = newBirthdate
		self.authorityAccountId = authorityAccountId
		self.sessionToken = sessionToken
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
	func getAuthorityAccountId() -> Int {
		return self.authorityAccountId
	}
	func getSessionToken() -> Int {
		return self.sessionToken
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
}
