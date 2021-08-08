import Foundation
import AVKit
import AVFoundation

class System : ObservableObject  {
    var staff:[Staff] = []
    var key:KeySignature
    var tempo = 5
    @Published var timeSlice:[TimeSlice]
    let engine = AVAudioEngine()
    let sampler = AVAudioUnitSampler()
    let ledgerLineCount = 1
    var staffLineCount = 5
    static var accSharp = "\u{266f}"
    static var accNatural = "\u{266e}"
    static var accFlat = "\u{266d}"

    init(key:KeySignature) {
        self.key = key
        self.timeSlice = []
        staffLineCount = 5 + (2*ledgerLineCount)
        //self.key = key
        //engine.attach(reverb)
        //reverb.loadFactoryPreset(.largeHall2)
        //reverb.loadFactoryPreset(
        //reverb.wetDryMix = 50

        // Connect the nodes.
        //engine.connect(sampler, to: reverb, format: nil)
        //engine.connect(reverb, to: engine.mainMixerNode, format:engine.mainMixerNode.outputFormat(forBus: 0))
        engine.attach(sampler)
        engine.connect(sampler, to:engine.mainMixerNode, format:engine.mainMixerNode.outputFormat(forBus: 0))
        
        do {
            //https://www.rockhoppertech.com/blog/the-great-avaudiounitsampler-workout/#soundfont
            if let url = Bundle.main.url(forResource:"Nice-Steinway-v3.8", withExtension:"sf2") {
                print("found resource")
                try sampler.loadSoundBankInstrument(at: url, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
                print("loaded resource")
            }
            print("try start engine")
            try engine.start()
            print("engine started", engine.mainMixerNode.description)
        } catch {
            print("Couldn't start engine")
        }
    }
    
    func setTempo(temp: Int) {
        self.tempo = temp
    }
    
    func addTimeSlice(ts:TimeSlice) {
        DispatchQueue.main.async {
            self.timeSlice.append(ts)
        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.timeSlice = []
        }
    }

    func play() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            for ts in timeSlice {
                for note in ts.note {
                    sampler.startNote(UInt8(note.num), withVelocity:48, onChannel:0)
                }
                let t = 10-self.tempo
                if t > 0 {
                    usleep(useconds_t((t) * 100000))
                }
            }
//            DispatchQueue.main.async {
//                print("This is run on the main queue, after the previous code in outer block")
//            }
        }
    }
    
}
