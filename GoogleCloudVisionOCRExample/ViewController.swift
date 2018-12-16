//
//  ViewController.swift
//  GoogleCloudVisionOCRExample
//
//  Created by Peter Goldsborough on 10/12/2018.
//  Copyright © 2018 Peter Goldsborough. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  
  var captureSession: AVCaptureSession!
  var capturePhotoOutput: AVCapturePhotoOutput!
  var tapRecognizer: UITapGestureRecognizer!
  var readyImage: UIImage!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupCamera()
    setupTapRecognizer()
    setupPhotoOutput()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    captureSession.startRunning()
    tapRecognizer.isEnabled = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    captureSession.stopRunning()
    tapRecognizer.isEnabled = false
  }
  
  private func setupCamera() {
    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
    var input: AVCaptureDeviceInput
    do {
      input = try AVCaptureDeviceInput(device: captureDevice!)
    } catch {
      fatalError("Error configuring capture device: \(error)");
    }
    captureSession = AVCaptureSession()
    captureSession.addInput(input)
    
    // Setup the preview view.
    let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    videoPreviewLayer.frame = view.layer.bounds
    view.layer.addSublayer(videoPreviewLayer)
  }
  
  private func setupTapRecognizer() {
    tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    tapRecognizer?.numberOfTapsRequired = 1
    tapRecognizer?.numberOfTouchesRequired = 1
    view.addGestureRecognizer(tapRecognizer!)
  }
  
  @objc func handleTap(sender: UITapGestureRecognizer) {
    if sender.state == .ended {
      capturePhoto()
    }
  }
  
  private func setupPhotoOutput() {
    capturePhotoOutput = AVCapturePhotoOutput()
    capturePhotoOutput.isHighResolutionCaptureEnabled = true
    captureSession.addOutput(capturePhotoOutput!)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let imageViewController = segue.destination as? ImageViewController {
      imageViewController.image = readyImage
    }
  }
}

extension ViewController : AVCapturePhotoCaptureDelegate {
  private func capturePhoto() {
    let photoSettings = AVCapturePhotoSettings()
    photoSettings.isAutoStillImageStabilizationEnabled = true
    photoSettings.isHighResolutionPhotoEnabled = true
    photoSettings.flashMode = .auto
    // Set ourselves as the delegate for `capturePhoto`.
    capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
  }
  
  func photoOutput(_ output: AVCapturePhotoOutput,
                   didFinishProcessingPhoto photo: AVCapturePhoto,
                   error: Error?) {
    guard error == nil else {
      fatalError("Failed to capture photo: \(String(describing: error))")
    }
    guard let imageData = photo.fileDataRepresentation() else {
      fatalError("Failed to convert pixel buffer")
    }
    guard let image = UIImage(data: imageData) else {
      fatalError("Failed to convert image data to UIImage")
    }
    readyImage = image
    performSegue(withIdentifier: "ShowImageSegue", sender: self)
  }
}

