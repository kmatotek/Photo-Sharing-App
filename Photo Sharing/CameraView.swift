import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject var camera = CameraModel()
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack {
                HStack {
                    Spacer()
                    
                    if !camera.isTaken {
                        Button(action: {}, label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding(.trailing, 10)
                    }
                }
                .padding(.top, 10) // Add padding to the top for spacing
                
                Spacer()
                
                HStack {
                    if camera.isTaken {
                        Button(action: {
                            camera.isTaken = false
                            camera.capturedImage = nil
                            camera.session.startRunning() // Restart camera preview
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding()
                                .foregroundColor(.white)
                        })
                        .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            // Implement save action if needed
                        }, label: {
                            Image(systemName: "square.and.arrow.down.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding()
                                .foregroundColor(.white)
                        })
                        .padding(.trailing)
                    } else {
                        Button(action: {
                            camera.takePicture()
                        }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 65, height: 70)
                            }
                        })
                        .frame(height: 75)
                        .padding(.bottom, 30) // Adjust bottom padding for button placement
                    }
                }
                .frame(height: 75)
            }
        }
        .onAppear {
            camera.checkAuthorization()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview?.frame = view.frame
        camera.preview?.videoGravity = .resizeAspectFill
        
        if let preview = camera.preview {
            view.layer.addSublayer(preview)
        }
        
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    var preview: AVCaptureVideoPreviewLayer?
    @Published var capturedImage: UIImage?
    
    override init() {
        super.init()
        setUpCamera()
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUpCamera()
        case .notDetermined:
            requestCameraAccess()
        case .denied:
            alert = true
        default:
            break
        }
    }
    
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        }
    }
    
    private func setUpCamera() {
        DispatchQueue.main.async { [weak self] in
            do {
                self?.session.beginConfiguration()
                
                // Ensure the device is available
                guard let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) ??
                                    AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    print("No camera available")
                    return
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                
                if self?.session.canAddInput(input) ?? false {
                    self?.session.addInput(input)
                }
                
                if self?.session.canAddOutput(self?.output ?? AVCapturePhotoOutput()) ?? false {
                    self?.session.addOutput(self?.output ?? AVCapturePhotoOutput())
                }
                
                self?.session.commitConfiguration()
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func takePicture() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo: \(error!.localizedDescription)")
            return
        }
        
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            capturedImage = image
            isTaken = true
            session.stopRunning() // Stop camera preview after taking picture
        }
    }
}

#if DEBUG
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
#endif
