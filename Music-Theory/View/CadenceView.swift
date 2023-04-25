import SwiftUI
import CoreData

struct CadenceView: View {
    @State var score:Score
    @ObservedObject var staff:Staff
    @State var scale:Scale
    @State private var pitchAdjust: Double = 0
    @State var cadenceName:String?
    @State var queuedDegree = 0
    @State var widen = false
    @State var degreeNames:[String]
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
        score.key = Key.currentKey //Key(type: Key.KeyType.major, keySig: KeySignature(type: AccidentalType.sharp, count: 0))
        score.minorScaleType = Scale.MinorType.harmonic
        
        self.score = score
        self.staff = staff
        self.scale = Scale(score: score)
        self.degreeNames = ["I", "ii", "iii", "IV", "V", "vi", "viio"]
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
    
    func makeCadenceChords() {
        score.clear()

        var tonicChord = Chord()
        let chordType = score.key.type == Key.KeyType.major ? Chord.ChordType.major : Chord.ChordType.minor
        tonicChord.makeTriad(root: score.key.firstScaleNote(), type: chordType)
        tonicChord = tonicChord.makeOpen()
        
        cadenceName = nil
        let index = Int.random(in: 0..<2)
        let offsets = [5,7]
        let names = ["Plagal","Perfect"]
        let offset = offsets[index]
        var cadenceChord = Chord()
        cadenceChord.makeTriad(root: score.key.firstScaleNote() + offset, type: chordType)
        
//        if voiceLead {
//            cadenceChord = tonicChord.makeVoiceLead(to: cadenceChord!)
//        }

//            if tonicSATB {
//                if lastTonicChord?.notes == tonicChord.notes && lastDegreeChord?.notes == cadenceChord?.notes {
//                    cadenceChord = nil
//                    continue
//                }
//            }
//        
        var ts = score.addTimeSlice()
        ts.addChord(c: cadenceChord)
        ts = score.addTimeSlice()
        ts.addChord(c: tonicChord)
        self.lastDegreeChord = cadenceChord
        self.lastTonicChord = tonicChord

        score.playScore(select: nil, arpeggio: self.playAsArpeggio)
        DispatchQueue.global(qos: .userInitiated).async {
            cadenceName = "?"
            sleep(1)
            //let invName = inversion == 0 ? "" : ", Inversion " + "\(inversion)"
            cadenceName = "\(names[index]) Cadence"
        }
    }
    
//    func playDegree() {
//        let chord:Chord = self.lastDegreeChord!
//        score.playChord(chord: chord, arpeggio: playAsArpeggio)
//    }
//    func playTonic() {
//        let chord:Chord = self.lastTonicChord!
//        score.playChord(chord: chord, arpeggio: playAsArpeggio)
//    }

//    func writeScale(scale: Scale) {
//        score.clear()
//        for note in scale.notes {
//            let ts = score.addTimeSlice()
//            ts.addNote(n: note)
//        }
//        let hi = Note(num: scale.notes[0].num+12)
//        let ts = score.addTimeSlice()
//        ts.addNote(n:hi)
//    }
//
//    func writeScaleCromo(scale: Scale) {
//        score.clear()
//        let n = scale.notes[0].num
//        for i in 0..<12 {
//            let ts = score.addTimeSlice()
//            let nt = Note(num:n+i)
//            nt.staff = 0
//            ts.addNote(n: nt)
//        }
//    }
    
//    func newKey(type:Key.KeyType? = nil) {
//        var newKey = score.key
//        while newKey == score.key {
//            let accType = Int.random(in: 0..<2) < 1 ? AccidentalType.flat : AccidentalType.sharp
//            let keyType = Int.random(in: 0..<2) == 0 ? Key.KeyType.major : Key.KeyType.minor
//            
//            if !(self.newKeyMajor && self.newKeyMinor) {
//                if self.newKeyMajor {
//                    if keyType != Key.KeyType.major {
//                        continue
//                    }
//                }
//                else {
//                    if self.newKeyMinor {
//                        if keyType != Key.KeyType.minor {
//                            continue
//                        }
//                    }
//                }
//            }
//
//            let accCount = accType == AccidentalType.flat ? Int.random(in: 0..<7) : Int.random(in: 0..<5)
//            let key = Key(type: keyType, keySig: KeySignature(type: accType, count: accCount))
//            if key == lastKey {
//                continue
//            }
//            newKey = key
//        }
//
//        var minorType:Scale.MinorType = Scale.MinorType.natural
//        if newKey.type == Key.KeyType.minor {
//            let r = Int.random(in: 0..<2)
//            minorType = r == 0 ? Scale.MinorType.natural : Scale.MinorType.harmonic
//            
//        }
//        self.score.setKey(key: newKey)
//        self.score.minorScaleType = minorType
//        self.scale = Scale(score: score)
//        self.setDegreeNames()
//    }
    
//    func showDegreeSelect (i : Int) -> some View {
//        HStack {
//            Button(action: {
//                cadencesSelected[i] = cadencesSelected[i] == 0 ? 1 : 0
//            }) {
//                HStack(spacing: 10) {
//                    Image(systemName: cadencesSelected[i]==1 ? "checkmark.square": "square")
//                    Text("\(degreeNames[i])")
//                }
//            }
//            Button(action: {
//                score.playChord(chord: self.makeDegreeChord(scaleDegree: i+1), arpeggio: playAsArpeggio)
//            }) {
//                Image(systemName: "music.note")
//            }
//        }
//    }
//
//    func someSelected() -> Bool{
//        for i in cadencesSelected {
//            if i>0 {
//                return true
//            }
//        }
//        return false
//    }
    
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
    
    func setKey(key:Key) {
        score.setKey(key: key)
        scale = Scale(score: score)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScoreView(score: score).padding()
                .onAppear {
                    setKey(key: Key.currentKey)
                }
                
                Button(action: {
                    makeCadenceChords()
                }) {
                    UIHiliteText(text: "Next Cadence")//.foregroundColor(.purple) //.font(.title)
                }
                .padding()
                //.disabled(!someSelected())
                Text(cadenceName ?? "").font(.title3)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SetKeyView()) {
                        UIHiliteText(text: "Change Key")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    UIHiliteText(text: "Tempo")
                }
            }
        }
    }
}


