import Foundation

enum HandType {
    case left
    case right
}

class Note : Hashable {
    var num:Int
    var hand:HandType
    static let MIDDLE_C = 40
    static let noteNames:[Character] = ["A", "B", "C", "D", "E", "F", "G"]

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
    
    static func noteName(idx:Int) -> Character {
        if idx >= 0 {
            return self.noteNames[idx % noteNames.count]
        }
        else {
            return self.noteNames[noteNames.count - (abs(idx) % noteNames.count)]
        }
    }

    static func getAllOctaves(staff:Staff, note:Int) -> [Int] {
        var notes:[Int] = []
        for n in staff.lowestNoteValue...staff.highestNoteValue {
            if note >= n {
                if (note - n) % 12 == 0 {
                    notes.append(n)
                }
            }
            else {
                if (n - note) % 12 == 0 {
                    notes.append(n)
                }
            }
        }
        return notes
    }
}
