import Foundation
import AVKit
import AVFoundation

//https://mammothmemory.net/music/sheet-music/reading-music/treble-clef-and-bass-clef.html

enum StaffType {
    case treble
    case bass
}

class StaffPosition {
    var staffOffsetFromBottom:Int
    var positionOffset:Int
    var name:Character?
    
    init (staffOffset: Int, posOffset:Int, name:Character? = nil) {
        self.staffOffsetFromBottom = staffOffset
        self.positionOffset = posOffset
        self.name = name
    }
    
    func noteName() -> String {
        if let name = name {
            var nm:String = "\(name)"
            if positionOffset > 0 {
                nm = nm + System.accSharp
            }
            return nm
        }
        return ""
    }
    
    func move(up:Bool) {
        if up {
            if positionOffset < 1 {
                positionOffset = 1
                return
            }
            let nameIndex = Note.noteNames.firstIndex(of: name!)
            name = Note.noteName(idx: nameIndex!+1)
            staffOffsetFromBottom += 1
            positionOffset = 0
        }
        else {
            if positionOffset > 0 {
                positionOffset = 0
                return
            }
            let nameIndex = Note.noteNames.firstIndex(of: name!)
            name = Note.noteName(idx: nameIndex!-1)
            staffOffsetFromBottom -= 1
            positionOffset = 1
        }
    }
}

class Staff : ObservableObject, Hashable  {
    let system:System
    var type:StaffType
    var noteOffsets:[StaffPlacementsByKey] = []
    let linesInStaff = 5
    var lowestNoteValue:Int
    var lowestNoteNameIdx:Int
    var highestNoteValue:Int
    var key:KeySignature
    var staffOffsets:[Int] = []
    var offsetStart:Int

    init(system:System, type:StaffType) {
        self.system = system
        self.key = system.key
        self.type = type
        lowestNoteValue = 0
        highestNoteValue = 88
        //              C C D D E F F G G A A B
        staffOffsets = [1,0,1,0,1,1,0,1,0,1,0,1]
        offsetStart = 0
        lowestNoteNameIdx = 0
        
        if type == StaffType.treble {
            if system.ledgerLineCount == 0 {
                lowestNoteValue = 44
                offsetStart = 4
                lowestNoteNameIdx = 4
            }
            if system.ledgerLineCount == 1 {
                lowestNoteValue = 40
                offsetStart = 0
                lowestNoteNameIdx = 2
            }
            if system.ledgerLineCount == 2 {
                lowestNoteValue = 37
                offsetStart = 9
                lowestNoteNameIdx = 0
            }
            if system.ledgerLineCount == 3 {
                lowestNoteValue = 33
                offsetStart = 5
                lowestNoteNameIdx = 5
            }
        }
        else {
            if system.ledgerLineCount == 0 {
                lowestNoteValue = 23
                offsetStart = 7
                lowestNoteNameIdx = 6
            }
            if system.ledgerLineCount == 1 {
                lowestNoteValue = 20
                offsetStart = 4
                lowestNoteNameIdx = 4
            }
            if system.ledgerLineCount == 2 {
                lowestNoteValue = 16
                offsetStart = 0
                lowestNoteNameIdx = 2
            }
            if system.ledgerLineCount == 3 {
                lowestNoteValue = 13
                offsetStart = 9
                lowestNoteNameIdx = 0
            }
        }
        noteOffsets = []
        //createNoteOffsets()
        
        //setNoteAccidentals()
        //show(lbl: "accidl")
    }
    
    
//    func show(lbl:String) {
//        print("")
//        for n in stride(from: noteOffsets.count-1, to: 0, by: -1) {
//            let sp = noteOffsets[n]
//            if !sp.noteName().isEmpty {
//                print("\(lbl) Note", n, "(\(sp.staffOffsetFromBottom),\(sp.positionOffset))\t", "name:\(sp.noteName())")
//            }
//        }
//    }
    
//    func adjustForKey() {
//        for a in 0..<key.accidentalCount {
//            if system.key.type == KeySignatureType.sharps {
//                let note = system.key.sharps[a]
//                for i in 0...1 {
//                    let all = Note.getAllOctaves(staff: self, note: note+i)
//                    for a in all {
//                        let sp = self.noteOffsets[a]
//                        sp.move(up: false)
//                    }
//                }
//            }
//            else {
//                let note = system.key.flats[a]
//                for i in 0...1 {
//                    let all = Note.getAllOctaves(staff: self, note: note-i)
//                    for a in all {
//                        let sp = self.noteOffsets[a]
//                        sp.move(up: true)
//                    }
//                }
//            }
//        }
//    }
    
//    func createNoteOffsets() {
//        noteOffsets = [StaffPosition](repeating: StaffPosition(staffOffset: 0, posOffset: 0), count: highestNoteValue + 1)
//        var last:Int?
//        last = nil
//        var staffOffset = 0
//        var nameOffset = self.lowestNoteNameIdx
//        
//        for n in 0...(highestNoteValue-lowestNoteValue) {
//            let note = lowestNoteValue + n
//            let offset = n==0 ? 0 : staffOffsets[(offsetStart + n) % staffOffsets.count]
//            staffOffset += offset
//
//
//            var posOffset = 0
//            if last != nil {
//                if offset == 0 {
//                    posOffset = 1
//                }
//                else {
//                    nameOffset += 1
//                }
//            }
//
//            let staffOffset = StaffPosition(staffOffset: staffOffset, posOffset: posOffset, name: Note.noteName(idx: nameOffset))
//            last = offset
//            noteOffsets[note] = staffOffset
//        }
//        show(lbl: "   create")
//        adjustForKey()
//        show(lbl: "after_key")
//    }
//
//    func incr(_ n:Int, _ delta:Int, _ modu:Int) -> Int {
//        var num = n + delta
//        if num > modu-1 {
//            num = 0
//        }
//        if num < 0 {
//            num = modu-1
//        }
//        return num
//    }
//    
//    func setNoteAccidentals() {
//        let key = KeySignature(type: KeySignatureType.sharps, count: 0)
//        var nameIdx = 0
//        if type == StaffType.treble {
//            nameIdx = 0
//        }
//        else {
//            nameIdx = 2
//        }
//        for n in 0...(highestNoteValue-lowestNoteValue) {
//            let note = lowestNoteValue + n
//            let staffPosition = noteOffsets[note]
//            //nameIdx = incr(nameIdx, direction, noteNames.count)
//            if nameIdx < 0 {
//                nameIdx = Note.noteNames.count-1
//            }
//            else {
//                if nameIdx > Note.noteNames.count-1 {
//                    nameIdx = 0
//                }
//            }
//            staffPosition.name = Note.noteNames[nameIdx]
//            //print(note, staffPosition.name)
//
//            if staffPosition.positionOffset != 0 {
//                if note == 27 {
//                    let x = 1
//                }
//                let flatFreq = key.accidentalFrequency(note: note+1, sigType: KeySignatureType.flats)
//                let sharpFreq = key.accidentalFrequency(note: note-1, sigType: KeySignatureType.sharps)
//                if flatFreq > sharpFreq {
//                staffPosition.staffOffsetFromBottom -= 1
//                staffPosition.positionOffset = 1
//                //staffPosition.name = Note.noteNames[nameIdx] + System.accFlat
//                nameIdx = incr(nameIdx, -1, Note.noteNames.count)
//                }
//                else {
//                    nameIdx = incr(nameIdx, -1, Note.noteNames.count)
//                    //staffPosition.name = Note.noteNames[nameIdx] + System.accSharp
//                }
//            }
//        }
//    }
//
    static func == (lhs: Staff, rhs: Staff) -> Bool {
        return lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }

    class StaffPlacement {
        var note:Int
        var acc: Int?
        init(_ note:Int, _ acc:Int?=nil) {
            self.note = note
            self.acc = acc
        }
    }
    
    class StaffPlacementsByKey {
        var staffPlacement:[StaffPlacement] = []
    }
    
    class M {
        var m:[String] = []
        init () {
            //  Key     C  D♭   D    E♭   E    F    G♭   G    A♭   A    B♭   B
            m.append("0    0    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //C
            m.append("0,2  1    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //C#
            m.append("1    0    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //D
            m.append("2,0  0    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //
            m.append("2    0    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //E
            m.append("3    0    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //F
            m.append("3,2  0    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //F#
            m.append("4    0    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //G
            proc()
        }
        
        func proc() {
            for line in m {
                let sp = StaffPlacementsByKey()
                let pairs = line.components(separatedBy: " ")
                for pair in pairs {
                    if pair.isEmpty {
                        continue
                    }
                    let noteParts = pair.trimmingCharacters(in: .whitespaces).components(separatedBy: ",")
                    let note = StaffPlacement(Int(noteParts[0])!)
                    if noteParts.count > 1 {
                        note.acc = Int(noteParts[1])!
                    }
                    sp.staffPlacement.append(note)
                }
            }
        }
    }
    
    func noteViewData(noteValue:Int) -> (Int?, String, [Int]) {
        let m = M()
        let toffsetFromBottom = 0
        let staffPosition = self.noteOffsets[noteValue]
        let offsetFromBottom = staffPosition.staffOffsetFromBottom
        var acc = ""
//        if staffPosition.positionOffset > 0 {
//            acc = System.accSharp
//        }
        let offsetFromTop = (system.staffLineCount * 2) - staffPosition.staffOffsetFromBottom - 2

        //ledger lines - return number of half lines above note pos
        var ledgerLines:[Int] = []
        if abs(offsetFromBottom) <= system.ledgerLineCount*2 - 2 {
            let onSpace = abs(offsetFromBottom) % 2 == 1
            var lineOffset = 0
            if onSpace {
                lineOffset -= 1
            }
            for _ in 0..<(system.ledgerLineCount - offsetFromBottom/2) + lineOffset {
                ledgerLines.append(lineOffset)
                lineOffset -= 2
            }
        }
        if abs(offsetFromTop) <= system.ledgerLineCount*2 - 2 {
            let onSpace = abs(offsetFromTop) % 2 == 1
            var lineOffset = 0
            if onSpace {
                lineOffset += 1
            }
            for _ in 0..<(system.ledgerLineCount - offsetFromTop/2) - lineOffset {
                ledgerLines.append(lineOffset)
                lineOffset += 2
            }
        }

        return (offsetFromTop, acc, ledgerLines)
    }
}
 
