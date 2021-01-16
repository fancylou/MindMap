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



class MindMapNodeView: CustomView {
    static var nodeGap: CGFloat = 50
    static var nodeLineGap: CGFloat = 20
    var mindMapNode: MindMapNode
    var line: MindMapLineView?
    var parentNodeView: MindMapNodeView?
    let nameLabel: UILabel = {
        let x = UILabel()
        x.textColor = .white
        x.setContentHuggingPriority(.init(1000), for: .vertical)
        x.setContentHuggingPriority(.init(1000), for: .horizontal)
        x.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        x.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        return x
    }()
    
    var selectedBorderColor = UIColor.gray
    
    var selected: Bool = false {
        didSet {
            self.layer.borderWidth = selected ? 3: 0
        }
    }
    
    init(node: MindMapNode) {
        self.mindMapNode = node
        super.init(frame: .zero)
        node.view = self
        self.layer.borderColor = self.selectedBorderColor.cgColor
        self.layer.borderWidth = selected ? 3: 0
    }
    
    func selfDragSafeArea() -> CGRect {
        var rect = frame
        let extendWidth = MindMapNodeView.nodeGap
        if mindMapNode.position.isLeftPosition() == false {
            rect.size.width += extendWidth
        } else {
            rect.size.width += extendWidth
            rect.origin.x -= extendWidth
        }
//        rect.origin.y -= MindMapNodeView.nodeLineGap / 2
//        rect.size.height += MindMapNodeView.nodeLineGap
        return rect
    }
    
    func selfAndOneDeepChildSafeArea() -> CGRect {
        var rect: CGRect = selfDragSafeArea()
        var rects = [CGRect]()
        for c in mindMapNode.children {
            if let r = c.view?.frame {
                rects.append(r)
            }
        }
        rect = rects.reduce(rect) { (r, v) -> CGRect in
            return r.union(v)
        }
        
        if rects.count > 0 {
            rect.origin.y -= MindMapNodeView.nodeLineGap / 2
            rect.size.height += MindMapNodeView.nodeLineGap
        }

        return rect
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
    
    func getInnerNodeView() -> [MindMapNodeView] {
        
        return mindMapNode.getInnerNode().map{$0.view}
            .compactMap{$0}
    }
    
    func removeOtherNodeViewConstraint(constraintsContainerView: UIView) {
        let innerNodeView = getInnerNodeView()
        
        for c in constraintsContainerView.constraints.filter({$0.firstItem is MindMapNodeView && $0.secondItem is MindMapNodeView}) {
            var needRemove: [NSLayoutConstraint] = []
            
            if innerNodeView.contains(where: {$0 === c.firstItem}), innerNodeView.contains(where: {$0 === c.secondItem}) {
                continue
            }
            
            needRemove.append(c)
            constraintsContainerView.removeConstraints(needRemove)

        }
        
    }
    
    func findColsedNodeView(rect: CGRect) -> MindMapNodeView {
        let views = getInnerNodeView()

        for v in views {
            let isCollision = v.selfAndOneDeepChildSafeArea().collision(rect: rect)
            if isCollision.0, isCollision.1 {
                return v
            }
        }
        
        var minDistance: CGFloat!
        var closedView: MindMapNodeView?
        
        for v in views {
           let distance = v.frame.offsetCenter(rect: rect)
            if minDistance == nil || distance.distancePower < minDistance {
                minDistance = distance.distancePower
                closedView = v
            }
        }
        
        return closedView ??  self
    }
    
    func findInsertIndex(rect: CGRect, position: MindMapPosition) -> Int {
        var index: Int = 0
       let samePostionNodes = mindMapNode.children
            .filter({ (x: MindMapNode) -> Bool in
                return x.position.isLeftPosition() == position.isLeftPosition()
            })
        
        for (offset, node) in samePostionNodes.enumerated() {
            if let v = node.view {
                if rect.centerY > v.frame.centerY {
                    index = offset + 1
                } else {
                    break
                }
            }
        }
        
        if index > 0 {
            let realIndex = mindMapNode.children.firstIndex(where: {$0 === samePostionNodes[index - 1]})!
            return Int(realIndex) + 1
        } else {
            return index
        }
    }
    
}
