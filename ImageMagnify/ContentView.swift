import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            ScrollViewWithZoom {
                Image("mountain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width)
            }
        }
    }
}

struct ScrollViewWithZoom<Content: View>: UIViewRepresentable {
    private let contentView: Content
    
    init(@ViewBuilder content: () -> Content) {
        contentView = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 10.0
        scrollView.minimumZoomScale = 1.0
        
        let contentView = UIHostingController(rootView: self.contentView)
        scrollView.addSubview(contentView.view)
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
        contentView.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
        contentView.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor).isActive = true
        contentView.view.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.view.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
                
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }
    }
}
