//
//  HandAttachmentView.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/7.
//

import RealityKit
import RealityKitContent
import RealityUI
import SwiftUI

struct HandAttachmentView: View {
  @State private var handUI = false
  @State private var handUIColor: Color = .white
  @State private var volume: Float = 0.0
  var body: some View {
    RealityView { content, attachments in
      let handAnchor = AnchorEntity(.hand(.left, location: .palm))
      handAnchor.anchoring.trackingMode = .continuous
      let wristAnchor = AnchorEntity(.hand(.left, location: .wrist))
      wristAnchor.anchoring.trackingMode = .continuous

      let ocPlane = ModelEntity(mesh: .generatePlane(width: 0.1, depth: 0.1, cornerRadius: 0.1), materials: [OcclusionMaterial()])
      ocPlane.setParent(wristAnchor)
      ocPlane.setPosition([0, 0.025, 0], relativeTo: wristAnchor)

      if let wristAttachment = attachments.entity(for: "menu") {
        wristAttachment.components.set(InputTargetComponent())
        wristAttachment.setOrientation(.init(angle: .pi / 2, axis: [1, 0, 0]), relativeTo: wristAttachment)
        wristAttachment.setOrientation(.init(angle: .pi / 2, axis: [0, 0, -1]), relativeTo: wristAttachment)
        wristAttachment.setPosition([0, -0.015, 0], relativeTo: wristAnchor)
        wristAttachment.setParent(wristAnchor)
      }

      content.add(handAnchor)
      content.add(wristAnchor)

    } update: { content, attachments in
      if let handAttachment = attachments.entity(for: "hand") {
        if handUI {
          if let handAnchor = content.entities.first {
            handAttachment.setOrientation(.init(angle: -.pi / 2, axis: [1, 1, 1]), relativeTo: nil)
            handAttachment.setPosition([0, 0, 0.2], relativeTo: handAnchor)
            handAttachment.setParent(handAnchor)
          }
        } else {
          handAttachment.removeFromParent()
        }
      }
    } attachments: {
      Attachment(id: "menu") {
        Button {
          handUI.toggle()
        } label: {
          Image(systemName: "apple.logo")
            .font(.title)
            .bold()
        }
        .frame(width: 40, height: 40)
        .cornerRadius(20)
      }
      Attachment(id: "hand") {
        VStack {
          Text("Home Menu")
          Divider()
          /*
          Toggle(isOn: $handUI, label: {
            HStack {
              Image(systemName: "hand.point.up.left.and.text")
            }
          })
           */
          HStack {
            Image(systemName: "sun.rain")
              .padding(8)
              .font(.headline)
            Image(systemName: "mountain.2")
              .padding(8)
              .font(.headline)
            Image(systemName: "battery.75percent")
              .padding(8)
              .font(.headline)
            Image(systemName: "bell.slash")
              .padding(8)
              .font(.headline)
          }
          Slider(value: $volume, in: 0 ... 100, step: 10) {
          } minimumValueLabel: {
            Image(systemName: "speaker.wave.1")
          } maximumValueLabel: {
            Image(systemName: "speaker.wave.3")
          }
          .padding()
        }
        .padding()
        .frame(width: 300)
//        .foregroundColor(handUIColor)
        .glassBackgroundEffect()
      }
    }
    .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { value in
      print("Tapped: ", value.entity.name)
    })
  }
}

#Preview {
  HandAttachmentView()
}
