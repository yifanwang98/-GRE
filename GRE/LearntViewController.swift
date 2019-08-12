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

class LearntViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LearntWordCell.identifier, for: indexPath)
        (cell as! LearntWordCell).setUp(wordList[indexPath.item])
        return (cell as! LearntWordCell)
    }

    @IBOutlet weak var tableView: UITableView!
    
    var wordList: [GreWord] = []
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

class LearntWordCell: UITableViewCell {
    
    static let identifier: String = "learntCell"
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    func setUp(_ word: GreWord) -> Void {
        label1.text = word.word
        label2.text = word.meaning
        label3.text = word.engMeaning
        if word.engMeaning.count < 2 {
            print(word)
        }
    }
}
