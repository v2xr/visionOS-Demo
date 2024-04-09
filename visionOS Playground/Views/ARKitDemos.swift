//
//  ARKitDemos.swift
//  visionOS Playground
//
//  Created by V2XR on 2024/4/6.
//

import RealityKit
import SwiftUI

struct ARKitDemos: View {
  @State private var immersiveSpaceID = ""

  @State private var showHandPalmParticle = false
  @State private var showHandAttachment = false
  @State private var showPlaneDetection = false

  @Environment(DataModel.self) var model
  @Environment(\.openImmersiveSpace.self) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace.self) var dissmissImmersiveSpace
  @State private var immersiveSpaceIsShown = false {
    didSet {
      if !immersiveSpaceIsShown {
        showHandPalmParticle = false
        showHandAttachment = false
      }
    }
  }

  var body: some View {
    List {
      Toggle(isOn: $showHandPalmParticle) {
        HStack {
          Image(systemName: "hands.and.sparkles")
          Text("Hand Palm Particle")
        }
      }.toggleStyle(.switch)
      Toggle(isOn: $showHandAttachment) {
        HStack {
          Image(systemName: "hand.point.up.left.and.text")
          Text("Hand Attachment UI")
        }
      }.toggleStyle(.switch)
    }
    .onChange(of: showHandPalmParticle) { _, newValue in
      if showHandPalmParticle {
        immersiveSpaceID = "HandPalmParticle"
      }
      Task {
        await onChangeTask(toggle: newValue)
      }
    } // end onChange
    .onChange(of: showHandAttachment) { _, newValue in
      if showHandAttachment {
        immersiveSpaceID = "HandAttachment"
      }
      Task {
        await onChangeTask(toggle: newValue)
      }
    }
  }

  func onChangeTask(toggle: Bool) async {
    if toggle {
      switch await openImmersiveSpace(id: immersiveSpaceID) {
      case .opened:
        immersiveSpaceIsShown = true
      case .error,
           .userCancelled:
        fallthrough
      @unknown default:
        immersiveSpaceIsShown = false
      }
    } else if immersiveSpaceIsShown {
      await dissmissImmersiveSpace()
      immersiveSpaceIsShown = false
    }
  }
}

#Preview {
  ARKitDemos().environment(DataModel())
}
