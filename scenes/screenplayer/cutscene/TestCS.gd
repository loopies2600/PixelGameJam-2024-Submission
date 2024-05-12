extends Cutscene

func seq2():
	chatter("branch test")
	sleep(0.1)
	
	changeSequence("sequence")
	
func sequence():
	chatter("Yo2")
	sleep(0.1)
	
	changeSequence("seq2")
	
func _marshallPrint():
	print(getLastCommandResult())
	
