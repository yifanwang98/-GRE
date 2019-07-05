//
//  WordList.swift
//  GRE
//
//  Created by Yifan Wang on 2019/7/4.
//  Copyright © 2019 Yifan Wang. All rights reserved.
//

import Foundation

class WordList: NSObject, NSCoding {
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("GreWordList")
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(wordList, forKey: "wordList")
    }
    
    required init?(coder aDecoder: NSCoder) {
        wordList = aDecoder.decodeObject(forKey: "wordList") as! [GreWord]
    }
    override init() {
        super.init()
    }
    var wordList: [GreWord] = []
    
}

class GreWord: NSObject, NSCoding {
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("GreWord")
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(word, forKey: "word")
        aCoder.encode(meaning, forKey: "meaning")
        aCoder.encode(engMeaning, forKey: "engMeaning")
        aCoder.encode(studied, forKey: "studied")
        aCoder.encode(firstDate, forKey: "firstDate")
        aCoder.encode(lastDate, forKey: "lastDate")
        aCoder.encode(numStudy, forKey: "numStudy")
        aCoder.encode(numIncorrect, forKey: "numIncorrect")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let w = aDecoder.decodeObject(forKey: "word") as! String
        let m = aDecoder.decodeObject(forKey: "meaning") as! String
        let e = aDecoder.decodeObject(forKey: "engMeaning") as! String
        
        let s = aDecoder.decodeBool(forKey: "studied")
        
        let f = (aDecoder.decodeObject(forKey: "firstDate") as? Date)
        let l = aDecoder.decodeObject(forKey: "firstDate") as? Date
        
        let ns = aDecoder.decodeInteger(forKey: "numStudy")
        let ni = aDecoder.decodeInteger(forKey: "numIncorrect")
        
        self.init(word: w, meaning: m, description: e,
                  s: s, f: f, l: l, ns: ns, ni: ni)
    }
    
    
    let word: String
    let meaning: String
    let engMeaning: String
    
    var studied: Bool = false
    
    var firstDate: Date?
    var lastDate: Date?
    
    var numStudy: Int = 0
    var numIncorrect: Int = 0
    
    init(word: String, meaning: String, description: String) {
        self.word = word
        self.meaning = meaning
        self.engMeaning = description
    }
    
    init(word: String, meaning: String, description: String,
         s: Bool, f: Date?, l: Date?, ns: Int, ni: Int) {
        self.word = word
        self.meaning = meaning
        self.engMeaning = description
        
        studied = s
        firstDate = f
        lastDate = l
        numStudy = ns
        numIncorrect = ni
    }
    
}
