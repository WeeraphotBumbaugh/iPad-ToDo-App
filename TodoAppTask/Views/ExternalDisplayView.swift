//
//  ExternalDisplayView.swift
//  TodoAppTask
//
//

import SwiftUI

struct ExternalDisplayView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "display")
                .font(.system(size: 80, weight: .bold))
            Text("TodoAppTask — External Display")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 12) {
                Label("Main iPad shows editor", systemImage: "ipad")
                Label("External shows summary", systemImage: "rectangle.on.rectangle")
                Label("HDMI / AirPlay supported", systemImage: "bolt.horizontal.circle")
            }
            .font(.headline)
        }
        .padding(40)
        .dynamicTypeSize(.medium ... .accessibility2)
    }
}
