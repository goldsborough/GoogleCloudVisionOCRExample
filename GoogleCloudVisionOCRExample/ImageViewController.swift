//
//  ImageViewController.swift
//  GoogleCloudVisionOCRExample
//
//  Created by Peter Goldsborough on 11/12/2018.
//  Copyright © 2018 Peter Goldsborough. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
  
  var image: UIImage!
  var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let resizedImage = resize(image: image, to: view.frame.size) else {
      fatalError("Error resizing image")
    }
    
    let imageView = UIImageView(frame: view.frame)
    imageView.image = resizedImage
    view.addSubview(imageView)
    
    setupCloseButton()
    setupActivityIndicator()
    
    detectBoundingBoxes(for: resizedImage)
  }
  
  private func resize(image: UIImage, to targetSize: CGSize) -> UIImage? {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle.
    var newSize: CGSize
    if(widthRatio > heightRatio) {
      newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
      newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height + 1)
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  private func detectBoundingBoxes(for image: UIImage) {
    GoogleCloudOCR().detect(from: image) { ocrResult in
      self.activityIndicator.stopAnimating()
      guard let ocrResult = ocrResult else {
        print("Did not recognize any text in this image")
        return
      }
      self.displayBoundingBoxes(for: ocrResult)
    }
  }
  
  private func displayBoundingBoxes(for ocrResult: OCRResult) {
    for annotation in ocrResult.annotations[1...] {
      let path = createBoundingBoxPath(along: annotation.boundingBox.vertices)
      let button = BoundingBoxButton(path: path, text: annotation.text)
      button.addTarget(self, action: #selector(boundingBoxTapped), for: .touchUpInside)
      self.view.addSubview(button)
    }
  }
  
  @objc private func boundingBoxTapped(sender: BoundingBoxButton) {
    let alert = UIAlertController(title: sender.text, message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(
      title: NSLocalizedString("Yey", comment: "Default action"),
      style: .default,
      handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  private func createBoundingBoxPath(along vertices: [Vertex]) -> UIBezierPath {
    let path = UIBezierPath()
    path.move(to: vertices[0].toCGPoint())
    for vertex in vertices[1...] {
      path.addLine(to: vertex.toCGPoint())
    }
    path.close()
    return path
  }
  
  private func setupActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    view.addSubview(activityIndicator)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    activityIndicator.startAnimating()
  }
  
  private func setupCloseButton() {
    let closeButton = UIButton()
    view.addSubview(closeButton)
    
    closeButton.setTitle("✕", for: .normal)
    closeButton.setTitleColor(UIColor.white, for: .normal)
    closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
    
    closeButton.addTarget(self, action: #selector(closeAction), for: .touchDown)
    
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
  }
  
  @objc private func closeAction() {
    dismiss(animated: false, completion: nil)
  }
}
