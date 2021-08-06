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
    
    static func isSameNote(note1:Int, note2:Int) -> Bool {
        return (note1 % 12) == (note2 % 12)
    }
    
    init(num:Int, hand:HandType) {
        self.num = num
        self.hand = hand
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(num)
    }
 
}
