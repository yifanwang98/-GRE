//
//  Config.swift
//  GRE
//
//  Created by Yifan Wang on 2019/7/4.
//  Copyright © 2019 Yifan Wang. All rights reserved.
//

import Foundation
import os.log

class GreConfig {
    static var gre: WordList?
    
    static func load() -> Void {
        
        if let nsData = NSData(contentsOf: WordList.ArchiveURL) {
            do {
                GreConfig.gre = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [], from: nsData as Data) as? WordList
            } catch {
                os_log("gre failed to load.")
            }
        }
        //NSKeyedUnarchiver.unarchiveObject(withFile: WordList.ArchiveURL.path) as! WordList
        
    }
    
    static func save() {
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
