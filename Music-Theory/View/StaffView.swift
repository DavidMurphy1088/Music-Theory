import SwiftUI
import CoreData
import MessageUI
 
struct StaffView: View {
    @ObservedObject var system:System
    @ObservedObject var staff:Staff
    static let lineHeight = 1
    let lineSpacing = 16
        
    init (system:System, staff:Staff) {
        self.system = system
        self.staff = staff
    }
            
    func colr(line: Int) -> Color {
        if line < system.ledgerLineCount || line >= system.ledgerLineCount + 5 {
            return Color.gray
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
                        HStack {
                            Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 7)))
                            //Spacer()
                        }
                        .border(Color.green)
                        HStack {
                            Text("\u{1d122}").font(.system(size: CGFloat(lineSpacing * 4)))
                            //Spacer()
                        }
                        .border(Color.green)
                    }
                    .frame(width: geometry.size.width / 6) //, height: max(proxy.size.height, 120))
//                    ForEach(staff.key!.accidentals, id: \.self) { acc in
//                            AccidentalView(staff: staff, acc: Note.MIDDLE_C + 12 + acc , lineSpacing: lineSpacing)
//                    }
                    .frame(width: geometry.size.width / 40) //, height: max(proxy.size.height, 120))
                    .border(Color.green)
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
    }
}
