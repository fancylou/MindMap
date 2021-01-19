//
//  MindMap.swift
//  MindMap
//
//  Created by 钟志远 on 2021/1/18.
//

import Foundation
import UIKit

public class MindMapRes {
    // convenient for specific image
    public static func location() -> UIImage {
        return image(named: "location") ?? UIImage()
    }
    
    public static func node_slibing() -> UIImage {
        return image(named: "node_slibing") ?? UIImage()
    }
    
    public static func node() -> UIImage {
        return image(named: "node") ?? UIImage()
    }

    // for any image located in bundle where this class has built
    public static func image(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle(for: self), with: nil)
    }
}
