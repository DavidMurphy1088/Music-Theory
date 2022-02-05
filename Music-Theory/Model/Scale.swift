
import Foundation

class Scale {
    var notes:[Note] = []
    var key:Key
    
    init(key:Key) {
        self.key = key
        var num = key.firstScaleNote()
        for i in 0..<8 {
            notes.append(Note(num: num))
            if [2,6].contains(i) {
                num += 1
            }
            else {
                num += 2
            }
        }
    }
    
    //list the diatonic note offsets in the scale
    func diatonicOffsets() -> [Int] {
        if key.type == Key.KeyType.major {
            return [0, 2, 4, 5, 7, 9, 11]
        }
        return [0]
    }
    
    //return the degree in the scale of a note offset
    func noteDegree(offset:Int) -> Int {
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
    
    func degreeName(degree: Int) -> String {
        switch degree {
        case 1: return "Tonic"
        case 2: return "Supertonic"
        case 3: return "Mediant"
        case 4: return "Subdominant"
        case 5: return "Dominant"
        case 6: return "Submediant"
        case 7: return "Leading Tone"

        default: return ""
        }
    }
}
