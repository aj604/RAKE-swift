// Swift implementation of Rapid Automatic Keyword Extraction
// As described in
// Rose, Stuart, Dave Engel, Nick Cramer, and Wendy Cowley.
// "Automatic keyword extraction from individual documents."
// Text Mining: Applications and Theory (2010): 1-20.
//
//
// This keyword extraction algorithm works by identifying parts of speech which typically
// will separate keywords, hereby refered to as stopwords.
// you then remove all instances of stopwords from the text, and tokenize based on what comes between them.
// This provides the list of keywords that appear in the text.
// A

import Foundation


//MARK: EXTENSIONS
extension String {
    func substring(range: NSRange) -> String {
        let botIndex = self.index(self.startIndex, offsetBy: range.location)
        let newRange = botIndex..<self.index(botIndex, offsetBy: range.length)
        return String(self[newRange])
   }
}


func isNumber(s: String) -> Bool {
    if let _ = Float(s) {
        return true
    } else if let _ = Int(s){
        return true
    }
    return false
}

//Import a stopWord csv
func importStopWords(stopWordFile: String) -> [String] {
    var stopWords = [String]()
    let text2 = try? String(contentsOfFile: stopWordFile)
    stopWords = (text2?.components(separatedBy: ", "))!
    return stopWords
}

//Maybe rewrite using NSLinguisticTagger
func separateWords(text : String, minWordSize : Int) -> [String] {
    let rePattern = "[^a-zA-Z0-9_\\+\\-/]+"
    var words = [String]()
    let regEx = try! NSRegularExpression(pattern: rePattern, options: [])
    let newSentence = regEx.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count), withTemplate: " | ")
    let newWords = newSentence.components(separatedBy:  " | ")
    for word in newWords {
        if word.characters.count > minWordSize && word != " " && isNumber(s: word) == false {
            words.append(word)
        }
    }
    //print("separateWords turned \(text) into \(words)")
    return words
}

func splitSentences(text: String) -> [String] {
        var sentences = [String]()
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences, { substring, substringRange, enclosingRange, stop in
            sentences.append(substring!)
        })
        return sentences
}

func buildStopWordRegex(stopWords : [String]) -> String {
    var stopWordRegexList = [String]()
    var wordRegex = ""
    for word in stopWords {
        wordRegex = "\\b\(word)(?![\\w-])"
        stopWordRegexList.append(wordRegex)
    }
    return stopWordRegexList.joined(separator: " | ")
}

func generateCandidateKeywords(sentenceList: [String], stopwordRegexPattern : String) -> [String]{
    var phraseList = [String]()
    let regEx = try! NSRegularExpression(pattern: stopwordRegexPattern, options: .caseInsensitive)
    print(sentenceList)
    for sentence in sentenceList {
        let newSentence = regEx.stringByReplacingMatches(in: sentence, options: [], range: NSRange(location: 0, length: sentence.characters.count), withTemplate: " | ")
        print(newSentence)
        let words = newSentence.components(separatedBy:  "|")
        for word in words {
            if word != "" && word != " " {
                print(word)
                phraseList.append(word)
            }
        }
    }
    print(phraseList)
    return phraseList
}


// Calculate word scores for input tokens
// Pre: Tokenized list of keywords
// Post: Value of each word
func calculateWordScores(phraseList:[String]) -> Dictionary<String, Double> {
    var wordFrequency = Dictionary<String, Double>() // Return Dict
    var wordDegree = Dictionary<String, Double>() // Storage for individual word scores
    for phrase in phraseList { // Can either be a single word, or a string of words that represents a keyword
        let wordList = separateWords(text: phrase, minWordSize: 0) // split phrase. Use separateWords to avoid iterating through chars
        let wordListDegree = Double(wordList.count - 1) // Number of Words in keyword
        for word in wordList {
            print("This word in phraseList is \(word)")
            if wordFrequency[word] == nil{
                wordFrequency.updateValue(0.0, forKey: word)
            }
            wordFrequency.updateValue(wordFrequency[word]! + 1, forKey: word)
            if wordDegree[word] == nil {
                wordDegree.updateValue(0.0, forKey: word)
            }
            wordDegree.updateValue(wordDegree[word]! + wordListDegree, forKey: word)
        }
    }
    
    for (key, value) in wordFrequency {
        wordDegree.updateValue(wordDegree[key]! + value, forKey: key)
    }
    
    var wordScore = Dictionary<String, Double>()
    for (key, value) in wordFrequency{
        if wordScore[key] == nil {
            wordScore.updateValue(0.0, forKey: key)
        }
        wordScore.updateValue(wordDegree[key]! / value * 1.0, forKey: key)
        print("updating WordScore for \(key) with value \(wordDegree[key]! / value * 1.0)")
    }
    return wordScore
}

func generateCandidateKeywordScores(phraseList: [String], wordScore: Dictionary<String, Double>) -> Dictionary<String, Double> {
    var keywordCandidates = Dictionary<String, Double>()
    for phrase in phraseList {
        if keywordCandidates[phrase] == nil {
            keywordCandidates.updateValue(0.0, forKey: phrase)
        }
        let wordList = separateWords(text: phrase, minWordSize: 0)
        var candidateScore = 0.0
        for word in wordList {
            candidateScore += wordScore[word]!
        }
        keywordCandidates.updateValue(candidateScore, forKey: phrase)
    }
    return keywordCandidates
}

struct Rake {
    var stopWords = [String]()
    var stopWordsPattern = ""
    init(inputStopWords: [String]){
        stopWords = inputStopWords
        stopWordsPattern = buildStopWordRegex(stopWords: stopWords)
    }
    func run(text: String) -> Dictionary<String, Double> {
        let sentenceList = splitSentences(text: text)
        let phraseList = generateCandidateKeywords(sentenceList: sentenceList, stopwordRegexPattern: stopWordsPattern)
        let wordScores = calculateWordScores(phraseList: phraseList)
        let keywordCandidates = generateCandidateKeywordScores(phraseList: phraseList, wordScore: wordScores)
        return keywordCandidates
    }
}
print("Lets get started with RAKE!")
var text = "For a whole day my companion had rambled about the room with his chin upon his chest and his brows knitted, charging and recharging his pipe with the strongest black tobacco, and absolutely deaf to any of my questions or remarks. "
var stopWords = importStopWords(stopWordFile: "csvStopList.csv")
print("Have stopwords")
var hello = Rake(inputStopWords: stopWords)
print("have Rake")
let scoreDict =  hello.run(text: text)
var maxKey = ""
var max = 0.0
for (key, value) in scoreDict {
    print(key)
    if value != 0.0 {
        //print("key \"\(key)\" has a value of \(value)")
        if value > max {
            max = value
            maxKey = key
        } else if value == max {
            maxKey += ", \(key)"
        }
    }
}
print("The leading interest of this text was \(maxKey), with a value of \(max)")















