//
//  rac_textField.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 25.09.16.
//
//
import Foundation
extension String {
    func isValidEmail() -> Bool {
        if self == "" { return false }
        do {
            let regex = try NSRegularExpression(pattern:
                "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
                    "\\@" +
                    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                    "(" +
                    "\\." +
                    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                ")+", options: .caseInsensitive)
            
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
}
