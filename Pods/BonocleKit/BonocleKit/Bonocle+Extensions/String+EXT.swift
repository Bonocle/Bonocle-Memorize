//
//  String+EXT.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import Foundation

public extension String {
    func leftPad(with character: Character, length: UInt) -> String {
        let maxLength = Int(length) - count
        guard maxLength > 0 else {
            return self
        }
        return String(repeating: String(character), count: maxLength) + self
    }
}

public extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: CountableRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: CountablePartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

public extension String {
    
    var hexadecimal: Data? {
        var data = Data(capacity: self.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    /// Create `String` representation of `Data` created from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a String object from that. Note, if the string has any spaces, those are removed. Also if the string started with a `<` or ended with a `>`, those are removed, too.
    ///
    /// For example,
    ///
    ///     String(hexadecimal: "<666f6f>")
    ///
    /// is
    ///
    ///     Optional("foo")
    ///
    /// - returns: `String` represented by this hexadecimal string.
    
    init?(hexadecimal string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.hexadecimal else {
            return nil
        }
        
        self.init(data: data, encoding: encoding)
    }
    
    /// Create hexadecimal string representation of `String` object.
    ///
    /// For example,
    ///
    ///     "foo".hexadecimalString()
    ///
    /// is
    ///
    ///     Optional("666f6f")
    ///
    /// - parameter encoding: The `String.Encoding` that indicates how the string should be converted to `Data` before performing the hexadecimal conversion.
    ///
    /// - returns: `String` representation of this String object.
    
    func hexadecimalString(encoding: String.Encoding = .utf8) -> String? {
        return data(using: encoding)?
            .hexadecimal
    }
    
    func getParaghraphs() -> [String] {
        let range = self.startIndex..<self.endIndex
        var paraghraphs: [String] = Array()
        self.enumerateSubstrings(in: range, options: .byParagraphs) { (paragraph, paragraphRange, enclosingRange, stop) -> () in

        //    guard let range = Range(paragraphRange, in: paragraph)
            let paraghraph = self[paragraphRange]
            paraghraphs.append(String(paraghraph))
        }
        
        return paraghraphs
    }
    
    func getLines() -> [String] {
        let range = self.startIndex..<self.endIndex
        var paraghraphs: [String] = Array()
        self.enumerateSubstrings(in: range, options: .byLines) { (paragraph, paragraphRange, enclosingRange, stop) -> () in

        //    guard let range = Range(paragraphRange, in: paragraph)
            let paraghraph = self[paragraphRange]
            paraghraphs.append(String(paraghraph))
        }
        
        return paraghraphs
    }
    
    func getWords() -> [String] {
        let range = self.startIndex..<self.endIndex
        var paraghraphs: [String] = Array()
        self.enumerateSubstrings(in: range, options: .byWords) { (paragraph, paragraphRange, enclosingRange, stop) -> () in

        //    guard let range = Range(paragraphRange, in: paragraph)
            let paraghraph = self[paragraphRange]
            paraghraphs.append(String(paraghraph))
            paraghraphs.append(" ")
        }
        paraghraphs.remove(at: paraghraphs.count-1)
        return paraghraphs
    }
    
    func getSentences() -> [String] {
        let range = self.startIndex..<self.endIndex
        var paraghraphs: [String] = Array()
        self.enumerateSubstrings(in: range, options: .bySentences) { (paragraph, paragraphRange, enclosingRange, stop) -> () in

        //    guard let range = Range(paragraphRange, in: paragraph)
            let paraghraph = self[paragraphRange]
            paraghraphs.append(String(paraghraph))
        }
        
        return paraghraphs
    }
    
}

extension Character{
    func toHex() -> String{
        let data = Data(self.utf8)
        let hexString = data.map{ String(format:"%02x", $0) }.joined()
        return hexString
    }
}
