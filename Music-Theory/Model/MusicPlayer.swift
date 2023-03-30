import Foundation
import AVKit
import AVFoundation

class MusicPlayer : ObservableObject {
    
    func play (notes: [Note]) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let playTempo = 3.0
            let pitchAdjust = 5
            var n = 0
            for note in notes {
                var dynamic:Double = 48
//                if n < 3 {
//                    dynamic *= 1.3
//                }
                n += 1
                Score.sampler.startNote(UInt8(note.num + 12 + pitchAdjust), withVelocity:UInt8(dynamic), onChannel:0)
                let wait = playTempo * 50000.0 * Double(note.duration)
                usleep(useconds_t(wait))
            }
        }
    }
}


