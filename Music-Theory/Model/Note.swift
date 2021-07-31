import Foundation

enum HandType {
    case left
    case right
}

class Note : Hashable {
    var num:Int
    var hand:HandType
    static let MIDDLE_C = 40

    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.num == rhs.num
    }
    
    init(num:Int, hand:HandType) {
        self.num = num
        self.hand = hand
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(num)
    }
 
}
