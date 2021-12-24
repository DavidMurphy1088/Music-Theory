import SwiftUI
import CoreData

struct TriadView: View {
    @State var score:Score
    @ObservedObject var staff:Staff
    @State var scale:Scale!
    @State private var tempo: Double = 3
    @State var key = Key(type: Key.KeyType.major, keySig: KeySignature(type: KeySignatureType.flats, count: 0))

    init() {
        let score = Score()
        score.tempo = 8
        let staff = Staff(score: score, type: .treble)
        score.setStaff(num: 0, staff: staff)
        self.score = score
        self.staff = staff
        
    }

    func setKey(key:Key) {
        self.score.setKey(key: key)
        self.scale = Scale(key: key)
    }

    var body: some View {
        HStack {
            VStack {
                ScoreView(score: score)
                .padding()
                Spacer()
                VStack {
                    Button("Make Triad") {
                        let ts1 = score.addTimeSlice()
                        let c1 = Chord()
                        c1.makeTriad(root: key.firstScaleNote(), type: Chord.ChordType.major)
                        ts1.addChord(c: c1)
                        var offset = 0
                        let diatonics = scale.diatonicNotes()
                        while true {
                            offset = Int.random(in: 1..<12)
                            //print("  OFF", offset)
                            if diatonics.contains(offset) {
                               break
                            }
                        }
                        print("OFF", offset)
                        let ts2 = score.addTimeSlice()
                        let c2 = Chord()
                        //let degree = scale.noteDegree(offset: offset)
                        var triadType = Chord.ChordType.major
                        if key.type == Key.KeyType.major {
                            let minors = [2,4,9]
                            if minors.contains(offset) {
                                triadType = Chord.ChordType.minor
                            }
                            if offset == 11 {
                                triadType = Chord.ChordType.diminished
                            }
                        }
                        c2.makeTriad(root: key.firstScaleNote()+offset, type: triadType)
                        ts2.addChord(c: c2)
                    }

                    Spacer()
                    Button("Play") {
                        score.setTempo(temp: Int(tempo))
                        score.play()
                    }
                    Spacer()
                    Button("Clear") {
                        score.clear()
                    }
                    Spacer()
                    HStack {
                        Text("Tempo").padding()
                        Slider(value: $tempo, in: 3...Double(score.maxTempo)).padding()
                    }
                }
            }
        }
        .onAppear {
            setKey(key: key)
        }
    }

}

