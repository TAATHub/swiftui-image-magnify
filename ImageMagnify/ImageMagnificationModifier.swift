import SwiftUI

struct ImageMagnificationModifier: ViewModifier {
    private var contentSize: CGSize
    private var aspectRatio: CGFloat
    private var minScale: CGFloat = 1.0
    private var maxScale: CGFloat = 5.0
    
    @State private var currentScale: CGFloat = 1.0
    @State private var lastMagnificationValue: CGFloat = 1.0
    
    init(contentSize: CGSize, aspectRatio: CGFloat) {
        self.contentSize = contentSize
        self.aspectRatio = aspectRatio
    }

    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let changeRate = value / lastMagnificationValue
                lastMagnificationValue = value
                
                DispatchQueue.main.async {
                    currentScale *= changeRate
                    currentScale = min(max(minScale, currentScale), maxScale)
                }
            }
            .onEnded { value in
                lastMagnificationValue = 1.0
            }
    }
    
    var doubleTap: some Gesture {
        TapGesture(count: 2).onEnded {
            currentScale = currentScale < maxScale ? maxScale : minScale
        }
    }
    
    func body(content: Content) -> some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            content
                .scaleEffect(currentScale)
                .gesture(magnification)
                .simultaneousGesture(doubleTap)
                .frame(width: contentSize.width * currentScale, height: contentSize.width / aspectRatio * currentScale, alignment: .center)
        }
    }
}
