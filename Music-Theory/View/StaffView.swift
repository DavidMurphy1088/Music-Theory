import SwiftUI
import CoreData
import MessageUI
 
struct StaffView: View {
    var score:Score
    @ObservedObject var staff:Staff
    static let lineHeight = 1
    let lineSpacing = 12
        
    init (score:Score, staff:Staff) {
        self.score = score
        self.staff = staff
    }
            
    func colr(line: Int) -> Color {
        if line < score.ledgerLineCount || line >= score.ledgerLineCount + 5 {
            return Color.white
        }
        return Color.blue
    }
              
    var body: some View {
        GeometryReader { geometry in
            ZStack (alignment: .leading) {
                
                ForEach(0..<score.staffLineCount) { row in
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
                    Text("staff:"+String(staff.upd))
                    if staff.type == StaffType.treble {
                        Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 9)))
                        .offset(y:CGFloat(0 - lineSpacing))
                    }
                    else {
                        Text("\u{1d122}").font(.system(size: CGFloat(lineSpacing * 6)))
                        .offset(y:CGFloat(0 - lineSpacing))
                    }

                    HStack (spacing: 0) {
                        ForEach(0 ..< score.key.accidentalCount, id: \.self) { i in
                            AccidentalView(staff: staff, key:score.key, noteIdx: i, lineSpacing: lineSpacing)
                        }
                    }
                    .border(Color.green)
                    .frame(width: CGFloat(score.staffLineCount/3 * lineSpacing)) 

                    HStack {
                        ForEach(score.timeSlices, id: \.self) { timeSlice in
                            ZStack {
                                ForEach(timeSlice.note, id: \.self) { note in
                                    NoteView(staff: staff, note: note, lineSpacing: lineSpacing)
                                }
                            }
                        }
                    }
//                    HStack {
//                        ForEach(staff.voices, id: \.self.id) { voice in
//                            ZStack {
//                                ForEach(voice.notes, id: \.self) { note in
//                                    NoteView(staff: staff, note: note, lineSpacing: lineSpacing)
//                                }
//                            }
//                        }
//                    }

                }
            }
            .border(Color.purple)
            .frame(height: CGFloat(score.staffLineCount * lineSpacing)) //fixed size of height for all staff lines + ledger lines
        }
    }
}
