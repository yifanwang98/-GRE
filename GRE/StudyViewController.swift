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
    
    @IBOutlet weak var progress: UILabel!
    
    var mode_study: Bool = true
    
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetUI(rememberedBTN)
        refresh()
    }
    
    var sessionWordCount = 0
    
    func refresh() -> Void {
        if let w = GreConfig.gre!.getWord() {
            wordLabel.text = w.word
            meaningLabel.text = w.meaning
            explainationLabel.text = w.engMeaning
            GreConfig.currentWord = w
            sessionWordCount += 1
            progress.text = "Session: \(sessionWordCount)"
        } else {
            wordLabel.text = "没词了"
            meaningLabel.text = "没词了"
            explainationLabel.text = "没词了"
        }
    }
    
    @IBAction func pronounce(_ sender: UIBarButtonItem) {
        pronounce(wordLabel.text ?? "")
    }
    
    private func pronounce(_ text: String) -> Void {
        let utterance  = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice()
        utterance.rate = 0.5
        
        self.synthesizer.speak(utterance)
    }
    
    private func resetUI(_ btn: UIButton) -> Void {
        btn.backgroundColor = GreConfig.greyBGC
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 5.0
    }
    
    @IBAction func markRemembered(_ sender: Any) {
        GreConfig.gre?.markAsLearnt(GreConfig.currentWord!.word)
        GreConfig.save()
        refresh()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
