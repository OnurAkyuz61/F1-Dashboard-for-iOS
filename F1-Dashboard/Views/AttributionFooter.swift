//
//  AttributionFooter.swift
//  F1-Dashboard
//

import SwiftUI

struct AttributionFooter: View {
    var body: some View {
        Text("Data provided by Jolpi/Ergast API. F1, FORMULA 1, and related marks are trademarks of Formula One Licensing BV.")
            .font(.system(size: 11, weight: .regular, design: .default))
            .foregroundColor(.white.opacity(0.45))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.top, 8)
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        AttributionFooter()
    }
}
