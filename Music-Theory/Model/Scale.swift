
import Foundation

class Scale {
    var notes:[Note] = []
    var key:Key
    var minorType:MinorType?
    
    enum MinorType {
        case natural
        case harmonic
        case melodic
    }

    init(key:Key, minorType: MinorType? = nil) {
        self.key = key
        self.minorType = minorType
        var num = key.firstScaleNote()
        for i in 0..<7 {
            notes.append(Note(num: num))
            if key.type == Key.KeyType.major {
                if [2,6].contains(i) {
                    num += 1
                }
                else {
                    num += 2
                }
            }
            else {
                if [1,4].contains(i) {
                    num += 1
                }
                else {
                    num += 2
                }
            }
        }
        //melodic minor not yet supported
        if self.minorType != nil && self.minorType == MinorType.harmonic {
            notes[6].num += 1
        }
    }
    
    func noteInScale(note: Note) -> Bool {
        for octaveOffset in 0...4 {
            if self.notes.contains(Note(num: note.num + octaveOffset*12)){
                return true
            }
            if self.notes.contains(Note(num: note.num - octaveOffset*12)){
                return true
            }
        }
        return false
    }
    
    //list the diatonic note offsets in the scale
    func diatonicOffsets() -> [Int] {
        if key.type == Key.KeyType.major {
            return [0, 2, 4, 5, 7, 9, 11]
        }
        else {
            if self.minorType == MinorType.natural {
                return [0, 2, 3, 5, 7, 8, 10]
            }
            else {
                return [0, 2, 3, 5, 7, 8, 11]
            }
        }
    }
    
    //return the degree in the scale of a note offset
    func noteDegree(offset:Int) -> Int {
        if key.type == Key.KeyType.major {
            switch offset {
            case 0:
                return 1
            case 2:
                return 2
            case 4:
                return 3
            case 5:
                return 4
            case 7:
                return 5
            case 9:
                return 6
            case 11:
                return 7
            default:
                return 0
            }
        }
        else {
            switch offset {
            case 0:
                return 1
            case 2:
                return 2
            case 3:
                return 3
            case 5:
                return 4
            case 7:
                return 5
            case 8:
                return 6
            case 10:
                if self.minorType == MinorType.natural {
                    return 7
                }
                return 0
            case 11:
                if self.minorType == MinorType.harmonic {
                    return 7
                }
                return 0
            default:
                return 0
            }
        }
    }
    
    func degreeName(degree: Int) -> String {
        switch degree {
        case 1: return "Tonic"
        case 2: return "Supertonic"
        case 3: return "Mediant"
        case 4: return "Subdominant"
        case 5: return "Dominant"
        case 6: return "Submediant"
        case 7:
            if self.minorType == MinorType.harmonic {
                return "Leading Tone"
            }
            else {
                return "Subtonic"
            }
        default: return ""
        }
    }
}
