import SwiftUI
import CoreData
import MessageUI

struct AccidentalView: View {
    var note:Int
    var lineSpacing:Int
    var accidental:String
    var offsetFromStaffTop:Int
    
    init(staff:Staff, key:KeySignature, noteIdx:Int, lineSpacing: Int) {
        self.lineSpacing = lineSpacing
        var minOffset = 999
        self.note = 0
        //TODO not right for all accidentals e.g > 4
        // https://www.doremistudios.com.au/key-signatures-explained/
        let midNote = staff.type == StaffType.treble ? 54 : 30

        for octave in -3...3 { //TODO -5,5
            let note = key.type == KeySignatureType.sharps ? key.sharps[noteIdx] + (12*octave) : key.flats[noteIdx] + (12*octave)
            let offset = abs(midNote - note)
            //print ("   ", note, offset)
            if offset < minOffset {
                minOffset = offset
                self.note = note
            }
        }

        accidental = key.type == KeySignatureType.sharps ? System.accSharp : System.accFlat
        let pos = staff.noteViewData(noteValue: note)
        //print(noteIdx, self.note, pos.0)
        offsetFromStaffTop = pos.0!
    }

    
    var body: some View {
        Text(accidental).font(.title)
            .position(x: CGFloat(lineSpacing/2), y: CGFloat(offsetFromStaffTop * lineSpacing/2))

    }
}

