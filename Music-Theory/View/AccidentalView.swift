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
        for octave in -5...5 {
            let note = key.type == KeySignatureType.sharps ? key.sharps[noteIdx] + (12*octave) : key.flats[noteIdx] + (12*octave)
            let offset = abs(staff.middleOfStaffNoteValue - note)
            if offset < minOffset {
                minOffset = offset
                self.note = note
            }
        }

        accidental = key.type == KeySignatureType.sharps ? System.accSharp : System.accFlat
        let pos = staff.noteViewData(noteValue: note)
        offsetFromStaffTop = pos.0!
    }

    
    var body: some View {
        Text(accidental).font(.title)
            .position(x: CGFloat(lineSpacing/2), y: CGFloat(offsetFromStaffTop * lineSpacing/2))

    }
}

