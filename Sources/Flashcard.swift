class Flashcard {
    private var front: String
    private var back: String
    var description: String { get { return "{\"front\": \"\(self.front)\", \"back\": \"\(self.back)\"}"} }

    init() {
        self.front = ""
        self.back = ""
    }

    init(newFront: String, newBack: String) {
        self.front = newFront
        self.back = newBack
    }

    func getFront() -> String {
        return self.front
    }

    func getBack() -> String {
        return self.back
    }

    func setFront(newFront: String) {
        self.front = newFront
    }

    func setBack(newBack: String) {
        self.back = newBack
    }

}
