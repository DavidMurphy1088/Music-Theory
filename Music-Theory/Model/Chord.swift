class Chord : Identifiable {
    var notes:[Int] = []
    
    enum ChordType {
        case major
        case minor
        case diminished
    }
    
    init() {
    }
    
    func makeTriad(root: Int, type:ChordType) {
        notes.append(root)
        if type == ChordType.major {
            notes.append(root+4)
        }
        else {
            notes.append(root+3)
        }
        if type == ChordType.diminished {
            notes.append(root+6)
        }
        else {
            notes.append(root+7)
        }
    }
}
