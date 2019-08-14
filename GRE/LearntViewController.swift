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

class LearntViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 26
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlphabetCell.identifier, for: indexPath)
        (cell as! AlphabetCell).setUp(indexPath.item, currentSelction: currentSelection)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            if currentSelection == indexPath.item {
                currentSelection = -1
                (cell as! AlphabetCell).containerView.backgroundColor = .white
                (cell as! AlphabetCell).label.textColor = .black
                currentChar = nil
            } else {
                currentSelection = indexPath.item
                (cell as! AlphabetCell).containerView.backgroundColor = GreConfig.correctBGC
                (cell as! AlphabetCell).label.textColor = .white
                currentChar = (cell as! AlphabetCell).label.text?.first
            }
            tableView.reloadData()
            if tableView.numberOfRows(inSection: 0) > 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            (cell as! AlphabetCell).containerView.backgroundColor = .white
            (cell as! AlphabetCell).label.textColor = .black
            currentChar = nil
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LearntWordCell.identifier, for: indexPath)
        (cell as! LearntWordCell).setUp(wordList[indexPath.item])
        return (cell as! LearntWordCell)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentChar: Character? = nil
    var currentSelection: Int = -1
    
    var wordList: [GreWord] {
        if GreConfig.gre == nil {
            return []
        }
        if currentChar != nil {
            return GreConfig.gre!.listLearnt(currentChar?.lowercased().first)
        }
        return GreConfig.gre!.listLearnt()
    }
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        
        collectionView.dataSource = self
        collectionView.delegate = self
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

class AlphabetCell: UICollectionViewCell {
    
    static let identifier: String = "alphabetCell"
    static let alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    
    func setUp(_ item: Int, currentSelction: Int) -> Void {
        containerView.layer.cornerRadius = 5.0
        var i = 0
        for char in AlphabetCell.alphabet {
            if i == item {
                label.text = String(char)
                break
            }
            i += 1
        }
        
        if currentSelction == item {
            containerView.backgroundColor = GreConfig.correctBGC
            label.textColor = .white
        } else {
            containerView.backgroundColor = .white
            label.textColor = .black
        }
    }
    
}
