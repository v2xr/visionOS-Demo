//
//  HeaderView.swift
//  visionOS Playground
//
//  Created by V2XR on 2024/4/6.
//

import Shimmer
import SwiftUI

struct HeaderView: View {
  var body: some View {
    HStack {
      Text("XRI Experiences")
      Image(systemName: "visionpro.fill")
    }
    .font(.title)
    .fontWeight(.bold)
    .padding(20)
    .shimmering()
  }
}

#Preview {
  HeaderView()
}
