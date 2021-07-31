import Foundation
import AVKit
import AVFoundation

enum StaffType {
    case treble
    case bass
    case all
}

class Staff : ObservableObject {
    @Published var timeSlice:[TimeSlice]
    var type:StaffType
    var key:KeySignature?
    let engine = AVAudioEngine()
    let sampler = AVAudioUnitSampler()
    var tempo = 5
    let ledgerLineCount = 3
    var lineCount:Int
    var noteOffsets:[Int] = []
    static var accSharp = "\u{266f}"
    static var accNatural = "\u{266e}"
    static var accFlat = "\u{266d}"

    init(type:StaffType) {
        self.type = type
        self.timeSlice = []
        lineCount = (2*5) + (4*ledgerLineCount)
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
        
        var trebleOffsets:[Int] = []
        var offs:[Int] = [0,2,4,5,7,9,11]
        for i in 0...2 * (ledgerLineCount + 5) {
            let octave = i / offs.count
            let scaleOffset = (12 * octave) + offs[i%offs.count]
            trebleOffsets.append(scaleOffset)
        }
        offs = [0,1,3,5,7,8,10]
        var bassOffsets:[Int] = []
        for i in 0...2 * (ledgerLineCount + 5) {
            let octave = i / offs.count
            let scaleOffset = (-12 * octave) - offs[i%offs.count]
            bassOffsets.append(scaleOffset)
        }
        bassOffsets.sort {
            $0 < $1
        }
        self.noteOffsets.append(contentsOf: bassOffsets)
        self.noteOffsets.append(contentsOf: trebleOffsets[1...trebleOffsets.count-1])
    }
    
    func setKey(key:KeySignature) {
        self.key = key
        if key.accidentals.count > 0 {
            for i in 0...self.noteOffsets.count-1 {
                for j in 0...key.accidentals.count-1 {
                    let a = key.accidentals[j]
                    let match1 = self.noteOffsets[i] % 12 == a
                    let match2 = (self.noteOffsets[i]) % 12 == a - 12
                    if i == 49 {
                        print(i, j, self.noteOffsets[i], self.noteOffsets[i] % 12, (self.noteOffsets[i] - 12) % 12 , match1, match2 )
                    }
                    if match1 || match2 {
                        if key.type == .sharps {
                            self.noteOffsets[i] += 1
                        }
                        else {
                            self.noteOffsets[i] -= 1
                        }
                    }
                }
            }
        }
    }
    
    func getLineCount() -> Int {
        return lineCount
    }
    
//    func getMiddleCOffset() -> Int {
//        return (lineCount+1) /// 2
//    }

    func addTimeSlice(ts:TimeSlice) {
        DispatchQueue.main.async {
            self.timeSlice.append(ts)
        }
    }
    
    func setTempo(temp: Int) {
        self.tempo = temp
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
    
    func staffOffset(noteValue:Int) -> (Int, String, Bool) {
        var index:Int?
        var indexLo:Int?
        var indexHi:Int?
        for i in 0...noteOffsets.count-1 {
            let diff = Note.MIDDLE_C + noteOffsets[i] - noteValue
            if abs(diff) < 2 {
                if diff == 0 {
                    index = i
                }
                else {
                    if diff == 1 {
                        indexHi = i
                    }
                    if diff == -1 {
                        indexLo = i
                    }
                }
            }
        }
        var acc = " "
        if index == nil {
            //get note's offset *above* middle C since key sigs are defined as offsets above middle C
            let InSignature = key!.accidentals.contains((noteValue + (6 * 12) - Note.MIDDLE_C) % 12)
            if key?.type == KeySignatureType.sharps {
                //let match1 = self.noteOffsets[i] % 12 == a
                //let match2 = (self.noteOffsets[i]) % 12 == a - 12
                print("===", noteValue, (noteValue - Note.MIDDLE_C) % 12, (12 + (noteValue - Note.MIDDLE_C)) % 12)
                if InSignature {
                    index = indexHi
                    acc = Staff.accNatural
                }
                else {
                    index = indexLo
                    acc = Staff.accSharp
                }
            }
            else {
                if InSignature {
                    index = indexLo
                    acc = Staff.accNatural
                }
                else {
                    index = indexHi
                    acc = Staff.accFlat
                }
            }
        }
        //let offset = 2*(ledgerLineCount + 5)// - index!
        let offset = noteOffsets.count - index! - 1
        let needsLedgerLine = offset >= noteOffsets.count/2
        print("---> Offset", offset)
        return (offset, acc, needsLedgerLine)
    }
}
 
