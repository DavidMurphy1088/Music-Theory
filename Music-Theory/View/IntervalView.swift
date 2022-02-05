import SwiftUI
import CoreData

//https://www.musictheory.net/calculators/interval
//https://www.musicca.com/interval-song-chart

struct IntervalView: View {
    @State var score:Score 
    @ObservedObject var staff:Staff
    static let startPitch:Double = 40
    @State private var pitch: Double = startPitch
    @State private var tempo: Double = 3
    @State var maxInterval: CGFloat = 10
    @State var intervals = Intervals()
    @State var intName:String?
    @State var scale:Scale
    @State var diatonic = true
    @State var descending = false
    @State var ascending = true
    @State var fixedRoot = true
    @State var lastNote1 = 0
    @State var lastNote2 = 0
    @State var queuedSpan = 0
    @State var lastKey:Key
    @State var key:Key

    init() {
        let score = Score()
        score.tempo = 8
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        score.setStaff(num: 0, staff: staff)
        self.score = score
        self.staff = staff
        let key = Key(type: Key.KeyType.major, keySig: KeySignature(type: KeySignatureType.flats, count: 0))
        self.scale = Scale(key: key)
        self.key = key
        self.lastKey = key
    }
    
    func setKey(key:Key) {
        scale = Scale(key: key)
        score.setKey(key: key)
    }
    
    func makeInterval() {
        intName = nil
        
        while true {
            var note1ScaleOffset = 0
            if !fixedRoot {
                let idx = Int.random(in: 0..<scale.diatonicOffsets().count)
                //let idx = 6
                note1ScaleOffset = scale.diatonicOffsets()[idx]
                print("===", idx, note1ScaleOffset)
            }
            //let note1 = Note(num: scale.notes[root].num)
            let note1 = Note(num: scale.notes[0].num + note1ScaleOffset)
            
            let note2Distance = Int.random(in: -12..<12)
            if note2Distance == 0 {
                continue
            }
            if ascending && !descending {
                if note2Distance < 0 {
                    continue
                }
            }
            if descending && !ascending {
                if note2Distance > 0 {
                    continue
                }
            }
            if diatonic {
                let offsets = scale.diatonicOffsets()
                var check = (note2Distance < 0) ? 12 + note2Distance : note2Distance
                check = (check + note1ScaleOffset) % 12
                if !offsets.contains(check) {
                    continue
                }
            }
            let note2 = Note(num: note1.num + note2Distance)

            if note1.num < Note.MIDDLE_C || note2.num < Note.MIDDLE_C {
                note2.num += 12
                note1.num += 12
            }
            
            print("-----> end make int", note1.num, note2.num, note1ScaleOffset, note2Distance)

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
                queuedSpan = note2Distance
                sleep(UInt32(2))
                if note2Distance == queuedSpan {
                    intName = "\(intervals.getName(span: abs(note2Distance)) ?? "none")"
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
                score.setTempo(temp: Int(tempo))
                score.play()
            }
            Spacer()
            Spacer()
            Button("Play") {
                score.setTempo(temp: Int(tempo))
                score.play()
            }

            Spacer()
            Text(intName ?? "").font(.title)
            Spacer()
            VStack {
                //Spacer()
                HStack {
                    Text("Tempo").padding()
                    Slider(value: $tempo, in: 3...Double(score.maxTempo)).padding()
                }
                //Spacer()
                Button(action: {
                    fixedRoot = !fixedRoot
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: fixedRoot ? "checkmark.square": "square")
                        Text("Fixed Interval Root")
                    }
                }
                //Spacer()
                Button(action: {
                    diatonic = !diatonic
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: diatonic ? "checkmark.square": "square")
                        Text("Diatonic")
                    }
                }
                //Spacer()
                HStack {
                    Button(action: {
                        ascending = !ascending
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: ascending ? "checkmark.square": "square")
                            Text("Ascending")
                        }
                    }
                    Button(action: {
                        descending = !descending
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: descending ? "checkmark.square": "square")
                            Text("Descending")
                        }
                    }
                }
                //Spacer()
                Button("Key") {
                    score.clear()
                    while (true) {
                        let type = (Int.random(in: 0...1) == 0) ? KeySignatureType.sharps : KeySignatureType.flats
                        let keySig = KeySignature(type: type, count: Int.random(in: 0...4))
                        if keySig.flats != lastKey.keySig.flats || keySig.sharps != lastKey.keySig.sharps {
                            let key = Key(type: Key.KeyType.major, keySig: keySig)
                            setKey(key: key)
                            lastKey = key
                            break
                        }
                    }
                }
            }
            //Spacer()
        }

//        .onAppear {
//            setKey(key: key)
//            lastKey = key
//        }
    }
    
}
