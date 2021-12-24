import SwiftUI
import CoreData

//https://www.musictheory.net/calculators/interval

struct IntervalView: View {
    @State var score:Score 
    @ObservedObject var staff:Staff
    static let startPitch:Double = 40
    @State private var pitch: Double = startPitch
    @State private var tempo: Double = 3
    @State var maxInterval: CGFloat = 10
    @State var intervals = Intervals()
    @State var intName:String?
    @State var scale:Scale?
    @State var diatonic = true
    @State var descending = false
    @State var fixedRoot = true
    @State var lastNote1 = 0
    @State var lastNote2 = 0
    @State var queuedSpan = 0
    @State var lastKey:Key!
    @State var key = Key(type: Key.KeyType.major, keySig: KeySignature(type: KeySignatureType.flats, count: 0))

    init() {
        let score = Score()
        score.tempo = 8
        let staff = Staff(score: score, type: .treble)
        score.setStaff(num: 0, staff: staff)
        self.score = score
        self.staff = staff
    }
    
    func setKey(key:Key) {
        scale = Scale(key: key)
        score.setKey(key: key)
    }
    
    func makeInterval() {
        intName = nil
        
        while true {
            var root = 0
            if !fixedRoot {
                root = Int.random(in: 0..<scale!.notes.count)
            }
            let note1 = Note(num: scale!.notes[root].num)
            //note1.num += octave * 12
            
            var span = 0

            var note2:Note
            var r2 = 0
            var octave = 0
            if diatonic {
                let cnt = scale!.notes.count
                r2 = Int.random(in: 0..<cnt)
                note2 = Note(num: scale!.notes[r2].num)
                if descending {
                    octave = Int.random(in: -1...0)
                }
                note2.num += octave * 12
            }
            else {
                r2 = Int.random(in: -12..<12)
                note2 = Note(num: note1.num + r2)
            }
            span = abs(note2.num - note1.num)
            print("-----> end make int", note1.num, note2.num, span)

            if span == 0 {
                continue
            }
            if !descending {
                if note2.num < note1.num {
                    continue
                }
            }
            if note1.num == lastNote1 && note2.num == lastNote2 {
                continue
            }
            let ts1 = score.addTimeSlice()
            ts1.addNote(n: note1)
            let ts2 = score.addTimeSlice()
            ts2.addNote(n: note2)
            lastNote1 = note1.num
            lastNote2 = note2.num

            DispatchQueue.global(qos: .userInitiated).async {
                intName = "?"
                queuedSpan = span
                sleep(UInt32(tempo))
                if span == queuedSpan {
                    intName = "\(intervals.getName(span: span) ?? "none")"
                }
            }
            break
        }

    }
    
    var body: some View {

        VStack {
            ScoreView(score: score)
            .padding()
            Button("Select") {
                intName = ""
                score.clear()
                makeInterval()
                score.play()
            }
            Spacer()
            Button("Play") {
                score.setTempo(temp: Int(tempo))
                score.play()
            }

            Spacer()
            Text(intName ?? "").font(.title)
            
            VStack {
                Spacer()
                HStack {
                    Text("Tempo").padding()
                    Slider(value: $tempo, in: 3...Double(score.maxTempo)).padding()
                }
                Spacer()
                Button(action: {
                    fixedRoot = !fixedRoot
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: fixedRoot ? "checkmark.square": "square")
                        Text("Fixed Interval Root")
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
                Spacer()
                Button(action: {
                    descending = !descending
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: descending ? "checkmark.square": "square")
                        Text("Include Descending")
                    }
                }
                Spacer()
                Button("Key") {
                    score.clear()
                    while (true) {
                        let type = (Int.random(in: 0...1) == 0) ? KeySignatureType.sharps : KeySignatureType.flats
                        let keySig = KeySignature(type: type, count: Int.random(in: 0...4))
                        if key.keySig.flats != lastKey.keySig.flats || key.keySig.sharps != lastKey.keySig.sharps {
                            let key = Key(type: Key.KeyType.major, keySig: keySig)
                            setKey(key: key)
                            lastKey = key
                            break
                        }
                    }
                }
            }
            Spacer()
        }

        .onAppear {
            setKey(key: key)
            lastKey = key
        }
    }
    
}
