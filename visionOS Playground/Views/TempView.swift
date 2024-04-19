//
//  TempView.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/12.
//

import SwiftUI
import RealityKit

struct TempView: View {
  @Environment(TableKeyboardModel.self) var model
  var body: some View {
    RealityView { content in
      let keyboard = model.makeMyKeyboard()
      keyboard.orientation = .init(angle: .pi/2, axis: [1, 0, 0])
      content.add(keyboard)
    }
  }
}


