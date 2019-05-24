//
//  CameraViewController.swift
//  FinalProject
//
//  Created by Zholdas on 4/3/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    var captureSession = AVCaptureSession()

    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?

    var photoOutput: AVCapturePhotoOutput?
    
    var videoOutput: AVCaptureMovieFileOutput?

    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?

    var isConfigured: Bool = false

    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]


    lazy var captureButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "takePhoto") as UIImage?
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        return button
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "left-arrow") as UIImage?
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCancelButton(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCaptureSession()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (takePhotoButton(_:)))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(takeVideoButton(_:)))
        tapGesture.numberOfTapsRequired = 1

        captureButton.addGestureRecognizer(tapGesture)
        captureButton.addGestureRecognizer(longGesture)

        setupView()

    }

    func setupView(){
        title = "Camera"
        view.backgroundColor = .white

        navigationController?.isNavigationBarHidden = true

        view.addSubview(captureButton)
        view.addSubview(cancelButton)

        captureButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(70)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }

        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.height.equalTo(20)
        }
    }


    @objc private func didTapCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func takePhotoButton(_ gesture: UITapGestureRecognizer) {
        photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    @objc private func takeVideoButton(_ gesture: UILongPressGestureRecognizer) {
                if gesture.state == UIGestureRecognizer.State.began {
                    captureButton.setImage(UIImage(named: "takeVideo"), for:.normal)
                    
                    let  filemainurl = NSURL(string: ("\(documentsURL.appendingPathComponent(Date().description))" + ".mov"))
                    
                    videoOutput?.startRecording(to: filemainurl! as URL, recordingDelegate: self)

                }else if gesture.state == UIGestureRecognizer.State.changed {
                    print("recording video")
                }
                else if gesture.state == UIGestureRecognizer.State.ended {
                    print("end recording")
                    videoOutput?.stopRecording()
                    captureButton.setImage(UIImage(named: "takePhoto"), for:.normal)
                }
    }



    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isConfigured {
            captureSession.startRunning()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }

    private func configureCaptureSession() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()

        isConfigured = true
    }

    private func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    private func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                      mediaType: .video,
                                                                      position: .unspecified)

        let devices = deviceDiscoverySession.devices

        for device in devices {
            switch device.position {
            case .front:
                frontCamera = device
            case .back:
                backCamera = device
            default:
                continue
            }
        }

        currentCamera = backCamera
    }

    private func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)

            photoOutput = AVCapturePhotoOutput()
            videoOutput = AVCaptureMovieFileOutput()
            
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            
            
            let maxDuration: CMTime = CMTimeMake(value: 600, timescale: 10)
            videoOutput?.maxRecordedDuration = maxDuration
            videoOutput?.minFreeDiskSpaceLimit = 1024 * 1024
            
            if self.captureSession.canAddOutput(videoOutput!) {
                self.captureSession.addOutput(videoOutput!)
            }

            
            captureSession.addOutput(photoOutput!)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    private func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait

        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }

    private func startRunningCaptureSession() {
        captureSession.startRunning()
    }


}

extension CameraViewController: AVCapturePhotoCaptureDelegate ,AVCaptureFileOutputRecordingDelegate{
   
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard
            let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData)
            else {
                print("Failed for some reason")
                return
        }

        let vc = AddCommentViewController()
        vc.messageImageView.image = image
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        DispatchQueue.main.async {
            do {
                let asset = AVURLAsset(url: outputFileURL , options: nil)
                
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                
                let vc = AddCommentViewController()
                vc.messageImageView.image = uiImage
                vc.getVideoUrl = outputFileURL as NSURL
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            catch let error as NSError {
                print(error)
                return }
        }
    }
        

}
