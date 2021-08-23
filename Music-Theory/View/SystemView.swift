import SwiftUI
import CoreData
import MessageUI
 
struct SystemView: View {
    @ObservedObject var system:System
    
    var body: some View {
        ForEach(system.getStaff(), id: \.self) { staff in
            StaffView(system: system, staff: staff)
        }
    }
}
