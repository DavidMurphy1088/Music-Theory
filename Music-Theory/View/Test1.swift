import SwiftUI
import CoreData

struct Test1: View {
    @State var score:Score
    @ObservedObject var staff:Staff
    @State var note = 52
    
    init() {
        let score = Score()
        let staff = Staff(system: score, type: .treble)
        score.setStaff(num: 0, staff: staff)
        self.score = score
        self.staff = staff
    }
    
    func setKey(key:KeySignature) {
        score.setKey(key: key)
        //system.setStaff(num: 1, staff: Staff(system: system, type: .bass))
    }
        
    var body: some View {
        HStack {
            VStack {
                ScoreView(score: score)
                .padding()
                Spacer()
                VStack {
                    Button("Make Note") {
                        let ts = score.addTimeSlice()
                        ts.addNote(n: Note(num: note))
                        ts.addNote(n: Note(num: note-4))
                        note = note - 6
                    }
                    Spacer()
                    Button("Make Chord") {
                        //let ch = Chord(key: key)
                        //let ts = TimeSlice(score: score)
                        //ts.addChord(c: ch)
                        //system.addTimeSlice(ts: ts)
                    }
                    Spacer()
                    Button("Clear") {
                        score.clear()
                    }
                    Spacer()
                    Button("Play") {
                        score.play()
                    }
                }
            }
        }
        .onAppear {
            let key:KeySignature = KeySignature(type: KeySignatureType.flats, count: 0)
            setKey(key: key)
        }
    }
    
}

