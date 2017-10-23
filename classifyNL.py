import nltk
import json
from nltk.corpus import wordnet
from rake_nltk import Rake

def classify(word, categories):

    #Clean up the download functions
    #Should happen at a higher level
	#try:
	#	nltk.data.find('tokenizers/punkt')
	#	nltk.data.find('tokenizers/wordnet')
	#	nltk.data.find('tokenizers/averaged_perceptron_tagger')
	#except LookupError:
	#	nltk.download('punkt')
	#	nltk.download('wordnet')
	#	nltk.download('averaged_perceptron_tagger')

	category_list = []
	mapping = {}
    #Iterate keys and build synonym dictionary
    #track which category each synonym is for
	for k in categories.keys():
		syn_k = wordnet.synsets(k, pos=wordnet.NOUN)
		for syn in syn_k:
			category_list.append(syn)
			mapping[syn.name()] = k

	res = categories
	#create new dict to store count of appeared synonyms
	synCount = {}

	#initialize dict to 0
	for key in categories.keys():
		synCount[key] = 0

	#Calculate synonyms for word
	wordsets = wordnet.synsets(word, pos=wordnet.NOUN)
	#print(synCount)
	if len(wordsets):
		for synset in wordsets:
			#print("currently working with synset", synset.examples())
			for c in category_list:
				name = mapping[c.name()]
				similarity = synset.path_similarity(c, simulate_root=False)
				if similarity != None:
					synCount[name] += 1.0
					res[name] += (res.get(name, 0) + similarity) / synCount[name]
			for key in synCount.keys():
				#print( res.get(key, 0), key, synCount[key])
			#	res[key] = res.get(key, 0) / synCount[key]
				synCount[key] = 0

	return res

def normalizeScore(categories):
	print(type(categories))
	total = 0
	for key, value in categories.items():
		total += value
	for keyword, value in categories.items():
		categories[keyword] = value / total
	return categories

categories = {
	'sports' : 0.0,
	'food' : 0.0,
	'entertainment' : 0.0,
	'electronics' : 0.0
	}

score = {}
for key in categories.keys():
	score[key] = 0.0
text = "Mcdonalds | Gym | Play | laptop"
r = Rake()
r.extract_keywords_from_text(text)
keywords = r.get_ranked_phrases_with_scores()
for value, keyword in keywords:
	scores = classify(keyword, categories)
	for keyword in scores.keys():
		score[keyword] = scores[keyword]
print("Scores for", text)
score = normalizeScore(score)
print(score)










