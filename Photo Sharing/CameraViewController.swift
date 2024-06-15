import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    // Capture session
    var session: AVCaptureSession?
    
    // Photo output
    let output = AVCapturePhotoOutput()
    
    // Video preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // Shutter button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    // Close button
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        // Set the Quicksand-Regular font with size 24
        button.titleLabel?.font = UIFont(name: "Quicksand-SemiBold", size: 36)

        
        let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -0.2,  // Negative value for outer stroke
                .font: button.titleLabel?.font ?? UIFont.boldSystemFont(ofSize: 36)
        ]
        let attributedTitle = NSAttributedString(string: "x", attributes: attributes)
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setTitle("x", for: .normal)
        button.frame = CGRect(x: 10, y: 10, width: 50, height: 50) // Adjusted position
        button.layer.cornerRadius = 25
        button.isHidden = true
        return button
    }()
    
    private var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        view.addSubview(closeButton)
        checkCameraPermissions()
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        applyCornerMask(to: previewLayer)
        
        shutterButton.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 100)
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted, .denied:
            // Handle restricted or denied access
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
            } catch {
                print(error)
            }
        }
    }
    
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @objc private func didTapCloseButton() {
        imageView?.removeFromSuperview()
        closeButton.isHidden = true
        session?.startRunning()
    }
    
    private func applyCornerMask(to layer: CALayer) {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 30, height: 30))
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        
        session?.stopRunning()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        applyCornerMask(to: imageView.layer)  // Apply corner mask to the image view
        view.addSubview(imageView)
        view.bringSubviewToFront(closeButton)
        
        self.imageView = imageView
        closeButton.isHidden = false
    }
}
