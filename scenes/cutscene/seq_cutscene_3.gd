extends Cutscene

const PRT_QUEJONTE := preload("res://assets/sprites/portraits/port_sir_quejonte.tres")
const PRT_POSEID := preload("res://assets/sprites/portraits/port_sir_poseidon.png")
const PRT_KING := preload("res://assets/sprites/portraits/port_sir_burgking.png")

func sequence():
	sleep(2)
	
	setNameplate("Poseidon")
	setPortrait(PRT_POSEID)
	chatter("I see your fast-food king sent you after my people in a mission to satiate his gargantuan hunger.")
	chatter("It's just normal that you're also after me. Since I taste just like fish.")
	
	playSound("res://assets/streams/sounds/ringtone.wav")
	
	sleep(0.3)
	
	playSound("res://assets/streams/sounds/beep.wav")
	
	setPortrait(PRT_KING)
	chatter("We're not here to eat you! We're here to discuss that free-trade agreement we postponed last month. ")

	setNameplate("Poseidon")
	setPortrait(PRT_POSEID)
	chatter("Ah, so this is merely a political strategy.")
	chatter("I don't want your filthy hamburgers down here.")
	
	setPortrait(PRT_KING)
	chatter("We shall see about that.")
	chatter("Sir Quejonte! Kill him! Kill him so I can kill you later!")
