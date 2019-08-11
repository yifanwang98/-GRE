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

class ReviewViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var option1: UIButton!
    @IBOutlet weak var option2: UIButton!
    @IBOutlet weak var option3: UIButton!
    @IBOutlet weak var option4: UIButton!
    @IBOutlet weak var dontKnow: UIButton!
    
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var correctRateLabel: UILabel!
    
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var from: UIDatePicker!
    @IBOutlet weak var to: UIDatePicker!
    @IBOutlet weak var limit: UITextField!
    @IBOutlet weak var sortBy: UISegmentedControl!
    @IBOutlet weak var order: UISegmentedControl!
    @IBOutlet weak var cover: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetUI(option1)
        resetUI(option2)
        resetUI(option3)
        resetUI(option4)
        resetUI(dontKnow)
        
        //reviewAllWords()
        correctRateLabel.text = "0.00%"
        
        errorLabel.text = ""
        
        from.minimumDate = GreConfig.gre?.getMinDate()
        from.maximumDate = Date()
        to.minimumDate = from.minimumDate
        to.maximumDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())
    }
    
    @IBOutlet weak var reviewToday: UIBarButtonItem!
    @IBOutlet weak var reviewAll: UIBarButtonItem!
    
    @IBAction func switchMode(_ sender: UIBarButtonItem) {
        correctRateLabel.text = "0.00%"
        correctNum = 0
        currentIndex = 0
        
        if sender.title! == "Start" {
            listLearnt = GreConfig.gre?.customizeReview(from: from.date,
                                                        to: to.date,
                                                        limit: Int(limit.text!) ?? 1,
                                                        sortBy: sortBy.selectedSegmentIndex,
                                                        order: order.selectedSegmentIndex)
            if listLearnt!.count > 0 {
                settingView.isHidden = true
                cover.isHidden = true
                sender.title! = "Edit"
                reviewNext()
            } else {
                errorLabel.text = "Unsatisfiable setting"
            }
        } else if sender.title! == "Edit" {
            settingView.isHidden = false
            cover.isHidden = false
            sender.title! = "Start"
            errorLabel.text = ""
        }
        /*
        if sender.title! == "All" {
            reviewAll.title = "Worst"
            reviewAllWords()
        } else if sender.title! == "Worst" {
            reviewAll.title = "All"
            reviewWorstWords()
        } else if sender.title! == "Today" {
            reviewTodayWords()
        }*/
    }
    
    @IBAction func endEdit(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    var listLearnt:[GreWord]?
    var currentIndex: Int = 0
    var correctNum: Int = 0
    
    weak var correct: UIButton?
    
    func reviewAllWords() -> Void {
        listLearnt = GreConfig.gre?.listLearnt()
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
        listLearnt?.shuffle()
        
        if listLearnt!.isEmpty {
            switchMode(reviewAll)
            return
        }
        
        reviewNext()
    }
    
    func reviewTodayWords() -> Void {
        listLearnt = GreConfig.gre?.listLearntToday()
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
            switchMode(reviewToday)
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
        btn.titleLabel?.numberOfLines = 2
    }
    
    var selected: Bool = false
    
    @IBAction func selectAnswer(_ sender: UIButton) {
        if self.selected {
            return
        }
        self.selected = true
        
        if sender == self.correct {
            self.correctNum += 1
            self.markAsCorrect(sender)
            DispatchQueue.global().sync {
                GreConfig.gre?.markAsCorrect(self.listLearnt![self.currentIndex].word)
            }
        } else {
            self.markAsCorrect(self.correct!)
            self.markAsError(sender)
            DispatchQueue.global().sync {
                GreConfig.gre?.markAsWrong(self.listLearnt![self.currentIndex].word)
            }
        }
        self.currentIndex += 1
        self.correctRateLabel.text = String(format: "%.2f", (Float(self.correctNum) / Float(self.currentIndex) * 100.0))
        self.correctRateLabel.text?.append("%")
        
        DispatchQueue.global().sync {
            GreConfig.save()
        }
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
