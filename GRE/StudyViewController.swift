//
//  StudyViewController.swift
//  GRE
//
//  Created by Yifan Wang on 2019/7/4.
//  Copyright © 2019 Yifan Wang. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class StudyViewController: UIViewController {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var explainationLabel: UILabel!
    
    @IBOutlet weak var rememberedBTN: UIButton!
    @IBOutlet weak var option1: UIButton!
    @IBOutlet weak var option2: UIButton!
    @IBOutlet weak var option3: UIButton!
    @IBOutlet weak var option4: UIButton!
    @IBOutlet weak var dontKnow: UIButton!
    
    @IBOutlet weak var progress: UILabel!
    
    var mode_study: Bool = true
    
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rememberedBTN.layer.cornerRadius = 5.0
        resetUI(rememberedBTN)
        
        refresh()
        mode(isStudy: true)
        
        resetUI(option1)
        resetUI(option2)
        resetUI(option3)
        resetUI(option4)
        resetUI(dontKnow)
    }
    
    @IBOutlet weak var reviewToday: UIBarButtonItem!
    @IBOutlet weak var reviewAll: UIBarButtonItem!
    
    @IBAction func switchMode(_ sender: UIBarButtonItem) {
        if sender.title! == "Study" {
            mode(isStudy: true)
            sender.title = "Review"
            reviewToday.isEnabled = true
            refresh()
        } else if sender.title! == "Review" {
            mode(isStudy: false)
            sender.title = "Study"
            review()
        } else if sender.title! == "Today" {
            mode(isStudy: false)
            reviewAll.title = "Study"
            reviewTodayWords()
            reviewToday.isEnabled = false
        }
    }
    
    var sessionWordCount = 0
    
    func mode(isStudy: Bool) -> Void {
        if isStudy {
            rememberedBTN.isHidden = false
            option1.isHidden = true
            option2.isHidden = true
            option3.isHidden = true
            option4.isHidden = true
            dontKnow.isHidden = true
            sessionWordCount = 0
            progress.text = "Session: \(sessionWordCount)"
        } else {
            meaningLabel.text = ""
            explainationLabel.text = ""
            rememberedBTN.isHidden = true
            option1.isHidden = false
            option2.isHidden = false
            option3.isHidden = false
            option4.isHidden = false
            dontKnow.isHidden = false
            //review()
        }
        
        mode_study = !mode_study
    }
    
    func refresh() -> Void {
        if let w = GreConfig.gre!.getWord() {
            wordLabel.text = w.word
            meaningLabel.text = w.meaning
            explainationLabel.text = w.engMeaning
            GreConfig.currentWord = w
            
            //pronounce(w.word)
        } else {
            wordLabel.text = "没词了"
        }
    }
    
    func pronounce(_ text: String) -> Void {
        let utterance  = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice()
        utterance.rate = 0.6
        
        self.synthesizer.speak(utterance)
    }
    
    var listLearnt:[GreWord]?
    var currentIndex: Int = 0
    weak var correct: UIButton?
    
    func review() -> Void {
        listLearnt = GreConfig.gre?.listLearnt()
        currentIndex = 0
        listLearnt?.shuffle()
        
        if listLearnt!.isEmpty {
            mode(isStudy: true)
            return
        }
        reviewNext()
    }
    
    func reviewTodayWords() -> Void {
        listLearnt = GreConfig.gre?.listLearntToday()
        currentIndex = 0
        listLearnt?.shuffle()
        
        if listLearnt!.isEmpty {
            mode(isStudy: true)
            return
        }
        reviewNext()
    }
    
    func reviewNext() -> Void {
        if currentIndex >= listLearnt!.count {
            mode(isStudy: true)
            reviewAll.title = "Review"
            reviewToday.isEnabled = true
            refresh()
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
    
    
    @IBAction func markRemembered(_ sender: Any) {
        GreConfig.gre?.markAsLearnt(GreConfig.currentWord!.word)
        //GreConfig.currentWord?.markAsLearnt()
        GreConfig.save()
        refresh()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
