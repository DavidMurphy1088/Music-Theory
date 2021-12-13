class Chord : Identifiable {
    var notes:[Int] = []
    
    init(key:KeySignature) {
        let f = key.firstScaleNote()
        let o = Note.getAllOctaves(note: f)
        let n = Note.getClosestNote(notes: o, to: 40)!
        notes.append(n)
        //notes.append(n + 4)
        //notes.append(n + 7)
        //notes.append(n + 12)
    }
}
