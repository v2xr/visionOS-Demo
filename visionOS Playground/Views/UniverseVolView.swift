//
//  UniverseVolView.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/17.
//

import RealityKit
import SwiftUI

struct UniverseVolView: View {
  @Environment(DataModel.self) var model
  let universeData: UniverseData
  var body: some View {
    RealityView { content, attachments in

      let box = UniverseBox(data: universeData, color: model.universeColors[universeData.order])
      content.add(box)

      if universeData.order == 1 {
        box.spawnAt(position: [0, 0, 0])
      }

      _ = content.subscribe(to: CollisionEvents.Began.self) { event in
        if event.entityA.name == "Ball" || event.entityB.name == "Ball" {
//          model.handleCollision(event: event, universe: universeData)
        }
      }

      if let order = attachments.entity(for: "bottomOrm") {
        order.setPosition([0, -Float(universeData.size.height / 2), Float(universeData.size.depth / 2) + universeData.DEPTH], relativeTo: nil)
        order.setOrientation(.init(angle: -.pi / 12, axis: [1, 0, 0]), relativeTo: nil)
        box.addChild(order)
      }

      model.universes[universeData.order] = box
    } update: { _, _ in
    } attachments: {
      Attachment(id: "bottomOrm") {
        HStack {
          Image(systemName: "globe.asia.australia")
          Text("Universe #\(universeData.order)")
        }
        .font(.footnote)
        .foregroundColor(model.universeColors[universeData.order])
        .padding(12)
        .glassBackgroundEffect()
      }
    }
//    .installGestures()
    .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { value in
      print("Tapped: ", value.entity.name, " of Universe #\(universeData.order)")

      if value.entity.name == "Ball", false {
        guard let pb = value.entity as? HasPhysicsBody else {
          return
        }
        pb.components[PhysicsBodyComponent.self]?.mode = .dynamic
        pb.addForce(.randomForce(), relativeTo: nil)
        pb.addTorque([0, 0, 0], relativeTo: pb)
//        pb.applyImpulse(.randomForce(), at: [0,0,0], relativeTo: nil)
      }

    })
    .gesture(
      DragGesture()
        .targetedToAnyEntity()
        .onChanged { value in
          if let dragComp = value.entity.components[DragToShootComponent.self] {
            dragComp.handleDragChange(value: value)
          } else {
            print("No componet")
          }
        }.onEnded { value in
          if let dragComp = value.entity.components[DragToShootComponent.self] {
            dragComp.handleDragEnd(value: value)
          }
        })
  }
}

extension SIMD3<Float> {
  static func randomForce() -> SIMD3<Float> {
    return [.random(in: -2 ... 2), .random(in: -2 ... 2), .random(in: -2 ... 2)]
  }
}
