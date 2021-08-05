import SwiftUI
import CoreData

struct ContentView: View {
    var system:System
    static let startPitch:Double = 40
    @State private var pitch: Double = startPitch
    @State private var tempo: Double = 8
    @State var notes:[Note] = []
    @State var ts = TimeSlice()
    
    init(system:System) {
        self.system = system
        system.staff.append(Staff(system: system, type: .treble))
        system.staff.append(Staff(system: system, type: .bass))
        setKey()
    }
    
    func setKey() {
        let key = KeySignature(type: KeySignatureType.flats, count: 0)
        system.setKey(key: key)
    }
    
    var body: some View {
        VStack {
            SystemView(system: system)
            VStack {
                Button("Play") {
                    system.setTempo(temp: Int(tempo))
                    system.play()
                }
                HStack {
                    Text("pitch")
                    Text("\(Int(pitch))")
                    Slider(value: $pitch, in: 17...108)
                }
                HStack {
                    Text("tempo")
                    Slider(value: $tempo, in: 5...10)
                }
                HStack {
                    Spacer()
                    Button("Up") {
                        self.pitch += 1
                        print(pitch)
                    }
                    Spacer()
                    Button("Down") {
                        self.pitch += -1
                        print(pitch)
                    }
                    Spacer()
                }
                Button("AddNote") {
                    ts.addNote(n: Note(num: Int(pitch), hand: HandType.right))
                    print("Added ", pitch)
                }
                
                Button("AddChord") {
                    system.addTimeSlice(ts: ts)
                    print("Added chord", ts.note.count)
                    ts = TimeSlice()
                }
                Spacer()
                HStack {
                    Button("Up_Scale") {
                        print("---")
                        for i in 0...12 {
                            ts = TimeSlice()
                            system.addTimeSlice(ts: ts)
                            ts.addNote(n: Note(num: Int(pitch), hand: HandType.right))
                            self.pitch += 1
                            print("Added scale", Int(pitch)+i, system.timeSlice.count)
                        }
                    }
                    Button("Down_Scale") {
                        print("---")
                        for i in 0...12 {
                            ts = TimeSlice()
                            system.addTimeSlice(ts: ts)
                            ts.addNote(n: Note(num: Int(pitch), hand: HandType.right))
                            self.pitch -= 1
                            print("Added scale", Int(pitch)+i, system.timeSlice.count)
                        }
                    }
                }
                Button("Clear") {
                    system.clear()
                    pitch = ContentView.startPitch
                }
            }
        }
        .padding()
        .onChange(of: tempo) { newValue in
            print("changed tempo", tempo)
            system.setTempo(temp: Int(tempo))

          }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
