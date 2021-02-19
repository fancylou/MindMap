//
//  MindMapNode.swift
//  Example
//
//  Created by 钟志远 on 2021/1/12.
//

import Foundation
import UIKit


open class MindMapNode {
    open var name: String = ""
    open var position: MindMapPosition = .rightBottom
    open var payload: Any?
    
    private(set) var children: [MindMapNode] = []
    open weak var parent: MindMapNode?
    public weak var view: MindMapNodeView?
    public init(){}
    
    public func resort() {
        
        //翻转
        if parent != nil {
            if MindMapPosition.rightPosition.contains(self.position) { // 本节点在右侧 则子节点也在右侧
                _ = children.map{$0.position = .rightBottom}
            } else {
                _ = children.map{$0.position = .leftBottom}
            }
        }
        
        var nodes = self.nodes(positions: MindMapPosition.rightPosition)
        var numFlag = nodes.count / 2
        var oddFlag = nodes.count % 2 == 1
        for (index, node) in nodes.enumerated() {
            let calcNum = index - numFlag
            if calcNum < 0 {
                node.position = .rightTop
            } else {
                node.position = .rightBottom
                if oddFlag, calcNum == 0 {
                    node.position = .right
                }
            }
            node.resort()
        }
        
        nodes = self.nodes(positions: MindMapPosition.leftPosition)
        numFlag = nodes.count / 2
        oddFlag = nodes.count % 2 == 1
        for (index, node) in nodes.enumerated() {
            let calcNum = index - numFlag
            if calcNum < 0 {
                node.position = .leftTop
            } else {
                node.position = .leftBottom
                if oddFlag, calcNum == 0 {
                    node.position = .left
                }
            }
            node.resort()
        }
        
    }
    
    public func removeFromParent() {
        parent?.removeChild(node: self)
    }
    
    public func removeChild(node: MindMapNode) {
        if let index = children.firstIndex(where: {$0 === node}) {
            children.remove(at: index)
        }
        node.parent?.resort()
        node.parent = nil
    }
    
    
    public  func addChild(node: MindMapNode, index: Int? = nil) {
        node.parent = self
        if let i = index {
            children.insert(node, at: i)
        } else {
            children.append(node)
        }
        resort()
    }
    
    public func getPostionIndex() -> Int {
        guard let parent = parent else {
            return 0
        }
        
        if [MindMapPosition.left, MindMapPosition.right].contains(position) {
            return 0
        }
        
        if [MindMapPosition.leftBottom, MindMapPosition.rightBottom].contains(position) {
            let nodes = parent.nodes(positions: [position])
            if let index = nodes.firstIndex(where: {$0 === self}) {
                return index + 1
            }
        } else {
            
            let nodes = parent.nodes(positions: [position])
            if let index = nodes.firstIndex(where: {$0 === self}) {
                return nodes.count - index
            }
            
        }
        
        return 0
    }
    
    
    public func calcInsertIndex(newPosition: MindMapPosition, geoIndex: Int) -> Int {
        let result = nodes(positions: [newPosition])
        var insertIndex = geoIndex
        
        if insertIndex > (result.count + 1) { //最大
            insertIndex = result.count + 1
        }
        
        return insertIndex
        
    }
    
    public func slibing(isLast: Bool = true) -> MindMapNode? {
        guard let c = parent?.children.filter({ (x) -> Bool in
            x.position.isLeftPosition() == self.position.isLeftPosition()
        }) else {
            return nil
        }
        
        if let index = c.firstIndex(where: {$0 === self}) {
            if isLast {
                if index == 0 {
                    return nil
                }
                return c[index - 1]
            } else {
                let i = index + 1
                if i == c.count {
                    return nil
                }
                return c[i]
            }
        }
        return nil
    }
    
    public func deepNode(isTop: Bool = true, isLeft: Bool = false) -> MindMapNode {
        let subNodes = children.filter({$0.position.isLeftPosition() == isLeft})
        if subNodes.count == 0 {
            return self
        }
        
        if isTop {
            return subNodes.first!.deepNode(isTop: isTop, isLeft: isLeft)
        } else {
            return subNodes.last!.deepNode(isTop: isTop, isLeft: isLeft)
        }
    }
    
    public func getInnerNode() -> [MindMapNode] {
        
        var result = [MindMapNode]()
        result.append(self)
        for c in children {
            result.append(contentsOf: c.getInnerNode())
        }
        return result
    }
    
    public func nodes(positions: [MindMapPosition]) -> [MindMapNode] {
        return children.filter{positions.contains($0.position)}
    }
}

