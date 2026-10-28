import AVFoundation
import Combine

/// Plays one looping background sound across the app.
final class SoundPlayer: ObservableObject {
    static let shared = SoundPlayer()

    @Published private(set) var isMuted = false
    private var player: AVAudioPlayer?
    private var currentVolume: Float = 0.6

    /// Used by the mood page. Always plays out loud, even if the drawing page was muted before.
    func play(_ sound: Sound) {
        isMuted = false

        let url = ["mp3", "m4a", "wav"]
            .lazy
            .compactMap { Bundle.main.url(forResource: sound.fileName, withExtension: $0) }
            .first

        guard let url else {
            print("Sound file '\(sound.fileName)' was not found in the project")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            currentVolume = sound.volume
            player?.numberOfLoops = -1
            player?.volume = isMuted ? 0 : currentVolume
            player?.prepareToPlay()
            player?.play()
            print("Playing \(url.lastPathComponent)")
        } catch {
            print("Could not play \(url.lastPathComponent): \(error.localizedDescription)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    func toggleMute() {
        isMuted.toggle()
        player?.volume = isMuted ? 0 : currentVolume
    }
}
