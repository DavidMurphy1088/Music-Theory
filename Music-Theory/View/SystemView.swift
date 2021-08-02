import SwiftUI
import CoreData
import MessageUI
 
struct SystemView: View {
    var system:System
    
    var body: some View {
        ForEach(system.staff, id: \.self) { staff in
            StaffView(system: system, staff: staff)
        }
    }
}
