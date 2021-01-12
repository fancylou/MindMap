//
//  MindMapLineView.swift
//  Example
//
//  Created by 钟志远 on 2021/1/12.
//

import Foundation
import UIKit

class MindMapLineView: CustomView {
    let pathLayer = CAShapeLayer()
    
    override func setupUI() {
        layer.addSublayer(pathLayer)
    }
    
    var useBezier = true

    func setLayout(parent: MindMapNodeView, child: MindMapNodeView, position: MindMapPosition) {
        
        useBezier = [MindMapPosition.top, MindMapPosition.topRight, MindMapPosition.topLeft, MindMapPosition.bottom, MindMapPosition.bottomRight, MindMapPosition.bottomLeft].contains(position) == false

        if position == .rightBottom {
            transform = .init(scaleX: 1, y: -1)
        } else if position == .rightTop {
            transform = .init(scaleX: 1, y: 1)
        } else if position == .leftTop {
            transform = .init(scaleX: -1, y: 1)
        } else if position == .leftBottom {
            transform = .init(scaleX: -1, y: -1)
        }
        
        self.snp.remakeConstraints { (ConstraintMaker) in
            switch position {
            case .right, .rightTop:
                ConstraintMaker.left.equalTo(parent.snp.right)
                ConstraintMaker.right.equalTo(child.snp.left)
                ConstraintMaker.bottom.equalTo(parent.snp.centerY)
                ConstraintMaker.top.equalTo(child.snp.centerY)
            case .rightBottom:
                ConstraintMaker.bottom.equalTo(child.snp.centerY)
                ConstraintMaker.left.equalTo(parent.snp.right)
                ConstraintMaker.right.equalTo(child.snp.left)
                ConstraintMaker.top.equalTo(parent.snp.centerY)
            case .leftBottom:
                ConstraintMaker.bottom.equalTo(child.snp.centerY)
                ConstraintMaker.left.equalTo(child.snp.right)
                ConstraintMaker.right.equalTo(parent.snp.left)
                ConstraintMaker.top.equalTo(parent.snp.centerY)
            case .left, .leftTop:
                ConstraintMaker.left.equalTo(child.snp.right)
                ConstraintMaker.right.equalTo(parent.snp.left)
                ConstraintMaker.bottom.equalTo(parent.snp.centerY)
                ConstraintMaker.top.equalTo(child.snp.centerY)
            case .bottomRight:
                ConstraintMaker.left.equalTo(child)
                ConstraintMaker.right.equalTo(parent)
                ConstraintMaker.bottom.equalTo(child.snp.top)
                ConstraintMaker.top.equalTo(parent.snp.bottom)
            case .bottomLeft:
                ConstraintMaker.left.equalTo(parent)
                ConstraintMaker.right.equalTo(child)
                ConstraintMaker.bottom.equalTo(child.snp.top)
                ConstraintMaker.top.equalTo(parent.snp.bottom)
            case .topLeft:
                ConstraintMaker.left.equalTo(parent)
                ConstraintMaker.right.equalTo(child)
                ConstraintMaker.bottom.equalTo(parent.snp.top)
                ConstraintMaker.top.equalTo(child.snp.bottom)
            case .topRight:
                ConstraintMaker.left.equalTo(child)
                ConstraintMaker.right.equalTo(parent)
                ConstraintMaker.bottom.equalTo(parent.snp.top)
                ConstraintMaker.top.equalTo(child.snp.bottom)
            default:
                break
            }
        }
    }
    


    override func layoutSubviews() {
        pathLayer.frame = bounds
        
        // bezier
        let rect = self.bounds
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: 0, y: rect.maxY))
        path.addCurve(to: .init(x: rect.maxX, y: 0) , controlPoint1: .init(x: rect.maxX / 2, y: rect.maxY), controlPoint2: .init(x: rect.maxX / 2, y: 0))
        path.lineWidth = 1
        
        //line
            
        let linePath = CGMutablePath()
        linePath.move(to: .init(x: rect.centerX, y: 0))
        linePath.addLine(to: .init(x: rect.centerX, y: rect.maxY))
        //
        
        
        pathLayer.strokeColor = UIColor.red.cgColor
        pathLayer.fillColor = nil
        pathLayer.path = useBezier ? path.cgPath : linePath
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
}
