import UIKit
import Combine
import CombineCocoa

public class UIImageViewerView: UIView {
    private let imageName: String
    private let scrollView: UIScrollView = UIScrollView()
    private let imageView: UIImageView = UIImageView()
    
    private var cancellables = Set<AnyCancellable>()
    
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
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
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
        updateContentSize()
        updateContentInset()
    }
    
    /// imageViewのサイズを調整する
    ///
    /// - note: scrollView.boundsをもとに拡大率を計算して、imageViewのサイズを調整する。
    private func adjustImageViewSize() {
        guard let size = imageView.image?.size else { return }
        let rate = min(scrollView.bounds.width / size.width,
                       scrollView.bounds.height / size.height)
        imageView.frame.size = CGSize(width: size.width * rate,
                                      height: size.height * rate)
    }
    
    /// scrollView.contentSizeを更新する
    ///
    /// - note: scrollView.contentSizeもimageViewのサイズに合わせることで、imageViewの範囲外はスクロールできないようにする。
    private func updateContentSize() {
        scrollView.contentSize = imageView.frame.size
    }
    
    /// scrollView.contentInsetを更新する
    ///
    /// - note: imageViewをscrollViewの中心に表示させる。
    private func updateContentInset() {
        let edgeInsets = UIEdgeInsets(
            top: max((self.frame.height - imageView.frame.height) / 2, 0),
            left: max((self.frame.width - imageView.frame.width) / 2, 0),
            bottom: 0,
            right: 0)
        scrollView.contentInset = edgeInsets
    }
    
    private var tapGestureRecognizer: UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer
            .tapPublisher
            .sink { [weak self] recognizer in
                self?.onDoubleTap(recognizer: recognizer)
            }
            .store(in: &cancellables)
        return tapGestureRecognizer
    }
    
    private func onDoubleTap(recognizer: UITapGestureRecognizer) {
        let maximumZoomScale = scrollView.maximumZoomScale

        if maximumZoomScale != scrollView.zoomScale {
            let tapPoint = recognizer.location(in: imageView)
            let size = CGSize(
                width: scrollView.frame.size.width / maximumZoomScale,
                height: scrollView.frame.size.height / maximumZoomScale)
            let origin = CGPoint(
                x: tapPoint.x - size.width / 2,
                y: tapPoint.y - size.height / 2)
            scrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
        } else {
            scrollView.zoom(to: scrollView.frame, animated: true)
        }
    }
}

extension UIImageViewerView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // ズーム終了時にscrollView.contentInsetを更新して、imageViewをscrollViewの中心に表示させる。
        updateContentInset()
    }
}
