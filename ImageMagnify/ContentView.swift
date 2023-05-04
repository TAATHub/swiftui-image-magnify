import SwiftUI

struct ContentView: View {
    @State private var aspectRatio: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { proxy in
            Image("mountain")
                .resizable()
                .scaledToFit()
                .frame(width: proxy.size.width)
                // backgroundでGeometryReaderを使うことで、対象のViewのサイズを取得できる
                .background(GeometryReader { imageGeometry in
                    Color.clear
                        .onAppear {
                            aspectRatio = imageGeometry.size.width / imageGeometry.size.height
                        }
                })
                .modifier(ImageMagnificationModifier(contentSize: proxy.size, aspectRatio: aspectRatio))
                .background(.black)
                .ignoresSafeArea()
        }
    }
}
