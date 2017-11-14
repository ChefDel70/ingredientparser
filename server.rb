require 'HTTParty'
require 'nokogiri'


states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]


base_url = "http://www.simplesteps.org/eat-local/state/"
data = []
counter = 1 
for state in states
	# puts "*** #{counter}.  #{state} ***"
	state_hash = {}
	state_hash[:state_name] = state
	url = "http://www.simplesteps.org/eat-local/state/#{state.downcase.tr_s(" ", "-")}"
	response = HTTParty.get url
	dom = Nokogiri::HTML(response.body)
	seasons = dom.css('.state-produce').css('.season')
	season_data = []
	for season in seasons
		season_hash = {}
		season_hash[:season_name] = season.css('h3').text
		# puts "--- #{season_hash[:season_name]} ---"
		ingredients = []
		for ingredient in season.css('a')
			ingredients << ingredient.text
		end 
		season_hash[:ingredients] = ingredients
		season_data << season_hash
	end 
	state_hash[:season_data] = season_data
	data << state_hash
	counter += 1
end 


#Compile all ingredients from all states, and all seasons into a single master ingredients array.
master_ingredients = []
for state in data    		# for every state
	for season_hash in state[:season_data]      # for every season
		# state[:season_data] returns an array of hashes
		# loop through every hash in state[:season_data]
		for ingredient in season_hash[:ingredients]		# <- returns an array of ingredients
			master_ingredients << ingredient
		end
	end
end
# p master_ingredients.uniq.sort
# puts "total ingredients with duplicates: #{master_ingredients.length}"
# puts "total unique ingredients: #{master_ingredients.uniq.length}"



# ************ Notes ************
# Debugging code to inspect array for multiples of an ingredient
# Echos the frequency of every unique ingredient 
# **best used when states array has one element
# cross-reference this with the page of a particular state

# for uniq_ingredient in master_ingredients.uniq
# 	counter = master_ingredients.count(uniq_ingredient)
# 	puts "#{counter}   #{uniq_ingredient}"
# end
# ************ End of Notes ************

# Choose the unique subset of master ingredients array when creating seed data for ingredients table

# Seeding unique ingredients to the Ingredients table
# Ingredient.create(name: [ingredient_name STRING])
# ingredients_seed = []
# for ingredient in master_ingredients.uniq
# 	create = "Ingredient.create(name: #{ingredient})"
# 	ingredients_seed << create
# end
# puts ingredients_seed

# Sanitize ingredients that we want to rephrase or remove.

ingredients_to_remove = [ "Christmas Trees", "Oysters, Eastern", "Turkey - Bourbon Red", "Turkey - Midget White", "Turkey - Standard Bronze", "Wreathes"]
ingredients_to_add = ["Oyster", "Oysters", "Turkey"]
ingredients_to_remove.each do |i|
 master_ingredients.delete(i)
end
master_ingredients += ingredients_to_add
puts "#{master_ingredients.uniq.sort}.map{ |ing| 'Ingredient.create(ing)'}"




