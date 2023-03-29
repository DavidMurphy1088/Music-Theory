class Key : Equatable, Hashable {
    static var currentKey = Key(type: Key.KeyType.major, keySig: KeySignature(type: AccidentalType.sharp, count: 2))

    var keySig: KeySignature
    var type: KeyType
    //var isSelected: Bool = false //TODO Remove this - should be in UI in SetKeyView
    
    enum KeyType {
        case major
        case minor
    }
    
    static func allKeys(keyType:KeyType) -> [Key] {
        var list:[Key] = []
        for k in 0..<5 {
            list.append(Key(type: keyType, keySig: KeySignature(type: AccidentalType.sharp, count: k)))
            if k>0 {
                list.append(Key(type: keyType, keySig: KeySignature(type: AccidentalType.flat, count: k)))
            }
        }
        return list
    }
    
    static func == (lhs: Key, rhs: Key) -> Bool {
        return (lhs.type == rhs.type) && (lhs.keySig.accidentalCount == rhs.keySig.accidentalCount) &&
        (lhs.keySig.accidentalType == rhs.keySig.accidentalType)
    }
    
    init(type: KeyType, keySig:KeySignature) {
        self.keySig = keySig
        self.type = type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(keySig.accidentalCount)
    }
    
    func description() -> String {
        var desc = ""
        if keySig.accidentalType == AccidentalType.sharp {
            switch self.keySig.accidentalCount {
            case 0:
                desc = self.type == KeyType.major ? "C" : "A"
            case 1:
                desc = self.type == KeyType.major ? "G" : "E"
            case 2:
                desc = self.type == KeyType.major ? "D" : "B"
            case 3:
                desc = self.type == KeyType.major ? "A" : "F#"
            case 4:
                desc = self.type == KeyType.major ? "E" : "C#"
            default:
                desc = "unknown"
            }
        }
        else {
            switch self.keySig.accidentalCount {
            case 0:
                desc = self.type == KeyType.major ? "C" : "A"
            case 1:
                desc = self.type == KeyType.major ? "F" : "D"
            case 2:
                desc = self.type == KeyType.major ? "B"+Score.accFlat : "G"
            case 3:
                desc = self.type == KeyType.major ? "E"+Score.accFlat : "C"
            case 4:
                desc = self.type == KeyType.major ? "A"+Score.accFlat : "F"
            case 5:
                desc = self.type == KeyType.major ? "D"+Score.accFlat : "B"+Score.accFlat
            case 6:
                desc = self.type == KeyType.major ? "G"+Score.accFlat : "E"+Score.accFlat
            default:
                desc = "unknown"
            }

        }
        switch self.type {
        case KeyType.major:
            desc += " Major"
        case KeyType.minor:
            desc += " Minor"

        }
        return desc
    }
    
    func firstScaleNote() -> Int {
        var note = 40
        if keySig.accidentalCount > 0 {
            if self.keySig.accidentalType == AccidentalType.sharp {
                note = keySig.sharps[keySig.accidentalCount-1] + 2
            }
            else {
                note = keySig.flats[keySig.accidentalCount-1] - 6
            }
        }
        if self.type == KeyType.minor {
            note -= 3
        }
        note = Note.getClosestOctave(note: note, toPitch: 45)!
        return note
    }
}
