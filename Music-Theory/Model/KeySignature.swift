import Foundation
import AVKit
import AVFoundation

enum KeySignatureType {
    case sharps
    case flats
}

class KeySignature {
    var type:KeySignatureType
    var sharps:[Int] = []
    var flats:[Int] =  []
    var maxAccidentals = 7
    var accidentalCount:Int

    // how frequently is this note in a key signature
    func accidentalFrequency(note:Int, sigType: KeySignatureType) -> Int {
        var pos:Int?
        if sigType == KeySignatureType.sharps {
            for i in 0...sharps.count-1 {
                if Note.isSameNote(note1: note, note2: sharps[i]) {
                    pos = i
                    break
                }
            }
        }
        else {
            for i in 0...flats.count-1 {
                if Note.isSameNote(note1: note, note2: flats[i]) {
                    pos = i
                    break
                }
            }
        }
        if let pos = pos {
            return maxAccidentals - pos
        }
        else {
            return 0
        }
    }
    
    init(type:KeySignatureType, count:Int) {
        self.type = type
        self.accidentalCount = count
        for i in 0...maxAccidentals-1 {
            sharps.append(45 + i*7)
            flats.append(39 + i*5)
        }
    }

}
