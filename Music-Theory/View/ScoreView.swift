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
                    //.border(Color.purple)
            }
        }
        .frame(height: 12 + 2 * CGFloat(score.staffLineCount * score.lineSpacing))
    }
}
