import Foundation
import AVKit
import AVFoundation

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
}

class Staff : ObservableObject, Hashable  {
    let system:System
    var type:StaffType
    var noteOffsets:[StaffPosition] = []
    let linesInStaff = 5
    var middleOfStaffNoteValue:Int
    
    init(system:System, type:StaffType) {
        self.system = system
        self.type = type
        if type == StaffType.treble {
            middleOfStaffNoteValue = 51
        }
        else {
            middleOfStaffNoteValue = 30
        }
        createNoteOffsets()
    }
    
    func createNoteOffsets() {
        noteOffsets = [StaffPosition](repeating: StaffPosition(staffOffset: 0, posOffset: 0, name: ""), count: 2 * middleOfStaffNoteValue)
        var upOffsets:[Int] = []
        var downOffsets:[Int] = []
        let name = 65 //ASCII A : 0
        var nameIdx = 0

        if type == StaffType.treble {
            //               B C C D D E F F G G A A
            upOffsets =     [0,1,1,2,2,3,4,4,5,5,6,6]
            downOffsets =   [0,0,1,1,2,2,3,4,4,5,5,6]
        }
        else {
            upOffsets =     [0,0,1,2,2,3,3,4,4,5,6,6]
            downOffsets =   [0,0,1,1,3,4,4,5,5,6,7,7]
        }
        
        let totalNotes = (system.staffLineCount + 2 * system.ledgerLineCount) * 2
        var last:Int?
        
        for direction in -1...1 {
            if direction == 0 {
                continue
            }
            last = nil
            nameIdx = type == StaffType.treble ? 1 : 3
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
                    else {
                        if direction < 0 {
                            nameIdx -= 1
                            if nameIdx < 0 {
                                nameIdx = 6
                            }
                        }
                        else {
                            nameIdx += 1
                        }
                    }
                }
                var nm = ""
                nm = String(UnicodeScalar(UInt8(name + (nameIdx % 7))))
                if direction < 0 {
                    if needAccidental {
                        nm += System.accFlat
                    }
                }
                else {
                    if needAccidental {
                        nm += System.accSharp
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
                let staffOffset = StaffPosition(staffOffset: offsetFromMiddle, posOffset: posOffset, name: nm)
                //print(note, offset, nm)
                last = offset
                noteOffsets[note] = staffOffset
            }
        }
 
        for n in stride(from: noteOffsets.count-1, to: 0, by: -1) {
            let sp = noteOffsets[n]
            if !sp.name.isEmpty {
                print("Note", n, "(\(sp.staffOffsetFromMiddle),\(sp.positionOffset))\t", sp.name)
            }
        }
    }
    
    static func == (lhs: Staff, rhs: Staff) -> Bool {
        return lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }

    func setKey(key:KeySignature) {
        //createNoteOffsets()
        var newPos:[Int] = []
        
        if key.accidentals.count > 0 {
            for j in 0...key.accidentals.count-1 {
                let accNoteValue = key.accidentals[j]
                for octave in -5...10 {
                    let noteValue = accNoteValue + (octave*12)
                    if noteValue == 51 {
                        let x = 1
                    }
//                    let pos = getNoteStaffPos(noteValue: noteValue)
//                    if let idx = pos.0 {
//                        if key.type == KeySignatureType.sharps {
//                            newPos[idx] += 1
//                        }
//                        else {
//                            newPos[idx] -= 1
//                        }
//                    }
                }
            }
        }
        //self.noteOffsets = []
        //self.noteOffsets.append(contentsOf: newPos)
    }
    
    func staffOffset(noteValue:Int) -> (Int?, String, [Int]) {
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
 
