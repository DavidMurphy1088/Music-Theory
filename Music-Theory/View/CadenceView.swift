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
    @State var newKeyMajor = true
    @State var newKeyMinor = false
    @State var lastKey:Key?
    @State var lastCadenceIndex:Int?

    @State var lastDegreeChord:Chord?
    @State var lastTonicChord:Chord?
    @State private var animationAmount = 1.0
    @State var answerWaitCounter = 0
    
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
    
    func makeNewKey(type:Key.KeyType? = nil) {
        score.clear()
        lastCadenceIndex = nil
        cadenceName = nil
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

//    func makeDegreeChord(scaleDegree : Int) -> Chord {
//        //scaleDegree is 1 offset
//        var triadType = Chord.ChordType.major
//        if score.key.type == Key.KeyType.major {
//            let minors = [2,3,6]
//            if minors.contains(scaleDegree) {
//                triadType = Chord.ChordType.minor
//            }
//            if scaleDegree == 7 {
//                triadType = Chord.ChordType.diminished
//            }
//        }
//        else {
//            triadType = Chord.ChordType.minor
//            if score.minorScaleType == Scale.MinorType.natural {
//                if [3,6,7].contains(scaleDegree) {
//                    triadType = Chord.ChordType.major
//                }
//                if [1,4,5].contains(scaleDegree) {
//                    triadType = Chord.ChordType.minor
//                }
//                if [2].contains(scaleDegree) {
//                    triadType = Chord.ChordType.diminished
//                }
//            }
//            else {
//                if [3,5,6].contains(scaleDegree) {
//                    triadType = Chord.ChordType.major
//                }
//                if [1,4].contains(scaleDegree) {
//                    triadType = Chord.ChordType.minor
//                }
//                if [2,7].contains(scaleDegree) {
//                    triadType = Chord.ChordType.diminished
//                }
//            }
//        }
//        let rootNote = scale.notes[scaleDegree-1]
//        let degreeChord = Chord()
//        degreeChord.makeTriad(root: rootNote.num, type: triadType)
//        if score.key.type == Key.KeyType.minor && scaleDegree == 3 && score.minorScaleType == Scale.MinorType.harmonic {
//            degreeChord.notes[2].num += 1 //augmented
//        }
//        return degreeChord
//    }
    
    func makeCadenceChords() {
        score.clear()

        let offsets = [(5,0), (7,0), (7,9), (2,7)]
        let names = ["Plagal","Perfect", "Interrupted (Deceptive)", "Half"]

        var cadenceIndex = 0
        while true {
            cadenceIndex = Int.random(in: 0..<offsets.count)
            if lastCadenceIndex == nil || cadenceIndex != lastCadenceIndex {
                break
            }
        }
        let offset = offsets[cadenceIndex]

        var secondChord = Chord()
//        var chordType2 = score.key.type == Key.KeyType.major ? Chord.ChordType.major : Chord.ChordType.minor
//        if offset.1 == 9 {
//            chordType2 = Chord.ChordType.minor
//        }
        var chordType2 = score.key.getTriadType(scaleOffset: offset.1)
        secondChord.makeTriad(root: score.key.firstScaleNote() + offset.1, type: chordType2)
        secondChord = secondChord.makeSATBFourNote()
        
        //var chordType1 = score.key.type == Key.KeyType.major ? Chord.ChordType.major : Chord.ChordType.minor
        var chordType1 = score.key.getTriadType(scaleOffset: offset.0)
        var firstChord = Chord()
        firstChord.makeTriad(root: score.key.firstScaleNote() + offset.0, type: chordType1)
        firstChord = firstChord.makeSATBFourNote()
        //cadenceChord.notes = [Note(num: 45, staff: 1)] //, Note(num: 49, staff: 1)]
        
        var ts = score.addTimeSlice()
        ts.addChord(c: firstChord)
        ts = score.addTimeSlice()
        ts.addChord(c: secondChord)
        self.lastDegreeChord = firstChord
        self.lastTonicChord = secondChord

        score.playScore(select: nil, arpeggio: self.playAsArpeggio)
        lastCadenceIndex = cadenceIndex
        
        DispatchQueue.global(qos: .userInitiated).async {
            cadenceName = ""
            answerWaitCounter = 0
            while answerWaitCounter < 4 { //8 
                Thread.sleep(forTimeInterval: 0.5)
                answerWaitCounter += 1
            }
            cadenceName = "\(names[cadenceIndex]) Cadence"
        }
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
                
                if cadenceName == "" {
                    Button(action: {
                        answerWaitCounter = 8
                        animationAmount = 1
                    }) {
                        Label(
                            title: { Text("") },
                            icon: {
                                Image("questionMark")
                                    .padding(16)
                                    .background(Color.blue.opacity(0.4))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(.blue)
                                            .scaleEffect(animationAmount)
                                            .opacity(2 - animationAmount)
                                            .opacity(1)
                                            .animation(
                                                .easeInOut(duration: 1)
                                                .repeatForever(autoreverses: false),
                                                value: animationAmount
                                            )
                                    )
                                    .onAppear {
                                        animationAmount += 1
                                    }
                                    .onDisappear() {
                                        animationAmount = 1
                                    }
                            }
                        )
                        .frame(width: 20, height: 20)
                    }
                    .padding()
                }
                else {
                    if let cadenceName = cadenceName {
                        UIHiliteText(text: cadenceName, answerMode: 1)
                    }
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        makeCadenceChords()
                    }) {
                        UIHiliteText(text: "Next Cadence")//.foregroundColor(.purple) //.font(.title)
                    }
                    
                    if lastCadenceIndex != nil {
                        Spacer()
                        Button(action: {
                            score.playScore(select: nil, arpeggio: self.playAsArpeggio)
                        }) {
                            UIHiliteText(text: "Play Again")//.foregroundColor(.purple) //.font(.title)
                        }
                    }
                    Spacer()
                }
                
                Button(action: {
                    makeNewKey()
                }) {
                    UIHiliteText(text: "Next Key")//.foregroundColor(.purple) //.font(.title)
                }
                
                Button(action: {
                    self.self.playAsArpeggio = !self.playAsArpeggio
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: self.playAsArpeggio ? "checkmark.square": "square")
                        Text("\("Arpeggio")")
                    }
                }
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


