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
    
    func makeVoiceLead(to:Chord) -> Chord {
        print("\nVoiceL")
        let result = Chord()
        var unusedPitches:[Int] = []
        for t in to.notes {
            unusedPitches.append(t.num)
            unusedPitches.append(t.num+12)
        }
        // for each from chord note find the closest unused degree chord note
        for fromIdx in 0..<self.notes.count {
            var bestPitch = 0
            //print(fromIdx, bestPitch, "...unused", unusedPitches)
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
                //bestPitch = 52
            }
            if bestPitch > 0 {
                let bestNote = Note(num: bestPitch)
                bestNote.staff = notes[fromIdx].staff
                result.notes.append(bestNote)
            }
            print(fromIdx, self.notes[fromIdx].num, "->", bestPitch)
        }
        return result
    }
    
    //“SATB” refers to four-part chords scored for soprano (S), alto (A), tenor (T), and bass (B) voices. Three-part chords are often specified as SAB (soprano, alto, bass) but could be scored for any combination of the three voice types. SATB voice leading will also be referred to as “chorale-style” voice leading.
    func makeSATB() -> Chord {
        //find the best note for each range/voice
        let result = Chord()
        var indexesDone:[Int] = []
        var nextPitch = abs(Note.getClosestOctave(note: self.notes[0].num, toPitch: 40 - 12 - 3)!)
        
        for index in 0...self.notes.count {
            if index == 0 {
                let bassNote = Note(num: nextPitch)
                bassNote.staff = 1
                result.notes.append(bassNote)
                indexesDone.append(0)
                nextPitch += 8 - 2//Int.random(in: 0..<4)
                continue
            }
            //which range to put this next chord note?
            var lowestDiff:Int? = nil
            var bestPitch = 0
            
            for i in 0...self.notes.count-1 {
                if indexesDone.contains(i) {
                    continue
                }
                let closestPitch = abs(Note.getClosestOctave(note: self.notes[i].num, toPitch: nextPitch)! )
                let diff = abs(closestPitch - nextPitch)
                if lowestDiff == nil || diff < lowestDiff! {
                    lowestDiff = diff
                    bestPitch = closestPitch
                    //bestIdx = i
                }
            }
            let note = Note(num: bestPitch)
            if [0,1].contains(index) {
                note.staff = 1
            }
            result.notes.append(note)
            //done.append(bestIdx)
            //print("range", rng, "bestIdx", bestIdx, "done", done)
            nextPitch += 8
        }
        return result
    }
}
