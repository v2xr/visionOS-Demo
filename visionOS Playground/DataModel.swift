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

@Observable
class DataModel {
  var gameSounds: [String: AudioResource] = [:]
  var fireBall: Entity?

  init() {
    Task { @MainActor in
      fireBall = try! await Entity(named: "Fireball", in: realityKitContentBundle)
    }
  }
}
