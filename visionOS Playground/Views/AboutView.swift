//
//  AboutView.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/7.
//

import SwiftUI

struct AboutView: View {
  let recipient: String = "sunyusheng@vivo.com"
  @State private var isMailAppOpen = false

  var body: some View {
    Button(action: openMailApp) {
      Label("\(recipient)", systemImage: "envelope")
//      Text("Email: \(recipient)")
    }
    .sheet(isPresented: $isMailAppOpen) {
      Text("Opening Mail App...")
    }
    .glassBackgroundEffect()
  }

  private func openMailApp() {
    let mailURL = URL(string: "mailto:\(recipient)")
    guard let url = mailURL, UIApplication.shared.canOpenURL(url) else {
      print("Could not open mail app")
      return
    }

    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    isMailAppOpen = true
  }
}

#Preview {
  AboutView()
}
