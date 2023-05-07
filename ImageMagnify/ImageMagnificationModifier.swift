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
                // 前回の拡大率に対する今回の拡大率の割合
                let changeRate = value / lastMagnificationValue
                
                DispatchQueue.main.async {
                    // 前回からの拡大率の変化分を考慮した現在のスケールを計算
                    currentScale *= changeRate
                    // 最小・最大スケールの範囲内に収める
                    currentScale = min(max(minScale, currentScale), maxScale)
                }
                
                lastMagnificationValue = value
            }
            .onEnded { value in
                // ジェスチャー開始時は1.0から始まるため、ジェスチャー終了時に1.0に戻す
                lastMagnificationValue = 1.0
            }
    }
    
    var doubleTap: some Gesture {
        TapGesture(count: 2).onEnded {
            // 最小・最大スケールを切り替える
            currentScale = currentScale < maxScale ? maxScale : minScale
        }
    }
    
    func body(content: Content) -> some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            content
                .scaleEffect(currentScale)
                .gesture(magnification)
                .simultaneousGesture(doubleTap)
                .frame(width: contentSize.width * currentScale,
                       height: contentSize.width / aspectRatio * currentScale,
                       alignment: .center)
        }
    }
}
