import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var staff:Staff
    static let startPitch:Double = 40 + 14
    @State private var pitch: Double = startPitch
    @State private var tempo: Double = 8
    @State var notes:[Note] = []
    @State var ts = TimeSlice()
    let w = CGFloat(100)
    
    init() {
        //let notes:[Note] = [Note(num: 40)] //, Note(num: 44), Note(num: 45), Note(num: 47), Note(num: 49), Note(num: 51),  Note(num: 52), Note(num: 54), Note(num: 56)]
        staff = Staff(type: .all)
        setKey()
    }
    
    func setKey() {
        let key = KeySignature(type: KeySignatureType.flats, count: 0)
        staff.setKey(key: key)
    }
    
    var body3: some View {
        Text("Hello, World!")
            .background(Color.red)
            .border(Color .green)
            .padding()
    }
    
    var body33: some View {
        VStack {
            ZStack (alignment: .center) {
                //VStack {
                Rectangle()
                    .fill(Color.pink)
                    .frame(width: w+20, height: 2, alignment: .center)
                    .offset(y: 0-w/2)
               // }
                
                Text("XXXX.......XXXX")
                    //.frame(width: w*2, height: w*2, alignment: .top)
                    .border(Color.purple)
                    
//                Text("mmm")
//                    //.frame(width: w*2, height: w*2, alignment: .top)
//                    .border(Color.purple)
                    
                Ellipse()
                    .foregroundColor(.blue)
                    .frame(width: w, height: w, alignment: .center)
                    //.border(Color.green)
            }
            .frame(alignment: .top)
        }
        .border(Color.green)
        //.position(x: CGFloat(4), y: CGFloat(100))
        .frame(alignment: .leading)

    }

    var body: some View {
        VStack {
            StaffView(staff: staff)
            VStack {
                Button("Play") {
                    staff.setTempo(temp: Int(tempo))
                    staff.play()
                }
                HStack {
                    Text("pitch")
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
                    staff.addTimeSlice(ts: ts)
                    print("Added chord", ts.note.count)
                    ts = TimeSlice()
                }
                Spacer()
                HStack {
                    Button("Up_Scale") {
                        print("---")
                        for i in 0...15 {
                            ts = TimeSlice()
                            staff.addTimeSlice(ts: ts)
                            ts.addNote(n: Note(num: Int(pitch+Double(i)), hand: HandType.right))
                            print("Added scale", Int(pitch)+i, staff.timeSlice.count)
                        }
                    }
                    Button("Down_Scale") {
                        print("---")
                        for i in 0...7 {
                            ts = TimeSlice()
                            staff.addTimeSlice(ts: ts)
                            ts.addNote(n: Note(num: Int(pitch-Double(i)), hand: HandType.right))
                            print("Added scale", Int(pitch)+i, staff.timeSlice.count)
                        }
                    }
                }
                Button("Clear") {
                    staff.clear()
                    pitch = ContentView.startPitch
                }
            }
        }
        .padding()
        .onChange(of: tempo) { newValue in
            print("changed tempo", tempo)
            staff.setTempo(temp: Int(tempo))

          }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
