import SwiftUI
import CoreData

struct HarmonicAnalysisView: View {
    @State var score:Score
    @ObservedObject var staff:Staff
    @State var scale:Scale
    @State private var tempo: Double = 4
    @State private var pitchAdjust: Double = 0
    @State var degreeName:String?
    @State var queuedDegree = 0
    @State var lastOffsets:[Int] = []
    @State var inversions = false
    @State var widen = false

    init() {
        let score = Score()
        score.tempo = 8
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        let staff1 = Staff(score: score, type: .bass, staffNum: 1)
        score.setStaff(num: 0, staff: staff)
        score.setStaff(num: 1, staff: staff1)
        
        //score.key = Key(type: Key.KeyType.major, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 0))
        score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 0))
        //score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 2))
        
        self.score = score
        self.staff = staff
        //self.scale = Scale(key: score.key, minorType: Scale.MinorType.natural)
        //self.scale = Scale(key: score.key, minorType: Scale.MinorType.harmonic)
        self.scale = Scale(key: score.key, minorType: Scale.MinorType.natural)
    }

    var body: some View {
        HStack {
            VStack {
                ScoreView(score: score)
                .padding()
                Spacer()
                VStack {
//                    Button("Test") {
//                        score.clear()
//                        let root = Chord()
//                        root.notes.append(Note(num: 40))
//                        root.notes.append(Note(num: 47))
//                        let ts = score.addTimeSlice()
//                        ts.addChord(c: root)
//                        score.setTempo(temp: Int(tempo))
//                        score.play()
//                    }
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
                        //var offset = 0
//                        let diatonics = scale.diatonicOffsets()
//                        while true {
//                            offset = Int.random(in: 1..<12)
//                            if lastOffsets.contains(offset) {
//                                continue
//                            }
//                            if diatonics.contains(offset) {
//                               break
//                            }
//                        }
                        var scaleDegree = Int.random(in: 2..<8)
                        //scaleDegree = 4
                        ts = score.addTimeSlice()
                        var c2 = Chord()
                        var triadType = Chord.ChordType.major
                        if score.key.type == Key.KeyType.major {
                            let minors = [2,3,6]
                            if minors.contains(scaleDegree) {
                                triadType = Chord.ChordType.minor
                            }
                            if scaleDegree == 7 {
                                triadType = Chord.ChordType.diminished
                            }
                        }
                        else {
                            triadType = Chord.ChordType.minor
                            var majors = [3,6,7]
                            if scale.minorType == Scale.MinorType.harmonic {
                                majors.append(5)
                            }
                            if majors.contains(scaleDegree) {
                                triadType = Chord.ChordType.major
                            }
                            if scaleDegree == 2 {
                                triadType = Chord.ChordType.diminished
                            }
                        }

                        var rootNote = scale.notes[scaleDegree - 1]
                        
                        c2.makeTriad(root: rootNote.num, type: triadType)
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
                        lastOffsets.append(scaleDegree)
                        if lastOffsets.count > 2 {
                            lastOffsets.removeFirst()
                        }
                        
                        ts = score.addTimeSlice()
                        ts.addChord(c: root)

                        score.setTempo(temp: Int(tempo), pitch: Int(pitchAdjust))
                        score.play()
                        DispatchQueue.global(qos: .userInitiated).async {
                            degreeName = "?"
                            sleep(1)
                            //if span == queuedSpan {
                            //let degree = scale.noteDegree(offset: offset)
                            print("  offset", offset, "degree", scaleDegree)
                            degreeName = "\(scaleDegree) \(scale.degreeName(degree: scaleDegree)), Inv: \(inversion)"
                            //}
                        }
                    }

                    Spacer()
                    HStack {
                        Spacer()
                        Button("Play") {
                            score.setTempo(temp: Int(tempo), pitch: Int(pitchAdjust))
                            score.play()
                        }
                        Spacer()
                        Spacer()
                        Button("Degree") {
                            score.setTempo(temp: Int(tempo), pitch: Int(pitchAdjust))
                            score.play(select: [1])
                        }
                        Spacer()
                    }
                    
                    //Spacer()
                    Text(degreeName ?? "").font(.title3)
                    
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
                        var minorType:Scale.MinorType = Scale.MinorType.natural
                        if newKey.type == Key.KeyType.minor {
                            let r = Int.random(in: 0..<2)
                            minorType = r == 0 ? Scale.MinorType.natural : Scale.MinorType.harmonic
                        }
                        self.score.setKey(key: newKey, minorType: minorType)
                        self.scale = Scale(key: newKey, minorType: minorType)
                    }
                    //Spacer()
                    HStack {
                        Text("Tempo").padding()
                        Slider(value: $tempo, in: 4...Double(score.maxTempo)).padding()
                        Text("Pitch").padding()
                        Slider(value: $pitchAdjust, in: 0...Double(20)).padding()
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


