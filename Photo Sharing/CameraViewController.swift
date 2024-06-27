import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    // Capture session
    var session: AVCaptureSession?

    // Current camera position
    var currentCameraPosition: AVCaptureDevice.Position = .back

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
    private let bottomBar = BottomBarView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        view.addSubview(closeButton)
        view.addSubview(bottomBar) // Add BottomBarView as a subview
        checkCameraPermissions()

        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapScreen))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = view.safeAreaInsets

        // Adjust preview layer frame to fill the view's bounds, ignoring safe area insets
        previewLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height + safeAreaInsets.bottom
        )
        applyCornerMask(to: previewLayer)

        // Position shutter button at the bottom center
        shutterButton.center = CGPoint(x: view.bounds.midX, y: view.bounds.maxY - 100 - safeAreaInsets.bottom)

        // Position bottom bar at the bottom of the view
        let bottomBarHeight: CGFloat = 60
         bottomBar.frame = CGRect(x: 0, y: view.bounds.height - bottomBarHeight, width: view.bounds.width, height: bottomBarHeight)
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
        guard let device = getCamera(for: currentCameraPosition) else {
            print("Could not get camera device for position: \(currentCameraPosition)")
            return
        }

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

    private func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                       mediaType: .video, position: .unspecified).devices
        return devices.first(where: { $0.position == position })
    }

    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    @objc private func didTapCloseButton() {
        imageView?.removeFromSuperview()
        closeButton.isHidden = true
        session?.startRunning()
    }

    @objc private func didDoubleTapScreen() {
        switchCamera()
    }

    private func switchCamera() {
        guard let session = session else { return }
        session.beginConfiguration()

        // Remove existing input
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        session.removeInput(currentInput)

        // Get new input
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
        guard let newDevice = getCamera(for: currentCameraPosition) else { return }

        do {
            let newInput = try AVCaptureDeviceInput(device: newDevice)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
            } else {
                // If we can't add new input, re-add the old input
                if session.canAddInput(currentInput) {
                    session.addInput(currentInput)
                }
            }
        } catch {
            print(error)
            // If an error occurs, re-add the old input
            if session.canAddInput(currentInput) {
                session.addInput(currentInput)
            }
        }

        session.commitConfiguration()
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
        
        // Correct the orientation if using the front camera
        let finalImage: UIImage
        if currentCameraPosition == .front, let cgImage = image?.cgImage {
            finalImage = UIImage(cgImage: cgImage, scale: image?.scale ?? 1.0, orientation: .leftMirrored)
        } else {
            finalImage = image ?? UIImage()
        }

        session?.stopRunning()

        let imageView = UIImageView(image: finalImage)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        applyCornerMask(to: imageView.layer)  // Apply corner mask to the image view
        view.addSubview(imageView)
        view.bringSubviewToFront(closeButton)

        self.imageView = imageView
        closeButton.isHidden = false
    }
}
