import SwiftUI
import CoreData

class UICommons {
    static let buttonCornerRadius:Double = 20.0
    static let buttonPadding:Double = 8
}

struct UIHiliteText : View {
    @State var text:String
    var body: some View {
        Text(text)
        .foregroundColor(.black)
        .padding(UICommons.buttonPadding)
        .background(
            RoundedRectangle(cornerRadius: UICommons.buttonCornerRadius, style: .continuous).fill(Color.blue.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: UICommons.buttonCornerRadius, style: .continuous).strokeBorder(Color.blue, lineWidth: 1)
        )
        .padding()
    }
    
    
}
