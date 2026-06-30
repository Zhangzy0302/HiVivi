import AVFoundation
import Combine
import Foundation

struct VoiceMorphAudioConfig: Equatable {
    var voiceMorphPitch: Double
    var voiceMorphSpeed: Double
    var voiceMorphNoiseReduction: Double
    var voiceMorphEmotion: Double
    var voiceMorphReverb: String
    var voiceMorphDistortionPreset: AVAudioUnitDistortionPreset?
    var voiceMorphDistortionWetDryMix: Float
    var voiceMorphDelayTime: TimeInterval
    var voiceMorphDelayFeedback: Float
    var voiceMorphDelayWetDryMix: Float

    init(
        voiceMorphPitch: Double,
        voiceMorphSpeed: Double,
        voiceMorphNoiseReduction: Double,
        voiceMorphEmotion: Double,
        voiceMorphReverb: String,
        voiceMorphDistortionPreset: AVAudioUnitDistortionPreset? = nil,
        voiceMorphDistortionWetDryMix: Float = 0,
        voiceMorphDelayTime: TimeInterval = 0,
        voiceMorphDelayFeedback: Float = 0,
        voiceMorphDelayWetDryMix: Float = 0
    ) {
        self.voiceMorphPitch = voiceMorphPitch
        self.voiceMorphSpeed = voiceMorphSpeed
        self.voiceMorphNoiseReduction = voiceMorphNoiseReduction
        self.voiceMorphEmotion = voiceMorphEmotion
        self.voiceMorphReverb = voiceMorphReverb
        self.voiceMorphDistortionPreset = voiceMorphDistortionPreset
        self.voiceMorphDistortionWetDryMix = voiceMorphDistortionWetDryMix
        self.voiceMorphDelayTime = voiceMorphDelayTime
        self.voiceMorphDelayFeedback = voiceMorphDelayFeedback
        self.voiceMorphDelayWetDryMix = voiceMorphDelayWetDryMix
    }

    var voiceMorphPitchCents: Float {
        Float((voiceMorphPitch - 0.5) * 2400)
    }

    var voiceMorphRate: Float {
        Float(0.55 + voiceMorphSpeed * 1.15)
    }

    var voiceMorphReverbWetDryMix: Float {
        switch voiceMorphReverb {
        case "KTV":
            return 14
        case "Room":
            return 8
        case "Ethereal":
            return 16
        case "Concert":
            return 18
        default:
            return 10
        }
    }

    var voiceMorphHighPassGain: Float {
        Float(-18 * voiceMorphNoiseReduction)
    }

    var voiceMorphEmotionHighGain: Float {
        Float((voiceMorphEmotion - 0.5) * 8)
    }
}

enum VoiceMorphAudioFileBox {
    static func voiceMorphRecordingsDirectory() throws -> URL {
        let voiceDocumentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let voiceDirectoryURL = voiceDocumentsURL.appendingPathComponent("HiViviVoiceMorph", isDirectory: true)
        if !FileManager.default.fileExists(atPath: voiceDirectoryURL.path) {
            try FileManager.default.createDirectory(at: voiceDirectoryURL, withIntermediateDirectories: true)
        }
        return voiceDirectoryURL
    }

    static func voiceMorphNewFileURL(prefix voicePrefix: String, extension voiceExtension: String = "m4a") throws -> URL {
        try voiceMorphRecordingsDirectory()
            .appendingPathComponent("\(voicePrefix)_\(UUID().uuidString).\(voiceExtension)")
    }
}

final class VoiceMorphAudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published private(set) var voiceMorphIsRecording = false

    private var voiceMorphRecorder: AVAudioRecorder?
    private var voiceMorphFinishHandler: ((Result<URL, Error>) -> Void)?
    private var voiceMorphOutputURL: URL?

    func voiceMorphStartRecording(completion: @escaping (Result<URL, Error>) -> Void) {
        voiceMorphFinishHandler = completion

        let voiceSession = AVAudioSession.sharedInstance()
        voiceSession.requestRecordPermission { [weak self] voiceGranted in
            DispatchQueue.main.async {
                guard let self else { return }

                guard voiceGranted else {
                    completion(.failure(VoiceMorphAudioError.microphoneDenied))
                    return
                }

                do {
                    try voiceSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetoothHFP])
                    try voiceSession.setActive(true)

                    let voiceOutputURL = try VoiceMorphAudioFileBox.voiceMorphNewFileURL(prefix: "voice_morph_original")
                    let voiceSettings: [String: Any] = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44_100,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]

                    let voiceRecorder = try AVAudioRecorder(url: voiceOutputURL, settings: voiceSettings)
                    voiceRecorder.delegate = self
                    voiceRecorder.isMeteringEnabled = true
                    voiceRecorder.record()

                    self.voiceMorphOutputURL = voiceOutputURL
                    self.voiceMorphRecorder = voiceRecorder
                    self.voiceMorphIsRecording = true
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    func voiceMorphStopRecording() {
        guard voiceMorphIsRecording else { return }
        voiceMorphRecorder?.stop()
        voiceMorphIsRecording = false

        if let voiceOutputURL = voiceMorphOutputURL {
            voiceMorphFinishHandler?(.success(voiceOutputURL))
        }

        voiceMorphRecorder = nil
        voiceMorphOutputURL = nil
        voiceMorphFinishHandler = nil
    }

    func voiceMorphCancelRecording() {
        voiceMorphRecorder?.stop()
        voiceMorphRecorder?.deleteRecording()
        voiceMorphIsRecording = false
        voiceMorphRecorder = nil
        voiceMorphOutputURL = nil
        voiceMorphFinishHandler = nil
    }
}

enum VoiceMorphAudioProcessor {
    static func voiceMorphRenderProcessedFile(
        sourceURL voiceSourceURL: URL,
        config voiceConfig: VoiceMorphAudioConfig
    ) throws -> URL {
        let voiceSourceFile = try AVAudioFile(forReading: voiceSourceURL)
        let voiceSourceFormat = voiceSourceFile.processingFormat
        let voiceDestinationURL = try VoiceMorphAudioFileBox.voiceMorphNewFileURL(prefix: "voice_morph_processed")

        let voiceEngine = AVAudioEngine()
        let voicePlayer = AVAudioPlayerNode()
        let voicePitch = AVAudioUnitTimePitch()
        let voiceEQ = AVAudioUnitEQ(numberOfBands: 2)
        let voiceDistortion = AVAudioUnitDistortion()
        let voiceDelay = AVAudioUnitDelay()
        let voiceReverb = AVAudioUnitReverb()

        voicePitch.pitch = voiceConfig.voiceMorphPitchCents
        voicePitch.rate = voiceConfig.voiceMorphRate

        let voiceNoiseBand = voiceEQ.bands[0]
        voiceNoiseBand.filterType = .highPass
        voiceNoiseBand.frequency = 95
        voiceNoiseBand.bypass = false
        voiceNoiseBand.gain = voiceConfig.voiceMorphHighPassGain

        let voiceEmotionBand = voiceEQ.bands[1]
        voiceEmotionBand.filterType = .highShelf
        voiceEmotionBand.frequency = 3_200
        voiceEmotionBand.bypass = false
        voiceEmotionBand.gain = voiceConfig.voiceMorphEmotionHighGain

        if let voiceDistortionPreset = voiceConfig.voiceMorphDistortionPreset {
            voiceDistortion.loadFactoryPreset(voiceDistortionPreset)
            voiceDistortion.wetDryMix = voiceConfig.voiceMorphDistortionWetDryMix
        } else {
            voiceDistortion.wetDryMix = 0
        }

        voiceDelay.delayTime = voiceConfig.voiceMorphDelayTime
        voiceDelay.feedback = voiceConfig.voiceMorphDelayFeedback
        voiceDelay.wetDryMix = voiceConfig.voiceMorphDelayWetDryMix

        switch voiceConfig.voiceMorphReverb {
        case "KTV":
            voiceReverb.loadFactoryPreset(.mediumHall)
        case "Room":
            voiceReverb.loadFactoryPreset(.mediumRoom)
        case "Ethereal":
            voiceReverb.loadFactoryPreset(.cathedral)
        case "Concert":
            voiceReverb.loadFactoryPreset(.largeHall)
        default:
            voiceReverb.loadFactoryPreset(.mediumRoom)
        }
        voiceReverb.wetDryMix = voiceConfig.voiceMorphReverbWetDryMix

        voiceEngine.attach(voicePlayer)
        voiceEngine.attach(voicePitch)
        voiceEngine.attach(voiceEQ)
        voiceEngine.attach(voiceDistortion)
        voiceEngine.attach(voiceDelay)
        voiceEngine.attach(voiceReverb)

        voiceEngine.connect(voicePlayer, to: voicePitch, format: voiceSourceFormat)
        voiceEngine.connect(voicePitch, to: voiceEQ, format: voiceSourceFormat)
        voiceEngine.connect(voiceEQ, to: voiceDistortion, format: voiceSourceFormat)
        voiceEngine.connect(voiceDistortion, to: voiceDelay, format: voiceSourceFormat)
        voiceEngine.connect(voiceDelay, to: voiceReverb, format: voiceSourceFormat)
        voiceEngine.connect(voiceReverb, to: voiceEngine.mainMixerNode, format: voiceSourceFormat)

        let voiceMaxFrames: AVAudioFrameCount = 4_096
        try voiceEngine.enableManualRenderingMode(.offline, format: voiceSourceFormat, maximumFrameCount: voiceMaxFrames)
        try voiceEngine.start()

        voicePlayer.scheduleFile(voiceSourceFile, at: nil)
        voicePlayer.play()

        let voiceOutputFile = try AVAudioFile(
            forWriting: voiceDestinationURL,
            settings: voiceSourceFile.fileFormat.settings
        )
        guard let voiceBuffer = AVAudioPCMBuffer(
            pcmFormat: voiceEngine.manualRenderingFormat,
            frameCapacity: voiceEngine.manualRenderingMaximumFrameCount
        ) else {
            throw VoiceMorphAudioError.bufferCreationFailed
        }

        while voiceEngine.manualRenderingSampleTime < voiceSourceFile.length {
            let voiceFramesToRender = min(
                voiceBuffer.frameCapacity,
                AVAudioFrameCount(voiceSourceFile.length - voiceEngine.manualRenderingSampleTime)
            )

            switch try voiceEngine.renderOffline(voiceFramesToRender, to: voiceBuffer) {
            case .success:
                try voiceOutputFile.write(from: voiceBuffer)
            case .insufficientDataFromInputNode:
                break
            case .cannotDoInCurrentContext:
                continue
            case .error:
                throw VoiceMorphAudioError.renderFailed
            @unknown default:
                throw VoiceMorphAudioError.renderFailed
            }
        }

        voicePlayer.stop()
        voiceEngine.stop()
        voiceEngine.disableManualRenderingMode()
        return voiceDestinationURL
    }
}

enum VoiceMorphAudioError: LocalizedError {
    case microphoneDenied
    case bufferCreationFailed
    case renderFailed

    var errorDescription: String? {
        switch self {
        case .microphoneDenied:
            return "Microphone permission is required."
        case .bufferCreationFailed:
            return "Could not create audio buffer."
        case .renderFailed:
            return "Could not render processed audio."
        }
    }
}
