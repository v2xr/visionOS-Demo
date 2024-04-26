//
//  UniverseBox.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/17.
//

import Foundation
import RealityKit
import SwiftUI

class UniverseBox: Entity {
  var data: UniverseData
  var faces: [Faces: ModelEntity] = [:]

  var ball: ModelEntity?
  var ballSize: Float = 0.01

  var color: Color = .white

  let physicsMaterial: PhysicsMaterialResource = .generate(friction: 0.5, restitution: 1)
  init(data: UniverseData, color: Color = .white) {
    self.data = data
    self.color = color

    super.init()
    let defaultSize = data.size
    name = "Box-\(data.order)"

    let material = UnlitMaterial(color: UIColor(color).withAlphaComponent(0.25))

    let backShape: ShapeResource = .generateBox(width: Float(defaultSize.width), height: Float(defaultSize.height), depth: data.DEPTH)
    let back = ModelEntity(mesh: .generateBox(width: Float(defaultSize.width), height: Float(defaultSize.height), depth: data.DEPTH, cornerRadius: data.DEPTH / 2), materials: [material])
    back.name = "Face-Back"
    back.position.z = Float(-defaultSize.depth / 2)
    back.components.set(CollisionComponent(shapes: [backShape], isStatic: true))
    back.components.set(PhysicsBodyComponent(shapes: [backShape], mass: 1.0, material: physicsMaterial, mode: .static))
    faces[.back] = back

    let front = ModelEntity(mesh: .generatePlane(width: Float(defaultSize.width), height: Float(defaultSize.height)), materials: [UnlitMaterial(color: .white)])
    front.components.set(OpacityComponent(opacity: 0))
    front.components.set(CollisionComponent(shapes: [backShape], isStatic: true))
    front.components.set(PhysicsBodyComponent(shapes: [backShape], mass: 1.0, material: physicsMaterial, mode: .static))
    front.position.z = Float(defaultSize.depth / 2)
    addChild(front)

    let leftRightShape: ShapeResource = .generateBox(width: data.DEPTH, height: Float(defaultSize.height), depth: Float(defaultSize.depth))
    let left = ModelEntity(mesh: .generateBox(width: data.DEPTH, height: Float(defaultSize.height), depth: Float(defaultSize.depth), cornerRadius: data.DEPTH / 2), materials: [material])
    left.name = "Face-Left"
    left.position.x = Float(-defaultSize.width / 2)
    left.components.set(CollisionComponent(shapes: [leftRightShape], isStatic: true))
    left.components.set(PhysicsBodyComponent(shapes: [leftRightShape], mass: 1.0, material: physicsMaterial, mode: .static))
    faces[.left] = left

    let right = ModelEntity(mesh: .generateBox(width: data.DEPTH, height: Float(defaultSize.height), depth: Float(defaultSize.depth), cornerRadius: data.DEPTH / 2), materials: [material])
    right.name = "Face-Right"
    right.position.x = Float(defaultSize.width / 2)
    right.components.set(CollisionComponent(shapes: [leftRightShape], isStatic: true))
    right.components.set(PhysicsBodyComponent(shapes: [leftRightShape], mass: 1.0, material: physicsMaterial, mode: .static))
    faces[.right] = right

    let topBottomShape: ShapeResource = .generateBox(width: Float(defaultSize.width), height: data.DEPTH, depth: Float(defaultSize.depth))
    let top = ModelEntity(mesh: .generateBox(width: Float(defaultSize.width), height: data.DEPTH, depth: Float(defaultSize.depth), cornerRadius: data.DEPTH / 2), materials: [material])
    top.name = "Face-Top"
    top.position.y = Float(defaultSize.height / 2)
    top.components.set(CollisionComponent(shapes: [topBottomShape], isStatic: true))
    top.components.set(PhysicsBodyComponent(shapes: [topBottomShape], mass: 1.0, material: physicsMaterial, mode: .static))

    faces[.top] = top

    let bottom = ModelEntity(mesh: .generateBox(width: Float(defaultSize.width), height: data.DEPTH, depth: Float(defaultSize.depth), cornerRadius: data.DEPTH / 2), materials: [material])
    bottom.name = "Face-Bottom"
    bottom.position.y = Float(-defaultSize.height / 2)
    bottom.components.set(CollisionComponent(shapes: [topBottomShape], isStatic: true))
    bottom.components.set(PhysicsBodyComponent(shapes: [topBottomShape], mass: 1.0, material: physicsMaterial, mode: .static))

    faces[.bottom] = bottom

    addChild(back)
    addChild(top)
    addChild(bottom)
    addChild(left)
    addChild(right)
  }

  func exitance() -> ModelEntity {
    return faces[data.exitance]!
  }

  func entrance() -> ModelEntity {
    return faces[data.entrance]!
  }

  func spawnAt(position: SIMD3<Float> = [0, 0, 0]) {
    ball = ModelEntity(mesh: .generateSphere(radius: ballSize), materials: [UnlitMaterial(color: .init(.black))])
    ball!.name = "Ball"
    ball!.components.set(CollisionComponent(shapes: [.generateSphere(radius: ballSize)], collisionOptions: [.fullContactInformation]))
    var physic: PhysicsBodyComponent = .init(shapes: [.generateSphere(radius: ballSize)], mass: 0.01, material: .generate(friction: 0.5, restitution: 1), mode: .static)
    physic.isAffectedByGravity = false
    ball!.components.set(physic)
    ball!.components.set(HoverEffectComponent())
    ball!.components.set(InputTargetComponent())
//    ball!.components.set(GestureComponent(canDrag: true, pivotOnDrag: true, canScale: false, canRotate: false))
    ball!.components.set(DragToShootComponent())
    if position.x == 0 && position.y == 0 && position.z == 0 {
//      ball!.setPosition(position, relativeTo: nil)
      ball!.position = position
    } else {
      let spawnPosition: SIMD3<Float> = [-Float(data.size.width / 2) + ballSize, position.y, position.z - Float(data.size.depth / 2)]
      ball!.setPosition(spawnPosition, relativeTo: nil)
    }

    addChild(ball!)
  }

  func removeBall() {
    ball?.isEnabled = false
  }

  required init() {
    fatalError()
  }
}
