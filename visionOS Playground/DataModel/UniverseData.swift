//
//  UniverseData.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/17.
//

import Foundation
import SwiftUI

enum Faces {
  case back
  case left
  case right
  case top
  case bottom
}

class UniverseData: Hashable, Codable {
  let DEPTH:Float = 0.005
  
  let order: Int
  let size: Size3D

  let faces: [Faces] = []
  let entrance: Faces = .left
  let exitance: Faces = .right

  enum CodingKeys: CodingKey {
    case order
    case size
  }

  init(order: Int, size: Size3D) {
    self.order = order
    self.size = size
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(order)
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    order = try container.decode(Int.self, forKey: .order)
    size = try container.decode(Size3D.self, forKey: .size)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(order, forKey: .order)
    try container.encode(size, forKey: .size)
  }

  static func == (lhs: UniverseData, rhs: UniverseData) -> Bool {
    return lhs.order == rhs.order
  }
}
