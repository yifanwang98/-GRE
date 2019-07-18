//
//  ReviewViewController.swift
//  GRE
//
//  Created by Yifan Wang on 2019/7/17.
//  Copyright © 2019 Yifan Wang. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ReviewViewController: UIViewController {
    
    @IBOutlet weak var wordLabel: UILabel!

    @IBOutlet weak var option1: UIButton!
    @IBOutlet weak var option2: UIButton!
    @IBOutlet weak var option3: UIButton!
    @IBOutlet weak var option4: UIButton!
    @IBOutlet weak var dontKnow: UIButton!
    
    @IBOutlet weak var progress: UILabel!
    
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetUI(option1)
        resetUI(option2)
        resetUI(option3)
        resetUI(option4)
        resetUI(dontKnow)
        
        reviewAllWords()
    }
    
    @IBOutlet weak var reviewToday: UIBarButtonItem!
    @IBOutlet weak var reviewAll: UIBarButtonItem!
    
    @IBAction func switchMode(_ sender: UIBarButtonItem) {
        if sender.title! == "All" {
            reviewAll.title = "Worst"
            reviewAllWords()
        } else if sender.title! == "Worst" {
            reviewAll.title = "All"
            reviewWorstWords()
        } else if sender.title! == "Today" {
            reviewTodayWords()
        }
    }
    
    var listLearnt:[GreWord]?
    var currentIndex: Int = 0
    weak var correct: UIButton?
    
    func reviewAllWords() -> Void {
        listLearnt = GreConfig.gre?.listLearnt()
        currentIndex = 0
        listLearnt?.shuffle()
        
        if listLearnt!.isEmpty {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let toViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            self.present(toViewController, animated:true, completion:nil)
            return
        }
        
        reviewNext()
    }
    
    func reviewWorstWords() -> Void {
        listLearnt = GreConfig.gre?.listWorst()
        currentIndex = 0
        listLearnt?.shuffle()
        
        if listLearnt!.isEmpty {
            switchMode(reviewAll)
            return
        }
        
        reviewNext()
    }
    
    func reviewTodayWords() -> Void {
        listLearnt = GreConfig.gre?.listLearntToday()
        currentIndex = 0
        listLearnt?.shuffle()
        
        if listLearnt!.isEmpty {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let toViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            self.present(toViewController, animated:true, completion:nil)
            return
        }
        
        reviewNext()
    }
    
    func reviewNext() -> Void {
        if currentIndex >= listLearnt!.count {
            switchMode(reviewAll)
            return
        }
        progress.text = "\(currentIndex + 1) / \(listLearnt!.count)"
        wordLabel.text = listLearnt![currentIndex].word
        let number = Int.random(in: 1 ..< 5)
        let m = listLearnt![currentIndex].meaning
        let wrongs = GreConfig.gre!.getRandom3Meaning(except: m)
        if number == 1 {
            correct = option1
            option2.setTitle(wrongs[0], for: .normal)
            option3.setTitle(wrongs[1], for: .normal)
            option4.setTitle(wrongs[2], for: .normal)
        } else if number == 2 {
            correct = option2
            option1.setTitle(wrongs[0], for: .normal)
            option3.setTitle(wrongs[1], for: .normal)
            option4.setTitle(wrongs[2], for: .normal)
        } else if number == 3 {
            correct = option3
            option2.setTitle(wrongs[0], for: .normal)
            option1.setTitle(wrongs[1], for: .normal)
            option4.setTitle(wrongs[2], for: .normal)
        } else if number == 4 {
            correct = option4
            option2.setTitle(wrongs[0], for: .normal)
            option3.setTitle(wrongs[1], for: .normal)
            option1.setTitle(wrongs[2], for: .normal)
        }
        correct?.setTitle(m, for: .normal)
    }
    
    func markAsError(_ btn: UIButton) -> Void {
        btn.backgroundColor = GreConfig.wrongBGC
        btn.setTitleColor(.white, for: .normal)
    }
    
    func markAsCorrect(_ btn: UIButton) -> Void {
        btn.backgroundColor = GreConfig.correctBGC
        btn.setTitleColor(.white, for: .normal)
    }
    
    func resetUI(_ btn: UIButton) -> Void {
        btn.backgroundColor = GreConfig.greyBGC
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 5.0
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.numberOfLines = 1
    }
    
    var selected: Bool = false
    
    @IBAction func selectAnswer(_ sender: UIButton) {
        DispatchQueue.main.async {
            if self.selected {
                return
            }
            if sender == self.correct {
                self.markAsCorrect(sender)
                GreConfig.gre?.markAsCorrect(self.listLearnt![self.currentIndex].word)
            } else {
                self.markAsCorrect(self.correct!)
                self.markAsError(sender)
                GreConfig.gre?.markAsWrong(self.listLearnt![self.currentIndex].word)
            }
            self.selected = true
            self.currentIndex += 1
            GreConfig.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                self.resetUI(self.option1)
                self.resetUI(self.option2)
                self.resetUI(self.option3)
                self.resetUI(self.option4)
                self.resetUI(self.dontKnow)
                self.reviewNext()
                self.selected = false
            })
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
