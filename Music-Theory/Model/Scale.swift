
import Foundation

class Scale {
    var notes:[Note] = []
    
    init(key:KeySignature) {
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
}
