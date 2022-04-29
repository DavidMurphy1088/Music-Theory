import Foundation
import AVKit
import AVFoundation

class Score : ObservableObject {
    static let engine = AVAudioEngine()
    static let sampler = AVAudioUnitSampler()
    static var auStarted = false
    let ledgerLineCount = 3//4 is required to represent low E
    let lineSpacing = 10

    private var staff:[Staff] = []
    @Published var key:Key = Key(type: Key.KeyType.major, keySig: KeySignature(type: AccidentalType.sharp, count: 0))
    var minorScaleType = Scale.MinorType.natural
    var tempo = 5
    var pitchAdjust = 5

    var staffLineCount = 0
    static var accSharp = "\u{266f}"
    static var accNatural = "\u{266e}"
    static var accFlat = "\u{266d}"
    var maxTempo = 10
    var timeSlices:[TimeSlice] = []
    
    static func startAu()  {
        engine.attach(sampler)
        engine.connect(sampler, to:engine.mainMixerNode, format:engine.mainMixerNode.outputFormat(forBus: 0))
        Score.auStarted = true
        DispatchQueue.global(qos: .userInitiated).async {
            print("Start AU engine")
            do {
                //https://www.rockhoppertech.com/blog/the-great-avaudiounitsampler-workout/#soundfont
                if let url = Bundle.main.url(forResource:"Nice-Steinway-v3.8", withExtension:"sf2") {
                    try Score.sampler.loadSoundBankInstrument(at: url, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
                }
                try Score.engine.start()
                print("Started AU engine")
            } catch {
                print("Couldn't start engine")
            }
        }
    }
    
    init() {
        staffLineCount = 5 + (2*ledgerLineCount)
        //engine.attach(reverb)
        //reverb.loadFactoryPreset(.largeHall2)
        //reverb.loadFactoryPreset(
        //reverb.wetDryMix = 50

        // Connect the nodes.
        //engine.connect(sampler, to: reverb, format: nil)
        //engine.connect(reverb, to: engine.mainMixerNode, format:engine.mainMixerNode.outputFormat(forBus: 0))
        
        if !Score.auStarted {
            Score.startAu()
        }
    }
    
    func updateStaffs() {
        for staff in staff {
            staff.update()
        }
    }
    
    func setStaff(num:Int, staff:Staff) {
        if self.staff.count <= num {
            self.staff.append(staff)
        }
        else {
            self.staff[num] = staff
        }
    }
    
    func getStaff() -> [Staff] {
        return self.staff
    }
    
    func keyDesc() -> String {
        var desc = key.description()
        if key.type == Key.KeyType.minor {
            desc += minorScaleType == Scale.MinorType.natural ? " (Natural)" : " (Harmonic)"
        }
        return desc
    }
    
    func setKey(key:Key) {
        self.key = key
        DispatchQueue.main.async {
            self.key = key
        }
        updateStaffs()
    }

    func setTempo(temp: Int, pitch: Int? = nil) {
        self.tempo = temp
        if let setPitch = pitch {
            self.pitchAdjust = setPitch
        }
    }
    
    func addTimeSlice() -> TimeSlice {
        let ts = TimeSlice(score: self)
        self.timeSlices.append(ts)
        return ts
    }
    
    func clear() {
        self.timeSlices = []
        for staff in staff  {
            staff.clear()
        }
    }

    func play(chord: Chord) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let t = self.maxTempo - self.tempo
            for i in [0,1] {
                for note in chord.notes {
                    if i > 0 {
                        if t > 0 {
                            usleep(useconds_t((t) * 2 * 100000))
                        }
                        Score.sampler.startNote(UInt8(note.num + 12 + self.pitchAdjust), withVelocity:48, onChannel:0)
                    }
                }
                if i == 0 {
                    usleep(500000)
                }
            }
        }
    }
    
    func play(select: [Int]? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            var index = 0
            for ts in timeSlices {
                if let selected = select {
                    if !selected.contains(index) {
                        index += 1
                        continue
                    }
                }
                for note in ts.note {
                    Score.sampler.startNote(UInt8(note.num + 12 + self.pitchAdjust), withVelocity:48, onChannel:0)
                }
                let t = self.maxTempo - self.tempo
                if t > 0 {
                    usleep(useconds_t((t) * 2 * 100000))
                }
                index += 1
            }
        }
    }

}
