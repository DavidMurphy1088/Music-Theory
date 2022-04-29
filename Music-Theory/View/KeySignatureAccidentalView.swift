import SwiftUI
import CoreData
import MessageUI

struct KeySignatureAccidentalView: View {
    //var note:Int
    var lineSpacing:Int
    var accidental:String
    var offsetFromStaffTop:Int
    
//    init(staff:Staff, key:KeySignature, noteIdx:Int, lineSpacing: Int) {
//        self.lineSpacing = lineSpacing
//        var minOffset = 999
//        self.note = 0
//        //TODO not right for all accidentals e.g > 4
//        // https://www.doremistudios.com.au/key-signatures-explained/
//        let midNote = staff.type == StaffType.treble ? 54 : 30
//
//        for octave in -3...3 { //TODO -5,5
//            let note = key.accidentalType == KeySignatureAccidentalType.sharps ? key.sharps[noteIdx] + (12*octave) : key.flats[noteIdx] + (12*octave)
//            let offset = abs(midNote - note)
//            if offset < minOffset {
//                minOffset = offset
//                self.note = note
//            }
//        }
//
//        if staff.type == StaffType.treble {
//            var dd = 0
//            dd = dd+1
//        }
//        accidental = key.accidentalType == KeySignatureAccidentalType.sharps ? Score.accSharp : Score.accFlat
//        let pos = staff.noteViewData(noteValue: note)
//        offsetFromStaffTop = pos.0!
//        if staff.type == StaffType.treble {
//            print(noteIdx, "note", self.note, "pos", pos.0, pos.1, pos.2, "\toffsetTop", offsetFromStaffTop)
//        }
//    }

    init(staff:Staff, key:KeySignature, noteIdx:Int, lineSpacing: Int) {
        accidental = key.accidentalType == AccidentalType.sharp ? Score.accSharp : Score.accFlat
        self.lineSpacing = lineSpacing
        if key.accidentalType == AccidentalType.sharp {
            switch noteIdx {
            case 0: offsetFromStaffTop = 1
            case 1: offsetFromStaffTop = 4
            case 2: offsetFromStaffTop = 0
            case 3: offsetFromStaffTop = 3
            case 4: offsetFromStaffTop = 6
            case 5: offsetFromStaffTop = 2
            default: offsetFromStaffTop = 0
            }
        }
        else {
            switch noteIdx {
            case 0: offsetFromStaffTop = 4
            case 1: offsetFromStaffTop = 1
            case 2: offsetFromStaffTop = 5
            case 3: offsetFromStaffTop = 2
            case 4: offsetFromStaffTop = 6
            case 5: offsetFromStaffTop = 3
            default: offsetFromStaffTop = 0
            }
        }

        if key.accidentalType == AccidentalType.sharp {
            offsetFromStaffTop -= 1
        }
        offsetFromStaffTop += staff.score.ledgerLineCount * 2
        if staff.type == StaffType.bass {
            offsetFromStaffTop += 2
        }
    }
    
    var body: some View {
        Text(accidental).font(.title)
            .position(x: CGFloat(lineSpacing/2), y: CGFloat(offsetFromStaffTop * lineSpacing/2) + 1)
    }
}
