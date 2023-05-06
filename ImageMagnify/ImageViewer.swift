import SwiftUI

struct ImageViewer: UIViewRepresentable {
    let imageName: String
    
    func makeUIView(context: Context) -> UIImageViewerView {
        let view = UIImageViewerView(imageName: imageName)
        return view
    }
    
    func updateUIView(_ uiView: UIImageViewerView, context: Context) {}
}

public class UIImageViewerView: UIView {
    private let imageName: String
    private let scrollView: UIScrollView = UIScrollView()
    private let imageView: UIImageView = UIImageView()
    
    required init(imageName: String) {
        self.imageName = imageName
        super.init(frame: .zero)
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 10.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        addSubview(scrollView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        
        adjustImageViewSize()
        updateContentInset()
    }
    
    private func adjustImageViewSize() {
        guard let size = imageView.image?.size else { return }
        let rate = min(scrollView.bounds.width / size.width,
                       scrollView.bounds.height / size.height)
        imageView.frame.size = CGSize(width: size.width * rate,
                                      height: size.height * rate)
        scrollView.contentSize = imageView.frame.size
    }
    
    private func updateContentInset() {
        let edgeInsets = UIEdgeInsets(
            top: max((self.frame.height - imageView.frame.height) / 2, 0),
            left: max((self.frame.width - imageView.frame.width) / 2, 0),
            bottom: 0,
            right: 0)
        scrollView.contentInset = edgeInsets
    }
}

extension UIImageViewerView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
}
