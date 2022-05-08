class Chord : Identifiable {
    var notes:[Note] = []
    
    enum ChordType {
        case major
        case minor
        case diminished
    }
    
    init() {
    }
    
    func makeTriad(root: Int, type:ChordType) {
        notes.append(Note(num: root))
        if type == ChordType.major {
            notes.append(Note(num: root+4))
        }
        else {
            notes.append(Note(num: root+3))
        }
        if type == ChordType.diminished {
            notes.append(Note(num: root+6))
        }
        else {
            notes.append(Note(num: root+7))
        }
    }
    
    func addSeventh() {
        let n = self.notes[0].num
        self.notes.append(Note(num: n+10))
    }
    
    func makeInversion(inv: Int) -> Chord {
        let res = Chord()
        for i in 0...self.notes.count-1 {
            let j = (i + inv)
            var n = self.notes[j % self.notes.count].num
            if j >= self.notes.count {
                n += 12
            }
            res.notes.append(Note(num: n))
        }
        return res
    }
    
    func moveClosestTo(pitch: Int, index: Int) {
        let octaves = Note.getAllOctaves(note: self.notes[index].num)
        let pitch = Note.getClosestPitch(pitches: octaves, toPitch: pitch)!
        let offset = self.notes[index].num - pitch
        for i in 0...self.notes.count-1 {
            self.notes[i].num -= offset
        }
    }
    
    // order lowest to highest pitch
    func order() {
        self.notes.sort()
    }
    
    func toStr() -> String {
        var s = ""
        for note in self.notes {
            //var n = (note.num % Note.noteNames.count)...
            s += "\(note.num)  "
        }
        return s
    }
    //“SATB” voice leading refers to four-part chords scored for soprano (S), alto (A), tenor (T), and bass (B) voices. Three-part chords are often specified as SAB (soprano, alto, bass) but could be scored for any combination of the three voice types. SATB voice leading will also be referred to as “chorale-style” voice leading.
    func makeSATB() -> Chord {
        //find the best note for each range/voice
        print("\nSATB", self.toStr())
        let result = Chord()
        var indexesDone:[Int] = []
        let octaves = Note.getAllOctaves(note: self.notes[0].num)
        var nextPitch = abs(Note.getClosestPitch(pitches: octaves, toPitch: 40 - 12 - 3)!)
        
        for rng in 0...self.notes.count {
            if rng == 0 {
                let bassNote = Note(num: nextPitch)
                bassNote.staff = 1
                result.notes.append(bassNote)
                indexesDone.append(0)
                nextPitch += 8 - Int.random(in: 0..<4)
                continue
            }
            //which range to put this next chord note?
            var lowestDiff:Int? = nil
            var bestPitch = 0
            
            for i in 0...self.notes.count-1 {
                if indexesDone.contains(i) {
                    continue
                }
                let octaves = Note.getAllOctaves(note: self.notes[i].num)
                let closestPitch = abs(Note.getClosestPitch(pitches: octaves, toPitch: nextPitch)! )
                let diff = abs(closestPitch - nextPitch)
                if lowestDiff == nil || diff < lowestDiff! {
                    lowestDiff = diff
                    bestPitch = closestPitch
                    //bestIdx = i
                }
            }
            let note = Note(num: bestPitch)
            if [0,1].contains(rng) {
                note.staff = 1
            }
            result.notes.append(note)
            //done.append(bestIdx)
            //print("range", rng, "bestIdx", bestIdx, "done", done)
            nextPitch += 8
        }
        print("SATB->", result.toStr())
        return result
    }
}
