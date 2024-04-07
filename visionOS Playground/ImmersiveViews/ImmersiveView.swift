//
//  ImmersiveView.swift
//  visionOS Playground
//
//  Created by V2XR on 2024/4/6.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct HandPalmParticle: View {
  var body: some View {
    RealityView { content in
      // Add the initial RealityKit content
      let handAnchor = AnchorEntity(.hand(.right, location: .palm))
      handAnchor.anchoring.trackingMode = .continuous

      let fireball = try! await Entity(named: "Fireball", in: realityKitContentBundle)
      handAnchor.addChild(fireball)

      content.add(handAnchor)
    }
  }
}

#Preview(immersionStyle: .mixed) {
  HandPalmParticle()
}
