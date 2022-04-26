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
    @State var degrees:[Int] = [0,0,0,1,1,0,0]
    @State var degreeNames:[String] = ["I", "ii", "iii", "IV", "V", "vi", "viio"]
    
    init() {
        let score = Score()
        score.tempo = 8
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        let staff1 = Staff(score: score, type: .bass, staffNum: 1)
        score.setStaff(num: 0, staff: staff)
        score.setStaff(num: 1, staff: staff1)
        score.key = Key(type: Key.KeyType.major, keySig: KeySignature(type: KeySignatureAccidentalType.sharps, count: 0))
        //score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 6))
        //score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 2))
        
        self.score = score
        self.staff = staff
        //self.scale = Scale(key: score.key, minorType: Scale.MinorType.natural)
        //self.scale = Scale(key: score.key, minorType: Scale.MinorType.harmonic)
        self.scale = Scale(key: score.key, minorType: Scale.MinorType.natural)
    }
    
    func makeChord() {
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

        var scaleDegree = 0
        while scaleDegree == 0 {
            let i = Int.random(in: 0..<7)
            if degrees[i] == 1 {
                scaleDegree = i+1
                break
            }
        }
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
            let invName = inversion == 0 ? "root" : "inversion " + "\(inversion)"
            degreeName = "\(degreeNames[scaleDegree-1]) \(scale.degreeName(degree: scaleDegree)), \(invName)"
            //}
        }
    }
    
    var settings : some View {
        VStack {
        HStack {
            Spacer()
            VStack {
                ForEach(0 ..< 4, id: \.self) { i in
                    Button(action: {
                        degrees[i] = degrees[i] == 0 ? 1 : 0
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: degrees[i]==1 ? "checkmark.square": "square")
                            Text("\(degreeNames[i])")
                        }
                    }
                }
            
            }
            Spacer()
            VStack {
                ForEach(4 ..< 7, id: \.self) { i in
                    Button(action: {
                        degrees[i] = degrees[i] == 0 ? 1 : 0
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: degrees[i]==1 ? "checkmark.square": "square")
                            Text("\(degreeNames[i])")
                        }
                    }
                }
            }
            Spacer()
        }
        Spacer()
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
    }
    }

    func someSelected() -> Bool{
        for i in degrees {
            if i>0 {
                return true
            }
        }
        return false
    }
    
    var body: some View {
        //NavigationView {
            
            VStack {
                Spacer()
                ScoreView(score: score)
                Button("Make Degree") {
                    makeChord()
                }
                .disabled(!someSelected())

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
                
                Text(degreeName ?? "").font(.title3)
                
                Spacer()
                settings

                Spacer()
                Button("Key") {
                    score.clear()
                    var newKey = score.key
                    while newKey == score.key {
                        let accType = Int.random(in: 0..<2) < 1 ? KeySignatureAccidentalType.flats : KeySignatureAccidentalType.sharps
                        let keyType = Int.random(in: 0..<2) == 0 ? Key.KeyType.major : Key.KeyType.minor
                        let accCount = accType == KeySignatureAccidentalType.flats ? Int.random(in: 0..<7) : Int.random(in: 0..<5)
                        newKey = Key(type: keyType, keySig: KeySignature(type: accType, count: accCount))
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
//                    VStack {
//                        NavigationLink(destination: DegreesSelect()) {
//                            Text("Select Degrees")
//                        }
//                        .navigationTitle("Chord Identification")
//                        .navigationBarTitleDisplayMode(.inline)
//                    }
            //}
        }
//        .onAppear {
//            setKey(key: key)
//            score.setTempo(temp: Int(tempo))
//        }
    }

}


