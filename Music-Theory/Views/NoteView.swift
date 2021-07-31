import SwiftUI
import CoreData
import MessageUI

struct NoteView: View {
    var staff:Staff
    var note:Note
    var lineSpacing:Int
    var offsetFromStaffTop:Int
    var accidental:String
    var needsLedgerLine:Bool
    
    init(staff:Staff, note:Note, lineSpacing: Int) {
        self.staff = staff
        self.note = note
        self.lineSpacing = lineSpacing
        (offsetFromStaffTop, accidental, needsLedgerLine) = staff.staffOffset(noteValue: note.num)
    }
    
    func ledgerOffset() -> Int {
        if offsetFromStaffTop % 2 == 0 {
            return 0
        }
        else {
            return 0 - lineSpacing/2 - 1
        }
    }
    
    var body: some View {
        HStack { //}(alignment: .center, spacing: 0, content: {
            Text(accidental)//.font(.title)
            ZStack {
                if needsLedgerLine {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: CGFloat(lineSpacing) * 1.8, height: 2, alignment: .top)
                        .offset(y: CGFloat(ledgerOffset()))
                }
                Ellipse()
                    .foregroundColor(.black)
                    .frame(width: CGFloat(lineSpacing)*1.2, height: CGFloat(Double(lineSpacing) * 1.0))
                    //.border(Color.green)
            }
        }
        //)
        //.border(Color.green)
        .position(x: CGFloat(0), y: CGFloat(offsetFromStaffTop * lineSpacing/2))
    }
}

