import SwiftUI

struct ImageMagnificationModifier: ViewModifier {
    private var contentSize: CGSize
    private var aspectRatio: CGFloat
    private var minScale: CGFloat = 1.0
    private var maxScale: CGFloat = 10.0
    private var scaleStride: CGFloat = 2.5
    
    @State private var currentScale: CGFloat = 1.0
    @State private var lastMagnificationValue: CGFloat = 1.0
    
    init(contentSize: CGSize, aspectRatio: CGFloat) {
        self.contentSize = contentSize
        self.aspectRatio = aspectRatio
    }
    
    var doubleTap: some Gesture {
        TapGesture(count: 2).onEnded {
            currentScale = currentScale < maxScale ? floor(currentScale) + scaleStride : minScale
        }
    }

    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let changeRate = value / lastMagnificationValue
                currentScale *= changeRate
                currentScale = min(max(minScale, currentScale), maxScale)
                lastMagnificationValue = value
            }
            .onEnded { value in
                lastMagnificationValue = 1.0
            }
    }
    
    func body(content: Content) -> some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            content
                .scaleEffect(currentScale)
                .gesture(doubleTap)
                .simultaneousGesture(magnification)
                .frame(width: contentSize.width * currentScale, height: contentSize.width / aspectRatio * currentScale, alignment: .center)
        }
    }
}
