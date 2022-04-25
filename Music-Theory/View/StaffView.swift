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
    
    func keyDesc() -> String {
        var desc = score.key.description()
        if self.staff.score.key.type == Key.KeyType.minor {
            desc += self.score.minorScaleType == Scale.MinorType.natural ? " (Natural)" : " (Harmonic)"
        }
        return desc
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
                Text("\n\n\n\n\n\n\n\n\n\n\(self.keyDesc())").font(.system(size: CGFloat(lineSpacing)))
                HStack {
                    //Text("staff:"+String(staff.publishUpdate))
                    if staff.type == StaffType.treble {
                        Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 9)))
                        .offset(y:CGFloat(0 - lineSpacing))
                    }
                    else {
                        Text("\u{1d122}").font(.system(size: CGFloat(lineSpacing * 6)))
                        .offset(y:CGFloat(0 - lineSpacing))
                    }
                    if score.key != nil {
                        HStack (spacing: 0) {
                            ForEach(0 ..< score.key.keySig.accidentalCount, id: \.self) { i in
                                AccidentalView(staff: staff, key:score.key.keySig, noteIdx: i, lineSpacing: lineSpacing)
                            }
                        }
                        .border(Color.green)
                        .frame(width: CGFloat(score.staffLineCount/3 * lineSpacing))
                    }

                    HStack {
                        ForEach(score.timeSlices, id: \.self) { timeSlice in
                            ZStack {
                                ForEach(timeSlice.note, id: \.self) { note in
                                    //if the note isn't shown on both staff's the alignment between staffs is wrong
                                    if note.staff == staff.staffNum {
                                        NoteView(staff: staff, note: note, lineSpacing: lineSpacing, color: Color.black)
                                    }
                                    else {
                                        NoteView(staff: staff, note: note, lineSpacing: lineSpacing, color: Color.white)
                                    }
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
