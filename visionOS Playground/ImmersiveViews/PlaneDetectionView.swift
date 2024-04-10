//
//  ImmersiveView.swift
//  Spatial Bowling
//
//  Created by 孙雨生 on 2024/4/2.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct PlaneDetectionView: View {
  @Environment(DataModel.self) var model

  @State var dropBall = false

  var body: some View {
    ZStack {
      RealityView { content in
        // Add the initial RealityKit content
        content.add(model.setupContentEntity())
        content.add(model.handAnchor)

        Task {
          await model.run()
        }
      }
      .task {
//              await model.processHandUpdates()
      }
      .task(priority: .low) {
        await model.processReconstructionUpdates()
      }
    }
  }
}
