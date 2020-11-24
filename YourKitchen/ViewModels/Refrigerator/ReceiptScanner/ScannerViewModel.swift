//
//  ScannerViewModel.swift
//  YourKitchen
//
//  Created by Markus Moltke on 15/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

/*
import Foundation
import MLKit

public class ScannerViewModel {
    
    
    public func fixScan(_ strings : [String]) {
        var newStrings = [String]()
        for s in strings {
            for query in s.components(separatedBy: "\n") {
                print(query)
                if (trimmedAlphabet(s: query) != "") {
                    newStrings.append(trimmedAlphabet(s: query))
                }
            }
        }
        print(newStrings)
    }
    
    func trimmedAlphabet(s : String) -> String {
        let unsafeChars = CharacterSet.letters.inverted  // Remove the .inverted to get the opposite result.
        let tmpChars = unsafeChars.union(CharacterSet(charactersIn: " ."))
        
        let cleanChars = s.components(separatedBy: tmpChars).joined(separator: "")
        return cleanChars == "x" ? s : cleanChars.components(separatedBy: "x")[0]
    }
    
    func getLanguage(s : String, _ completion : @escaping (String) -> Void) {
        let languageId = LanguageIdentification.languageIdentification()
        
        languageId.identifyLanguage(for: s) { (languageCode, err) in
            if let err = err {
                UserResponse.displayError(msg: err.localizedDescription)
                return
            }
            if let languageCode = languageCode, languageCode != "und" {
                completion(languageCode)
            }
        }
    }
    
    func translateString(s : String, _ completion : @escaping (String) -> Void) {
        self.getLanguage(s: s) { (languageCode) in
            print(languageCode)
        }
    }
}
*/
