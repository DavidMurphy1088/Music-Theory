import SwiftUI
import CoreData
import MessageUI

//struct AccidentalView: View {
//    var staff:Staff
//    var acc:Int
//    var lineSpacing:Int
//    var offset:Int
//    var accidental:String
//
//    init(staff:Staff, acc:Int, lineSpacing: Int) {
//        self.staff = staff
//        self.acc = acc
//        self.lineSpacing = lineSpacing
//        offset = staff.staffOffset(noteValue: acc).0
//        accidental = staff.key!.type == KeySignatureType.sharps ? Staff.accSharp : Staff.accFlat
//    }
//
//    var body: some View {
//        HStack (alignment: .center, spacing: 0, content: {
//            Text(accidental).font(.title)
//                .frame(width: CGFloat(lineSpacing)*1.0, height: CGFloat(Double(lineSpacing) * 0.80))
////            Ellipse()
////                .foregroundColor(.blue)
////                .frame(width: CGFloat(lineSpacing)*1.0, height: CGFloat(Double(lineSpacing) * 0.80))
////                //.position(x: CGFloat(4), y: CGFloat((staff.noteOffset(n: note) + staff.getMiddleCOffset()) * lineSpacing/2))
//            }
//        )
//        .position(x: CGFloat(4), y: CGFloat(offset * lineSpacing/2))
//    }
//}

