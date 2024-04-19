//
//  DataModel.swift
//  visionOS Playground
//
//  Created by V2XR on 2024/4/6.
//

import ARKit
import Foundation
import RealityKit
import RealityKitContent
import SwiftUI

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

  var universes: [Int: UniverseBox] = [:]
  var universeColors: [Color] = [.white, .pink, .orange, .cyan, .mint, .purple]

  init() {
    Task { @MainActor in
      universeColors.shuffle()
      fireBall = try! await Entity(named: "Fireball", in: realityKitContentBundle)
      do {
        let keystroke = try await AudioFileResource(named: "ball.mp3")
        gameSounds["keystroke"] = keystroke
      } catch {
        fatalError("Error loading cloud sound resources.")
      }
    }
  }

  func handleCollision(event: CollisionEvents.Began, universe: UniverseData) {
    let controller = event.entityA.prepareAudio(gameSounds["keystroke"]!)
    controller.play()

    guard let box = event.entityB.parent as? UniverseBox else {
      return
    }

    if box.exitance().name == event.entityB.name {
      print("Exit! @ \(event.position)")
      box.removeBall()
      if let nextUniverse = getNextUniverse(order: universe.order) {
        nextUniverse.spawnAt(position: event.position)
      }
    }
  }

  func getNextUniverse(order: Int) -> UniverseBox? {
    if let next = universes[order + 1] {
      return next
    } else {
      return universes[1]
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
