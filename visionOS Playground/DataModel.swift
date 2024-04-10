//
//  DataModel.swift
//  visionOS Playground
//
//  Created by V2XR on 2024/4/6.
//

import Foundation
import RealityKit
import RealityKitContent
import SwiftUI
import ARKit

@Observable
class DataModel {
  var gameSounds: [String: AudioResource] = [:]
  var fireBall: Entity?
  
  let session = ARKitSession()
  let handTracking = HandTrackingProvider()
  let sceneReconstruction = SceneReconstructionProvider(modes: [.classification])
  let planeDetection = PlaneDetectionProvider()
  
  public var handAnchor = AnchorEntity(.hand(.left, location: .palm))
  var contentEntity = Entity()
  var miniRoomEntity = Entity()
  
  private var sceneReconstructionHandler: SceneReconstructionHandler?
  let miniRoomScaleFactor: Float = 0.03

  init() {
    Task { @MainActor in
      fireBall = try! await Entity(named: "Fireball", in: realityKitContentBundle)
    }
  }
  
  func run() async {
    guard PlaneDetectionProvider.isSupported else {
      print("PlaneDetectionProvider is NOT supported.")
      return
    }
    
    do {
      try await session.run([sceneReconstruction, handTracking, planeDetection])
      print("ARKit session is running...")
      
    } catch {
      print("ARKit session error \(error)")
    }
  }
  
  func setupContentEntity() -> Entity {
    handAnchor.anchoring.trackingMode = .continuous
    miniRoomEntity.setScale(.init(repeating: miniRoomScaleFactor), relativeTo: nil)
    miniRoomEntity.position.y = 0.05
    miniRoomEntity.setParent(handAnchor)
    
    sceneReconstructionHandler = .init(rootEntity: contentEntity, miniRootEntity: miniRoomEntity, meshMaterial: nil)
    return contentEntity
  }
  func processReconstructionUpdates() async {
    for await update in sceneReconstruction.anchorUpdates {
      await sceneReconstructionHandler?.process(update)
    }
  }
}
