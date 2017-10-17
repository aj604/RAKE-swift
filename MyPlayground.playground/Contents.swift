//: Playground - noun: a place where people can play

import Foundation

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

print(splitSentences(text: str))
