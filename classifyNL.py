import nltk
import json
from nltk.corpus import wordnet
from rake_nltk import Rake

def classify(word, categories):

    #Clean up the download functions
    #Should happen at a higher level
    try:
        nltk.data.find('tokenizers/punkt')
        nltk.data.find('tokenizers/wordnet')
        nltk.data.find('tokenizers/averaged_perceptron_tagger')
    except LookupError:
        nltk.download('punkt')
        nltk.download('wordnet')
        nltk.download('averaged_perceptron_tagger')

    wordnet.path_similarity()
    category_list = []
    mapping = {}


    #Iterate keys and build synonym dictionary
    for k in categories.keys():
        syn_k = wordnet.synsets(k, pos=wordnet.NOUN)
        for syn in syn_k:
            category_list.append(syn)
            mapping[syn.name()] = k


    res = categories
    wordsets = wordnet.synsets(word, pos=wordnet.NOUN)
    if len(wordsets):
        for c in category_list:
            name = mapping[c.name()]
            res[name] = res.get(name, 0) + wordsets.path_similarity(c)

    return res
