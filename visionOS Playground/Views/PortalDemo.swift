//
//  PortalDemo.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/7.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct PortalDemo: View {
  @Environment(DataModel.self) var model
  var body: some View {
    RealityView { content in
      let world = makeWorld()
      let portal = makePortal(world: world)

      content.add(world)
      content.add(portal)
    }
  }

  func makeWorld() -> Entity {
    let world = Entity()
//    world.components.set(ModelComponent(mesh: .generateSphere(radius: 0.1), materials: []))
    world.components.set(WorldComponent())

    world.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: world)

    /*
     let ufo = ModelEntity(mesh: .generateSphere(radius: 0.1), materials: [SimpleMaterial(color: .red, isMetallic: false)])
     ufo.position.z = -0.2
     world.addChild(ufo)
      */
    let earth = try! Entity.load(named: "Earth", in: realityKitContentBundle)
    earth.position.z = -0.5
    let spinAnimation = FromToByAnimation(
      to: Transform(rotation: .init(angle: .pi, axis: [0, 1, 0]), translation: [0,0,-0.5]),
      duration: 3.0, bindTarget: .transform, repeatMode: .repeat)
    let animationResource = try! AnimationResource.generate(with: spinAnimation)
    earth.playAnimation(animationResource)

    world.addChild(earth)

    return world
  }

  func makePortal(world: Entity) -> Entity {
    let portal = Entity()
    portal.components.set(ModelComponent(mesh: .generatePlane(width: 0.2, height: 0.2, cornerRadius: 0.02), materials: [PortalMaterial()]))
    portal.components.set(PortalComponent(target: world))
    portal.components.set(ParticleEmitterComponent())

    if let particle = model.fireBall?.findEntity(named: "ParticleEmitter") {
      if var particleComponent = particle.components[ParticleEmitterComponent.self] {
        particleComponent.emitterShapeSize = .init(repeating: 0.1)
//        portal.components[ParticleEmitterComponent.self] = particleComponent
      } else {
        print("No ParticleEmitterComponent")
      }
    } else {
      print("No fireball particle found")
    }

    /*

     let occlusion = ModelEntity(mesh: .generateBox(size: .init(x: 0.1, y: 0.1, z: 0.1 )), materials: [OcclusionMaterial()])
     occlusion.position.z = -0.0001 - 0.05
     occlusion.setParent(portal)

     let ufo = ModelEntity(mesh: .generateCylinder(height: 0.1, radius: 0.02), materials: [SimpleMaterial(color: .green, isMetallic: false)])
     ufo.orientation = simd_quatf(angle: .pi/2, axis: [1,0,0])
     ufo.setParent(portal)
      */

    return portal
  }

  private func createLogoParticleSystem() -> ParticleEmitterComponent {
    var particles = ParticleEmitterComponent()

    particles.timing = .repeating(warmUp: 0.5, emit: ParticleEmitterComponent.Timing.VariableDuration(duration: 1.0))

    particles.emitterShape = .torus
    particles.birthLocation = .surface
    particles.emitterShapeSize = [1.2, 0.4, 0.2]
    particles.birthDirection = .world
    particles.emissionDirection = [0.0, -1.0, 0.0]
    particles.speed = 0.15
    particles.speedVariation = 0.12
    particles.spawnVelocityFactor = 0.5

    particles.mainEmitter.color = .evolving(start: .single(.blue), end: .single(.white))
    particles.mainEmitter.blendMode = .additive
    particles.mainEmitter.birthRate = 500
    particles.mainEmitter.birthRateVariation = 100
    particles.mainEmitter.size = 0.005
    particles.mainEmitter.lifeSpan = 1.5
    particles.mainEmitter.lifeSpanVariation = 0.75
    particles.mainEmitter.spreadingAngle = 0.7
    particles.mainEmitter.dampingFactor = 0.6

    return particles
  }
}

#Preview {
  PortalDemo().environment(DataModel())
}
