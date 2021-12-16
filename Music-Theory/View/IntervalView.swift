import SwiftUI
import CoreData

//https://www.musictheory.net/calculators/interval

struct IntervalView: View {
    @State var score:Score 
    @ObservedObject var staff:Staff
    static let startPitch:Double = 40
    @State private var pitch: Double = startPitch
    @State private var tempo: Double = 4
    @State var maxInterval: CGFloat = 10
    @State var intervals = Intervals()
    @State var intName:String?
    @State var scale:Scale?
    @State var diatonic = false
    @State var descending = false
    
    init() {
        let score = Score()
        score.tempo = 8
        let staff = Staff(system: score, type: .treble)
        score.setStaff(num: 0, staff: staff)
        self.score = score
        self.staff = staff
    }
    
    func setKey(key:KeySignature) {
        scale = Scale(key: key)
        score.setKey(key: key)
    }
    
    func makeInterval() {
        intName = nil
        let octave = 0 //Int.random(in: 0...1)
        while true {
            var r1 = Int.random(in: 0..<scale!.notes.count)
            let note1 = Note(num: scale!.notes[r1].num)
            note1.num += octave * 12
            
            var span = 0
            print("------> start make int")

            var note2:Note
            var r2 = 0
            if !diatonic {
                let cnt = scale!.notes.count
                r2 = Int.random(in: 0..<cnt)
                note2 = Note(num: scale!.notes[r2].num)
                note2.num += octave * 12
            }
            else {
                r2 = Int.random(in: -12..<12)
                note2 = Note(num: note1.num + r2)
            }
            span = abs(note2.num - note1.num)
            if span == 0 {
                continue
            }
            if !descending && note1.num > note2.num {
                continue
            }

            let ts1 = score.addTimeSlice()
            ts1.addNote(n: note1)
            let ts2 = score.addTimeSlice()
            ts2.addNote(n: note2)
            print("-----> end make int", note1.num, note2.num, span)

            DispatchQueue.global(qos: .userInitiated).async {
                intName = "?"
                sleep(2)
                intName = "\(intervals.getName(span: span) ?? "none")"
            }
            break
        }

    }
    
    var body: some View {

        VStack {
            ScoreView(score: score)
            .padding()
            Button("Select") {
                score.clear()
                makeInterval()
                score.play()
            }
            Spacer()
            Button("Play") {
                score.setTempo(temp: Int(tempo))
                score.play()
            }
//                Spacer()
//                HStack {
//                    Text("Tempo").padding()
//                    //Slider(value: $tempo, in: 3...Double(system.maxTempo)).padding()
//                }
            Spacer()
            Text(intName ?? "").font(.title)
            Spacer()
            Button("Key") {
                let type = (Int.random(in: 0...1) == 0) ? KeySignatureType.sharps : KeySignatureType.flats
                let key = KeySignature(type: type, count: Int.random(in: 0...4))
                setKey(key: key)
            }
            
            VStack {
                Spacer()
                Button(action: {
                    descending = !descending
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: descending ? "checkmark.square": "square")
                        Text("Descending")
                    }
                }
                
                Spacer()
                Button(action: {
                    diatonic = !diatonic
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: diatonic ? "checkmark.square": "square")
                        Text("Diatonic")
                    }
                }
            }
            Spacer()
        }

        .onAppear {
            let key = KeySignature(type: KeySignatureType.flats, count: 0)
            setKey(key: key)
        }
    }
    
}
