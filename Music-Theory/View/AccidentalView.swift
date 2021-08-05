import SwiftUI
import CoreData
import MessageUI

struct AccidentalView: View {
    var staff:Staff
    var acc:Int
    var lineSpacing:Int
    var accidental:String

    init(staff:Staff, acc:Int, lineSpacing: Int) {
        self.staff = staff
        self.acc = acc
        self.lineSpacing = lineSpacing
        accidental = staff.system.key.type == KeySignatureType.sharps ? System.accSharp : System.accFlat
    }

    func offset() -> Int {
        return 0
//        let pos = staff.getNoteStaffPos(noteValue: acc)
//        let ind = pos.0
//        let hi = pos.1
//        let lo = pos.2
//        if ind == nil {
//            if staff.system.key.type == KeySignatureType.sharps {
//                return lo!
//            }
//            else {
//                return hi!
//            }
//        }
//        else {
//            return ind!
//        }
    }
    
    var body: some View {
        Text(accidental).font(.title)
            .position(x: CGFloat(lineSpacing/2), y: CGFloat(offset() * lineSpacing/2))

    }
}

