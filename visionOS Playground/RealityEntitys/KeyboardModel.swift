//
//  KeyboardModel.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/11.
//

import Foundation
import RealityKit
import RealityUI

class KeyFingerComponent: Component {}

class Keyboard: Entity {
  static let KEYBOARD_LAYOUT: [[String]] = [
    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "←"],
    ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "↩︎"],
    ["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "↑"],
  ]
  let KEYBOARD_WIDTH: Float = 0.312 // 13 cols * 0.022
  let KEYBOARD_DEPTH: Float = 0.096 // 4 rows * 0.022

  let KEY_SIZE: Float = 0.02
  let KEY_DEPTH: Float = 0.002

  let KEY_SPACING: Float = 0.002
  let KEY_BOUNDING: Float = 0.024

  let KEY_TEXT_SCALE_FACTOR: Float = 0.5

  var isCap = true

  required init() {
    super.init()
    name = "Keyboard"

    let modelComponent = ModelComponent(
      mesh: .generateBox(width: KEYBOARD_WIDTH, height: KEY_DEPTH, depth: KEYBOARD_DEPTH, cornerRadius: KEY_SIZE),
      materials: [SimpleMaterial(color: .white.withAlphaComponent(0.1), isMetallic: false)]
    )

    components[ModelComponent.self] = modelComponent
    components[CollisionComponent.self] = .init(shapes: [.generateBox(width: KEYBOARD_WIDTH, height: KEYBOARD_DEPTH, depth: KEYBOARD_DEPTH)], isStatic: true)

    components.set(PhysicsBodyComponent(mode: .static))
    components.set(InputTargetComponent(allowedInputTypes: .indirect))
    components.set(GestureComponent(canDrag: true, canScale: false, canRotate: true))

    setupKeys()
  }

  func setupKeys() {
    for row in 0 ..< Keyboard.KEYBOARD_LAYOUT.count {
      for col in 0 ..< Keyboard.KEYBOARD_LAYOUT[row].count {
        let key = makeKey(keyname: Keyboard.KEYBOARD_LAYOUT[row][col])
        key.transform.translation = .init(
          x: (Float(col) + 0.5) * KEY_BOUNDING - KEYBOARD_WIDTH / 2 + Float(row) * 0.5 * KEY_BOUNDING,
          y: KEY_DEPTH,
          z: (Float(row) + 0.5) * KEY_BOUNDING - KEYBOARD_DEPTH / 2
        )
        addChild(key)
      }
    }

    let spaceBar = makeSpaceBar()
    spaceBar.transform.translation = .init(
      x: 0,
      y: KEY_DEPTH*2,
      z: 3.5 * KEY_BOUNDING - KEYBOARD_DEPTH / 2
    )
    addChild(spaceBar)
  }

  public func toggleCapKey() {
    isCap.toggle()
    children.removeAll(where: { $0.name.contains("KEY") })
    setupKeys()
  }

  func makeSpaceBar() -> Entity {
    let key = Entity()
    key.components[ModelComponent.self] = .init(mesh: .generatePlane(width: KEY_SIZE * 6, depth: KEY_SIZE, cornerRadius: KEY_SIZE), materials: [SimpleMaterial(color: .black, isMetallic: false)])
    key.name = "KEY-SPACE"
    key.position.y = KEY_DEPTH * 1.5
    key.components.set(PhysicsBodyComponent(mode: .static))
    key.components.set(CollisionComponent(shapes: [.generateBox(size: [KEY_SIZE * 6, KEY_DEPTH, KEY_SIZE])], isStatic: true)) // , filter: keyStrokeCollisionGroup))
    return key
  }

  func makeKey(keyname: String) -> Entity {
    let keyname = isCap ? keyname.uppercased() : keyname.lowercased()
    let key = Entity()
    key.components[ModelComponent.self] = ModelComponent(
      mesh: .generateCylinder(height: KEY_DEPTH, radius: KEY_SIZE / 2),
      materials: [SimpleMaterial(color: .black, isMetallic: false)]
    )
    key.name = "KEY-\(keyname)"
    key.position.y = KEY_DEPTH * 1.5

    let keyText = RUIText(with: keyname, font: .systemFont(ofSize: CGFloat(KEY_SIZE * KEY_TEXT_SCALE_FACTOR)), extrusion: KEY_DEPTH / 2, color: .white)
    keyText.setOrientation(.init(angle: .pi / 2, axis: [1, 0, 0]), relativeTo: keyText)
    keyText.position.y = KEY_DEPTH

    key.addChild(keyText)

    key.components.set(PhysicsBodyComponent(mode: .static))
    key.components.set(CollisionComponent(shapes: [.generateBox(size: [KEY_SIZE, KEY_SIZE, KEY_DEPTH])], isStatic: true)) // , filter: keyStrokeCollisionGroup))
    key.components.set(KeyFingerComponent())

    return key
  }
}
