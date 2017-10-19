//: Playground - noun: a place where people can play

import Foundation


let tagger = NSLinguisticTagger(tagSchemes: [.lexicalClass, .tokenType, .lemma], options: 0)
let options: NSLinguisticTagger.Options = [ .omitPunctuation, .omitWhitespace]
let text = "For a whole day my companion had rambled about the room with his chin upon his chest and his brows knitted, charging and recharging his pipe with the strongest black tobacco, and absolutely deaf to any of my questions or remarks.  "
tagger.string = text
let range = NSRange(location: 0, length: text.utf16.count)
tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options, using: { tag, tokenRange, stop in
    let token = (text as NSString).substring(with: tokenRange)
    print("\(token) = \(tag!.rawValue)")
})






















/*
extension String {
    func substring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: to - from)
        return String(self[start ..< end])
    }
    
    func substring(range: NSRange) -> String {
        return substring(from: range.lowerBound, to: range.upperBound)
    }
}

func splitSentences(text: String) -> [String] {
    var sentences = [String]()
    text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences, { substring, substringRange, enclosingRange, stop in
        sentences.append(substring!)
    })
    return sentences
}

var str = "Hello, playground. How are you doing today?"

var rePattern = "(\\w+)"

let regEx = try! NSRegularExpression(pattern: rePattern, options: [])
let matches = regEx.matches(in: str, options: [], range: NSRange(location: 0, length: str.characters.count))

for match in matches {
    let wordRange: NSRange = match.range(at:0)
    print(str.substring(range: wordRange))
    //print(str.substring(with: range))
}
*/

