import Foundation
import AVKit
import AVFoundation

class MusicPlayer : ObservableObject {
    
    func play (notes: [Note]) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let playTempo = 3
            let pitchAdjust = 5
            for note in notes {
                Score.sampler.startNote(UInt8(note.num + 12 + pitchAdjust ), withVelocity:48, onChannel:0)
                let wait = playTempo * 50000 * note.duration
                usleep(useconds_t(wait))
            }
        }
    }
}


