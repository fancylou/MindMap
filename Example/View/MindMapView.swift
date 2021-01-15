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
    static var nodeLineGap: CGFloat = 60
    var mindMapNode: MindMapNode
    var line: MindMapLineView?
    var parentNodeView: MindMapNodeView?
    let nameLabel: UILabel = {
        let x = UILabel()
        x.textColor = .white
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
    
    func dragSafeArea() -> CGRect {
        var rect = frame
        var extendWidth = MindMapNodeView.nodeGap
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
}
