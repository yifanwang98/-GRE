//
//  Config.swift
//  GRE
//
//  Created by Yifan Wang on 2019/7/4.
//  Copyright © 2019 Yifan Wang. All rights reserved.
//

import Foundation
import UIKit
import os.log

class GreConfig {
    
    static let wrongBGC: UIColor = UIColor(red: 204/255.0, green: 8/255.0, blue: 4/255.0, alpha: 1.0)
    static let correctBGC: UIColor = UIColor(red: 0, green: 148/255.0, blue: 169/255.0, alpha: 1.0)
    static let greyBGC: UIColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
    
    static var gre: WordList?
    
    static var currentWord : GreWord?
    
    static func load() -> Void {
//        gre = UserDefaults.standard.object(forKey: "greWordList") as? WordList
//        if let nsData = NSData(contentsOf: WordList.ArchiveURL) {
//            do {
//                GreConfig.gre = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [], from: nsData as Data) as? WordList
//            } catch {
//                os_log("gre failed to load.")
//            }
//        }
//
        gre = NSKeyedUnarchiver.unarchiveObject(withFile: WordList.ArchiveURL.path) as? WordList
        
    }
    
    static func save() {
        //UserDefaults.standard.set(gre, forKey: "greWordList")
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: gre!,
                                                        requiringSecureCoding: false)
            try data.write(to: WordList.ArchiveURL)
            os_log("gre successfully saved.")
        } catch {
            os_log("gre failed to save.")
        }
    }
}
