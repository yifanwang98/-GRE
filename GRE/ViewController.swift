//
//  ViewController.swift
//  GRE
//
//  Created by Yifan Wang on 2019/7/4.
//  Copyright © 2019 Yifan Wang. All rights reserved.
//

import UIKit
import Foundation
import os.log

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do {
            GreConfig.load()
            if GreConfig.gre == nil {
                if let filePath = Bundle.main.path(forResource: "greWordList", ofType: nil) {
                    let fullText:String = try String(contentsOfFile: filePath)
                    let textArr:[String] = fullText.components(separatedBy: "\n").dropLast()
                    print(textArr.count)
                    var i = 0;
                    GreConfig.gre = WordList()
                    while i < textArr.count - 2 {
                        GreConfig.gre?.wordList.append(GreWord(word: textArr[i],
                                                               meaning: textArr[i + 1],
                                                               description: textArr[i + 2]))
                        i += 3
                    }
                    GreConfig.save()
                }
            }
            
        } catch {
            /* error handling here */
            os_log("[Error] LoadingViewController viewDidAppear()")
        }
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

