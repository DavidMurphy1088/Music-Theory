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
        let pitch = Note.getClosestOctave(note: self.notes[index].num, toPitch: pitch)!
        let offset = self.notes[index].num - pitch
        for i in 0...self.notes.count-1 {
            self.notes[i].num -= offset
        }
    }
    
    func toStr() -> String {
        var s = ""
        for note in self.notes {
            //var n = (note.num % Note.noteNames.count)...
            s += "\(note.num)  "
        }
        return s
    }
    
    func makeVoiceLead(to:Chord) -> Chord {
        print("VoiceL")
        let result = Chord()
        var unusedPitches:[Int] = []
        for t in to.notes {
            unusedPitches.append(t.num)
        }
        var done:[Int] = []
        var log:[(Int, Int, Int)] = []
        
        // for each from chord note find the closest unused degree chord note
        
        while done.count < self.notes.count {
            var fromIdx = -1
            while true {
                fromIdx = Int.random(in: 0..<self.notes.count)
                if !done.contains(fromIdx) {
                    break
                }
            }
            var bestPitch = 0
            if unusedPitches.count > 0 {
                var minDiff = 1000
                var mi = 0
                for uindex in 0..<unusedPitches.count {
                    let closest = Note.getClosestOctave(note:unusedPitches[uindex], toPitch:notes[fromIdx].num)!
                    let diff = abs(closest - notes[fromIdx].num)
                    if diff < minDiff {
                        minDiff = diff
                        mi = uindex
                        bestPitch = closest
                    }
                }
                unusedPitches.remove(at: mi)
            }
            else {
                for t in to.notes {
                    unusedPitches.append(t.num+12)
                    unusedPitches.append(t.num-12)
                }
                continue
            }
            if bestPitch > 0 {
                let bestNote = Note(num: bestPitch)
                bestNote.staff = notes[fromIdx].staff
                result.notes.append(bestNote)
            }
            done.append(fromIdx)
            log.append((self.notes[fromIdx].num, bestPitch, done.count))
        }
        let ls = log.sorted {
            $0.0 < $1.1
        }
        for l in ls {
            print(l.0, " -> ", l.1, "\t(", "step:\(l.2)", ")")
        }
        result.order()
        return result
    }
    
    func order() {
        notes.sort {
            $0.num < $1.num
        }
    }
    
    //“SATB” refers to four-part chords scored for soprano (S), alto (A), tenor (T), and bass (B) voices. Three-part chords are often specified as SAB (soprano, alto, bass) but could be scored for any combination of the three voice types. SATB voice leading will also be referred to as “chorale-style” voice leading.
    func makeSATB() -> Chord {
        let result = Chord()
        var nextPitch = abs(Note.getClosestOctave(note: self.notes[0].num, toPitch: 40 - 12 - 3)!)
        for voice in 0..<4 {
            var bestPitch = 0
            var lowestDiff:Int? = nil
            for i in 0..<self.notes.count {
                let closestPitch = abs(Note.getClosestOctave(note: self.notes[i].num, toPitch: nextPitch)! )
                let diff = abs(closestPitch - nextPitch)
                if lowestDiff == nil || diff < lowestDiff! {
                    lowestDiff = diff
                    bestPitch = closestPitch
                }
            }
            let note = Note(num: bestPitch)
            if [0,1].contains(voice) {
                note.staff = 1
            }
            result.notes.append(note)
            if voice == 1 {
                nextPitch += 12
            }
            else {
                nextPitch += 8
            }
        }
        result.order()
        return result
    }
}
