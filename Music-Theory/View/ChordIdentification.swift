import SwiftUI
import CoreData

struct HarmonicAnalysisView: View {
    @State var score:Score
    @ObservedObject var staff:Staff
    @State var scale:Scale
    @State private var tempo: Double = 9
    @State private var pitchAdjust: Double = 0
    @State var degreeName:String?
    @State var queuedDegree = 0
    @State var lastOffsets:[Int] = []
    @State var inversions = false
    @State var widen = false
    @State var degreesSelected:[Int] = [0,0,0,1,1,0,0]
    @State var degreeNames:[String]
    @State var lastScaleDegree = 0
    @State var lastDegreeChord:Chord?
    
    init() {
        let score = Score()
        score.tempo = 8
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        let staff1 = Staff(score: score, type: .bass, staffNum: 1)
        score.setStaff(num: 0, staff: staff)
        score.setStaff(num: 1, staff: staff1)
        //score.key = Key(type: Key.KeyType.major, keySig: KeySignature(type: KeySignatureAccidentalType.sharps, count: 0))
        //score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 6))
        score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 0))
        score.minorScaleType = Scale.MinorType.harmonic
        
        self.score = score
        self.staff = staff
        //self.scale = Scale(key: score.key, minorType: Scale.MinorType.natural)
        //self.scale = Scale(key: score.key, minorType: Scale.MinorType.harmonic)
        self.scale = Scale(score: score)
        self.degreeNames = ["I", "ii", "iii", "IV", "V", "vi", "viio"]
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
            if degreesSelected[i] == 0 {
                continue
            }
            if !inversions && degreesSelected.filter({$0 == 1}).count > 1 {
                if i+1 == lastScaleDegree {
                    continue
                }
            }
            scaleDegree = i+1
            break
        }
        lastScaleDegree = scaleDegree
        
        //scaleDegree = 4
        ts = score.addTimeSlice()
        var degreeChord = Chord()
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
            if score.minorScaleType == Scale.MinorType.natural {
                if [3,6,7].contains(scaleDegree) {
                    triadType = Chord.ChordType.major
                }
                if [1,4,5].contains(scaleDegree) {
                    triadType = Chord.ChordType.minor
                }
                if [2].contains(scaleDegree) {
                    triadType = Chord.ChordType.diminished
                }
            }
            else {
                if [3,5,6].contains(scaleDegree) {
                    triadType = Chord.ChordType.major
                }
                if [1,4].contains(scaleDegree) {
                    triadType = Chord.ChordType.minor
                }
                if [2,7].contains(scaleDegree) {
                    triadType = Chord.ChordType.diminished
                }
            }
        }

        let rootNote = scale.notes[scaleDegree - 1]
        degreeChord.makeTriad(root: rootNote.num, type: triadType)
        self.lastDegreeChord = degreeChord
        if score.key.type == Key.KeyType.minor && scaleDegree == 3 && score.minorScaleType == Scale.MinorType.harmonic {
            //augmented
            degreeChord.notes[2].num += 1
        }
        var inversion = 0
        if inversions {
            inversion = Int.random(in: 0..<3)
        }

        //print("offset", offset, "inversion", inversion)
        degreeChord = degreeChord.makeInversion(inv: inversion)
        degreeChord.move(index: 0)
        if widen {
            degreeChord.notes[1].num += 12
        }
        bass = degreeChord.notes[0].num
        all = Note.getAllOctaves(note: bass)
        bass = Note.getClosestNote(notes: all, to: 40 - 12)!
        degreeChord.notes.append(Note(num: bass))
        degreeChord.notes[3].staff = 1

        ts.addChord(c: degreeChord)
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
            //print("  offset", offset, "degree", scaleDegree)
            let invName = inversion == 0 ? "root" : "inversion " + "\(inversion)"
            degreeName = "\(degreeNames[scaleDegree-1]) \(scale.degreeName(degree: scaleDegree)), \(invName)"
            //}
        }
    }
    
    func playDegree() {
        let chord:Chord = self.lastDegreeChord!

        score.play(select: [1])
        score.play(chord: chord)
    }
    
    func writeScale(scale: Scale) {
        score.clear()
        for note in scale.notes {
            let ts = score.addTimeSlice()
            ts.addNote(n: note)
            let lo = Note(num: note.num-24)
            lo.staff = 1
            ts.addNote(n: lo)
        }
        let hi = Note(num: scale.notes[0].num+12)
        let lo = Note(num: scale.notes[0].num-12)
        lo.staff = 1
        let ts = score.addTimeSlice()
        ts.addNote(n:hi)
        ts.addNote(n:lo)
        score.setTempo(temp: Int(tempo), pitch: Int(pitchAdjust))
    }

    var settings : some View {
        VStack {
        HStack {
            Spacer()
            VStack {
                ForEach(0 ..< 4, id: \.self) { i in
                    Button(action: {
                        degreesSelected[i] = degreesSelected[i] == 0 ? 1 : 0
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: degreesSelected[i]==1 ? "checkmark.square": "square")
                            Text("\(degreeNames[i])")
                        }
                    }
                }
            
            }
            Spacer()
            VStack {
                ForEach(4 ..< 7, id: \.self) { i in
                    Button(action: {
                        degreesSelected[i] = degreesSelected[i] == 0 ? 1 : 0
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: degreesSelected[i]==1 ? "checkmark.square": "square")
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
        for i in degreesSelected {
            if i>0 {
                return true
            }
        }
        return false
    }
    
    func setDegreeNames() {
        if score.key.type == Key.KeyType.major {
            self.degreeNames = ["I", "ii", "iii", "IV", "V", "vi", "viio"]
        }
        else {
            if score.minorScaleType == Scale.MinorType.natural {
                self.degreeNames = ["i  ", "iio ", "III ", "iv  ", "v   ", "VI  ", "VII "]
            }
            else {
                self.degreeNames = ["i  ", "iio ", "III+", "iv  ", "V   ", "VI  ", "viio"]
            }
        }
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
                    Button("Degree") {
                        score.setTempo(temp: Int(tempo), pitch: Int(pitchAdjust))
                        playDegree()
                    }
                    .disabled(self.lastDegreeChord == nil)
                    Spacer()
                    Button("Scale") {
                        score.setTempo(temp: Int(tempo), pitch: Int(pitchAdjust))
                        //makeChord()
                        writeScale(scale: scale)
                    }
                    Spacer()
                }
                
                Text(degreeName ?? "").font(.title3)
                
                Spacer()
                settings

                Spacer()
                Button("Key") {
                    score.clear()
                    if false {
                        //newKey = Key(type: score.keyType, keySig: KeySignature(type: accType, count: accCount))
                        //self.score.setKey(key: newKey)
                        self.score.minorScaleType = score.minorScaleType == Scale.MinorType.natural ? Scale.MinorType.harmonic : Scale.MinorType.natural
                        self.scale = Scale(score: score)
                        self.setDegreeNames()
                    }
                    else {
                        //while newKey == score.key {
                            let accType = Int.random(in: 0..<2) < 1 ? KeySignatureAccidentalType.flats : KeySignatureAccidentalType.sharps
                            let keyType = Int.random(in: 0..<2) == 0 ? Key.KeyType.major : Key.KeyType.minor
                            let accCount = accType == KeySignatureAccidentalType.flats ? Int.random(in: 0..<7) : Int.random(in: 0..<5)
                            let newKey = Key(type: keyType, keySig: KeySignature(type: accType, count: accCount))
                        //}

                        var minorType:Scale.MinorType = Scale.MinorType.natural
                        if newKey.type == Key.KeyType.minor {
                            let r = Int.random(in: 0..<2)
                            minorType = r == 0 ? Scale.MinorType.natural : Scale.MinorType.harmonic
                            
                        }
                        self.score.setKey(key: newKey)
                        print(newKey.keySig.sharps.count)
                        self.score.minorScaleType = minorType
                        self.scale = Scale(score: score)
                        self.setDegreeNames()
                    }
                    print("change key sharps:", score.key.keySig.sharps.count, score.key.keySig.flats.count, "type:", score.key.type, "scaleType:", score.minorScaleType)
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
//                    self.setDegreeNames()
//        }
    }

}


