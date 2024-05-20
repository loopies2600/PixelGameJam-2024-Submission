extends Cutscene

const PRT_QUEJONTE := preload("res://assets/sprites/portraits/port_sir_quejonte.tres")
const PRT_POSEID := preload("res://assets/sprites/portraits/port_sir_poseidon.png")
const PRT_KING := preload("res://assets/sprites/portraits/port_sir_burgking.png")

func sequence():
	sleep(2)
	
	setNameplate("")
	setPortrait(null)
	chatter("And so, The Great King feasted on every single one of the residents of the now lost kingdom of Atlantis. ")
	chatter("Sir Quejonte was surprisingly spared by the o great and humble King of... land, in... some place.")
	chatter("With Poseidon beat-up, there just was no way fish could exist anymore, so they went extinct. A very unfortunate ending for such a short tale.")
	chatter("The End")
