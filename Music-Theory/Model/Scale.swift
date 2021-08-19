
import Foundation

class Scale {
    var notes:[Note] = []
    
    init() {
        var num = 40
        for var i in 0..<8 {
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
