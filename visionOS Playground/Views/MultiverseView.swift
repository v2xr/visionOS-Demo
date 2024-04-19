//
//  MultiverseView.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/15.
//

import RealityKit
import SwiftUI

struct MultiverseView: View {
  @Environment(DataModel.self) var model
  @Environment(\.openWindow) var openWindow
  @Environment(\.dismissWindow) var dismissWindow

  @State var numberOfUniverses: Int = 2

  let size: Size3D
  var body: some View {
    Text("Multiverse")
      .font(.title)
      .padding(20)
    Divider()
    Spacer()
    VStack {
      Button {
        model.universeColors.shuffle()
        dismissWindow(id: "universeView")
      } label: {
        Label("Close all Universe", systemImage: "xmark.circle")
      }
      .padding()
      .glassBackgroundEffect()
      Button {
        for order in 1 ... numberOfUniverses {
          let ud = UniverseData(order: order, size: size)
          openWindow(id: "universeView", value: ud)
        }
      } label: {
        Label("Open Universe Volume", systemImage: "bonjour")
      }
      .padding()
      .glassBackgroundEffect()
      Stepper("\(numberOfUniverses) Universes", value: $numberOfUniverses, in: 2 ... 5, step: 1)
        .frame(width: 300)
        .padding()
        .glassBackgroundEffect()
    }
    Spacer()
  }
}
