//
//  HomeView.swift
//  visionOS Playground
//
//  Created by V2XR on 2024/4/6.
//

import SwiftUI

struct HomeView: View {
  @Environment(DataModel.self) var model
  var body: some View {
    VStack {
      HeaderView()
      Divider()
      TabView {
        ContentView()
          .environment(model)
          .tabItem {
            Label("Home", systemImage: "house")
          }

        ARKitDemos()
          .environment(model)
          .tabItem {
            Label("ARKit", systemImage: "arkit")
          }
        VStack {
          Label("WWDC 2024 Sample Projects", systemImage: "apple.terminal.on.rectangle")
          Text("Coming soon... June 10-14")
            .font(.footnote)
        }
        .tabItem {
          Label("WWDC24", systemImage: "w.circle")
        }
       AboutView()
          .tabItem {
            Label("About", systemImage: "info.circle")
          }
      }
      /*
       .toolbar {
         ToolbarItemGroup(placement: .bottomOrnament) {
           Button {
             // open Mail
           } label: {
             Image(systemName: "envelope")
             Text("Mail me")
           }
           .font(.title3)
           .padding()
           .fontWeight(.semibold)
         }
       }
       */
    }
  }
}

#Preview(windowStyle: .automatic) {
  HomeView()
}
