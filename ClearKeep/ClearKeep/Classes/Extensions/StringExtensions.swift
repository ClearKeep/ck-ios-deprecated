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
