//
//  ContentView.swift
//  ComoSeDice
//
//  Created by Willeam Mendez  on 2/17/26.
//

import SwiftUI

struct TranslateView: View {
    @State private var sliderValue: Double = 50
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("This will be the main translate screen")
            Button("Test slider") {
                print("Translate")
            }
            Slider(value: $sliderValue, in: 1...100, step: 1)
            Text("Value: \(Int(sliderValue))")
        }
        .padding()
    }
}

#Preview {
    TranslateView()
}
