
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
    func diatonicNotes() -> [Int] {
        if key.type == Key.KeyType.major {
            return [0, 2, 4, 5, 7, 9, 11]
        }
        return [0]
    }
    
    //return the degree in the scale of a note offset
    func noteDegree(offset:Int) -> Int {
        let dias = self.diatonicNotes()
        var deg = 0
        for d in dias {
            if d == offset {
                return deg
            }
            deg += 1
        }
        return -1
    }

    func degree(note:Int) {
        
    }
}
