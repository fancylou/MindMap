//
//  MindMapNode.swift
//  Example
//
//  Created by 钟志远 on 2021/1/12.
//

import Foundation


class MindMapNode {
    var name: String = ""
    var position: MindMapPosition = .rightBottom
    private(set) var children: [MindMapNode] = []
    weak var parent: MindMapNode?
    

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
    
    fileprivate func nodes(positions: [MindMapPosition]) -> [MindMapNode] {
        return children.filter{positions.contains($0.position)}
    }
}

