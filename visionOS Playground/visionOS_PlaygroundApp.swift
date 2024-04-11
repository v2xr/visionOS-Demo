//
//  visionOS_PlaygroundApp.swift
//  visionOS Playground
//
//  Created by V2XR on 2024/4/6.
//

import SwiftUI

@main
struct visionOS_PlaygroundApp: App {
  @State var dataModel = DataModel()
  @State var tableKeyboardModel = TableKeyboardModel()
  
  var body: some Scene {
    WindowGroup {
      HomeView()
        .environment(dataModel)
    }.defaultSize(.init(width: 450, height: 640))

    WindowGroup(id: "portalDemo") {
      PortalDemo().environment(dataModel)
    }
    .windowStyle(.volumetric)
    .defaultSize(.init(width: 0.15, height: 0.15, depth: 0.5), in: .meters)

    // ARKit - HandPalmParticle
    ImmersiveSpace(id: "HandPalmParticle") {
      HandPalmParticle()
    }
    // ARKit - HandAttachment
    ImmersiveSpace(id: "HandAttachment") {
      HandAttachmentView()
        .upperLimbVisibility(.hidden)
    }
    // ARKit - PlaneDetection
    ImmersiveSpace(id: "PlaneDetection") {
      PlaneDetectionView()
        .environment(dataModel)
    }
    // ARKit - TableSketchpad
    ImmersiveSpace(id: "TableSketchpad") {
      TableSketchpadView()
    }

    // ARKit - TableKeyboards
    ImmersiveSpace(id: "TableKeyboards") {
      TableKeyboards()
        .environment(tableKeyboardModel)
    }
  }
}
