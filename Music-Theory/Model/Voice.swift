import Foundation

//class Voice : ObservableObject  {
//    //@Published
//    var notes:[Note]
//    static var nextId = 0
//    var id = 0
//    var staff:Staff
//    
//    init(staff:Staff) {
//        Voice.nextId += 1
//        self.id = Voice.nextId
//        self.notes = []
//        self.staff = staff
//    }
//
//    func addNote(note:Note) {
//        self.notes.append(note)
//        print("Voice added note", note.num, "noes:", self.notes.count)
//        staff.update()
//    }
//    
////    func hash(into hasher: inout Hasher) {
////        hasher.combine(notes)
////    }
////    
////    static func == (lhs: Voice, rhs: Voice) -> Bool {
////        return true
////    }
//}
