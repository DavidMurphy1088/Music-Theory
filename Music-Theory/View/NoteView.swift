import SwiftUI
import CoreData
import MessageUI

struct NoteView: View {
    var staff:Staff
    var note:Note
    var lineSpacing:Int
    var noteWidth:CGFloat
    var offsetFromStaffTop:Int
    var accidental:String
    var ledgerLines:[Int]
    let ledgerLineWidth:Int
    var noteCenter:Int
    
    init(staff:Staff, note:Note, lineSpacing: Int) {
        self.staff = staff
        self.note = note
        self.lineSpacing = lineSpacing
        (offsetFromStaffTop, accidental, ledgerLines) = staff.staffOffset(noteValue: note.num)
        noteWidth = CGFloat(lineSpacing) * 1.2
        noteCenter = offsetFromStaffTop * lineSpacing/2
        ledgerLineWidth = Int(noteWidth * 0.7)
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
        GeometryReader { geometry in
        ZStack {
            if ledgerLines.count > 0 {
                ForEach(0..<ledgerLines.count) { row in
                    Path { path in
                        path.move(to: CGPoint(x: Int(geometry.size.width)/2-ledgerLineWidth, y: (offsetFromStaffTop + ledgerLines[row]) * lineSpacing/2))
                        path.addLine(to: CGPoint(x: Int(geometry.size.width)/2+ledgerLineWidth, y: (offsetFromStaffTop + ledgerLines[row]) * lineSpacing/2))
                        path.addLine(to: CGPoint(x: Int(geometry.size.width)/2+ledgerLineWidth, y: (offsetFromStaffTop + ledgerLines[row]) * lineSpacing/2 + StaffView.lineHeight))
                        path.addLine(to: CGPoint(x: Int(geometry.size.width)/2-ledgerLineWidth, y: (offsetFromStaffTop + ledgerLines[row]) * lineSpacing/2 + StaffView.lineHeight))
                        path.closeSubpath()
                    }
                    .fill(Color .red)
                }
            }
            Text(accidental)
                .frame(width: CGFloat(ledgerLineWidth * 3), alignment: .leading)
                .position(x: geometry.size.width/2, y: CGFloat(offsetFromStaffTop * lineSpacing/2))

            Ellipse()
                //the note ellipses line up in the center of the view
                .foregroundColor(.black)
                .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 1.0))
                .position(x: geometry.size.width/2, y: CGFloat(noteCenter)) //x required since it defaults to 0 if y is specified.
        }
        //.border(Color.green)
        }
    }
}

