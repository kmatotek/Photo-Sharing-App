import SwiftUI

struct BottomBarViewWrapper: UIViewRepresentable {
    
    func makeUIView(context: Context) -> BottomBarView {
        return BottomBarView()
    }
    
    func updateUIView(_ uiView: BottomBarView, context: Context) {
        // Update any properties of BottomBarView here if needed
    }
}
