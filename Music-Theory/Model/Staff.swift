import Foundation
import AVKit
import AVFoundation

//https://mammothmemory.net/music/sheet-music/reading-music/treble-clef-and-bass-clef.html

enum StaffType {
    case treble
    case bass
}

class StaffPlacement {
    var name:Character
    var offset:Int
    var acc: Int?
    init(name:Character, _ offset:Int, _ acc:Int?=nil) {
        self.offset = offset
        self.acc = acc
        self.name = name
    }
}

class StaffPlacementsByKey {
    var staffPlacement:[StaffPlacement] = []
}

class OffsetsByKey {
    var m:[String] = []
    init () {
        //  Key   C    D♭   D    E♭   E    F    G♭   G    A♭   A    B♭   B
        m.append("0    0    0,1  0    0,0  0    0    0    0    0,1  0    0,0")  //C
        m.append("0,2  1    0    0    0,0  1,0  0    0,2  0    0    0    0,0")  //C#
        m.append("1    0    1    0    0,0  1    0    1    0    1    0    0,0")  //D♭
        m.append("2,0  0    2,0  0    0,0  2,0  0    2,0  0    2,0  0    0,0")  //D
        m.append("2    0    2    0    0,0  2    0    2    0    2    0    0,0")  //E
        m.append("3    0    3,1  0    0,0  3    0    3,1  0    3,1  0    0,0")  //F
        m.append("3,2  0    3    0    0,0  4,0  0    3    0    3    0    0,0")  //F#
        m.append("4    0    4    0    0,0  4    0    4,1  0    4,1  0    0,0")  //G
        m.append("4,2  0    4,2  0    0,0  5,0  0    4    0    4    0    0,0")  //G#
        m.append("5    0    5    0    0,0  5    0    5    0    5    0    0,0")  //A
        m.append("6,0  0    6,0  0    0,0  6    0    6,0  0    6,0  0    0,0")  //B♭
        m.append("6    0    6    0    0,0  6,1  0    6    0    6    0    0,0")  //B
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


    init(system:System, type:StaffType) {
        self.system = system
        self.key = system.key
        self.type = type
        lowestNoteValue = 0
        highestNoteValue = 88
        lowestNoteNameIdx = 0

        if type == StaffType.treble {
            if system.ledgerLineCount == 0 {
                lowestNoteValue = 44
                lowestNoteNameIdx = 4
            }
            if system.ledgerLineCount == 1 {
                lowestNoteValue = 40
                lowestNoteNameIdx = 2
            }
            if system.ledgerLineCount == 2 {
                lowestNoteValue = 37
                lowestNoteNameIdx = 0
            }
            if system.ledgerLineCount == 3 {
                lowestNoteValue = 33
                lowestNoteNameIdx = 5
            }
        }
        else {
            if system.ledgerLineCount == 0 {
                lowestNoteValue = 23
                lowestNoteNameIdx = 6
            }
            if system.ledgerLineCount == 1 {
                lowestNoteValue = 20
                lowestNoteNameIdx = 4
            }
            if system.ledgerLineCount == 2 {
                lowestNoteValue = 16
                lowestNoteNameIdx = 2
            }
            if system.ledgerLineCount == 3 {
                lowestNoteValue = 13
                lowestNoteNameIdx = 0
            }
        }
        
        noteOffsets = [StaffPlacementsByKey](repeating: StaffPlacementsByKey(), count: highestNoteValue + 1)
        var noteIdx = 4
        let m = OffsetsByKey()
        var allDone = false
        var octaveCtr = 0
        var nameCtr = 2
        var lastOffset:Int? = nil

        while !allDone {
            for line in m.m {
                let sp = StaffPlacementsByKey()
                let pairs = line.components(separatedBy: " ")
                let octave = ((octaveCtr) / 12) - (self.type == StaffType.treble ? 3 : 1)
                octaveCtr += 1
                var col = 0
                
                for pair in pairs {
                    if pair.isEmpty {
                        continue
                    }
                    let noteParts = pair.trimmingCharacters(in: .whitespaces).components(separatedBy: ",")
                    let staffTypeOffset = type == StaffType.treble ? 0 : -2
                    //print(line, pair, noteParts)
                    let staffOffset = Int(noteParts[0])! + (octave * 7) + ((system.ledgerLineCount - 1) * 2) + staffTypeOffset
                    
                    if col == 0 {
                        if let lastOffset = lastOffset {
                            if staffOffset != lastOffset {
                                nameCtr += 1
                            }
                        }
                        lastOffset = staffOffset
                    }
                    col += 1
                    
                    let noteName = Note.noteName(idx: nameCtr)

                    let note = StaffPlacement(name: noteName, staffOffset)
                    if noteParts.count > 1 {
                        note.acc = Int(noteParts[1])!
                    }
                    sp.staffPlacement.append(note)
                }

                if noteIdx < noteOffsets.count {
                    noteOffsets[noteIdx] = sp
                    noteIdx += 1
                }
                else {
                    allDone = true
                    break
                }
            }
        }
        show("")
    }
    
    func show(_ lbl:String) {
        print("")
        for n in stride(from: noteOffsets.count-1, to: 0, by: -1) {
            let sp = noteOffsets[n]
            if sp.staffPlacement.count > 0 {
                var acc = ""
                if sp.staffPlacement[0].acc == 0 {acc = System.accFlat}
                if sp.staffPlacement[0].acc == 1 {acc = System.accNatural}
                if sp.staffPlacement[0].acc == 2 {acc = System.accSharp}
                print("\(lbl) Note", n,
                      "\(sp.staffPlacement[0].offset) \(sp.staffPlacement[0].name) \(acc)")
            }
        }
    }
    
    func keyColumn() -> Int {
        //    Key   C    D♭   D    E♭   E    F    G♭   G    A♭   A    B♭   B
        //m.append("0    0    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //C

        if system.key.type == KeySignatureType.sharps {
            switch key.accidentalCount {
            case 0:
                return 0
            case 1:
                return 7
            case 2:
                return 2
            case 3:
                return 9
            case 4:
                return 4
            case 5:
                return 11
            case 6:
                return 6
            case 7:
                return 1
            default:
                return 0
            }
        }
        else {
            switch key.accidentalCount {
            case 0:
                return 0
            case 1:
                return 5
            case 2:
                return 10
            case 3:
                return 3
            case 4:
                return 8
            case 5:
                return 1
            case 6:
                return 6
            case 7:
                return 11
            default:
                return 0
            }
        }
        return 0
    }
    
    func noteViewData(noteValue:Int) -> (Int?, String, [Int]) {
        let staffPosition = self.noteOffsets[noteValue]
        let keyCol = keyColumn()
        let offsetFromBottom = staffPosition.staffPlacement[keyCol].offset
        let offsetFromTop = (system.staffLineCount * 2) - offsetFromBottom - 2

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
        var acc = ""
        switch staffPosition.staffPlacement[keyCol].acc {
            case 0:
                acc=System.accFlat
            case 1:
                acc=System.accNatural
            case 2:
                acc=System.accSharp
            default:
                acc=""
        }
        return (offsetFromTop, acc, ledgerLines)
    }
    
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

}
 
