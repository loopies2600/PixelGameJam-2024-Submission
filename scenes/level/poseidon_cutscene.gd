extends Cutscene

func sequence():
	chatter("EMPTY")
	
	callSeq(get_tree().current_scene.level, "spawn_poseidon")
