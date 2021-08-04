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
    
    func update(_ note:Int) {
        for octave in -5...5 {
            let n = note + (octave * 12)
            if n >= 48 && n <= 64 {
                accidentals.append(n)
            }
        }
    }
    
    init(type:KeySignatureType, count:Int) {
        self.type = type
        if count > 0 {
            for i in 0...count-1 {
                if i==0 {
                    if type == .sharps {
                        update(45) //F
                    }
                    else {
                        update(39)
                    }
                }
                if i==1 {
                    if type == .sharps {
                        update(40)
                    }
                    else {
                        update(44) //the 4th semitone from middle C goes flat
                    }
                }
                if i==2 {
                    if type == .sharps {
                        update(47)
                    }
                    else {
                        update(37)
                    }
                }
                if i==3 {
                    if type == .sharps {
                        update(42)
                    }
                    else {
                        update(42)
                    }
                }
            }
        }
    }
}
