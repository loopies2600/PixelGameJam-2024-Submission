extends Cutscene

const PRT_KING := preload("res://assets/sprites/portraits/port_sir_burgking.png")
const PRT_QUEJONTE := preload("res://assets/sprites/portraits/port_sir_quejonte.tres")

func sequence():
	setNameplate("The Great King")
	setPortrait(PRT_KING)
	
	chatter("Sir Quejonte, you have failed me for the last time!")
	chatter("In consequence of your treacherous actions, I hereby sentence you to absolute death!")
	
	setNameplate("Sir Quejonte")
	setPortrait(PRT_QUEJONTE)
	chatter("But my king! I swear the food bag was sitting in my room!")
	
	setPortrait(PRT_KING)
	setNameplate("The Great King")
	chatter("Silence! The bag had my name stylishly written all over. Your actions are unredeemable.")
	setNameplate("Burg. R. King")
	chatter("I, Burg R. King, shall put an end to you.")
	chatter("But, since you were normally one of my most loyal men, you may have one last wish.")
	
	setNameplate("Sir Quejonte")
	setPortrait(PRT_QUEJONTE)
	chatter("Can I go swim?")
	
	setNameplate("Burg. R. King")
	setPortrait(PRT_KING)
	chatter("yeah sure.")
	chatter("you have thirty seconds from now.")
	
	setNameplate("")
	setPortrait(null)
	chatter("And so, Sir Quejonte went ahead and walked deep into the sea.")
	chatter("With his armor still on for some reason, he sinked and sinked until he reached the bottom of the sea.")
	
	setNameplate("Sir Quejonte")
	setPortrait(PRT_QUEJONTE)
	chatter("Right, I can breathe underwater.")
