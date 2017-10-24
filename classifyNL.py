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
		#category_list.append(syn_k[0])
		#mapping[syn_k[0].name()] = k
		for syn in syn_k:
			ii = 0
			while ii < 3:
				category_list.append(syn)
				mapping[syn.name()] = k
				ii += 1

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
				if similarity != None and similarity > 0.15:
					synCount[name] += 1.0
					res[name] += similarity / synCount[name]
			for key in synCount.keys():
				#print( res.get(key, 0), key, synCount[key])
			#	res[key] = res.get(key, 0) / synCount[key]
				synCount[key] = 0

	return res

def normalizeScore(categories):
	total = 0
	for key, value in categories.items():
		total += value
	if total == 0: 
		return categories
	for keyword, value in categories.items():
		categories[keyword] = value / total
	return categories

categories = {
	'food' : 0.0,
	'entertainment' : 0.0,
	'society' : 0.0,
	'travel' : 0.0,
	'dining' : 0.0
	}

score = {}
for key in categories.keys():
	score[key] = 0.0
text = """
The UK is among the world’s “best-value destinations” to visit in 2018, according to travel guide publisher Lonely Planet, which has released its annual Best in Travel hotlist.

Chosen by its editors, authors and a network of travel experts around the world, the list highlights the top 10 countries, cities, regions and best-value destinations for travellers to visit in the year ahead.

Pointing to the fact that the pound has weakened against “pretty much all currencies” since the Brexit referendum, the UK has now been ranked seventh on the best-value list, along with Poland and La Paz, Bolivia. The number one spot in this category goes to Tallinn, capital of Estonia – a long-time budget city break favourite.


"""
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










