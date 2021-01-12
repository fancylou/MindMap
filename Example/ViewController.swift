//
//  ViewController.swift
//  Example
//
//  Created by 钟志远 on 2021/1/11.
//

import UIKit

class ViewController: UIViewController {

    lazy var mindMapVC: MindMapViewController = MindMapViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        createFakeNode()
        
        view.addSubview(mindMapVC.view)
        mindMapVC.view.frame = view.bounds
        self.addChild(mindMapVC)
        mindMapVC.didMove(toParent: self)

    }
    
    func createFakeNode() {
        let node = MindMapNode()
        node.name = "AAAAA"
        
        let nodeB = MindMapNode()
        nodeB.name = "BBBB"
        
        let nodeC = MindMapNode()
        nodeC.name = "CCCC"
        
        let nodeD = MindMapNode()
        nodeD.name = "DDDD"
        
        let nodeE = MindMapNode()
        nodeE.name = "EEEE"
        
        node.addChild(node: nodeB)
        node.addChild(node: nodeC)
        node.addChild(node: nodeD)
        node.addChild(node: nodeE)
        mindMapVC.mindMapData = node

    }
}

