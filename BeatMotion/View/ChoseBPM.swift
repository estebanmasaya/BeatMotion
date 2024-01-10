//
//  ChoseBPM.swift
//  BeatMotion
//
//  Created by Niklas Roslund on 2024-01-10.
//

import SwiftUI

struct ChoseBPM: View {
    @EnvironmentObject var theViewModel : ViewModelBM
    //@State private var sliderValue: Double = 90
    var body: some View {
        VStack {
            Slider(value: $theViewModel.sliderValue, in: 0...300)

            Text("BPM Value: \(theViewModel.sliderValue, specifier: "%.0f")")
        }
    }
}

#Preview {
    ChoseBPM().environmentObject(ViewModelBM())
}
