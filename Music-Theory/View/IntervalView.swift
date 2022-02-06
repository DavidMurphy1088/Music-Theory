import SwiftUI
import CoreData

//https://www.musictheory.net/calculators/interval
//https://www.musicca.com/interval-song-chart

struct IntervalView: View {
    @State var score:Score
    @ObservedObject var staff:Staff
    @State private var tempo: Double = 3
    @State var intName:String?
    @State var scale:Scale
    @State var diatonic = true
    @State var descending = false
    @State var ascending = true
    @State var fixedRoot = true
    @State var lastNote1 = 0
    @State var lastNote2 = 0
    @State var queuedSpan = 0
    @State var intervalNotes: (Note, Note)
    @State var note1ScaleOffset = 0
    
    init() {
        //let key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.sharps, count: 0))
        let key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.sharps, count: 3))
        let score = Score()
        score.key = key
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        score.tempo = 8
        score.setStaff(num: 0, staff: staff)

        self.staff = staff
        self.scale = Scale(key: key, minorType: Scale.MinorType.harmonic)
        self.score = score
        self.intervalNotes = (Note(num: 0), Note(num: 0))
    }
    
    func setKey(key:Key) {
        scale = Scale(key: key, minorType: Scale.MinorType.harmonic)
        score.setKey(key: key)
        print ("KEY======", key.description())
    }
    
    func makeInterval() -> [Note] {
        intName = nil
        var notes:[Note] = []
        
        while true {
            note1ScaleOffset = 0
            if !fixedRoot {
                let idx = Int.random(in: 0..<scale.diatonicOffsets().count)
                //let idx = 6
                note1ScaleOffset = scale.diatonicOffsets()[idx]
                print("===", idx, note1ScaleOffset)
            }
            //let note1 = Note(num: scale.notes[root].num)
            let note1 = Note(num: scale.notes[0].num + note1ScaleOffset)
            
            var note2Distance = Int.random(in: -12..<12)
            note2Distance = 12
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
            notes.append(note1)
            notes.append(note2)
            return notes
        }
    }
    
    func notesToScore(notes : [Note]) {
        for note in notes {
            let ts = score.addTimeSlice()
            ts.addNote(n: note)
        }
    }
    
    func makeNoteSteps(interval: (Note, Note)) -> [Note] {
        var steps : [Note] = []
        let inc = interval.0.num < interval.1.num ? 1 : -1
        var num = interval.0.num
        while (num != interval.1.num) {
            let note = Note(num: num)
            if self.scale.noteInScale(note: note) {
                steps.append(note)
            }
            num += inc
        }

        steps.append(interval.1)
        return steps
    }

    var body: some View {

        VStack {
            ScoreView(score: score)
            .padding()
            Button("Select") {
                intName = ""
                score.clear()
                let notes = makeInterval()
                self.intervalNotes = (notes[0], notes[1])
                notesToScore(notes: notes)

                DispatchQueue.global(qos: .userInitiated).async {
                    intName = "?"
                    let span = notes[1].num - notes[0].num
                    queuedSpan = span
                    sleep(UInt32(2))
                    var intervals = Intervals()
                    if span == queuedSpan {
                        intName = "\(intervals.getName(span: abs(span)) ?? "none")"
                    }
                }
                score.setTempo(temp: Int(tempo))
                score.play()
            }
            Spacer()
            Spacer()
            HStack {
                Spacer()
                Button("Play") {
                    score.setTempo(temp: Int(tempo))
                    score.play()
                }
                Spacer()
                Button("Play Steps") {
                    score.clear()
                    let notes = makeNoteSteps(interval: self.intervalNotes)
                    notesToScore(notes: notes)
                    score.setTempo(temp: Int(tempo * 2))
                    score.play()
                }
                Spacer()
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
                HStack {
                    Text("\(self.staff.publishUpdate)")
                    Text("\(self.staff.keyDescription())")
                    Button("Change Key") {
                        var key = self.score.key
                        while key == self.score.key {
                            let accType = (Int.random(in: 0...1) == 0) ? KeySignatureAccidentalType.sharps : KeySignatureAccidentalType.flats
                            let keySig = KeySignature(type: accType, count: Int.random(in: 0...4))
                            var keyType = Key.KeyType.major
                            let r = Int.random(in: 1...1)
                            if (r == 1) {
                                keyType = Key.KeyType.minor
                            }
                            key = Key(type: keyType, keySig: keySig)
                        }
                        score.clear()
                        setKey(key: key!)
                    }
                }
            }
        }

    }
    
}
