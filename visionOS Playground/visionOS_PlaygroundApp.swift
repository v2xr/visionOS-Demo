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

  let defaultWinSize: Size3D = .init(vector: [0.4, 0.2, 0.2])

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

    WindowGroup(id: "tempWindow") {
      TempView().environment(tableKeyboardModel)
    }
    .windowStyle(.automatic)

    WindowGroup(id: "multiverse") {
      MultiverseView(size: defaultWinSize)
        .environment(dataModel)
    }
    WindowGroup(id: "universeView", for: UniverseData.self) { $value in
      UniverseVolView(
        universeData: value!
      )
      .environment(dataModel)
    }
    .windowStyle(.volumetric)
    .defaultSize(defaultWinSize, in: .meters)

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
