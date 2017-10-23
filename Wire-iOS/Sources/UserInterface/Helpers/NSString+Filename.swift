//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import Foundation

extension NSString {
    
    fileprivate static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-hh.mm.ss"
        return formatter
    }()

    static private let transforms = [kCFStringTransformStripCombiningMarks, kCFStringTransformToLatin, kCFStringTransformToUnicodeName]

    
    /// Convert to a POSIX "Fully portable filenames" (only allow A–Z a–z 0–9 . _ -)
    /// Space will be converted to underscore first.
    var normalizedFilename: String {
        let ref = NSMutableString(string: self) as CFMutableString
        type(of: self).transforms.forEach { CFStringTransform(ref, nil, $0, false) }
        
        let retString = (ref as String).replacingOccurrences(of: " ", with: "-")
        
        let characterSet = NSMutableCharacterSet() //create an empty mutable set
        characterSet.formUnion(with: CharacterSet.alphanumerics)
        characterSet.addCharacters(in: "_-.")

        let unsafeChars = characterSet.inverted
        let strippedString = retString.components(separatedBy: unsafeChars).joined(separator: "")
        
        return strippedString
    }

    /// return a file name with length < 255 - 4(reserve for extension) - 37(reserve for WireDataModel UUID prefix for meta) characters
    ///
    /// - Returns: a string <= 214 characters
    static func filenameForSelfUser() -> NSString {
        let dateString = dateFormatter.string(from: Date())
        let normalizedFilename = ZMUser.selfUser().name!.normalizedFilename

        let start = normalizedFilename.startIndex
        // reserve 5 characters for dash and file extension, 37 char for UUID prefix
        let end = normalizedFilename.index(normalizedFilename.endIndex, offsetBy: -(normalizedFilename.count - 255 + dateString.count + 5 + 37))
        let result = normalizedFilename[start..<end]
        let trimmedFilename = String(result)
        return "\(trimmedFilename ?? "")-\(dateString)" as NSString
    }
}
