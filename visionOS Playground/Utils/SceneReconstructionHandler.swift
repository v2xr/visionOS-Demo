//
//  SceneReconstructionHandler.swift
//  Spatial Bowling
//
//  Created by 孙雨生 on 2024/4/9.
//

import ARKit
import Foundation
import RealityKit

class SceneReconstructionHandler {
  var rootEntity: Entity
  var miniRootEntity: Entity
  var meshMaterial: RealityKit.Material?
  
  // 保存 MeshAnchor.ID -> MeshAnchor
  // private var meshAnchorsByID: [UUID: MeshAnchor] = [:]
  private var meshAnchorIDToEntity: [UUID: Entity] = [:]
  private var miniMeshAnchorIDtoEntity: [UUID: Entity] = [:]
  // 保存所有 MeshAnchor #get-only
  private var meshAnchors: [Entity] {
    Array(meshAnchorIDToEntity.values)
  }
  
  init(rootEntity: Entity, miniRootEntity: Entity, meshMaterial: RealityKit.Material?) {
    self.rootEntity = rootEntity
    self.miniRootEntity = miniRootEntity
    self.meshMaterial = meshMaterial
  }
  
  @MainActor
  func process(_ anchorUpdate: AnchorUpdate<MeshAnchor>) async {
    let anchor = anchorUpdate.anchor as MeshAnchor
    
    guard let shape = try? await ShapeResource.generateStaticMesh(from: anchor) else {
      return
    }
    
    switch anchorUpdate.event {
      case .added:
        // new MeshAnchor
        print("New MeshAnchor: \(rootEntity.children.count)")
        let entity = Entity()
        entity.name = "Mesh \(anchor.id)"
        entity.setTransformMatrix(anchor.originFromAnchorTransform, relativeTo: nil)
        // Generate a mesh for the Mesh
        var meshResource: MeshResource?
        do {
          let contents = MeshResource.Contents(meshGeometry: anchor.geometry)
          meshResource = try MeshResource.generate(from: contents)
        } catch {
          print("Failed to create mesh resource from a mesh anchor: \(error)")
          return
        }
        if let meshResource {
          entity.components.set(
            ModelComponent(
              mesh: meshResource,
              materials: [
                meshMaterial ?? SimpleMaterial(color: .gray.withAlphaComponent(0.1), isMetallic: false),
              ]
            ))
        }
        // set collision shape
        entity.components.set(CollisionComponent(shapes: [shape], isStatic: true))
        entity.components.set(PhysicsBodyComponent(shapes: [shape], mass: 0.0, mode: .static))
        
        meshAnchorIDToEntity[anchor.id] = entity
        rootEntity.addChild(entity)
        
        // add to MiniRootEntity
        let miniEntity = entity.clone(recursive: true)
        miniEntity.components[ModelComponent.self]?.materials = [SimpleMaterial(color: .white, isMetallic: false)]
        
        miniEntity.components.set(CollisionComponent(shapes: [shape], isStatic: true))
        miniEntity.components.set(PhysicsBodyComponent(shapes: [shape], mass: 0.0, mode: .static))
        
        miniMeshAnchorIDtoEntity[anchor.id] = miniEntity
        miniRootEntity.addChild(miniEntity)
      case .updated:
        // update MeshAnchor
        guard let entity = meshAnchorIDToEntity[anchor.id] else {
          return
        }
        // update entity transform
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
      case .removed:
        // remove MeshAnchor
        // 从 meshAnchors 中移除
        //      meshAnchorsByID.removeValue(forKey: anchor.id)
        // 移除对应的 Entity
        if let entity = meshAnchorIDToEntity.removeValue(forKey: anchor.id) {
          print("Remove Entity: \(entity.name)")
          entity.removeFromParent()
        }
        if let miniEntity = miniMeshAnchorIDtoEntity.removeValue(forKey: anchor.id) {
          print("Remove Mini Entity: \(miniEntity.name)")
          miniEntity.removeFromParent()
        }
    }
  }
}
