//
//  TableKeyboardModel.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/11.
//

import ARKit
import Foundation
import RealityKit

@Observable
class TableKeyboardModel {
//  var gameSounds: [String: AudioResource] = [:]
  var rootEntity = Entity()
  var keyboard: ModelEntity?
  var planeDetection = PlaneDetectionProvider()
  var handTracking = HandTrackingProvider()
  var arkitSession = ARKitSession()

  var planeAnchorHandler: PlaneAnchorHandler?

  private var planeMeshEntities = [UUID: ModelEntity]()
  private var allFingerTipJointNames: [HandSkeleton.JointName] = [
    .thumbTip,
    .indexFingerTip,
    .middleFingerTip,
    .ringFingerTip,
    .littleFingerTip,
  ]
  private var allFingerTipEntities: [HandAnchor.Chirality: [HandSkeleton.JointName: Entity]] = [:]

  init() {
    Task { @MainActor in
      planeAnchorHandler = .init(rootEntity: rootEntity)
    }
  }

  @MainActor
  func runARKitSession() async {
    do {
      // Run a new set of providers every time when entering the immersive space.
      try await arkitSession.run([planeDetection, handTracking])
    } catch {
      // No need to handle the error here; the app is already monitoring the
      // session for error.
      return
    }
  }

  func setUpContent() -> Entity {
    rootEntity.children.removeAll()

    rootEntity.addChild(makeKeyboard())
    setupFingerTipEntities()
    return rootEntity
  }

  func processHandTrackingUpdates() async {
    for await anchorUpdate in handTracking.anchorUpdates {
      let handAnchor = anchorUpdate.anchor

      guard handAnchor.isTracked else {
        continue
      }

      for jointName in allFingerTipJointNames {
        if let joint = handAnchor.handSkeleton?.joint(jointName) {
          guard let indexEntity = allFingerTipEntities[handAnchor.chirality]?[jointName] else {
            continue
          }
          let t = matrix_multiply(handAnchor.originFromAnchorTransform, joint.anchorFromJointTransform).columns.3.xyz
          await indexEntity.setPosition(t, relativeTo: nil)
        }
      }
    }
  }

  func processPlaneDetectionUpdates() async {
    for await anchorUpdate in planeDetection.anchorUpdates {
      if anchorUpdate.anchor.classification == .table {
        await planeAnchorHandler?.process(anchorUpdate)
      }
    }
  }

  func setupFingerTipEntities() {
    allFingerTipEntities[.left] = [:]
    allFingerTipEntities[.right] = [:]
    for finger in allFingerTipJointNames {
      allFingerTipEntities[.left]![finger] = .createFingertip(hand: .left, joint: finger)
      allFingerTipEntities[.right]![finger] = .createFingertip(hand: .right, joint: finger)

      rootEntity.addChild(allFingerTipEntities[.left]![finger]!)
      rootEntity.addChild(allFingerTipEntities[.right]![finger]!)
    }
  }

  func makeKeyboard() -> ModelEntity {
    keyboard = ModelEntity(
      mesh: .generatePlane(width: 0.3, depth: 0.1, cornerRadius: 0.01),
      materials: [SimpleMaterial(color: .white, isMetallic: false)],
      collisionShapes: [.generateBox(width: 0.3, height: 0.001, depth: 0.1)],
      mass: 0.0
    )
    keyboard?.name = "Keyboard"
    var material = PhysicallyBasedMaterial() // SimpleMaterial(color: .white, isMetallic: false)
    if let baseResource = try? TextureResource.load(named: "QWERT.png") {
      // Create a material parameter and assign it.
      let baseColor = MaterialParameters.Texture(baseResource)
      material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: baseColor)
      keyboard?.components[ModelComponent.self]?.materials = [material]
    } else {
      print("Failed to load texture")
    }

    keyboard?.components.set(PhysicsBodyComponent(mode: .static))
    keyboard?.components.set(InputTargetComponent(allowedInputTypes: .indirect))
    keyboard?.components.set(GestureComponent(canDrag: false, canScale: false, canRotate: true))
    return keyboard!
  }

  func updateKeyboardLocation(location: SIMD3<Float>) {
    let keyboardLocation = location + [0, 0.005, 0]
    keyboard?.transform.translation = keyboardLocation
  }
}

extension Entity {
  /// Creates an invisible sphere that can interact with dropped cubes in the scene.
  class func createFingertip(hand: HandAnchor.Chirality, joint: HandSkeleton.JointName) -> Entity {
    let entity = Entity()
    entity.components[ModelComponent.self] = .init(mesh: .generateSphere(radius: 0.005), materials: [UnlitMaterial(color: .green)])
    entity.components[CollisionComponent.self] = .init(shapes: [.generateSphere(radius: 0.015)])

    /*
     entity.components.set(
       PhysicsBodyComponent(
         shapes: entity.collision!.shapes,
         mass: 0.1,
         mode: .static
       )
     )
      */
//    entity.components.set(OpacityComponent(opacity: 0.5))
    entity.name = "Finger \(hand)-\(joint)"
    return entity
  }
}
