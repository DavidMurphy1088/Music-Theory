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
    
    init(system:System, type:StaffType) {
        self.system = system
        self.type = type

        let offs:[Int] = [0,2,4,5,7,9,11]
        for i in 0...2 * (system.ledgerLineCount + linesInStaff) {
            let octave = i / offs.count
            let scaleOffset = (12 * octave) + offs[i%offs.count]
            noteOffsets.append(scaleOffset)
        }
//        offs = [0,1,3,5,7,8,10]
//        var bassOffsets:[Int] = []
//        for i in 0...2 * (system.ledgerLineCount + 5) {
//            let octave = i / offs.count
//            let scaleOffset = (-12 * octave) - offs[i%offs.count]
//            bassOffsets.append(scaleOffset)
//        }
//        bassOffsets.sort {
//            $0 < $1
//        }
        //self.noteOffsets.append(contentsOf: bassOffsets)
        //self.noteOffsets.append(contentsOf: trebleOffsets[1...trebleOffsets.count-1])
//        self.noteOffsets.sort {
//            $0 > $1
//        }
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
        var index:Int?
        var indexLo:Int?
        var indexHi:Int?
        var ledgerLines:[Int] = []
        
        for i in 0...noteOffsets.count-1 {
            let diff = Note.MIDDLE_C + noteOffsets[i] - noteValue
            if abs(diff) < 2 {
                if diff == 0 {
                    index = i
                }
                else {
                    if diff == 1 {
                        indexHi = i
                    }
                    if diff == -1 {
                        indexLo = i
                    }
                }
            }
        }
        
        //accidental
        var acc = " "
        if index == nil {
            //get note's offset *above* middle C since key sigs are defined as offsets above middle C
            let InSignature = system.key.accidentals.contains((noteValue + (6 * 12) - Note.MIDDLE_C) % 12)
            if system.key.type == KeySignatureType.sharps {
                print("===", noteValue, (noteValue - Note.MIDDLE_C) % 12, (12 + (noteValue - Note.MIDDLE_C)) % 12)
                if InSignature {
                    index = indexHi
                    acc = System.accNatural
                }
                else {
                    index = indexLo
                    acc = System.accSharp
                }
            }
            else {
                if InSignature {
                    index = indexLo
                    acc = System.accNatural
                }
                else {
                    index = indexHi
                    acc = System.accFlat
                }
            }
        }
        
        //ledger lines
        //return number of half lines above note pos
        let indexFromMiddle = abs(noteOffsets.count/2 - index!)
        let onSpace = indexFromMiddle % 2 == 1
        var lineOffset = 0
        if onSpace {
            lineOffset += 1
        }
        ledgerLines.append(lineOffset)
        ledgerLines.append(lineOffset-2)
        ledgerLines.append(lineOffset-4)

        let offset = noteOffsets.count - index! - 1
        print("---> Offset", offset, ledgerLines)
        return (offset, acc, ledgerLines)
    }
}
 
