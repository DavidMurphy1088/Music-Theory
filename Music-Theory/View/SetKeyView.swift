import SwiftUI
import CoreData
import MusicKit

struct SetKeyView : View {
    @Environment(\.scenePhase) var scenePhase
    @State var majorKeys = Key.allKeys(keyType: Key.KeyType.major)
    @State var minorKeys = Key.allKeys(keyType: Key.KeyType.minor)
    @State var keyNum = 0
    @State private var selectedMajorRow: Int?
    @State private var selectedMinorRow: Int?

    func keyDesc(k: Key) -> String {
        return k.description()
    }

    var body: some View {
        VStack {
            VStack {
                    
                List {
                    ForEach(0..<majorKeys.count) { index in
                        Toggle(isOn: Binding(
                            get: { selectedMajorRow == index },
                            set: { isSelected in
                                if isSelected {
                                    selectedMajorRow = index
                                    Key.currentKey = majorKeys[index]
                                } else {
                                    selectedMajorRow = nil
                                }
                            }
                        )) {
                            Text(keyDesc(k: majorKeys[index]))
                        }
                    }
                }
                
                List {
                    ForEach(0..<minorKeys.count) { index in
                        Toggle(isOn: Binding(
                            get: { selectedMinorRow == index },
                            set: { isSelected in
                                if isSelected {
                                    selectedMinorRow = index
                                    Key.currentKey = minorKeys[index]
                                } else {
                                    selectedMinorRow = nil
                                }
                            }
                        )) {
                            Text(keyDesc(k: minorKeys[index]))
                        }
                    }
                }

            }
        }
    }
}
