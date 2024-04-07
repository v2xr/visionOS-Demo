//
//  ContentView.swift
//  visionOS Playground
//
//  Created by V2XR on 2024/4/6.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ContentView: View {
  @Environment(DataModel.self) var model
  @Environment(\.openWindow) var openWindow
  
  @State var showVolumetricWindowAlert = false
  var body: some View {
    List {
      Button {
        openWindow(id: "portalDemo")
      } label: {
        HStack {
          Image(systemName: "oval.portrait.inset.filled")
          Text("Open Portal Demo")
        }
      }

      Button {
        showVolumetricWindowAlert.toggle()
      } label: {
        HStack {
          Image(systemName: "cube.transparent")
          Text("Volumetric Window")
        }
      }
      .alert(isPresented: $showVolumetricWindowAlert, content: {
        Alert(title: Text("🚧"),
              message: Text("Comming soon..."),
              dismissButton: .default(Text("OK")))
      })
    }
  }
}

#Preview(windowStyle: .automatic) {
  ContentView().environment(DataModel())
}
