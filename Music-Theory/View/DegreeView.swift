import SwiftUI
import CoreData

struct DegreeView: View {
    @State var score:Score
    @ObservedObject var staff:Staff
    @State var scale:Scale
    @State private var tempo: Double = 3
    @State var degreeName:String?
    @State var queuedDegree = 0
    @State var lastOffsets:[Int] = []
    
    init() {
        let score = Score()
        score.tempo = 8
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        let staff1 = Staff(score: score, type: .bass, staffNum: 1)
        score.setStaff(num: 0, staff: staff)
        score.setStaff(num: 1, staff: staff1)
        score.key = Key(type: Key.KeyType.major, keySig: KeySignature(type: KeySignatureAccidentalType.flats, count: 0))
        self.scale = Scale(key: score.key)
        self.score = score
        self.staff = staff
    }

    func setKey(key:Key) {
        self.score.setKey(key: key, minorType: Scale.MinorType.natural)
        //let x = Scale(key: key)
        self.scale = Scale(key: key)
    }

//    func establishKey() {
//        //https://livingpianos.com/how-to-establish-the-key/
//        let root = Chord()
//        root.makeTriad(root: key.firstScaleNote(), type: Chord.ChordType.major)
//        root.notes.append(Note(num: key.firstScaleNote()-12))
//        root.notes[3].staff = 1
//
//        let ts = score.addTimeSlice()
//        ts.addChord(c: root)
//    }
    
    var body: some View {
        NavigationView {


            HStack {
                VStack {
                    ScoreView(score: score)
                    .padding()
                    Spacer()
                    VStack {
                        Button("Make Degree") {
                            score.clear()
                            let root = Chord()
                            let chordType = score.key.type == Key.KeyType.major ? Chord.ChordType.major : Chord.ChordType.minor
                            root.makeTriad(root: score.key.firstScaleNote(), type: chordType)
                            //root.notes.append(Note(num: key.firstScaleNote()-12))
                            //root.notes[3].staff = 1
                            root.notes[1].num += 12
                            
                            var ts = score.addTimeSlice()
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
                            ts = score.addTimeSlice()
                            var c2 = Chord()
                            //let degree = scale.noteDegree(offset: offset)
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
                            c2.makeTriad(root: score.key.firstScaleNote()+offset, type: triadType)
                            c2 = c2.makeInversion(inv: 1)
                            //c2.notes[0].num -= 12
                            //c2.notes[0].staff = 1
                            c2.notes.append(Note(num: c2.notes[0].num-12))
                            c2.notes[3].staff = 1
                            //c2.notes[1].num += 12
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
                                degreeName = "\(degree) \(scale.degreeName(degree: degree))"
                                //}
                            }
                        }

                        Spacer()
                        Button("Play") {
                            score.setTempo(temp: Int(tempo))
                            score.play()
                        }
                        Spacer()
                        Text(degreeName ?? "?")
                        Button("Clear") {
                            score.clear()
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
                            self.setKey(key: newKey)
                        }
                        Spacer()
                        HStack {
                            Text("Tempo").padding()
                            Slider(value: $tempo, in: 3...Double(score.maxTempo)).padding()
                        }

                    }
                }
            }

        }
    }
}

