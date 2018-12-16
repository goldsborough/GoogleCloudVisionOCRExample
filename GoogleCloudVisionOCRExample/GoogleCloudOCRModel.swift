//
//  GoogleCloudOCRModel.swift
//  GoogleCloudVisionOCRExample
//
//  Created by Peter Goldsborough on 12/12/2018.
//  Copyright © 2018 Peter Goldsborough. All rights reserved.
//

import Foundation
import UIKit

struct Vertex: Codable {
  let x: Int?
  let y: Int?
  enum CodingKeys: String, CodingKey {
    case x = "x", y = "y"
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    x = try container.decodeIfPresent(Int.self, forKey: .x)
    y = try container.decodeIfPresent(Int.self, forKey: .y)
  }
  
  func toCGPoint() -> CGPoint {
    return CGPoint(x: x ?? 0, y: y ?? 0)
  }
}

struct BoundingBox: Codable {
  let vertices: [Vertex]
  enum CodingKeys: String, CodingKey {
    case vertices = "vertices"
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    vertices = try container.decode([Vertex].self, forKey: .vertices)
  }
}

struct Annotation: Codable {
  let text: String
  let boundingBox: BoundingBox
  enum CodingKeys: String, CodingKey {
    case text = "description"
    case boundingBox = "boundingPoly"
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    text = try container.decode(String.self, forKey: .text)
    boundingBox = try container.decode(BoundingBox.self, forKey: .boundingBox)
  }
}

struct OCRResult: Codable {
  let annotations: [Annotation]
  enum CodingKeys: String, CodingKey {
    case annotations = "textAnnotations"
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    annotations = try container.decode([Annotation].self, forKey: .annotations)
  }
}

struct GoogleCloudOCRResponse: Codable {
  let responses: [OCRResult]
  enum CodingKeys: String, CodingKey {
    case responses = "responses"
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    responses = try container.decode([OCRResult].self, forKey: .responses)
  }
}
