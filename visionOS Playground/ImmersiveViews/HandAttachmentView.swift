//
//  HandAttachmentView.swift
//  visionOS Playground
//
//  Created by 孙雨生 on 2024/4/7.
//

import SwiftUI
import RealityKit
import RealityKitContent
import RealityUI

struct HandAttachmentView: View {
    var body: some View {
      RealityView { content in
        let text = RUIText(with: "Hello Hand Attachment", color: .red)
        text.position = [0, 1.5, -1.5]
        
        content.add(text)
        
      }
    }
}

#Preview {
    HandAttachmentView()
}
