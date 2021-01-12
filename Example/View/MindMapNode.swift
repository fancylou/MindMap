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
    
    func resort(node: MindMapNode, isInsert: Bool = true) {
        if MindMapPosition.rightPosition.contains(node.position) {
            let rightNodes = nodes(positions: MindMapPosition.rightPosition)
            let count = rightNodes.count
            if count == 1 {
                if isInsert {
                    node.position = .right
                } else {
                    rightNodes.first?.position = .right
                }
            } else {
                let rightTopNodes = nodes(positions: [.rightTop])
                let rightBottomNodes = nodes(positions: [.rightBottom])
                let rightTopCount = rightTopNodes.count
                let rightBottomCount = rightBottomNodes.count
                let rightTopIsBig = rightTopCount > rightBottomCount
                
                if count % 2 == 0 {
                    if isInsert {
                        let rightNode = nodes(positions: [.right]).first
                        if rightTopIsBig {
                            rightNode?.position = .rightBottom
                        } else {
                            rightNode?.position = .rightTop
                        }
                    } else {
                        if let rightNode = nodes(positions: [.right]).first {
                            if rightTopIsBig {
                                rightNode.position = .rightBottom
                            } else {
                                rightNode.position = .rightTop
                            }
                        }
                    }
                } else {
                    if isInsert {
                        node.position = .right
                    } else {
                        if rightTopIsBig {
                            rightTopNodes.last?.position = .right
                        } else {
                            rightBottomNodes.first?.position = .right
                        }
                    }
                }
            }
        } else { //left todo
            
            let leftNodes = nodes(positions: MindMapPosition.leftPosition)
            let count = leftNodes.count
            if count == 1 {
                node.position = .left
            } else {
                if count % 2 == 0 {
                    let leftNode = nodes(positions: [.left]).first
                    let leftTopCount = nodes(positions: [.leftTop]).count
                    let leftBottomCount = nodes(positions: [.leftBottom]).count
                    if leftTopCount > leftBottomCount {
                        leftNode?.position = .leftBottom
                    } else {
                        leftNode?.position = .leftTop
                    }
                } else {
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
            resort(node: node, isInsert: false)
        }
        node.parent = nil
        
    }
    
    /**插入 保留position信息*/
    func insert(node: MindMapNode, newIndex: Int) {
        node.parent = self
        
        for i in nodes(positions: [node.position]) {
            print(i.name)
            print(i.getPostionIndex())
        }
        if let oldNodeIndex = children.firstIndex(where: {$0.getPostionIndex() == newIndex && $0.position == node.position}) {
                children.insert(node, at: oldNodeIndex)
            
            //重排
            resort(node: node, isInsert: true)
        } else { // 没有冲突
//            if [MindMapPosition.rightTop, MindMapPosition.leftTop].contains(node.position) { // 判断哪个顺序 top则放到数组后面 直接加入child就可以了
            children.append(node)
            resort(node: node, isInsert: true)
//            } else { //bottom顺序
//                children.insert(node, at: 0)
//            }
        }
        
        
    }

    func addChild(node: MindMapNode) {
        node.parent = self
        children.append(node)
        if MindMapPosition.rightPosition.contains(node.position) {
            let rightNodes = nodes(positions: MindMapPosition.rightPosition)
            let count = rightNodes.count
            if count == 1 {
                node.position = .right
            } else {
                if count % 2 == 0 {
                    let rightNode = nodes(positions: [.right]).first
                    let rightTopCount = nodes(positions: [.rightTop]).count
                    let rightBottomCount = nodes(positions: [.rightBottom]).count
                    if rightTopCount > rightBottomCount {
                        rightNode?.position = .rightBottom
                    } else {
                        rightNode?.position = .rightTop
                    }
                } else {
                    node.position = .right
                }
            }
        } else { //left
            
            let leftNodes = nodes(positions: MindMapPosition.leftPosition)
            let count = leftNodes.count
            if count == 1 {
                node.position = .left
            } else {
                if count % 2 == 0 {
                    let leftNode = nodes(positions: [.left]).first
                    let leftTopCount = nodes(positions: [.leftTop]).count
                    let leftBottomCount = nodes(positions: [.leftBottom]).count
                    if leftTopCount > leftBottomCount {
                        leftNode?.position = .leftBottom
                    } else {
                        leftNode?.position = .leftTop
                    }
                } else {
                    node.position = .left
                }
            }
        }
    }
    
    public func getPostionIndex() -> Int {
        guard let parent = parent else {
            return 0
        }
        
        if [MindMapPosition.left, MindMapPosition.right].contains(position) {
            return 0
        }
        
//        if [MindMapPosition.leftBottom, MindMapPosition.rightBottom].contains(position) {
            let nodes = parent.nodes(positions: [position])
            if let index = nodes.firstIndex(where: {$0 === self}) {
               return index + 1
            }
//        } else {
//
//            let nodes = parent.nodes(positions: [position])
//            if let index = nodes.firstIndex(where: {$0 === self}) {
//                return index + 1
//            }
//
//        }
        
        return 0
    }
    
    public func updatePosition(newPositin: MindMapPosition, newIndex: Int) {
        let positionIndex = getPostionIndex()
        if newIndex == positionIndex, newPositin == position {
            return
        }
        
        let p = parent
        self.removeFromParent()
        
        self.position = newPositin
        p?.insert(node: self, newIndex: newIndex)
        
    }
    
    func calcInsertIndex(node: MindMapNode, newPosition: MindMapPosition, geoIndex: Int) -> Int {
        let result = nodes(positions: [newPosition])
        var insertIndex = geoIndex
        
        if insertIndex > (result.count + 1) { //最大
            insertIndex = result.count + 1
        }
//        return insertIndex
        if node.position == newPosition {

            return 0
        } else {
            
            
            
            return 0
        }
    }
    
    func node( index: Int, position: MindMapPosition) -> MindMapNode?{
        let result = nodes(positions: [position])
        if index > result.count {
            return nil
        }
        return result[index - 1]
    }

    fileprivate func nodes(positions: [MindMapPosition]) -> [MindMapNode] {
        return children.filter{positions.contains($0.position)}
    }
}

