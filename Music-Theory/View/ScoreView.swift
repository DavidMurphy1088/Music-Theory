import SwiftUI
import CoreData
import MessageUI
 
struct ScoreView: View {
    @ObservedObject var score:Score
    
    var body: some View {
        VStack {
            Text("\(score.keyDesc())")//.font(.system(size: CGFloat(lineSpacing)))
            ForEach(score.getStaff(), id: \.self.type) { staff in
                StaffView(score: score, staff: staff)
                    .frame(height: CGFloat(score.staffLineCount * score.lineSpacing)) //fixed size of height for all staff lines + ledger lines
            }
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30).stroke(.blue, lineWidth: 2)
        )
        .background(Color.blue.opacity(0.04))
        //.foregroundColor(.white)

        //.frame(height: 12 + 2 * CGFloat(score.staffLineCount * score.lineSpacing))
    }
}
