//
//  MindMapView.swift
//  Example
//
//  Created by 钟志远 on 2021/1/11.
//

import Foundation
import UIKit
import SnapKit

class CustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
        addTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
    }
    
    func addTarget() {
        
    }
    
    func bind() {
        
    }
}

class MindMapNode {
    var name: String = ""
    private(set) var children: [MindMapNode] = []
    var parent: MindMapNode?
    
    func addChild(node: MindMapNode) {
        children.append(node)
    }
}

class MindMapLineView: CustomView {
    let pathLayer = CAShapeLayer()
    
    override func setupUI() {
        layer.addSublayer(pathLayer)
    }
    
    override func layoutSubviews() {
        pathLayer.frame = bounds
        let path = UIBezierPath()
        let rect = self.bounds
        path.move(to: CGPoint.init(x: 0, y: rect.maxY))
        path.addCurve(to: .init(x: rect.maxX, y: 0) , controlPoint1: .init(x: rect.maxX / 2, y: rect.maxY), controlPoint2: .init(x: rect.maxX / 2, y: 0))
        path.lineWidth = 1
        pathLayer.strokeColor = UIColor.red.cgColor
        pathLayer.fillColor = nil
        pathLayer.path = path.cgPath
    }
}

class MindMapNodeView: CustomView {
    var mindMapNode: MindMapNode
    var line: MindMapLineView?
    var parentNodeView: MindMapNodeView?
    let nameLabel: UILabel = {
        let x = UILabel()
        x.textColor = .white
        return x
    }()
    
    init(node: MindMapNode) {
        self.mindMapNode = node
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        backgroundColor = .black
           _ = [nameLabel]
            .map{addSubview($0)}
        
        nameLabel.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalTo(UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5))
        }
        
        nameLabel.text = mindMapNode.name
    }
}

class MindMapViewController: UIViewController {
    
    var mindMapData: MindMapNode?
    
    override func viewDidLoad() {
        if let node = mindMapData {
            drawMindMap(node: node)
        }
        
    }
    
    func drawMindMap(parentNode: MindMapNodeView? = nil, node: MindMapNode) {
        let nodeView = MindMapNodeView(node: node)
        if let parentNode = parentNode {
            nodeView.parentNodeView = parentNode
            
            view.addSubview(nodeView)
            nodeView.snp.makeConstraints { (ConstraintMaker) in
                ConstraintMaker.left.equalTo(parentNode.snp.right).offset(30)
                ConstraintMaker.centerY.equalTo(parentNode).offset(-30)
            }
            let lView = MindMapLineView()
            nodeView.line = lView
            view.addSubview(lView)
            lView.snp.makeConstraints { (ConstraintMaker) in
                ConstraintMaker.bottom.equalTo(parentNode.snp.centerY)
                ConstraintMaker.left.equalTo(parentNode.snp.right)
                ConstraintMaker.right.equalTo(nodeView.snp.left)
                ConstraintMaker.top.equalTo(nodeView.snp.centerY)
            }
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panCallback(pan:)))
            nodeView.addGestureRecognizer(pan)
//            lView.transform = .init(scaleX: 1, y: -1)
        } else {
            view.addSubview(nodeView)
            nodeView.snp.makeConstraints { (ConstraintMaker) in
                ConstraintMaker.center.equalToSuperview()
            }
        }
        
        for child in node.children {
            drawMindMap(parentNode: nodeView, node: child)
        }
        
    }
    
    @objc func panCallback(pan: UIPanGestureRecognizer) {
        guard let v = pan.view as? MindMapNodeView, let parentNodeView = v.parentNodeView else {
            return
        }
        let offset = pan.translation(in: nil)
//        let pMaxX = v.parentNodeView?.frame.maxX
//        let pCenterY = (v.parentNodeView?.frame.maxY ?? 0) - (v.parentNodeView?.frame.height ?? 0)
        v.snp.remakeConstraints { (ConstraintMaker) in
            ConstraintMaker.left.equalTo(parentNodeView.snp.right).offset(30 + offset.x)
            ConstraintMaker.centerY.equalTo(parentNodeView).offset(-30 + offset.y)
        }
//        v.transform = .init(translationX: offset.x, y: offset.y)
    }
}
