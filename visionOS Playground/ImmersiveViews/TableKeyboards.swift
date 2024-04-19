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
  @State private var inputable = false

  @State private var inputText = ""
  @State private var nuLines = 1 // 当前行数
  @State private var currentLineChars = 0 // 当前行字符数
  @State private var currentChar = ""

  @State private var showFingerTips = true
  @State private var useIndexFingerOnly = false
  private let LINE_CHAR_LIMIT = 15

  var body: some View {
    RealityView { content, attachments in
      content.add(model.setUpContent())

      collisionSubscription = content.subscribe(to: CollisionEvents.Began.self, on: nil, componentType: KeyFingerComponent.self) { event in
        if !inputable {
          return
        }
        print("Handle keystroke \(event.entityA.name) -> \(event.entityB.name)")
        let entityA = event.entityA
        let entityB = event.entityB
        if entityA.name.contains("Finger") && entityB.name.contains("KEY") {
          let key = entityB.name.split(separator: "-").last!.description
          currentChar = key
          if key == "↩︎" {
            let controller = entityB.prepareAudio(model.gameSounds["carriage"]!)
            controller.gain = 150
            controller.play()
            inputText += "\n"
            nuLines += 1
          } else {
            let controller = entityB.prepareAudio(model.gameSounds["keystroke"]!)
            controller.gain = 150
            controller.play()
            if key == "←" {
              inputText = String(inputText.dropLast())
            } else if key == "↑" {
              model.keyboard?.toggleCapKey()
            } else if key == "SPACE" {
              inputText += " "
            } else {
              inputText += key
            }
          }
        }
      }

      if let preview = attachments.entity(for: "preview") {
        preview.setPosition([0, 0.01, -0.075], relativeTo: model.keyboard)
        preview.setOrientation(.init(angle: -.pi / 9, axis: [1, 0, 0]), relativeTo: nil)
        model.keyboard?.addChild(preview)
      }
      if let btnSend = attachments.entity(for: "btnSend"){
        btnSend.setPosition([0.17, 0.01, -0.075], relativeTo: model.keyboard)
        btnSend.setOrientation(.init(angle: -.pi / 9, axis: [1, 0, 0]), relativeTo: nil)
        model.keyboard?.addChild(btnSend)
      }
      if let keyboardOption = attachments.entity(for: "keyboardOptions") {
        keyboardOption.setPosition([0.25, 0, 0], relativeTo: model.keyboard)
        keyboardOption.setOrientation(.init(angle: -.pi / 2, axis: [1, 0, 0]), relativeTo: keyboardOption)
        model.keyboard?.addChild(keyboardOption)
      }

      Task {
        // Run the ARKit session after the user opens the immersive space.
        await model.runARKitSession()
      }
    } update: { _, attachments in
      if let preview = attachments.entity(for: "preview") {
        preview.setPosition([0, 0.01 * Float(1 + nuLines), -0.075], relativeTo: model.keyboard)
      }
    } attachments: {
      Attachment(id: "preview") {
        Text(inputText)
          .font(.system(size: 12))
          .fontDesign(.serif)
          .padding(4)
          .frame(width: 300, height: 25 * CGFloat(nuLines))
          .glassBackgroundEffect()
      }
      Attachment(id: "btnSend") {
        Button {
          print("Send")
        } label: {
          Image(systemName: "paperplane.fill")
        }
        .buttonBorderShape(.circle)
        .font(.system(size: 8))
//        .frame(width: 25, height: 25)
      }

      Attachment(id: "keyboardOptions") {
        VStack {
          Text("Options")
          Divider()
          Toggle(isOn: $showFingerTips) {
            Text("Show FingerTips")
          }
          Toggle(isOn: $useIndexFingerOnly) {
            Text("Use IndexFingers Only")
          }
        }
        .padding()
        .font(.system(size: 10))
        .frame(width: 200, height: 150)
        .glassBackgroundEffect()
      }
    }
//    .installGestures()
    .task {
      await model.processHandTrackingUpdates()
    }
    .task(priority: .low) {
      await model.processPlaneDetectionUpdates()
    }
    .gesture(SpatialTapGesture().handActivationBehavior(.pinch).targetedToAnyEntity().onEnded { value in
      if value.entity.name.contains("Plane") {
        print("Tapped: ", value.entity.name)
        let location3D = value.convert(value.location3D, from: .local, to: .scene)
        model.updateKeyboardLocation(location: location3D)
        inputable = true
      }
    })
  }
}

#Preview {
  TableKeyboards()
    .environment(TableKeyboardModel())
}
