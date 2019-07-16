//
//  StudyViewController.swift
//  GRE
//
//  Created by Yifan Wang on 2019/7/4.
//  Copyright © 2019 Yifan Wang. All rights reserved.
//

import Foundation
import UIKit

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
    
    var mode_study: Bool = true
    
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
    
    
    @IBAction func switchMode(_ sender: UIBarButtonItem) {
        if sender.title!.count > 8 {
            mode(isStudy: true)
            sender.title = "Review"
            refresh()
        } else {
            mode(isStudy: false)
            sender.title = "Skip This Review"
            review()
        }
    }
    
    func mode(isStudy: Bool) -> Void {
        if isStudy {
            rememberedBTN.isHidden = false
            option1.isHidden = true
            option2.isHidden = true
            option3.isHidden = true
            option4.isHidden = true
            dontKnow.isHidden = true
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
        } else {
            wordLabel.text = "没词了"
        }
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
    
    func reviewNext() -> Void {
        if currentIndex >= listLearnt!.count {
            mode(isStudy: true)
            refresh()
            return
        }
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
    
    @IBAction func selectAnswer(_ sender: UIButton) {
        DispatchQueue.main.async {
            if sender == self.correct {
                self.markAsCorrect(sender)
                GreConfig.gre?.markAsCorrect(self.listLearnt![self.currentIndex].word)
            } else {
                self.markAsCorrect(self.correct!)
                self.markAsError(sender)
                GreConfig.gre?.markAsWrong(self.listLearnt![self.currentIndex].word)
            }
            self.currentIndex += 1
            GreConfig.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
                self.resetUI(self.option1)
                self.resetUI(self.option2)
                self.resetUI(self.option3)
                self.resetUI(self.option4)
                self.resetUI(self.dontKnow)
                self.reviewNext()
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
