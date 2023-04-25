import SwiftUI
import CoreData

struct DegreeView: View {
    @State var score:Score
    @ObservedObject var staff:Staff
    @State var scale:Scale
    @State private var pitchAdjust: Double = 0
    @State var degreeName:String?
    @State var queuedDegree = 0
    @State var degreeInversions = false
    @State var tonicInversion1 = false
    @State var tonicInversion2 = false
    @State var tonicSATB = false
    @State var widen = false
    @State var degreesSelected:[Int] = [0,0,0,1,1,0,0]
    @State var degreeNames:[String]
    @State var lastKey:Key?
    @State var playAsArpeggio:Bool = false
    @State var voiceLead = true
    @State var newKeyMajor = true
    @State var newKeyMinor = false
    @State var randomKey = false
    
    @State var lastDegreeChord:Chord?
    @State var lastTonicChord:Chord?

    init() {
        let score = Score()
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        let staff1 = Staff(score: score, type: .bass, staffNum: 1)
        score.setStaff(num: 0, staff: staff)
        score.setStaff(num: 1, staff: staff1)
        score.key = Key(type: Key.KeyType.major, keySig: KeySignature(type: AccidentalType.sharp, count: 0))
        //score.key = Key(type: Key.KeyType.major, keySig: KeySignature(type: AccidentalType.flat, count: 1))
        //score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 6))
        //score.key = Key(type: Key.KeyType.minor, keySig: KeySignature(type: AccidentalType.flat, count: 1))
        score.minorScaleType = Scale.MinorType.harmonic
        
        self.score = score
        self.staff = staff
        //self.scale = Scale(key: score.key, minorType: Scale.MinorType.natural)
        //self.scale = Scale(key: score.key, minorType: Scale.MinorType.harmonic)
        self.scale = Scale(score: score)
        self.degreeNames = ["I", "ii", "iii", "IV", "V", "vi", "viio"]
        lastKey = score.key
        score.tempo = Score.midTempo
    }
    
    func makeDegreeChord(scaleDegree : Int) -> Chord {
        //scaleDegree is 1 offset
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
        let rootNote = scale.notes[scaleDegree-1]
        let degreeChord = Chord()
        degreeChord.makeTriad(root: rootNote.num, type: triadType)
        if score.key.type == Key.KeyType.minor && scaleDegree == 3 && score.minorScaleType == Scale.MinorType.harmonic {
            degreeChord.notes[2].num += 1 //augmented
        }
        return degreeChord
    }
    
    func makeDegreeChords() {
        score.clear()
        if self.randomKey {
            if self.newKeyMajor && self.newKeyMinor {
                let r = Int.random(in: 0..<2)
                self.newKey(type: r == 0 ? Key.KeyType.major : Key.KeyType.minor)
            }
            else {
                if self.newKeyMajor {
                    self.newKey(type: Key.KeyType.major)
                }
                else {
                    self.newKey(type: Key.KeyType.minor)
                }
            }
        }

        var tonicChord = Chord()
        let chordType = score.key.type == Key.KeyType.major ? Chord.ChordType.major : Chord.ChordType.minor
        tonicChord.makeTriad(root: score.key.firstScaleNote(), type: chordType)
        
        if self.tonicInversion1 || self.tonicInversion2 {
            var inversion = 0
            if self.tonicInversion1 && self.tonicInversion2 {
                inversion = Int.random(in: 0..<3)
            }
            else {
                inversion = Int.random(in: 0..<2)
                if self.tonicInversion2 && inversion == 1{
                    inversion = 2
                }
            }
            tonicChord = tonicChord.makeInversion(inv: inversion)
            print("root inversion", inversion)
        }
        if self.tonicSATB {
            tonicChord = tonicChord.makeSATB()
        }
        var ts = score.addTimeSlice()
        ts.addChord(c: tonicChord)

        // make degree chord
        
        degreeName = nil
        var scaleDegree = 0
        var degreeChord:Chord?
        var inversion = 0
        
        while degreeChord == nil {
            while scaleDegree == 0 {
                let i = Int.random(in: 0..<7)
                if degreesSelected[i] == 0 {
                    continue
                }
                scaleDegree = i+1
                break
            }
            degreeChord = makeDegreeChord(scaleDegree: scaleDegree)
            if voiceLead {
                degreeChord = tonicChord.makeVoiceLead(to: degreeChord!)
            }
            else {
                if degreeInversions {
                    inversion = Int.random(in: 0..<3)
                    degreeChord = degreeChord!.makeInversion(inv: inversion)
                }
            }
            if tonicSATB {
                if lastTonicChord?.notes == tonicChord.notes && lastDegreeChord?.notes == degreeChord?.notes {
                    degreeChord = nil
                    continue
                }
            }
        }
        ts = score.addTimeSlice()
        ts.addChord(c: degreeChord!)
        ts = score.addTimeSlice()
        ts.addChord(c: tonicChord)
        self.lastDegreeChord = degreeChord
        self.lastTonicChord = tonicChord

        score.playScore(select: nil, arpeggio: self.playAsArpeggio)
        DispatchQueue.global(qos: .userInitiated).async {
            degreeName = "?"
            sleep(1)
            let invName = inversion == 0 ? "" : ", Inversion " + "\(inversion)"
            degreeName = "\(degreeNames[scaleDegree-1]) \(scale.degreeName(degree: scaleDegree)) \(invName)"
        }
    }
    
    func playDegree() {
        let chord:Chord = self.lastDegreeChord!
        score.playChord(chord: chord, arpeggio: playAsArpeggio)
    }
    func playTonic() {
        let chord:Chord = self.lastTonicChord!
        score.playChord(chord: chord, arpeggio: playAsArpeggio)
    }

    func writeScale(scale: Scale) {
        score.clear()
        for note in scale.notes {
            let ts = score.addTimeSlice()
            ts.addNote(n: note)
        }
        let hi = Note(num: scale.notes[0].num+12)
        let ts = score.addTimeSlice()
        ts.addNote(n:hi)
    }
    
    func writeScaleCromo(scale: Scale) {
        score.clear()
        let n = scale.notes[0].num
        for i in 0..<12 {
            let ts = score.addTimeSlice()
            let nt = Note(num:n+i)
            nt.staff = 0
            ts.addNote(n: nt)
        }
    }
    
    func newKey(type:Key.KeyType? = nil) {
        var newKey = score.key
        while newKey == score.key {
            let accType = Int.random(in: 0..<2) < 1 ? AccidentalType.flat : AccidentalType.sharp
            let keyType = Int.random(in: 0..<2) == 0 ? Key.KeyType.major : Key.KeyType.minor
            
            if !(self.newKeyMajor && self.newKeyMinor) {
                if self.newKeyMajor {
                    if keyType != Key.KeyType.major {
                        continue
                    }
                }
                else {
                    if self.newKeyMinor {
                        if keyType != Key.KeyType.minor {
                            continue
                        }
                    }
                }
            }

            let accCount = accType == AccidentalType.flat ? Int.random(in: 0..<7) : Int.random(in: 0..<5)
            let key = Key(type: keyType, keySig: KeySignature(type: accType, count: accCount))
            if key == lastKey {
                continue
            }
            newKey = key
        }

        var minorType:Scale.MinorType = Scale.MinorType.natural
        if newKey.type == Key.KeyType.minor {
            let r = Int.random(in: 0..<2)
            minorType = r == 0 ? Scale.MinorType.natural : Scale.MinorType.harmonic
            
        }
        self.score.setKey(key: newKey)
        self.score.minorScaleType = minorType
        self.scale = Scale(score: score)
        self.setDegreeNames()
    }
    
    func showDegreeSelect (i : Int) -> some View {
        HStack {
            Button(action: {
                degreesSelected[i] = degreesSelected[i] == 0 ? 1 : 0
            }) {
                HStack(spacing: 10) {
                    Image(systemName: degreesSelected[i]==1 ? "checkmark.square": "square")
                    Text("\(degreeNames[i])")
                }
            }
            Button(action: {
                score.playChord(chord: self.makeDegreeChord(scaleDegree: i+1), arpeggio: playAsArpeggio)
            }) {
                Image(systemName: "music.note")
            }
        }
    }
    
    var settings : some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    ForEach(0 ..< 4, id: \.self) { i in
                        showDegreeSelect(i: i)
                    }
                }
                Spacer()
                VStack {
                    ForEach(4 ..< 7, id: \.self) { i in
                        HStack {
                            showDegreeSelect(i: i)
                        }
                    }
                }
                Spacer()
            }
            Spacer()
            HStack {
                Button(action: {
                    tonicSATB = !tonicSATB
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: tonicSATB ? "checkmark.square": "square")
                        Text("Tonic SATB")
                    }
                }
                Button(action: {
                    tonicInversion1 = !tonicInversion1
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: tonicInversion1 ? "checkmark.square": "square")
                        Text("Inv #1")
                    }
                }
                Button(action: {
                    tonicInversion2 = !tonicInversion2
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: tonicInversion2 ? "checkmark.square": "square")
                        Text("Inv #2")
                    }
                }
            }

        }
    }
    
    var setNewKey : some View {
        VStack {
            Spacer()
            Button("New Key") {
                score.clear()
                self.newKey()
            }
            HStack {
                Spacer()
                Button(action: {
                    self.newKeyMajor = !self.newKeyMajor
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: self.newKeyMajor ? "checkmark.square": "square")
                        Text("\("Major")")
                    }
                }
                Spacer()
                Button(action: {
                    self.newKeyMinor = !self.newKeyMinor
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: self.newKeyMinor ? "checkmark.square": "square")
                        Text("\("Minor")")
                    }
                }
                Spacer()
            }
        }
    }
    
    var setRandomKeys : some View {
        VStack {
            Spacer()
            Spacer()
            Button(action: {
                self.randomKey = !self.randomKey
            }) {
                HStack(spacing: 10) {
                    Image(systemName: self.randomKey ? "checkmark.square": "square")
                    Text("\("Random Keys")")
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
                    makeDegreeChords()
                }
                .disabled(!someSelected())

                HStack {
                    Spacer()
                    Button("Play") {
                        score.playScore(select: nil, arpeggio: self.playAsArpeggio)
                    }
                    Spacer()
                    Button("Tonic") {
                        playTonic()
                    }
                    .disabled(self.lastDegreeChord == nil)
                    Button("Degree") {
                        playDegree()
                    }
                    .disabled(self.lastDegreeChord == nil)
                    Spacer()
                    Button("Scale") {
                        writeScale(scale: scale)
                    }
                    Spacer()
                    Button("Chromo") {
                        writeScaleCromo(scale: scale)
                    }
                    Spacer()
                }
                
                Text(degreeName ?? "").font(.title3)
                
                Spacer()
                settings
                
                setNewKey

                //Spacer()
                setRandomKeys
                                
                //Spacer()
                HStack {
                    Button(action: {
                        self.self.playAsArpeggio = !self.playAsArpeggio
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: self.playAsArpeggio ? "checkmark.square": "square")
                            Text("\("Arpeggio")")
                        }
                    }

                    Text("Tempo").padding()
                    Slider(value: $score.tempo, in: Score.minTempo...Score.maxTempo).padding()

                }
        }
    }
}

