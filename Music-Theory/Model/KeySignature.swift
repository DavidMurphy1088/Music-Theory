import Foundation
import AVKit
import AVFoundation

enum KeySignatureType {
    case sharps
    case flats
}

class KeyAcc {
    var num = 0
}

class KeySignature {
    var type:KeySignatureType
    var accidentals:[Int] = []
    
    init(type:KeySignatureType, count:Int) {
        self.type = type
        if count > 0 {
            for i in 0...count-1 {
                if i==0 {
                    if type == .sharps {
                        accidentals.append(5) //the 5th semitone from middle C goes sharp
                    }
                    else {
                        accidentals.append(11)
                    }
                }
                if i==1 {
                    if type == .sharps {
                        accidentals.append(0)
                    }
                    else {
                        accidentals.append(4) //the 4th semitone from middle C goes flat
                    }
                }
                if i==2 {
                    if type == .sharps {
                        accidentals.append(7)
                    }
                    else {
                        accidentals.append(9)
                    }
                }
                if i==3 {
                    if type == .sharps {
                        accidentals.append(2)
                    }
                    else {
                        accidentals.append(2)
                    }
                }
            }
        }
    }
}
