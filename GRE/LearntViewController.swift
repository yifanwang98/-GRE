//
//  LearntViewController.swift
//  GRE
//
//  Created by Yifan Wang on 2019/7/15.
//  Copyright © 2019 Yifan Wang. All rights reserved.
//

import Foundation
import UIKit
import os.log

class LearntViewController: UIViewController {
    
    @IBOutlet weak var ta: UITextView!
    
    override func viewDidLoad() {
        ta.text.removeAll()
        let list = GreConfig.gre!.listLearnt()
        for item in list {
            ta.text.append(contentsOf: item.toString())
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
