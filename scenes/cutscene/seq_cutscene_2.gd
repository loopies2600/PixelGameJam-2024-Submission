extends Cutscene

const PRT_KING := preload("res://assets/sprites/portraits/port_sir_burgking.png")
const PRT_QUEJONTE := preload("res://assets/sprites/portraits/port_sir_quejonte.tres")

func sequence():
	sleep(2)
	
	setNameplate("Sir Quejonte")
	setPortrait(PRT_QUEJONTE)
	chatter("Huh, I don't remember seeing this down here.")
	
	sleep(2)
	
	s
	
	setNameplate("The Great King")
	setPortrait(PRT_KING)
	chatter("Sir Quejonte, it's been more than thirty seconds, where in my name are you?")

	setNameplate("Sir Quejonte")
	setPortrait(PRT_QUEJONTE)
	chatter("A golden underwater city...! I must be at Lantis!")
	
	setNameplate("The Great King")
	setPortrait(PRT_KING)
	chatter("It's ATLANTIS you moron! In fact, I deliberately built my kingdom above theirs to, you know, make use of its residents!")
	
	setNameplate("Sir Quejonte")
	setPortrait(PRT_QUEJONTE)
	chatter("You mean that's why we're always eating fish?")
	
	setNameplate("The Great King")
	setPortrait(PRT_KING)
	chatter("Ah, I see you understand where I'm getting to!")
	chatter("Quejonte, your death shall be postponed, and I will instead assign a new mission to you!")
	chatter("You see, our citizens are starving since I ate all the food left in the kingdom!")
	chatter("Unfortunately, I'm still hungry, so go get me some fish!")
	chatter("Every three minutes I'll be collecting your findings, and if you don't have enough fish by then, well...")
	chatter("I would recommend you to say your prayers, but I am the sole god of this land!")
	
	setNameplate("Sir Quejonte")
	setPortrait(PRT_QUEJONTE)
	chatter("Hmm... I think these crates contain fish, I should really hurry up.")
