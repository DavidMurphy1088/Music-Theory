import SwiftUI
import CoreData
import MessageUI

struct NoteView: View {
    var staff:Staff
    var note:Note
    var lineSpacing:Int
    var noteWidth:CGFloat
    var offsetFromStaffTop:Int?
    //var noteDistanceFromStaffTop:Int?
    var accidental:String
    var ledgerLines:[Int]
    let ledgerLineWidth:Int
    
    init(staff:Staff, note:Note, lineSpacing: Int) {
        self.staff = staff
        self.note = note
        self.lineSpacing = lineSpacing
        let pos = staff.noteViewData(noteValue: note.num)
        offsetFromStaffTop = pos.0
        accidental = pos.1
        ledgerLines = pos.2
        noteWidth = CGFloat(lineSpacing) * 1.2
        ledgerLineWidth = Int(noteWidth * 0.7)
    }
            
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if offsetFromStaffTop != nil {
                    if ledgerLines.count > 0 {
                        ForEach(0..<ledgerLines.count) { row in
                            Path { path in
                                path.move(to: CGPoint(x: Int(geometry.size.width)/2-ledgerLineWidth, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2))
                                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2+ledgerLineWidth, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2))
                                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2+ledgerLineWidth, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2 + StaffView.lineHeight))
                                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2-ledgerLineWidth, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2 + StaffView.lineHeight))
                                path.closeSubpath()
                            }
                            .fill(Color .red)
                        }
                    }
                    Text(accidental)
                        .frame(width: CGFloat(ledgerLineWidth * 3), alignment: .leading)
                        .position(x: geometry.size.width/2, y: CGFloat(offsetFromStaffTop! * lineSpacing/2))

                    Ellipse()
                        //the note ellipses line up in the center of the view
                        .foregroundColor(.black)
                        .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 1.0))
                        .position(x: geometry.size.width/2, y: CGFloat(offsetFromStaffTop! * lineSpacing/2)) //x required since it defaults to 0 if y is specified.
                }
            }
            //.border(Color.green)
        }
    }
}

