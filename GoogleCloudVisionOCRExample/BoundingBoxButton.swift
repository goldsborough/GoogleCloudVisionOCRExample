//
//  BoundingBoxButton.swift
//  Vime
//
//  Created by Peter Goldsborough on 7/11/2018.
//  Copyright © 2018 Peter Goldsborough. All rights reserved.
//

import UIKit

class BoundingBoxButton: UIButton {
  
  let text: String
  let path: UIBezierPath
  
  required init(path: UIBezierPath, text: String) {
    self.text = text
    self.path = path
    super.init(frame: path.bounds)
    path.apply(originTranslation(of: path, to: path.bounds.origin))
    addTarget(self, action: #selector(touchDown), for: .touchDown)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    let shape = CAShapeLayer()
    shape.lineWidth = 1.5
    shape.strokeColor = UIColor.blue.cgColor
    shape.fillColor = UIColor.blue.withAlphaComponent(0.1).cgColor
    shape.path = self.path.cgPath
    layer.addSublayer(shape)
  }
  
  @objc func touchDown(button: BoundingBoxButton, event: UIEvent) {
    if let touch = event.touches(for: button)?.first {
      let location = touch.location(in: button)
      if self.path.contains(location) == false {
        button.cancelTracking(with: nil)
      }
    }
  }
  
  private func originTranslation(of: UIBezierPath, to: CGPoint) -> CGAffineTransform {
    return CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
      .translatedBy(x: -frame.origin.x,
                    y: -frame.origin.y)
  }
}
