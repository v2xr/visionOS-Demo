//
//  TableKeyboards.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/11.
//

import Combine
import RealityKit
import SwiftUI

struct TableKeyboards: View {
  @Environment(TableKeyboardModel.self) var model
  @State private var collisionSubscription: EventSubscription?
  
  @State private var inputText = "Preview"

  var body: some View {
    RealityView { content, attachments in
      content.add(model.setUpContent())

      collisionSubscription = content.subscribe(to: CollisionEvents.Began.self, on: model.keyboard, componentType: nil) { event in
        print("Handle keystroke \(event.position)")
        if event.entityB.name.contains("Finger"){
          inputText = "keystroke @ [\(String(format: "%.2f", event.position.x)), \(String(format: "%.2f", event.position.y)), \(String(format: "%.2f", event.position.z))]"
        }
      }
      
      if let preview = attachments.entity(for: "preview") {
        preview.setPosition([0,0.01,-0.06], relativeTo: model.keyboard)
        preview.setOrientation(.init(angle: -.pi/9, axis: [1,0,0]), relativeTo: nil)
        model.keyboard?.addChild(preview)
      }

      Task {
        // Run the ARKit session after the user opens the immersive space.
        await model.runARKitSession()
      }
    } update: { _, _ in
      
    } attachments: {
      Attachment(id: "preview") {
        Text(inputText)
          .font(.caption)
          .padding(4)
          .frame(width: 300, height: 20)
          .glassBackgroundEffect()
      }
    }
      .installGestures()
      .task {
        await model.processHandTrackingUpdates()
      }
      .task(priority: .low) {
        await model.processPlaneDetectionUpdates()
      }
      .gesture(SpatialTapGesture().handActivationBehavior(.pinch).targetedToAnyEntity().onEnded { value in
        print("Tapped: ", value.entity.name)
        if value.entity.name.contains("Plane") {
          let location3D = value.convert(value.location3D, from: .local, to: .scene)
          model.updateKeyboardLocation(location: location3D)
        }
      })
  }
}

#Preview {
  TableKeyboards()
    .environment(TableKeyboardModel())
}
