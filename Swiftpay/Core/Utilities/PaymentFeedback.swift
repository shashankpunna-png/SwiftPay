import AVFoundation
import UIKit

enum PaymentFeedback {
    private static var player: AVAudioPlayer?

    static func playSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        play(named: "PaymentSuccess")
    }

    static func playCoins() {
        play(named: "CoinDrop")
    }

    private static func play(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            return
        }
    }
}
