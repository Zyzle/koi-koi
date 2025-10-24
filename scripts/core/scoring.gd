class_name Scoring

enum YAKU_TYPE {
	FIVE_BRIGHT,
	RED_POETRY_BLUE_TANZAKU,
	DRY_FOUR_BRIGHT,
	RAINY_FOUR_BRIGHT,
	DRY_THREE_BRIGHT,
	MOON_VIEWING,
	FLOWER_VIEWING,
	BOAR_DEER_BUTTERFLY,
	RED_POETRY_TANZAKU,
	BLUE_TANZAKU,
	TANE,
	TANZAKU,
	KASU
}

static func calculate_score(captured_cards: Array[Card]) -> Dictionary:
	var score_details = {
		"total_score": 0,
		"yaku_achieved": []
	}
	
	var type_counts = {
		Card.CardType.BRIGHT: 0,
		Card.CardType.RIBBON: 0,
		Card.CardType.ANIMAL: 0,
		Card.CardType.PLAIN: 0
	}
	
	var bright_cards = []
	var ribbon_cards = []
	var animal_cards = []

	for card in captured_cards:
		type_counts[card.type] += 1
		match card.type:
			Card.CardType.BRIGHT:
				bright_cards.append(card)
			Card.CardType.RIBBON:
				ribbon_cards.append(card)
			Card.CardType.ANIMAL:
				animal_cards.append(card)

	# Special cards presence
	var has_sake_cup = captured_cards.find_custom(func(card: Card):
		return card.month == 9 and card.number == 4
	) != -1

	var has_boar = animal_cards.find_custom(func(card: Card):
		return card.month == 7 and card.number == 4
	) != -1

	var has_deer = animal_cards.find_custom(func(card: Card):
		return card.month == 10 and card.number == 4
	) != -1

	var has_butterfly = animal_cards.find_custom(func(card: Card):
		return card.month == 6 and card.number == 4
	) != -1

	var has_cherry_blossom = bright_cards.find_custom(func(card: Card):
		return card.month == 3 and card.number == 4
	) != -1

	var has_moon = bright_cards.find_custom(func(card: Card):
		return card.month == 8 and card.number == 4
	) != -1

	var has_rain_man = bright_cards.find_custom(func(card: Card):
		return card.month == 11 and card.number == 4
	) != -1
	
	
	# Kasu
	if type_counts[Card.CardType.PLAIN] >= 10 or (has_sake_cup and type_counts[Card.CardType.PLAIN] >= 9):
		score_details.total_score += 1

		if has_sake_cup:
			score_details.total_score += type_counts[Card.CardType.PLAIN] - 9
		else:
			score_details.total_score += max(type_counts[Card.CardType.PLAIN] - 10, 0)

		score_details.yaku_achieved.append(YAKU_TYPE.KASU)

	# Tanzaku
	if type_counts[Card.CardType.RIBBON] >= 5:
		score_details.total_score += type_counts[Card.CardType.RIBBON] - 4
		score_details.yaku_achieved.append(YAKU_TYPE.TANZAKU)

	# Tane
	if type_counts[Card.CardType.ANIMAL] >= 5:
		score_details.total_score += type_counts[Card.CardType.ANIMAL] - 4
		score_details.yaku_achieved.append(YAKU_TYPE.TANE)

	# Aotan
	if ribbon_cards.size() >= 3:
		var num_blue = ribbon_cards.filter(func(card: Card):
			return card.month in [6, 9, 10]
		).size()

		if num_blue == 3:
			score_details.total_score += 5
			score_details.yaku_achieved.append(YAKU_TYPE.BLUE_TANZAKU)

	# Akatan
	if ribbon_cards.size() >= 3:
		var num_red = ribbon_cards.filter(func(card: Card):
			return card.month in [1, 2, 3]
		).size()

		if num_red == 3:
			score_details.total_score += 5
			score_details.yaku_achieved.append(YAKU_TYPE.RED_POETRY_TANZAKU)

	# Boar, Deer, Butterfly
	if has_boar and has_deer and has_butterfly:
		score_details.total_score += 5
		score_details.yaku_achieved.append(YAKU_TYPE.BOAR_DEER_BUTTERFLY)

	# Flower Viewing
	if has_cherry_blossom and has_sake_cup:
		score_details.total_score += 5
		score_details.yaku_achieved.append(YAKU_TYPE.FLOWER_VIEWING)

	# Moon Viewing
	if has_moon and has_sake_cup:
		score_details.total_score += 5
		score_details.yaku_achieved.append(YAKU_TYPE.MOON_VIEWING)

	# dry 3 bright
	if bright_cards.size() == 3 and not has_rain_man:
		score_details.total_score += 5
		score_details.yaku_achieved.append(YAKU_TYPE.DRY_THREE_BRIGHT)

	# dry/rainy 4 bright
	if bright_cards.size() == 4:
		if has_rain_man:
			score_details.total_score += 7
			score_details.yaku_achieved.append(YAKU_TYPE.RAINY_FOUR_BRIGHT)
		else:
			score_details.total_score += 8
			score_details.yaku_achieved.append(YAKU_TYPE.DRY_FOUR_BRIGHT)

	# 5 bright
	if bright_cards.size() == 5:
		score_details.total_score += 10
		score_details.yaku_achieved.append(YAKU_TYPE.FIVE_BRIGHT)
	
	return score_details