// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import Foundation
import SwiftUI
import AVKit

enum ImpactGenerator {
    static func soft() {
        let impactMed = UIImpactFeedbackGenerator(style: .soft)
        impactMed.impactOccurred()
    }

    static func light() {
        let impactMed = UIImpactFeedbackGenerator(style: .light)
        impactMed.impactOccurred()
    }

    static func rigid() {
        let impactMed = UIImpactFeedbackGenerator(style: .rigid)
        impactMed.impactOccurred(intensity: 0.6)
    }

    static func success() {
        let notify = UINotificationFeedbackGenerator()
        notify.notificationOccurred(.success)
    }

    static func error() {
        let notify = UINotificationFeedbackGenerator()
        notify.notificationOccurred(.error)
    }
}
#endif
