//
//  MindMapViewController.swift
//  Example
//
//  Created by 钟志远 on 2021/1/13.
//

import Foundation
import UIKit
import SnapKit

open class MindMapViewController: UIViewController, UIScrollViewDelegate {

   open var mindMapData: MindMapNode?
   open var selectedView: MindMapNodeView? {
        didSet {
            oldValue?.selected = false
            oldValue?.nameTextField.isUserInteractionEnabled = false
            selectedView?.selected = true
            updateToolView()
        }
    }
    public let toolView: NodeToolView = {
      let x = NodeToolView()
        return x
    }()
    
    public let scrollView: UIScrollView = {
        let x = UIScrollView()
        x.maximumZoomScale = 2
        x.minimumZoomScale = 0.5
        return x
    }()
    
    public let contentView = UIView()
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        scrollView.setContentOffset(.init(x: 800, y: 700), animated: true)
        gotoMapSource()
    }

    open override func viewDidLoad() {
//        contentView.backgroundColor = .green
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.delegate = self

        scrollView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalToSuperview()
            ConstraintMaker.width.equalTo(1000)
            ConstraintMaker.height.equalTo(1000)
        }
        
        if let node = mindMapData {
            updateNodesConstraints(node: node)
            self.view.layoutIfNeeded()
            updateContentSize()
        }

        view.addSubview(toolView)
        
        toolView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.right.equalTo(-20)
            ConstraintMaker.bottom.equalTo(-30)
        }

        toolView.addChildNodeBtn.addTarget(self, action: #selector(addChildNode), for: .touchUpInside)
        toolView.addSlibingNodeBtn.addTarget(self, action: #selector(addSlibingChildNode), for: .touchUpInside)
        toolView.locationBtn.addTarget(self, action: #selector(gotoMapSource), for: .touchUpInside)
        toolView.deleteBtn.addTarget(self, action: #selector(deleteNode), for: .touchUpInside)
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(MindMapViewController.viewTap))
        view.addGestureRecognizer(viewTap)
        updateToolView()
    }
    
    @objc func deleteNode() {
        if selectedView?.mindMapNode === mindMapData {
            return
        }
        
        let views = selectedView?.getInnerNodeView()
        
        selectedView?.mindMapNode.removeFromParent()
        
        _ = views?.map({ (v:MindMapNodeView) in
            v.line?.removeFromSuperview()
            v.removeFromSuperview()
        })

        if let d = mindMapData {
            updateNodesConstraints(node: d)
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            } completion: {[unowned self] (_) in
                self.updateContentSize()
            }
        }
        
    }
    
    @objc func viewTap() {
        self.selectedView = nil
    }
    
    func updateToolView() {
        if selectedView == nil || selectedView?.mindMapNode === mindMapData {
            _ = [self.toolView.addSlibingNodeBtn, self.toolView.deleteBtn]
                .map{$0.isHidden = true}
        } else {
            _ = [self.toolView.addChildNodeBtn, self.toolView.addSlibingNodeBtn, self.toolView.deleteBtn]
                .map{$0.isHidden = false}
        }
        
//        UIView.animate(withDuration: 0.25) {
//            self.toolView.layoutIfNeeded()
//        }
    }
    
    @objc func gotoMapSource() {
        guard let frame = mindMapData?.view?.frame else {
            return
        }
        let screenBounds = UIScreen.main.bounds
        self.scrollView.zoomScale = 1
        self.scrollView.setContentOffset(.init(x: frame.centerX - screenBounds.width / 2, y: frame.centerY - screenBounds.height / 2), animated: true)
    }
    
    func updateContentSize() {
        guard let frame = self.mindMapData?.view?.totalNodeViewFrame() else {
            return
        }
        
        let size = frame.size
        let screenBounds = UIScreen.main.bounds
        var w = size.width * 2 + screenBounds.width
        var h = size.height * 2 + screenBounds.height
        let scrollViewBounds = self.scrollView.bounds
        if w < scrollViewBounds.width {
            w = scrollViewBounds.width
        }
        if h < scrollViewBounds.height {
            h = scrollViewBounds.height
        }
        
        let oldBounds = contentView.bounds
        var widthOffset = w - oldBounds.width
        var heightOffset = h - oldBounds.height
        
        contentView.snp.updateConstraints { (ConstraintMaker) in
            ConstraintMaker.width.equalTo(w)
            ConstraintMaker.height.equalTo(h)
        }
        
        widthOffset *= self.scrollView.zoomScale
        heightOffset *= self.scrollView.zoomScale

        self.view.layoutIfNeeded()
        let oldOffset = self.scrollView.contentOffset
        self.scrollView.setContentOffset(.init(x: oldOffset.x + widthOffset / 2, y: oldOffset.y + heightOffset / 2) , animated: false)
        
    }
    

    @objc func addSlibingChildNode() {
        guard let selectedView = selectedView, let insertIndex = selectedView.mindMapNode.parent?.children.firstIndex(where: {$0 === selectedView.mindMapNode}) else {
           return
        }
        
        let node = MindMapNode.init()
        node.name = "子节点"
        node.position = selectedView.mindMapNode.position
        selectedView.mindMapNode.parent?.addChild(node: node, index: insertIndex + 1)
        updateNodesConstraints(parentNode: nil, node: mindMapData!)
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        } completion: {[unowned self] (_) in
            self.updateContentSize()
        }
    }
    
    @objc func addChildNode() {
        guard let selectedView = selectedView else {
           return
        }
        
        let node = MindMapNode.init()
        node.name = "子节点"
        selectedView.mindMapNode.addChild(node: node)
        updateNodesConstraints(parentNode: nil, node: mindMapData!)
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        } completion: {[unowned self] (_) in
            self.updateContentSize()
        }
    }

    var tmpOffsetCenter: CGPoint?
    var lastCalcPosition: MindMapPosition?
    var tmpChildFrame: CGRect?
    var closedNode: MindMapNode?
    
    var dragNode: MindMapNode?
    
//    open override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//    }
    
    @objc func tapNode(tap: UITapGestureRecognizer) {
        self.selectedView = tap.view as? MindMapNodeView
    }
    
    @objc func doubleTapNode(tap: UITapGestureRecognizer) {
        let v =  tap.view as? MindMapNodeView
        self.selectedView = v
        v?.nameTextField.isUserInteractionEnabled = true
        v?.nameTextField.becomeFirstResponder()
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
                tmpChildFrame = v.frame
                
                closedNode = parentNodeView.mindMapNode
                dragNode = v.mindMapNode
                v.mindMapNode.removeFromParent()
                v.removeOtherNodeViewConstraint(constraintsContainerView: self.contentView)
                updateNodesConstraints(parentNode: nil, node: mindMapData!)
            case .cancelled, .ended:
                if let node = mindMapData, let lastCalcPosition = lastCalcPosition {
                    v.mindMapNode.position = lastCalcPosition.transferValid()
                    if let index = closedNode?.view?.findInsertIndex(rect: v.frame, position: lastCalcPosition.transferValid()) {
                        closedNode?.addChild(node: v.mindMapNode, index: index)
                        self.updateNodesConstraints(node: node)
                        UIView.animate(withDuration: 0.25) {
                            self.view.layoutIfNeeded()
                        } completion: {[unowned self] (_) in
                            self.updateContentSize()
                        }
                    }
                }

                tmpOffsetCenter = nil
                tmpChildFrame = nil
                return
            default:
                break
        }
        

        //判断closeNode
        let findedCloseView = mindMapData?.view?.findColsedNodeView(rect: v.frame)
//        let nowClosedNode: MindMapNode? = parentNodeView.mindMapNode
        let nowClosedNode: MindMapNode? = findedCloseView?.mindMapNode
        if nowClosedNode !== closedNode {
            closedNode = nowClosedNode
            tmpOffsetCenter = tmpChildFrame?.offsetCenter(rect: nowClosedNode?.view?.frame ?? .zero)
        }
        //---
        
        if let value = tmpOffsetCenter, let tmpChildFrame = tmpChildFrame,  let closedNodeView = closedNode?.view {
            
            var tmpFrame = tmpChildFrame
            tmpFrame.origin.x += offset.x
            tmpFrame.origin.y += offset.y

        let position = MindMapPosition.generate(parentRect: closedNodeView.frame, childRect: tmpFrame)
            lastCalcPosition = position
            
            v.line?.setLayout(parent: closedNodeView, child: v, position: position)

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
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapNode(tap:)))
            doubleTap.numberOfTapsRequired = 2
            nodeView.addGestureRecognizer(doubleTap)
        }

        if let parentNode = parentNode {
            nodeView.parentNodeView = parentNode

            if nodeView.superview == nil {
                contentView.addSubview(nodeView)
            }

            nodeView.snp.remakeConstraints { (ConstraintMaker) in
                if node.position == .right || node.position == .rightTop || node.position == .rightBottom {
                    ConstraintMaker.left.equalTo(parentNode.snp.right).offset(MindMapNodeView.nodeGap).priority(.init(750))
                    ConstraintMaker.centerY.equalTo(parentNode).priority(.init(750))
                    if node.position == .rightTop {
                        ConstraintMaker.bottom.lessThanOrEqualTo(parentNode.snp.top).offset(-MindMapNodeView.nodeLineGap)
                    } else if node.position == .rightBottom {
                        ConstraintMaker.top.greaterThanOrEqualTo(parentNode.snp.bottom).offset(MindMapNodeView.nodeLineGap)
                    }
                } else if node.position == .left || node.position == .leftTop || node.position == .leftBottom {
                    ConstraintMaker.right.equalTo(parentNode.snp.left).offset(-MindMapNodeView.nodeGap).priority(.init(750))
                    ConstraintMaker.centerY.equalTo(parentNode).priority(.init(750))
                    
                    if node.position == .leftTop {
                        ConstraintMaker.bottom.lessThanOrEqualTo(parentNode.snp.top).offset(-MindMapNodeView.nodeLineGap)
                    } else if node.position == .leftBottom {
                        ConstraintMaker.top.greaterThanOrEqualTo(parentNode.snp.bottom).offset(MindMapNodeView.nodeLineGap)
                    }
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
            let n1 = node.deepNode(isLeft: node.position.isLeftPosition())
            let n2 = lastSlibing.deepNode(isTop: false, isLeft: lastSlibing.position.isLeftPosition())
            if let v1 = n1.view, let v2 = n2.view {
                if let existConstaint = v1.constraints.first(where: { (x) -> Bool in
                    return x.firstItem === v1 && x.secondItem === v2
                }) {
                    v1.removeConstraint(existConstaint)
                }
                v1.snp.makeConstraints { (ConstraintMaker) in
                    ConstraintMaker.top.greaterThanOrEqualTo(v2.snp.bottom).offset(MindMapNodeView.nodeLineGap)
                }
            }
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
    
//    func union(rect: CGRect) -> CGRect {
//        var result = CGRect()
//        result.origin.x = min(minX, rect.minX)
//        result.origin.y = min(minY, rect.minY)
//        let max_x = max(maxX, rect.maxX)
//        let max_y = max(maxY, rect.maxY)
//        result.size.width = max_x - result.origin.x
//        result.size.height = max_y - result.origin.y
//
//        return result
//    }
}

extension CGPoint {
    var distancePower: CGFloat {
        return x * x + y * y
    }
}
