import SwiftUI
import CoreData

//https://www.musictheory.net/calculators/interval

//struct IntervalView: View {
//    @StateObject var score:Score = Score()
//    static let startPitch:Double = 40
//    @State private var pitch: Double = startPitch
//    @State private var tempo: Double = 4
//    //@State var notes:[Note] = []
//    @State var maxInterval: CGFloat = 10
//    @State var intervals = Intervals()
//    @State var intName:String?
//    @State var scale:Scale?
//    @State var last1:Int?
//    @State var last2:Int?
//    @State var diatonic = true
//    
//    init() {
//    }
//    
//    func setKey(key:KeySignature) {
//        scale = Scale(key: key)
//        score.setKey(key: key)
//        score.setStaff(num: 0, staff: Staff(system: score, type: .treble))
//    }
//    
//    func toggle() {
//        diatonic = !diatonic
//    }
//    
//    func makeInterval() {
//        score.clear()
//        intName = nil
//        let octave = Int.random(in: 0...1)
//        var r = Int.random(in: 0..<scale!.notes.count)
//        //r = 0
//        let note1 = Note(num: scale!.notes[r].num)
//        note1.num += octave * 12
//        let ts1 = TimeSlice()
//        ts1.addNote(n: note1)
//        
//        let ts2 = TimeSlice()
//        var span = 0
//        while true {
//            var note2:Note
//            if diatonic {
//                r = Int.random(in: 0..<scale!.notes.count)
//                note2 = Note(num: scale!.notes[r].num)
//                note2.num += octave * 12
//            }
//            else {
//                r = Int.random(in: -12..<12)
//                note2 = Note(num: note1.num + r)
//            }
//            
//            span = abs(note2.num - note1.num)
//            if span == 0 {
//                continue
//            }
//            if last1 == note1.num && last2 == note2.num {
//                continue
//            }
//            last1 = note1.num
//            last2 = note2.num
//            ts2.addNote(n: note2)
//            break
//        }
//        //system.addTimeSlice(ts: ts1)
//        //system.addTimeSlice(ts: ts2)
//        DispatchQueue.global(qos: .userInitiated).async {
//            intName = "?"
//            sleep(2)
//            intName = "\(intervals.getName(span: span) ?? "none")"
//        }
//    }
//    
//    var body: some View {
//        HStack {
//            VStack {
//                ScoreView(score: score)
//                .padding()
//                Spacer()
//                VStack {
//                    Button("Select") {
//                        makeInterval()
//                    }
//                    Spacer()
//                    Button("Play") {
//                        score.setTempo(temp: Int(tempo))
//                        score.play()
//                    }
//                }
//                Spacer()
//                HStack {
//                    Text("Tempo").padding()
//                    //Slider(value: $tempo, in: 3...Double(system.maxTempo)).padding()
//                }
//                Spacer()
//                Text(intName ?? "").font(.title)
//                Spacer()
//
//            }
//            VStack {
//                Button("Key") {
//                    let type = (Int.random(in: 0...1) == 0) ? KeySignatureType.sharps : KeySignatureType.flats
//                    let key = KeySignature(type: type, count: Int.random(in: 0...4))
//                    setKey(key: key)
//                }
//
//                Button(action: {
//                    toggle()
//                }) {
//                    HStack(spacing: 10) {
//                        Image(systemName: diatonic ? "checkmark.square": "square")
//                        Text("Diatonic")
//                    }
//                }
//                .padding()
//            }
//        }
//        .onAppear {
//            let key = KeySignature(type: KeySignatureType.flats, count: 0)
//            setKey(key: key)
//        }
//    }
//    
//}
