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
    
    func getRandom3Meaning(except: String) -> [String] {
        var temp: [String] = []
        var nums: [Int] = []
        while temp.count != 3 {
            let number = Int.random(in: 0 ..< wordList.count)
            if wordList[number].word != except && !nums.contains(number) {
                temp.append(wordList[number].meaning)
                nums.append(number)
            }
        }
        return temp
    }
    
    func getWord() -> GreWord? {
        for w in wordList {
            if !w.studied {
                return w
            }
        }
        
        return nil
    }
    
    func getMinDate() -> Date {
        var min: Date = Date()
        for w in wordList {
            if w.firstDate?.compare(min) == .orderedAscending {
                min = w.firstDate!
            }
        }
        return min
    }
    
    func getMaxDate() -> Date {
        var max: Date = Date()
        for w in wordList {
            if w.firstDate?.compare(max) == .orderedDescending {
                max = w.firstDate!
            }
        }
        return max
    }
    
    func customizeReview(from: Date, to: Date, limit: Int, sortBy: Int, order: Int) -> [GreWord] {
        var temp: [GreWord] = []
        for w in wordList {
            if w.studied {
                if w.firstDate!.compare(from) == .orderedAscending || w.firstDate!.compare(to) == .orderedDescending {
                    continue
                }
                temp.append(w)
            }
        }
        switch sortBy {
        case 1:
            if order == 0 {
                temp.sort(by: {(x: GreWord, y: GreWord) -> Bool in return (Float(x.numIncorrect) / Float(x.numStudy)) < (Float(y.numIncorrect) / Float(y.numStudy))})
            } else if order == 1 {
                temp.sort(by: {(x: GreWord, y: GreWord) -> Bool in return (Float(x.numIncorrect) / Float(x.numStudy)) > (Float(y.numIncorrect) / Float(y.numStudy))})
            }
        case 2:
            if order == 0 {
                temp.sort(by: {(x: GreWord, y: GreWord) -> Bool in return x.firstDate!.compare(y.firstDate!) == .orderedAscending })
            } else if order == 1 {
                temp.sort(by: {(x: GreWord, y: GreWord) -> Bool in return x.firstDate!.compare(y.firstDate!) == .orderedDescending})
            }
        case 3:
            if order == 0 {
                temp.sort(by: {(x: GreWord, y: GreWord) -> Bool in return x.numStudy < y.numStudy })
            } else if order == 1 {
                temp.sort(by: {(x: GreWord, y: GreWord) -> Bool in return x.numStudy > y.numStudy })
            }
        default:
            temp.shuffle()
        }
        var result: [GreWord] = []
        result.append(contentsOf: temp.prefix(limit))
        if order == 3 && sortBy != 0 {
            result.shuffle()
        }
        temp.removeAll()
        return result
    }
    
    func listLearnt(_ char: Character? = nil) -> [GreWord] {
        var temp: [GreWord] = []
        for w in wordList {
            if w.studied {
                temp.append(w)
            }
        }
        return temp
    }
    
    func listWorst() -> [GreWord] {
        var temp: [GreWord] = []
        for w in wordList {
            if w.studied && w.numIncorrect > 0 {
                temp.append(w)
            }
        }
        temp.sort(by: {(x: GreWord, y: GreWord) -> Bool in return (Float(x.numIncorrect) / Float(x.numStudy)) > (Float(y.numIncorrect) / Float(y.numStudy))})
        return temp
    }
    
    func listLearntToday() -> [GreWord] {
        var temp: [GreWord] = []
        for w in wordList {
            if w.studied && Calendar.current.isDateInToday(w.firstDate!) {
                temp.append(w)
            }
        }
        return temp
    }
    
    func markAsLearnt(_ w: String) -> Void {
        for item in self.wordList {
            if item.word == w {
                item.markAsLearnt()
                break
            }
        }
    }
    
    func markAsCorrect(_ w: String) -> Void {
        for item in self.wordList {
            if item.word == w {
                item.markAsLearnt()
                break
            }
        }
    }
    
    func markAsWrong(_ w: String) -> Void {
        for item in self.wordList {
            if item.word == w {
                item.markAsWrong()
                break
            }
        }
    }
    
    func getStats() -> String {
        var s = "Total Learnt: "
        var count = 0, today = 0, yesterday = 0
        for item in self.wordList {
            if item.studied {
                count += 1
                if Calendar.current.isDateInToday(item.firstDate!) {
                    today += 1
                } else if Calendar.current.isDateInYesterday(item.firstDate!) {
                    yesterday += 1
                }
            }
        }
        s.append("\(count)\n\n")
        s.append("Total To Learn: \(self.wordList.count - count)\n\n")
        s.append("Today Learnt: \(today)\n\n")
        s.append("Yesterday Learnt: \(yesterday)\n\n")
        return s
    }
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
        let l = aDecoder.decodeObject(forKey: "lastDate") as? Date
        
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
    
    func markAsLearnt() -> Void {
        studied = true
        if firstDate == nil {
            firstDate = Date()
        }
        
        lastDate = Date()
        numStudy += 1
    }
    
    func markAsWrong() -> Void {
        lastDate = Date()
        numIncorrect += 1
        numStudy += 1
    }
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "EDT")
        let f = dateFormatter.string(from: firstDate!)
        let l = dateFormatter.string(from: lastDate!)
        var s: String = ""
        s.append(self.word)
        s.append("\n\t")
        s.append(self.meaning)
        s.append("\n\t")
        s.append(self.engMeaning)
        s.append("\n\t")
        s.append("\(f) ~ \(l)")
        s.append("\n\t")
        s.append("Incorrect Rate: \(numIncorrect) / \(numStudy)")
        s.append("\n\n")
        return s
    }
}
