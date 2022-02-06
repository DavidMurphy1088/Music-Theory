import SwiftUI
import CoreData
import MessageUI
 
struct ScoreView: View {
    var score:Score
    
    var body: some View {
        //Text("sys:"+String(system.upd))
        ForEach(score.getStaff(), id: \.self.type) { staff in
            StaffView(score: score, staff: staff)
        }
    }
}
