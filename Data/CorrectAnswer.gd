class_name CorrectAnswer



const Basic_plane := {
					0: {	#Первая глава
						0:	"""
							План короля по обороне замка следующий:
							1) Выкопать [u][url=slot_0]_____[/url][/u](ы) глубиной [u][url=slot_1]________[/url][/u]
							2) Заполнить его(её) [u][url=slot_2]______[/url][/u]
							3) Запустить в неё(него) [u][url=slot_3]______[/url][/u](ы)
							4) Отправить [u][url=slot_4]____[/url][/u] на патрулирование [u][url=slot_5]_____[/url][/u]
							""",
						1: 	"""
							План революционеров по штурму замка следующий:
							1) Выкопать [u][url=slot_0]_____[/url][/u](ы) под стенами замка на глубине [u][url=slot_1]________[/url][/u]
							2) Продолжить его до [u][url=slot_2]______[/url][/u]
							3) Дождаться [u][url=slot_3]______[/url][/u]
							4) Убить [u][url=slot_4]____[/url][/u]
							"""
						},
					1: {	#Вторая глава
						0: 	"""
							""",
						1: 	"""
							"""
						}
					}
					
					


const CORRECT_ANSWERS: = {
							0:{
								0: [DITCH, DEPTH, WATER, CROCODILE, WARRIORS, CASTLE_WALL],
								1: [TUNNEL, DEPTH, THRONE_ROOM, NIGHT, KING]
								},
							1:{
								0: [],
								1: []
								},
							}


# Chapter 1 stage 1
const DITCH = "ров"
const DEPTH = "3м"
const WATER = "вода"
const CROCODILE = "крокодил"
const WARRIORS = "всех воинов"
const CASTLE_WALL = "стен замка"


# Chapter 1 stage 2
const TUNNEL = "подкоп"
const THRONE_ROOM = "тронный зал"
const NIGHT = "ночь"
const KING = "король"
