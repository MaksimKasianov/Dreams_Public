import Speech
import AVFoundation


class SpeechRec {

    static let shared = SpeechRec()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var audioRecorder: AVAudioRecorder?
    private var timerAmplitude: Timer?
    
    var parentVC: NewDreamVC!
    var timer: Timer?
    var isRecord: Bool = false
    var tempText = ""
    
    func start(text: String) {
        tempText = text
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category.")
            return
        }
        
        SpeechRec.requestSpeechRecognizer { success in
            if success {
                do {
                    try self.startRecording()
                    self.captureAudio()
                } catch {
                    print("Failed to start recording.")
                }
            } else {
                print("Speech recognition not authorized.")
            }
        }
    }
    
    func stop() {
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        timer?.invalidate()
        timerAmplitude?.invalidate()
        if let audioRecorder = audioRecorder {
            audioRecorder.stop()
            self.audioRecorder = nil
        }
    }
    
    static func requestSpeechRecognizer(completionHandler: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                completionHandler(authStatus == .authorized)
            }
        }
    }
    
    private func startRecording() throws {
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) else {
            print("Speech recognizer not available for the current locale.")
            return
        }
        self.speechRecognizer = speechRecognizer

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create a recognition request.")
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.inputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start the audio engine.")
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                
                var resultText = ""
                if self.tempText.isEmpty {
                    resultText = result.bestTranscription.formattedString
                } else {
                    let text = result.bestTranscription.formattedString
                    let firstCharacter = text.prefix(1).lowercased()
                    let restOfString = text.dropFirst()
                    let result = firstCharacter + restOfString
                    
                    resultText = "\(self.tempText) \(result)"
                }
                self.parentVC.textOutput(resultText)
                
                if error != nil || result.isFinal {
                    self.tempText += resultText
                    self.stop()
                    print("restart")
                    self.start(text: self.tempText)
                }
            }
        }
    }
    
    
    private func captureAudio() {
        let audioFilename = FileManager.default.getAudioDirectory().appendingPathComponent("temp_record.m4a")
        var settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        let audioSession = AVAudioSession.sharedInstance()
        let sampleRate = audioSession.sampleRate
        let channels = audioSession.inputNumberOfChannels
        settings[AVSampleRateKey] = Int(sampleRate)
        settings[AVNumberOfChannelsKey] = channels

        print(audioFilename)
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()

            isRecord = true
            audioRecorder?.isMeteringEnabled = true

            timerAmplitude = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let audioRecorder = self.audioRecorder else { return }
                    audioRecorder.updateMeters()
                    let db = audioRecorder.averagePower(forChannel: 0)
                    let result = min((pow(10.0, db / 20.0) * 20), 20)

                    self.parentVC.amplitudeDB(db: result)
            }
        } catch {
            isRecord = false
            print("ERROR: Failed to start recording process.")
        }
    }
}
