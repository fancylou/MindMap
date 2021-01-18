//
//  NodeToolView.swift
//  MindMap
//
//  Created by 钟志远 on 2021/1/18.
//

import Foundation
import UIKit

public class NodeToolView: NodeMapCustomView {
    
    public let addChildNodeBtn: UIButton = {
      let x = UIButton()
        x.setImage(MindMapRes.node(), for: .normal)
        x.backgroundColor = UIColor.lightGray
        x.layer.cornerRadius = 8
        x.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        return x
    }()
    
    public let addSlibingNodeBtn: UIButton = {
      let x = UIButton()
        x.setImage(MindMapRes.node_slibing(), for: .normal)
        x.backgroundColor = UIColor.lightGray
        x.layer.cornerRadius = 8
        x.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        return x
    }()
    
    let stackView: UIStackView = {
        let x = UIStackView()
        x.axis = .horizontal
        x.spacing = 15
        return x
    }()
    
    override func setupUI() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalToSuperview()
        }
        
       _ = [addChildNodeBtn, addSlibingNodeBtn]
        .map{stackView.addArrangedSubview($0)}
        
        addChildNodeBtn.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.size.equalTo(CGSize.init(width: 40, height: 40))
        }
        
        addSlibingNodeBtn.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.size.equalTo(CGSize.init(width: 40, height: 40))
        }
    }
}
