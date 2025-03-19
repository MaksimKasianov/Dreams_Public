import AVFoundation

class AudioRecorder {
    var audioRecorder: AVAudioRecorder?

    private func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }
    
    func startRecording() {
        checkMicrophonePermission { permissionGranted in
            if !permissionGranted {
                print("Microphone access denied.")
                return
            }
        }
        
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let audioFilename = FileManager.default.getAudioDirectory().appendingPathComponent("recording.m4a")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ] as [String : Any]

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
        } catch {
            // Handle any recording errors here
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
    }
}
