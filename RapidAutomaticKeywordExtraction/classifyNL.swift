//
//  classifyNL.swift
//  RapidAutomaticKeywordExtraction
//
//  Created by Avery Jones on 2017-10-16.
//  Copyright © 2017 AJ productions. All rights reserved.
//

import Foundation


// Classifier Func.
//  takes a string to score, and a dictionary of categories, and their weightings
//  return a dictionary of categories and the score for each
//
func classifier(text: String, categories : Dictionary<String, Double>) -> Dictionary<String, Double> {
    
    //Rake text for keywords
    let stopWords = importStopWords(stopWordFile: "csvStopList.csv")
    let r = Rake(inputStopWords: stopWords)
    let rakeOut = r.run(text: text)
    var keywords = [String]()
    for keyword in rakeOut {
        keywords.append(keyword.key)
    }
    
    //Tag keywords that are noun and discard the rest
    let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .lexicalClass], options: 0)
    let options : NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation]
    tagger.string = String(describing: keywords)
    var range = NSRange(location: 0, length: (tagger.string?.utf16.count)!)
    tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options, using:
        {tag, tokenRange, stop in
        keywords = []
        if tag == NSLinguisticTag.noun {
            keywords.append((tagger.string! as NSString).substring(with: tokenRange))
        }
    })
    
    // Lemmatize keywords
    tagger.string = String(describing: keywords)
    range.length = (tagger.string?.utf16.count)!
    tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options, using:
        { tag, tokenRange, stop in
        keywords = []
            keywords.append((tagger.string! as NSString).substring(with: tokenRange))
        })
    
    
    // Calculate word distance from lemma to categories
    // Definitely incomplete, need to rethink how keywords are scored
    // and how the scores update. Removing n^2 is ideal
    var categoryScore = Dictionary<String, Double>()
    for word in keywords {
        for (key, _) in categories {
            categoryScore[key] = calculateWordDistance(from: key, to: word)
        }
    }
    return categoryScore
}



func calculateWordDistance(from: String, to: String) -> Double {
    return 4.0
}

//Classifier Func
//
// STEPS:
// 1. Determine synset for categories ******************** HOW DO I DO THIS???????????????????
// 2. Rake text for keywords // potentially for score
// 3. Parse keywords for nouns, Discard rest
// 4. For each category synset determine scores of all synonyms and append final to result dictionary
/*func classifier(text: String, categories : Dictionary<String, Double>) -> Dictionary<String, Double> {
    var categoryList = [String]()
    var mapping = Dictionary<String, String>()
    for k in categories.keys {
        
    }
}
*/
