//
//  MindMapViewController.swift
//  Example
//
//  Created by 钟志远 on 2021/1/13.
//

import Foundation
import UIKit
import SnapKit

class MindMapViewController: UIViewController, UIScrollViewDelegate {

    var mindMapData: MindMapNode?
    var selectedView: MindMapNodeView? {
        didSet {
            oldValue?.selected = false
            selectedView?.selected = true
        }
    }
    let addChildNodeBtn: UIButton = {
      let x = UIButton()
        x.setTitle("添加子节点", for: .normal)
        x.backgroundColor = .black
        return x
    }()
    
    let scrollView: UIScrollView = {
      let x = UIScrollView()
        return x
    }()
    
    let contentView = UIView()
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.setContentOffset(.init(x: 800, y: 700), animated: true)
    }

    override func viewDidLoad() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 0.3
        scrollView.delegate = self

        scrollView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalToSuperview()
            ConstraintMaker.width.equalTo(2000)
            ConstraintMaker.height.equalTo(2000)
        }
        
//        contentView.backgroundColor = .gray
        
        if let node = mindMapData {
            updateNodesConstraints(node: node)
        }
        
        view.addSubview(addChildNodeBtn)
        
        addChildNodeBtn.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.centerX.equalToSuperview()
            ConstraintMaker.bottom.equalTo(-30)
        }

        addChildNodeBtn.addTarget(self, action: #selector(addChildNode), for: .touchUpInside)
    }
    
    @objc func addChildNode() {
        guard let selectedView = selectedView else {
           return
        }
        
        let node = MindMapNode.init()
        node.name = "test"
        selectedView.mindMapNode.addChild(node: node)
        updateNodesConstraints(parentNode: nil, node: mindMapData!)
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    var tmpOffsetCenter: CGPoint?
    var tmpPostion: MindMapPosition?
    var lastCalcPosition: MindMapPosition?
    var tmpChildFrame: CGRect?
    var closedNode: MindMapNode?
    
    @objc func tapNode(tap: UITapGestureRecognizer) {
        self.selectedView = tap.view as? MindMapNodeView
    }
    
    @objc func panCallback(pan: UIPanGestureRecognizer) {
        guard let v = pan.view as? MindMapNodeView, let parentNodeView = v.parentNodeView else {
            return
        }
        var offset = pan.translation(in: nil)
        offset.x /= self.scrollView.zoomScale
        offset.y /= self.scrollView.zoomScale
        let offsetCenter = v.frame.offsetCenter(rect: parentNodeView.frame)
        
        
        switch pan.state {
            case .began:
                closedNode = parentNodeView.mindMapNode
                tmpOffsetCenter = offsetCenter
                tmpPostion = v.mindMapNode.position
                tmpChildFrame = v.frame
            case .cancelled, .ended:
                if let calcPosition = lastCalcPosition, let node = mindMapData {
                    let parentCenterY = parentNodeView.frame.centerY
                    let childY = v.frame.centerY
                    var index = Int(abs(childY - parentCenterY) / MindMapNodeView.nodeLineGap) + 1

                    index = parentNodeView.mindMapNode.calcInsertIndex( newPosition: calcPosition.transferValid(), geoIndex: index)
                    
                    parentNodeView.mindMapNode.move(node: v.mindMapNode, newIndex: index, newPosition: calcPosition.transferValid())


                    self.updateNodesConstraints(node: node)
                    UIView.animate(withDuration: 0.25) {
                        self.view.layoutIfNeeded()
                    }
                }
                
                tmpPostion = nil
                tmpOffsetCenter = nil
                tmpChildFrame = nil
                return
            default:
                break
        }
        

        //判断closeNode
        let nowClosedNode: MindMapNode? = parentNodeView.mindMapNode.children.first
        if nowClosedNode !== closedNode {
            closedNode = nowClosedNode
            tmpOffsetCenter = tmpChildFrame?.offsetCenter(rect: nowClosedNode?.view?.frame ?? .zero)
        }
        //---
        
        if let value = tmpOffsetCenter, let tmpChildFrame = tmpChildFrame, let tmpPostion = tmpPostion, let closedNodeView = closedNode?.view {
            
            var tmpFrame = tmpChildFrame
            tmpFrame.origin.x += offset.x
            tmpFrame.origin.y += offset.y

        let position = MindMapPosition.generate(parentRect: closedNodeView.frame, childRect: tmpFrame)
            lastCalcPosition = position
            
            if position != tmpPostion {
                v.line?.setLayout(parent: closedNodeView, child: v, position: position)
                self.tmpPostion = position
            }
            
            v.snp.remakeConstraints { (ConstraintMaker) in
                ConstraintMaker.centerX.equalTo(closedNodeView).offset(offset.x + value.x).priority(ConstraintPriority.init(750))
                ConstraintMaker.centerY.equalTo(closedNodeView).offset(offset.y + value.y).priority(ConstraintPriority.init(750))
            }
        }
        
    }
    
    func updateNodeBaseConstraints(parentNode: MindMapNodeView? = nil, node: MindMapNode) {
        var nodeView: MindMapNodeView! = node.view
        if nodeView == nil {
           nodeView = MindMapNodeView(node: node)
            let tap = UITapGestureRecognizer(target: self, action: #selector(MindMapViewController.tapNode(tap:)))
            nodeView.addGestureRecognizer(tap)
        }

        if let parentNode = parentNode {
            nodeView.parentNodeView = parentNode

            if nodeView.superview == nil {
                contentView.addSubview(nodeView)
            }

//            let positionIndex = CGFloat(node.getPostionIndex())

            nodeView.snp.remakeConstraints { (ConstraintMaker) in
                if node.position == .right {
                    ConstraintMaker.left.equalTo(parentNode.snp.right).offset(MindMapNodeView.nodeGap).priority(.init(750))
                    ConstraintMaker.centerY.equalTo(parentNode).priority(.init(750))
                } else if node.position == .rightTop {
                    ConstraintMaker.left.equalTo(parentNode.snp.right).offset(MindMapNodeView.nodeGap).priority(.init(750))
//                    ConstraintMaker.centerY.equalTo(parentNode).offset(-MindMapNodeView.nodeLineGap * positionIndex).priority(.init(750))
                } else if node.position == .rightBottom {
                    ConstraintMaker.left.equalTo(parentNode.snp.right).offset(MindMapNodeView.nodeGap).priority(.init(750))
//                    ConstraintMaker.centerY.equalTo(parentNode).offset(MindMapNodeView.nodeLineGap * positionIndex).priority(.init(750))
                } else if node.position == .left {
                    ConstraintMaker.right.equalTo(parentNode.snp.left).offset(-MindMapNodeView.nodeGap).priority(.init(750))
                    ConstraintMaker.centerY.equalTo(parentNode).priority(.init(750))
                } else if node.position == .leftTop {
                    ConstraintMaker.right.equalTo(parentNode.snp.left).offset(-MindMapNodeView.nodeGap).priority(.init(750))
//                    ConstraintMaker.centerY.equalTo(parentNode).offset(-MindMapNodeView.nodeLineGap * positionIndex).priority(.init(750))
                } else if node.position == .leftBottom {
                    ConstraintMaker.right.equalTo(parentNode.snp.left).offset(-MindMapNodeView.nodeGap).priority(.init(750))
//                    ConstraintMaker.centerY.equalTo(parentNode).offset(MindMapNodeView.nodeLineGap * positionIndex).priority(.init(750))
                }
            }
            
            if nodeView.line == nil {
                let lView = MindMapLineView()
                nodeView.line = lView
                contentView.addSubview(lView)
                let pan = UIPanGestureRecognizer(target: self, action: #selector(panCallback(pan:)))
                nodeView.addGestureRecognizer(pan)
            }
                
            nodeView.line?.setLayout(parent: parentNode, child: nodeView, position: node.position)
            
        } else {
            if nodeView.superview == nil {
                contentView.addSubview(nodeView)
            }
            nodeView.snp.remakeConstraints { (ConstraintMaker) in
                ConstraintMaker.center.equalToSuperview()
            }
        }

        for child in node.children {
            updateNodeBaseConstraints(parentNode: nodeView, node: child)
        }
    }
    
    func addSlibingConstraints(node: MindMapNode) {
        if let lastSlibing = node.slibing() {
            let n1 = node.deepNode()
            let n2 = lastSlibing.deepNode(isTop: false)
            print("node: \(node.name) \(n1.name) - \(n2.name)")
            if let v1 = n1.view, let v2 = n2.view {
                v1.snp.makeConstraints { (ConstraintMaker) in
                    ConstraintMaker.top.equalTo(v2.snp.bottom).offset(MindMapNodeView.nodeLineGap)
                }
            }
//            return
        } else {
                
        }
        
        for cn in node.children {
            addSlibingConstraints(node: cn)
        }
        
    }

    func updateNodesConstraints(parentNode: MindMapNodeView? = nil, node: MindMapNode) {
        updateNodeBaseConstraints(parentNode: parentNode, node: node)
        addSlibingConstraints(node: node)
    }
}

extension CGRect {
    
    
    func collision(rect: CGRect) -> (Bool, Bool) {
       var x = true
       var y = true
        
        if minX > rect.maxX || maxX < rect.minX {
            x = false
        }
        
        if minY > rect.maxY || maxY < rect.minY {
            y = false
        }
        
        return (x, y)
        
    }
    
    func offsetCenter(rect: CGRect) -> CGPoint {
        .init(x: centerX - rect.centerX, y: centerY - rect.centerY)
    }
    
    var centerY: CGFloat {
       return maxY - (height / 2)
    }
    
    var centerX: CGFloat {
       return maxX - (width / 2)
    }
}
