import SwiftUI
import CoreData
import MessageUI
 
struct StaffView: View {
    @ObservedObject var system:System
    var staff:Staff
    static let lineHeight = 1
    let lineSpacing = 12
        
    init (system:System, staff:Staff) {
        self.system = system
        self.staff = staff
    }
            
    func colr(line: Int) -> Color {
        if line < system.ledgerLineCount || line >= system.ledgerLineCount + 5 {
            return Color.white
        }
        return Color.blue
    }
              
    var body: some View {
        GeometryReader { geometry in
            ZStack (alignment: .leading) {
                ForEach(0..<system.staffLineCount) { row in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: row*lineSpacing))
                        path.addLine(to: CGPoint(x: Int(geometry.size.width), y: row*lineSpacing))
                        path.addLine(to: CGPoint(x: Int(geometry.size.width), y: row*lineSpacing + StaffView.lineHeight))
                        path.addLine(to: CGPoint(x: 0, y: row*lineSpacing + StaffView.lineHeight))
                        path.closeSubpath()
                    }
                    .fill(colr(line: row))
                }
                HStack {
                    if staff.type == StaffType.treble {
                        Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 9)))
                        .offset(y:CGFloat(0 - lineSpacing))
                    }
                    else {
                        Text("\u{1d122}").font(.system(size: CGFloat(lineSpacing * 6)))
                        .offset(y:CGFloat(0 - lineSpacing))
                    }

                    HStack (spacing: 0) {
                        ForEach(0 ..< system.key.accidentalCount, id: \.self) { i in
                            AccidentalView(staff: staff, key:system.key, noteIdx: i, lineSpacing: lineSpacing)
                        }
                    }
                    .border(Color.green)
                    .frame(width: CGFloat(system.staffLineCount/3 * lineSpacing)) 

                    HStack {
                        ForEach(system.timeSlice, id: \.self) { timeSlice in
                            ZStack {
                                ForEach(timeSlice.note, id: \.self) { note in
                                    NoteView(staff: staff, note: note, lineSpacing: lineSpacing)
                                }
                            }
                        }
                    }
                }
            }
            .border(Color.purple)
            .frame(height: CGFloat(system.staffLineCount * lineSpacing)) //fixed size of height for all staff lines + ledger lines
        }
    }
}
