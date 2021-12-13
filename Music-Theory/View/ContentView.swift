import SwiftUI
import CoreData

//struct ContentView: View {
//    var score:Score = Score()
//    static let startPitch:Double = 40
//    @State private var pitch: Double = startPitch
//    @State private var tempo: Double = 8
//    @State var notes:[Note] = []
//    
//    init() {
//        let key = KeySignature(type: KeySignatureType.flats, count: 4)
//        score.setKey(key: key)
//        score.setStaff(num: 0, staff: Staff(system: score, type: .treble))
//        score.setStaff(num: 1, staff: Staff(system: score, type: .bass))
//    }
//    
//    var body: some View {
//        VStack {
//            ScoreView(score: score)
//            VStack {
//                Button("Play") {
//                    score.setTempo(temp: Int(tempo))
//                    score.play()
//                }
//                HStack {
//                    Text("pitch")
//                    Text("\(Int(pitch))")
//                    Slider(value: $pitch, in: 17...108)
//                }
//                HStack {
//                    Text("tempo")
//                    Slider(value: $tempo, in: 5...10)
//                }
//                HStack {
//                    Spacer()
//                    Button("Up") {
//                        self.pitch += 1
//                    }
//                    Spacer()
//                    Button("Down") {
//                        self.pitch += -1
//                    }
//                    Spacer()
//                }
//                Button("AddNote") {
//                    //ts.addNote(n: Note(num: Int(pitch), hand: HandType.right))
//                }
//                
//                Button("AddChord") {
//                    //system.addTimeSlice(ts: ts)
//                    ts = TimeSlice()
//                }
//                Button("AddScale") {
//                    let scale = Scale(key: KeySignature(type: KeySignatureType.sharps, count: 0))
//                    for note in scale.notes {
//                        ts = TimeSlice()
//                        //ts.addNote(n: note)
//                        //system.addTimeSlice(ts: ts)
//                    }
//                }
//                Spacer()
//                HStack {
//                    Button("Up_Scale") {
//                        for _ in 0...12 {
//                            ts = TimeSlice()
//                            //system.addTimeSlice(ts: ts)
//                            ts.addNote(n: Note(num: Int(pitch), hand: HandType.right))
//                            self.pitch += 1
//                        }
//                    }
//                    Button("Down_Scale") {
//                        for _ in 0...12 {
//                            ts = TimeSlice()
//                            //system.addTimeSlice(ts: ts)
//                            ts.addNote(n: Note(num: Int(pitch), hand: HandType.right))
//                            self.pitch -= 1
//                        }
//                    }
//                }
//                Button("Clear") {
//                    score.clear()
//                    pitch = ContentView.startPitch
//                }
//            }
//        }
//        .padding()
//        .onChange(of: tempo) { newValue in
//            //system.setTempo(temp: Int(tempo))
//          }
//    }
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
