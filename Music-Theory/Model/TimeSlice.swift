import Foundation

class TimeSlice : ObservableObject, Hashable  {
    @Published var note:[Note]
    private static var idIndex = 0
    private var id = 0
    
    init() {
        self.note = []
        self.id = TimeSlice.idIndex
        TimeSlice.idIndex += 1
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(note)
    }
    
    func addNote(n:Note) {
        DispatchQueue.main.async {
            self.note.append(n)
        }
    }
    
    static func == (lhs: TimeSlice, rhs: TimeSlice) -> Bool {
        return lhs.id == rhs.id
    }
}
