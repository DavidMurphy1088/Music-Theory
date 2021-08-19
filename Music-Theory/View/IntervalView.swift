import SwiftUI
import CoreData

struct IntervalView: View {
    @ObservedObject var system:System
    static let startPitch:Double = 40
    @State private var pitch: Double = startPitch
    @State private var tempo: Double = 4
    @State var notes:[Note] = []
    @State var maxInterval: CGFloat = 10
    @State var isChecked:Bool = false
    @State var intervals = Intervals()
    @State var intName:String?
    @State var scale:Scale = Scale()
    
    init() {
        let key = KeySignature(type: KeySignatureType.sharps, count: 0)
        self.system = System(key: key)
        system.staff.append(Staff(system: system, type: .treble))
    }
    
    func toggle() {
        isChecked = !isChecked
    }

    var body: some View {
        HStack {
            VStack {
                SystemView(system: system)
                    //.frame(height: 200)
                    .padding()
                HStack {
                    Spacer()
                    Button("Play") {
                        system.setTempo(temp: Int(tempo))
                        system.play()
                    }
                    Spacer()
                    Text("tempo")
                    Slider(value: $tempo, in: 3...Double(system.maxTempo))
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button("Select") {
                        system.clear()
                        intName = nil
                        var r = Int.random(in: 0..<scale.notes.count)
                        var note1 = scale.notes[r]
                        let ts1 = TimeSlice()
                        ts1.addNote(n: note1)
                        let ts2 = TimeSlice()
                        r = Int.random(in: 0..<scale.notes.count)
                        var note2 = scale.notes[r]
                        //n += intervals.list[r].span
                        ts2.addNote(n: note2)
                        let span = abs(note2.num - note1.num)
                        system.addTimeSlice(ts: ts1)
                        system.addTimeSlice(ts: ts2)
                        DispatchQueue.global(qos: .userInitiated).async {
                            sleep(2)
                            intName = "\(span), "+(intervals.getName(span: span) ?? "none")
                        }
                    }
                    Spacer()
                    Text(intName ?? "")
                    Spacer()
                }

                Spacer()
            }
            VStack{
                ForEach(intervals.list) { interval in
                    Button(action: toggle){
                        Image(systemName: isChecked ? "checkmark.square": "square")
                        Text(interval.name)
                    }
                }
            }

        }
    }
}
