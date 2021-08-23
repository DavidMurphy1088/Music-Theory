import SwiftUI
import CoreData

struct ChordView: View {
    @StateObject var system:System = System()

    init() {
    }
    
    func setKey(key:KeySignature) {
        //scale = Scale(key: key)
        system.setKey(key: key)
        system.setStaff(num: 0, staff: Staff(system: system, type: .treble))
    }
        
    var body: some View {
        HStack {
            VStack {
                SystemView(system: system)
                .padding()
                Spacer()
                VStack {
                    Button("Select") {
                        //makeInterval()
                    }
                    Spacer()
                    Button("Play") {
                        system.play()
                    }
                }
            }
        }
        .onAppear {
            let key = KeySignature(type: KeySignatureType.flats, count: 0)
            setKey(key: key)
        }
    }
    
}

