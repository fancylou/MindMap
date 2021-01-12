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
    var positionIndexCache: Int = 0
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
        if let oldNodeIndex = nodes(positions: [node.position]).firstIndex(where: {$0.positionIndexCache == newIndex}) {
                children.insert(node, at: oldNodeIndex)
        } else { // 没有冲突
//            if [MindMapPosition.rightTop, MindMapPosition.leftTop].contains(node.position) { // 判断哪个顺序 top则放到数组后面 直接加入child就可以了
                children.append(node)
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
    
    public func updatePosition(newPositin: MindMapPosition, newIndex: Int) {
//        if newPositin == position {
            if newIndex == positionIndexCache {
                return
            }
            
            if newIndex > positionIndexCache {
                let p = parent
                self.removeFromParent()
                p?.insert(node: self, newIndex: newIndex)
            }
//        } else {
//        }
    }
    
    fileprivate func nodes(positions: [MindMapPosition]) -> [MindMapNode] {
        return children.filter{positions.contains($0.position)}
    }
}

