//
//  DragToShootComponent.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/19.
//

import RealityKit
import simd
import SwiftUI

public class DragToShootState {
  var targetEntity: Entity?
  var forceIndicator = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [UnlitMaterial(color: .white.withAlphaComponent(0.2))])

  var initPosition: SIMD3<Float> = .zero
  var latestPostion: SIMD3<Float> = .zero
  var isDragging = false

  static let shared = DragToShootState()
}

// public class
public struct DragToShootComponent: Component {
  var forceDistLimit: Float = 0.1
  init(limit: Float = 0.1) {
    forceDistLimit = limit
  }

  func handleDragChange(value: EntityTargetValue<DragGesture.Value>) {
    guard let pb = value.entity as? HasPhysicsBody else {
      return
    }
    pb.components[PhysicsBodyComponent.self]?.mode = .static
//    print(value.entity.position, value.entity.position(relativeTo: nil))

    let state = DragToShootState.shared
    if state.targetEntity == nil {
      state.targetEntity = value.entity
    }

    guard let entity = state.targetEntity else {
      fatalError("Gestre no entity")
    }

    if !state.isDragging {
      state.isDragging = true
      state.initPosition = entity.position
      state.forceIndicator.position = entity.position
      state.forceIndicator.setParent(entity)
    }
    let dragPosition = value.convert(value.gestureValue.translation3D, from: .local, to: entity)
//    state.forceIndicator.setPosition(dragPosition, relativeTo: state.targetEntity)
    let dragDistance = simd_distance(dragPosition, .zero)
    print("Init position: \(state.initPosition.describe()), Drag position: \(dragPosition.describe()), Drag distance: \(dragDistance)")

//    state.forceIndicator.position = dragPosition

    if dragDistance < forceDistLimit {
      state.forceIndicator.position = dragPosition
    } else {
      // only update direction
      let direction = simd_normalize(dragPosition)
      state.forceIndicator.position = direction * forceDistLimit
    }
  }

  func handleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
    print("Handle Drag End")
    let state = DragToShootState.shared
//    let endPosition = state.forceIndicator.position
    let endPosition = value.convert(value.gestureValue.translation3D, from: .local, to: state.targetEntity!)
    let forceVector: SIMD3<Float> = -endPosition

    state.isDragging = false
    state.forceIndicator.removeFromParent()
    state.targetEntity = nil

    guard let pb = value.entity as? HasPhysicsBody else {
      return
    }
    pb.components[PhysicsBodyComponent.self]?.mode = .dynamic
    pb.addForce(forceVector.normalized() * 0.5, relativeTo: nil)
  }
}

extension SIMD3<Float> {
  func normalized() -> SIMD3<Float> {
    return self / simd_length(self)
  }

  func describe() -> String {
    return "(\(String(format: "%.2f", x)), \(String(format: "%.2f", y)), \(String(format: "%.2f", z)))"
  }
}
