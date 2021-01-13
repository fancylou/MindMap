//
//  MindMapNode.swift
//  Example
//
//  Created by 钟志远 on 2021/1/12.
//

import Foundation
import UIKit


class MindMapNode {
    var name: String = ""
    var position: MindMapPosition = .rightBottom
    
    private(set) var children: [MindMapNode] = []
    weak var parent: MindMapNode?
    weak var view: MindMapNodeView?
    
    func resort() {
        
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
        }
        
    }
    
    func removeFromParent() {
        parent?.removeChild(node: self)
    }
    
    func removeChild(node: MindMapNode) {
        if let index = children.firstIndex(where: {$0 === node}) {
            children.remove(at: index)
        }
        node.parent = nil
    }
    
    /**插入 保留position信息*/
    func move(node: MindMapNode, newIndex: Int, newPosition: MindMapPosition) {

        if let oldNode = self.getNode(index: newIndex, position: newPosition) {
            if oldNode === node {
                return
            }
            

            node.removeFromParent()
            
            guard let oldNodeIndex = children.firstIndex(where: {$0 === oldNode}) else {
                return
            }

            if [MindMapPosition.rightTop, MindMapPosition.leftTop].contains(newPosition) {
                children.insert(node, at: oldNodeIndex + 1)
            } else {
                children.insert(node, at: oldNodeIndex)
            }
            node.parent = self
            
        } else { // 没有冲突
            
            node.removeFromParent()
            node.parent = self
            
            if [MindMapPosition.rightTop, MindMapPosition.leftTop].contains(newPosition) {
                children.insert(node, at: 0)
            } else {
                children.append(node)
            }
        }
        
        node.position = newPosition
        resort()
    }

    func addChild(node: MindMapNode) {
        node.parent = self
        children.append(node)
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
    
    func calcInsertIndex(newPosition: MindMapPosition, geoIndex: Int) -> Int {
        let result = nodes(positions: [newPosition])
        var insertIndex = geoIndex
        
        if insertIndex > (result.count + 1) { //最大
            insertIndex = result.count + 1
        }
        
        return insertIndex
        
    }
    
    func getNode( index: Int, position: MindMapPosition) -> MindMapNode?{
        let result = nodes(positions: [position])
        if index > result.count {
            return nil
        }
        
        if [MindMapPosition.left, MindMapPosition.right].contains(position) {
            return result[index - 1]
        }
        
        if [MindMapPosition.leftBottom, MindMapPosition.rightBottom].contains(position) {
            return result[index - 1]
        } else {
            return result[result.count - index]
        }
    }

    fileprivate func nodes(positions: [MindMapPosition]) -> [MindMapNode] {
        return children.filter{positions.contains($0.position)}
    }
}

