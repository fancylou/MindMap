//
//  MindMapPosition.swift
//  Example
//
//  Created by 钟志远 on 2021/1/11.
//

import Foundation
import UIKit

enum MindMapPosition {
    case right
    case rightTop
    case rightBottom
    case topRight
    case topLeft
    case top
    case leftTop
    case left
    case leftBottom
    case bottomLeft
    case bottom
    case bottomRight
    case collision
    
    static let leftPosition: [MindMapPosition] = [.left, .leftTop, .leftBottom]
    static let rightPosition: [MindMapPosition] = [.right, .rightTop, .rightBottom]
    
    func transferValid() -> MindMapPosition {
        switch self {
        case .top, .topRight:
            return .rightTop
        case .bottom, .bottomRight:
            return .rightBottom
        case .topLeft:
            return .leftTop
        case .bottomLeft:
            return .leftBottom
        
        default:
            return .rightTop
        }
    }
    
    static func generate(parentRect: CGRect, childRect: CGRect) -> MindMapPosition {
        let offsetCenter = childRect.offsetCenter(rect: parentRect)
        let collision = childRect.collision(rect: parentRect)
        
        if collision.0 && collision.1 {
            return .collision
        }
        
        if collision.0 == false && collision.1 == false {
            if offsetCenter.x > 0 {
                if offsetCenter.y > 0 {
                    return .rightBottom
                } else {
                    return .rightTop
                }
            } else if offsetCenter.x < 0 {
                if offsetCenter.y > 0 {
                    return .leftBottom
                } else {
                    return .leftTop
                }
            }
        }
        
        if collision.0 {
            if offsetCenter.x > 0 {
                if offsetCenter.y > 0 {
                    return .bottomRight
                } else {
                    return .topRight
                }
            } else if offsetCenter.x < 0 {
                if offsetCenter.y > 0 {
                    return .bottomLeft
                } else {
                    return .topLeft
                }
            } else {
                return offsetCenter.y > 0 ? .bottom : .top
            }
        } else {
            
            if offsetCenter.x > 0 {
                if offsetCenter.y > 0 {
                    return .rightBottom
                } else if offsetCenter.y < 0 {
                    return .rightTop
                } else {
                    return .right
                }
            } else {
                if offsetCenter.y > 0 {
                    return .leftBottom
                } else if offsetCenter.y < 0 {
                    return .leftTop
                } else {
                    return .left
                }
            }
            
        }
    }
}
