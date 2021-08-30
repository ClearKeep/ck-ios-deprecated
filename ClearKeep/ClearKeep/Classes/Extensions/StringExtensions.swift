//
//  StringExtensions.swift
//  ClearKeep
//
//  Created by Seoul on 1/29/21.
//

import Foundation

extension String {
    func textFieldValidatorEmail() -> Bool {
        if self.count > 100 {
            return false
        }
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    func textFieldValidatorURL() -> Bool {
        if self.count > 20 {
            return false
        }
        
        let urlFormat = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
        
        let urlPredicate = NSPredicate(format:"SELF MATCHES %@", urlFormat)
        return urlPredicate.evaluate(with: self)
    }

    /// Returns the first element of the collection of string. If a collection
    /// is empty, returns nil.
    var first: Character? {
        if isEmpty {
            return nil
        }
        return self[index(startIndex, offsetBy: 0)]
    }
    
    func prefixShortName(useSingleLetter: Bool = true) -> String {
        var letters = String()
        var components = self.components(separatedBy: " ")
        
        if let firstWord = components.first {
            if let letter = firstWord.first {
                letters.append(letter)
                components.removeFirst()
            }
        }
        
        if !useSingleLetter && !components.isEmpty {
            if let letter = components.first?.first {
                letters.append(letter)
            }
        }
        
        return letters.uppercased()
    }
}

extension String
    {
        var parseJSONString: AnyObject?
        {
            let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)

            if let jsonData = data
            {
                // Will return an object or nil if JSON decoding fails
                do
                {
                    let message = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers)
                    if let jsonResult = message as? NSMutableArray
                    {
                        print(jsonResult)

                        return jsonResult //Will return the json array output
                    }
                    else
                    {
                        return nil
                    }
                }
                catch let error as NSError
                {
                    print("An error occurred: \(error)")
                    return nil
                }
            }
            else
            {
                // Lossless conversion of the string was not possible
                return nil
            }
        }
    }
