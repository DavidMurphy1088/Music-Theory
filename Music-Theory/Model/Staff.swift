import Foundation
import AVKit
import AVFoundation

//https://mammothmemory.net/music/sheet-music/reading-music/treble-clef-and-bass-clef.html

enum StaffType {
    case treble
    case bass
}

class StaffPosition {
    var staffOffsetFromMiddle:Int
    var positionOffset:Int
    var name:String
    
    init (staffOffset: Int, posOffset:Int, name:String) {
        self.staffOffsetFromMiddle = staffOffset
        self.positionOffset = posOffset
        self.name = name
    }
    
    func move(moveOut:Bool) {
        if staffOffsetFromMiddle >= 0 {
            if positionOffset < 1 {
                positionOffset += 1
                return
            }
            positionOffset = -1
            staffOffsetFromMiddle += 1
        }
        if positionOffset < 1 {
            positionOffset += 1
            return
        }
        positionOffset = -1
        staffOffsetFromMiddle += 1

    }
}

class Staff : ObservableObject, Hashable  {
    let system:System
    var type:StaffType
    var noteOffsets:[StaffPosition] = []
    let linesInStaff = 5
    var middleOfStaffNoteValue:Int
    var totalNotes:Int
    var key:KeySignature
    
    init(system:System, type:StaffType) {
        self.system = system
        self.key = system.key
        self.type = type
        if type == StaffType.treble {
            middleOfStaffNoteValue = 51
        }
        else {
            middleOfStaffNoteValue = 30
        }
        totalNotes = ((system.staffLineCount + 2 * system.ledgerLineCount) * 2)
        createNoteOffsets()
        show(lbl: "create")
        setNoteAccidentals()
        show(lbl: "accidl")
    }
    
    func show(lbl:String) {
        print("")
        for n in stride(from: noteOffsets.count-1, to: 0, by: -1) {
            let sp = noteOffsets[n]
            if abs(n - middleOfStaffNoteValue) < 10 {
                print("\(lbl) Note", n, "(\(sp.staffOffsetFromMiddle),\(sp.positionOffset))\t", "name:\(sp.name)")
            }
        }
    }
    
    func getOffsets(direction:Int) -> [Int] {
        var o:[Int] = []
        if type == StaffType.treble {
            if direction == -1 {
                o = [0,1,1,2,2,3,4,4,5,5,6,6]
            }
            else {
                o = [0,0,1,1,2,2,3,4,4,5,5,6]
            }
        }
        else {
            
        }
        return o
    }
    
    func adjustForKey() {
        for a in 0..<key.accidentalCount {
//            let note = system.key.sharps[a]
//            let inc = note < middleOfStaffNoteValue ? 1 : -1
//            print(note)
//            var sp = self.noteOffsets[note+1]
//            sp.staffOffsetFromMiddle += inc
//            sp.positionOffset = 0
//            sp = self.noteOffsets[note]
//            //sp.staffOffsetFromMiddle += 1
//            sp.positionOffset = inc
        }
    }
    
    func createNoteOffsets() {
        noteOffsets = [StaffPosition](repeating: StaffPosition(staffOffset: 0, posOffset: 0, name: ""), count: 2 * middleOfStaffNoteValue)
        var upOffsets:[Int] = []
        var downOffsets:[Int] = []

        if type == StaffType.treble {
            //               B C C D D E F F G G A A
            upOffsets =     getOffsets(direction: -1)
            downOffsets =   getOffsets(direction: 1)
        }
        else {
            upOffsets =     [0,0,1,2,2,3,3,4,4,5,6,6]
            downOffsets =   [0,0,1,2,2,3,3,4,4,5,6,6]
        }
        
        var last:Int?
        
        for direction in -1...1 {
            if direction == 0 {
                continue
            }
            last = nil
            for n in 0...totalNotes/2 {
                let note = middleOfStaffNoteValue + n * direction
                var offset = 0
                if direction < 0 {
                    offset = downOffsets[n % upOffsets.count] + (n/upOffsets.count) * 7
                }
                else {
                    offset = upOffsets[n % upOffsets.count] + (n/upOffsets.count) * 7
                }
                var needAccidental = false
                if last != nil {
                    if offset == last {
                        needAccidental = true
                    }
                }
                
                let offsetFromMiddle = direction * offset * -1
                var posOffset = 0
                if needAccidental {
                    if direction < 0 {
                        posOffset = 1
                    }
                    else {
                        posOffset = -1
                    }
                }
                let staffOffset = StaffPosition(staffOffset: offsetFromMiddle, posOffset: posOffset, name: "")
                last = offset
                noteOffsets[note] = staffOffset
            }
        }
        adjustForKey()
    }

    func incr(_ n:Int, _ delta:Int, _ modu:Int) -> Int {
        var num = n + delta
        if num > modu-1 {
            num = 0
        }
        if num < 0 {
            num = modu-1
        }
        return num
    }
    
    func setNoteAccidentals() {
        let key = KeySignature(type: KeySignatureType.sharps, count: 0)
        let noteNames = ["A","B","C","D","E","F","G"]
        
        for direction in -1...1 {
            if direction == 0 {
                continue
            }
            var nameIdx = 0
            if type == StaffType.treble {
                nameIdx = direction < 0 ? 2 : 0
            }
            else {
                nameIdx = direction < 0 ? 4 : 2
            }
            for n in 0...(noteOffsets.count/2)-1 {
                let note = (noteOffsets.count/2) + (direction * n)

                let staffPosition = noteOffsets[note]
                nameIdx = incr(nameIdx, direction, noteNames.count)
                if nameIdx < 0 {
                    nameIdx = noteNames.count-1
                }
                else {
                    if nameIdx > noteNames.count-1 {
                        nameIdx = 0
                    }
                }
                staffPosition.name = noteNames[nameIdx]
                //print(note, staffPosition.name)
 
                if staffPosition.positionOffset != 0 {
                    if note == 27 {
                        let x = 1
                    }
                    let flatFreq = key.accidentalFrequency(note: note+1, sigType: KeySignatureType.flats)
                    let sharpFreq = key.accidentalFrequency(note: note-1, sigType: KeySignatureType.sharps)
                    if flatFreq > sharpFreq {
                        if direction < 0 {
                            nameIdx = incr(nameIdx, 0-direction, noteNames.count)
                        }
                        else {
                            staffPosition.staffOffsetFromMiddle -= 1
                            staffPosition.positionOffset = 1
                        }
                        staffPosition.name = noteNames[nameIdx] + System.accFlat
                        if direction > 0 {
                            nameIdx = incr(nameIdx, 0-direction, noteNames.count)
                        }

                    }
                    else {
                        if direction < 0 {
                            staffPosition.staffOffsetFromMiddle += 1
                            staffPosition.positionOffset = -1
                        }
                        else {
                            nameIdx = incr(nameIdx, 0-direction, noteNames.count)
                        }
                        staffPosition.name = noteNames[nameIdx] + System.accSharp
                        if direction < 0 {
                            nameIdx = incr(nameIdx, 0-direction, noteNames.count)
                        }
                    }
                }
            }
        }
    }

    static func == (lhs: Staff, rhs: Staff) -> Bool {
        return lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }

    func noteViewData(noteValue:Int) -> (Int?, String, [Int]) {
        let staffPosition = self.noteOffsets[noteValue]
        let offsetFromMiddle = staffPosition.staffOffsetFromMiddle
        var acc = ""
        if staffPosition.positionOffset > 0 {
            acc = System.accFlat
        }
        if staffPosition.positionOffset < 0 {
            acc = System.accSharp
        }
        let offsetFromTop = system.staffLineCount + offsetFromMiddle - 1

        //ledger lines - return number of half lines above note pos
        var ledgerLines:[Int] = []
        if abs(offsetFromMiddle) > 5 {
            let onSpace = abs(offsetFromMiddle) % 2 == 1
            var lineOffset = 0
            if offsetFromMiddle > 5 {
                if onSpace {
                    lineOffset -= 1
                }
                for _ in 0...(offsetFromMiddle-4)/2 - 1 {
                    ledgerLines.append(lineOffset)
                    lineOffset -= 2
                }
            }
            else {
                if onSpace {
                    lineOffset += 1
                }
                for _ in 0...(abs(offsetFromMiddle)-4)/2 - 1 {
                    ledgerLines.append(lineOffset)
                    lineOffset += 2
                }
            }
        }
        return (offsetFromTop, acc, ledgerLines)
    }
}
 
