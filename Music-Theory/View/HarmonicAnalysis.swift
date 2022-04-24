import SwiftUI
import CoreData

struct HarmonicAnalysisView: View {
    @State var score:Score
    @ObservedObject var staff:Staff
    @State var scale:Scale
    @State private var tempo: Double = 3
    @State var degreeName:String?
    @State var queuedDegree = 0
    @State var lastOffsets:[Int] = []
    @State var inversions = true
    @State var widen = false

    init() {
        let score = Score()
        score.tempo = 8
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        let staff1 = Staff(score: score, type: .bass, staffNum: 1)
        score.setStaff(num: 0, staff: staff)
        score.setStaff(num: 1, staff: staff1)
        
        score.key = Key(type: Key.KeyType.major, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 0))
        //score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 0))
        //score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 2))
        
        self.scale = Scale(key: score.key, minorType: Scale.MinorType.harmonic)
        self.score = score
        self.staff = staff
        self.setKey(key: score.key)
    }

    func setKey(key:Key) {
        self.score.setKey(key: key)
        self.scale = Scale(key: key, minorType: Scale.MinorType.harmonic)
    }

    var body: some View {
        HStack {
            VStack {
                ScoreView(score: score)
                .padding()
                Spacer()
                VStack {
                    Button("Test") {
                        score.clear()
                        let root = Chord()
                        root.notes.append(Note(num: 40))
                        root.notes.append(Note(num: 47))
                        var ts = score.addTimeSlice()
                        ts.addChord(c: root)
                        score.setTempo(temp: Int(tempo))
                        score.play()
                    }
                    Button("Make Degree") {
                        score.clear()
                        let root = Chord()
                        let chordType = score.key.type == Key.KeyType.major ? Chord.ChordType.major : Chord.ChordType.minor
                        root.makeTriad(root: score.key.firstScaleNote(), type: chordType)
                        var bass = root.notes[0].num
                        var all = Note.getAllOctaves(note: bass)
                        bass = Note.getClosestNote(notes: all, to: 40 - 12)!
                        root.notes.append(Note(num: bass))
                        root.notes[3].staff = 1
                        var ts = score.addTimeSlice()
                        if widen {
                            root.notes[1].num += 12
                        }
                        ts.addChord(c: root)

                        degreeName = nil
                        var offset = 0
                        let diatonics = scale.diatonicOffsets()
                        while true {
                            offset = Int.random(in: 1..<12)
                            if lastOffsets.contains(offset) {
                                continue
                            }
                            if diatonics.contains(offset) {
                               break
                            }
                        }
                        //offset = 7
                        ts = score.addTimeSlice()
                        var c2 = Chord()
                        var triadType = Chord.ChordType.major
                        if score.key.type == Key.KeyType.major {
                            let minors = [2,4,9]
                            if minors.contains(offset) {
                                triadType = Chord.ChordType.minor
                            }
                            if offset == 11 {
                                triadType = Chord.ChordType.diminished
                            }
                        }
                        else {
                            triadType = Chord.ChordType.minor
                            var majors = [3,8,10]
                            if scale.minorType == Scale.MinorType.harmonic {
                                majors.append(7)
                            }
                            if majors.contains(offset) {
                                triadType = Chord.ChordType.major
                            }
                            if offset == 2 {
                                triadType = Chord.ChordType.diminished
                            }
                        }

                        var rootNote = score.key.firstScaleNote()+offset
                        
                        c2.makeTriad(root: rootNote, type: triadType)
                        var inversion = 0
                        if inversions {
                            inversion = Int.random(in: 0..<3)
                        }
                        print("offset", offset, "inversion", inversion)
                        c2 = c2.makeInversion(inv: inversion)
                        c2.move(index: 0)
                        if widen {
                            c2.notes[1].num += 12
                        }
                        bass = c2.notes[0].num
                        all = Note.getAllOctaves(note: bass)
                        bass = Note.getClosestNote(notes: all, to: 40 - 12)!
                        c2.notes.append(Note(num: bass))
                        c2.notes[3].staff = 1

                        ts.addChord(c: c2)
                        lastOffsets.append(offset)
                        if lastOffsets.count > 2 {
                            lastOffsets.removeFirst()
                        }
                        
                        ts = score.addTimeSlice()
                        ts.addChord(c: root)

                        score.setTempo(temp: Int(tempo))
                        score.play()
                        DispatchQueue.global(qos: .userInitiated).async {
                            degreeName = "?"
                            sleep(1)
                            //if span == queuedSpan {
                            let degree = scale.noteDegree(offset: offset)
                            degreeName = "\(degree) \(scale.degreeName(degree: degree)), Inv: \(inversion)"
                            //}
                        }
                    }

                    Spacer()
                    Button("Play") {
                        score.setTempo(temp: Int(tempo))
                        score.play()
                    }
                    
                    //Spacer()
                    Text(degreeName ?? "").font(.title)
                    
                    Spacer()
//                    Text(degreeName ?? "?")
//                    Button("Clear") {
//                        score.clear()
//                    }
                    HStack {
                        Button(action: {
                            inversions = !inversions
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: inversions ? "checkmark.square": "square")
                                Text("Inversions")
                            }
                        }
                        Button(action: {
                            widen = !widen
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: widen ? "checkmark.square": "square")
                                Text("Widen")
                            }
                        }
                    }

                    Spacer()
                    Button("Key") {
                        score.clear()
                        var newKey = score.key
                        while newKey == score.key {
                            let type = Int.random(in: 0..<2) < 1 ? KeySignatureAccidentalType.flats : KeySignatureAccidentalType.sharps
                            let accs = Int.random(in: 0..<4)
                            let keyType = Int.random(in: 0..<2) == 0 ? Key.KeyType.major : Key.KeyType.minor
                            newKey = Key(type: keyType, keySig: KeySignature(type: type, count: accs))
                        }
                        self.setKey(key: newKey!)
                    }
                    //Spacer()
                    HStack {
                        Text("Tempo").padding()
                        Slider(value: $tempo, in: 3...Double(score.maxTempo)).padding()
                    }
                }
            }
        }
//        .onAppear {
//            setKey(key: key)
//            score.setTempo(temp: Int(tempo))
//        }
    }

}


