import SwiftUI
import CoreData
import MessageUI
 
struct StaffView: View {
    @ObservedObject var system:System
    @ObservedObject var staff:Staff
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
                HStack (alignment: .top) {
                    VStack {
                        if staff.type == StaffType.treble {
                            Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 7)))
                            .border(Color.green)
                        }
                        else {
                            Text("\u{1d122}").font(.system(size: CGFloat(lineSpacing * 4)))
                            .border(Color.green)
                        }
                    }
                    
                    HStack (spacing: 0) {
                        ForEach(0 ..< system.key.accidentalCount) { i in
                            AccidentalView(staff: staff, key:system.key, noteIdx: i, lineSpacing: lineSpacing)
                            .frame(width: CGFloat(lineSpacing)).border(Color.green)
                        }
                    }
                    
                    HStack {
                        ForEach(system.timeSlice, id: \.self) { timeSlice in
                            ZStack {
                                ForEach(timeSlice.note, id: \.self) { note in
                                    NoteView(staff: staff, note: note, lineSpacing: lineSpacing)
                                }
                            }
                        }
                    }
                    .border(Color.green)
                }
            }
        }
    }
}
