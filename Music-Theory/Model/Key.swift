class Key {
    var keySig: KeySignature
    var type: KeyType
    
    enum KeyType {
        case major
        case minorNatural
    }
    
    init(type: KeyType, keySig:KeySignature) {
        self.keySig = keySig
        self.type = type
    }
    
    func firstScaleNote() -> Int {
        var note = 40
//        if keySig.accidentalCount > 0 {
//            if self.type == KeySignatureType.sharps {
//                note = sharps[accidentalCount-1] + 2
//            }
//            else {
//                note = flats[accidentalCount-1] - 6
//            }
//            let all = Note.getAllOctaves(note: note)
//            note = Note.getClosestNote(notes: all, to: 40)!
//        }
        return note
    }
}
