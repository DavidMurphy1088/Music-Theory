import SwiftUI
import CoreData
import MessageUI

struct NoteView: View {
    var staff:Staff
    var note:Note
    var color: Color
    var opacity: Int
    var lineSpacing:Int
    var noteWidth:CGFloat
    var offsetFromStaffTop:Int?
    var accidental:String
    var ledgerLines:[Int]
    let ledgerLineWidth:Int
    
    init(staff:Staff, note:Note, lineSpacing: Int, color: Color, opacity:Int) {
        self.staff = staff
        self.note = note
        self.color = color
        self.lineSpacing = lineSpacing
        self.opacity = opacity
        let pos = staff.getNoteViewData(noteValue: note.num)
        offsetFromStaffTop = pos.0
        accidental = pos.1
        ledgerLines = pos.2
        noteWidth = CGFloat(lineSpacing) * 1.2
        ledgerLineWidth = Int(noteWidth * 0.8)
    }
            
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if offsetFromStaffTop != nil {
                    Text(accidental)
                        .frame(width: CGFloat(ledgerLineWidth) * 3.5, alignment: .leading)
                        //.border(Color.green) //DEBUG ONLY - not pos of .border in properties matters - different if after .position
                        .position(x: geometry.size.width/2, y: CGFloat(offsetFromStaffTop! * lineSpacing/2))
                    Ellipse()
                    //Text("X")
                        //the note ellipses line up in the center of the view
                        .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 1.0))
                        //.border(self.staff.staffNum == 0 ? Color.red : Color.green)
                        .foregroundColor(self.color)
                        .position(x: geometry.size.width/2, y: CGFloat(offsetFromStaffTop! * lineSpacing/2)) //x required since it defaults to 0 if y is specified.
                        .opacity(Double(opacity))

                    if ledgerLines.count > 0 {
                        ForEach(0..<ledgerLines.count) { row in
                            Path { path in
                                path.move(to: CGPoint(x: Int(geometry.size.width)/2 - ledgerLineWidth, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2))
                                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2 + ledgerLineWidth+1, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2))
                                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2 + ledgerLineWidth+1, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2 + StaffView.lineHeight))
                                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2 - ledgerLineWidth, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2 + StaffView.lineHeight))
                                path.closeSubpath()
                            }
                            .fill(self.color)
                            //.opacity(Double(opacity))
                        }
                    }

                }
            }
            //.border(Color.green)
        }
    }
}

