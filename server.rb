require 'HTTParty'
require 'nokogiri'


states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

# states = ["Alabama"]

# *********Beginning of Sanitation**********

# Sanitize ingredients that we want to rephrase or remove.

ingredients_to_omit = [ "Christmas Trees", "Wreathes"]
ingredients_to_rename = [
	["Oysters, Eastern", "Oyster"], 
	["Turkey - Standard Bronze", "Turkey"],
	["Turkey - Midget White", "Turkey"],
	["Turkey - Bourbon Red", "Turkey"]
	["Pollock (Alaskan)", "Cod"]
]

# *********End of Sanitation**********

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
			if !ingredients_to_omit.include? ingredient.text
				# if ingredient is not in our omission list 
				ingredients << ingredient.text
			end
		end 
		# rename ingredients we flagged to be renamed
		for ingredient in ingredients_to_rename
			# if ingredients includes an ingredient to rename
			if ingredients.include? ingredient[0]
				# delete that ingredient and replace it 
				ingredients.delete(ingredient[0])
				ingredients << ingredient[1]
			end
		end
		# remove duplicates
		ingredients.uniq!
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

# seed ingredients table
# Output is designed to be copied from the terminal and pasted into the seeds.rb
puts "#{master_ingredients.uniq.sort}.each{ |ing| Ingredient.create(name: ing)}"


# map seasons to weeks of the year so that we can populate state_ingredients table with in_season_week field
def get_weeks_from_period(time_period)
	# time_period (string), that maps to a early or late period of a month
	# returns an array of integers that converts the time_period to series
	# of week numbers in a 52-week year.

	# data source:
	# http://www.simplesteps.org/eat-local/state/

	case time_period
	when "Early January"
		return [1, 2]
	when "Late January"
		return [3, 4]
	when "Early February"
		return [5, 6]
	when "Late February"
		return [7, 8]
	when "Early March"
		return [9, 10]
	when "Late March"
		return [11, 12]
	when "Early April"
		return [13, 14]
	when "Late April"
		return [15, 16]
	when "Early May"
		return [17, 18]
	when "Late May"
		return [19, 20]
	when "Early June"
		return [21, 22]
	when "Late June"
		return [23, 24]
	when "Early July"
		return [25, 26]
	when "Late July"
		return [27, 28]
	when "Early August"
		return [29, 30]
	when "Late August"
		return [31, 32]
	when "Early September"
		return [33, 34]
	when "Late September"
		return [35, 36]
	when "Early October"
		return [37, 38]
	when "Late October"
		return [39, 40]
	when "Early November"
		return [41, 42]
	when "Late November"
		return [43, 44]
	when "Early December"
		return [45, 46]
	when "Late December"
		return [47, 48]
	end
end

# for each ingredient in a season 
# add a record for every week in that season
# with corresponding IDs for state and ingredient 

# for state in data
# 	state_name = state[:state_name]
# 	for season in state[:season_data]		# <- returns an array
# 		get_weeks_from_period(season[:season_name]).each do |week_num| # <- returns an array of week numbers
# 			for ingredient in season[:ingredients]
# 				puts "Create: "
# 				puts "#{state_name}, #{season[:season_name]}, #{week_num}, #{ingredient}"
# 				puts "*******"
# 			end
# 		end
# 	end 
# end



