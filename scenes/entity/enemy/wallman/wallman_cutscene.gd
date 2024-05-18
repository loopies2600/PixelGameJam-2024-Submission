extends Cutscene

func sequence():
	setPortrait(null)
	setNameplate("Wall Man")
	
	if get_parent().health < get_parent().max_health:
		chatter("you will not be welcome in the lord's land.")
	else:
		chatter("im the wall man")
	
	sleep(0.1)
