import Foundation
import AVKit
import AVFoundation

class Score  {//}: ObservableObject  {
    //static var instance = System()
    //@Published
    private var staff:[Staff] = []
    //@Published var upd = 0
    var key:KeySignature = KeySignature(type: KeySignatureType.sharps, count: 0)
    var tempo = 5
    let engine = AVAudioEngine()
    let sampler = AVAudioUnitSampler()
    let ledgerLineCount = 4 //4 is required to represent low E
    var staffLineCount = 0
    static var accSharp = "\u{266f}"
    static var accNatural = "\u{266e}"
    static var accFlat = "\u{266d}"
    var maxTempo = 10
    var timeSlices:[TimeSlice] = []
    
    init() {
        staffLineCount = 5 + (2*ledgerLineCount)
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
                //print("found resource")
                try sampler.loadSoundBankInstrument(at: url, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
                //print("loaded resource")
            }
            //print("try start engine")
            try engine.start()
            //print("engine started", engine.mainMixerNode.description)
        } catch {
            print("Couldn't start engine")
        }
    }
    
    func update() {
        for staff in staff {
            staff.update()
        }
    }
    
    func setStaff(num:Int, staff:Staff) {
        //DispatchQueue.main.async {
            if self.staff.count <= num {
                self.staff.append(staff)
            }
            else {
                self.staff[num] = staff
            }
        //}
    }
    
    func getStaff() -> [Staff] {
        return self.staff
    }
    
    func setKey(key:KeySignature) {
        self.key = key
    }

    func setTempo(temp: Int) {
        self.tempo = temp
    }
    
    func addTimeSlice() -> TimeSlice {
        let ts = TimeSlice(score: self)
        self.timeSlices.append(ts)
        return ts
    }
    
    func clear() {
//        DispatchQueue.main.async {
           self.timeSlices = []
//        }
    }

    func play() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            for ts in timeSlices {
                for note in ts.note {
                    sampler.startNote(UInt8(note.num), withVelocity:48, onChannel:0)
                }
                let t = self.maxTempo - self.tempo
                if t > 0 {
                    usleep(useconds_t((t) * 100000))
                }
            }
        }
    }

}
