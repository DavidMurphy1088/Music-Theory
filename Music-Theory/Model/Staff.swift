import Foundation
import AVKit
import AVFoundation

enum StaffType {
    case treble
    case bass
}

class Staff : ObservableObject, Hashable  {
    let system:System
    var type:StaffType
    var noteOffsets:[Int] = []
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

        var upOffsets:[Int] = []
        var downOffsets:[Int] = []
        if type == StaffType.treble {
            upOffsets =     [0,1,3,5,6,8,10]
            downOffsets =   [2,4,6,7,9,11,12]
        }
        else {
            upOffsets =     [0,2,3,5,7,9,10]
            downOffsets =   [2,3,5,7,9,10,12]
        }
        for i in 0...2 * (system.ledgerLineCount + linesInStaff/2) {
            let octave = i / upOffsets.count
            let scaleOffset = (12 * octave) + upOffsets[i%upOffsets.count]
            noteOffsets.append(scaleOffset)
        }
        for i in 0...2 * (system.ledgerLineCount + linesInStaff/2) - 1 {
            let octave = i / downOffsets.count
            let scaleOffset = (-12 * octave) - downOffsets[i%downOffsets.count]
            noteOffsets.append(scaleOffset)
        }
        noteOffsets.sort {
            $0 > $1
        }
    }
    
    static func == (lhs: Staff, rhs: Staff) -> Bool {
        return lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }

    func setKey(key:KeySignature) {
        if key.accidentals.count > 0 {
            for i in 0...self.noteOffsets.count-1 {
                for j in 0...key.accidentals.count-1 {
                    let a = key.accidentals[j]
                    let match1 = self.noteOffsets[i] % 12 == a
                    let match2 = (self.noteOffsets[i]) % 12 == a - 12
                    if i == 49 {
                        print(i, j, self.noteOffsets[i], self.noteOffsets[i] % 12, (self.noteOffsets[i] - 12) % 12 , match1, match2 )
                    }
                    if match1 || match2 {
                        if key.type == .sharps {
                            self.noteOffsets[i] += 1
                        }
                        else {
                            self.noteOffsets[i] -= 1
                        }
                    }
                }
            }
        }
    }
    
    func staffOffset(noteValue:Int) -> (Int, String, [Int]) {
        var noteRow:Int?
        var noteLo:Int?
        var noteHi:Int?
        var ledgerLines:[Int] = []
        
        for i in 0...noteOffsets.count-1 {
            let diff = middleOfStaffNoteValue + noteOffsets[i] - noteValue
            if abs(diff) < 2 {
                if diff == 0 {
                    noteRow = i
                }
                else {
                    if diff == 1 {
                        noteHi = i
                    }
                    if diff == -1 {
                        noteLo = i
                    }
                }
            }
        }
        
        //accidental
        var acc = " "
        if noteRow == nil {
            //get note's offset *above* middle C since key sigs are defined as offsets above middle C
            let InSignature = system.key.accidentals.contains((noteValue + (6 * 12) - Note.MIDDLE_C) % 12)
            if system.key.type == KeySignatureType.sharps {
                print("===", noteValue, (noteValue - Note.MIDDLE_C) % 12, (12 + (noteValue - Note.MIDDLE_C)) % 12)
                if InSignature {
                    noteRow = noteHi
                    acc = System.accNatural
                }
                else {
                    noteRow = noteLo
                    acc = System.accSharp
                }
            }
            else {
                if InSignature {
                    noteRow = noteLo
                    acc = System.accNatural
                }
                else {
                    noteRow = noteHi
                    acc = System.accFlat
                }
            }
        }
        
        //ledger lines
        //return number of half lines above note pos
        let indexFromMiddle = abs(noteOffsets.count/2 - noteRow!)
        if indexFromMiddle > 5 {
            let onSpace = indexFromMiddle % 2 == 1
            var lineOffset = 0
            if noteRow! > noteOffsets.count/2 {
                if onSpace {
                    lineOffset -= 1
                }
                for _ in 0...(indexFromMiddle-4)/2 - 1 {
                    ledgerLines.append(lineOffset)
                    lineOffset -= 2
                }
            }
            else {
                if onSpace {
                    lineOffset += 1
                }
                for _ in 0...(indexFromMiddle-4)/2 - 1 {
                    ledgerLines.append(lineOffset)
                    lineOffset += 2
                }
            }
        }
        
        print("---> Offset", noteRow!, ledgerLines)
        return (noteRow!, acc, ledgerLines)
    }
}
 
