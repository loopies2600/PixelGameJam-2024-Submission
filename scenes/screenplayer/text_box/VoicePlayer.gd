extends AudioStreamPlayer
class_name TextboxVoicePlayer

enum VoiceModes { SEQUENTIAL = 0, PICK_RANDOM, SEQUENTIAL_REVERSE }
var soundMode = VoiceModes.PICK_RANDOM 

var soundTable := []
var pitchRange := Vector2.ONE

var index := 0

func play(from := 0.0):
	if soundTable.size() == 0: return
	
	randomize()
	
	pitch_scale = rand_range(pitchRange.x, pitchRange.y)
	
	match soundMode:
		VoiceModes.SEQUENTIAL:
			stream = soundTable[index]
			index = wrapi(index + 1, 0, soundTable.size())
		VoiceModes.SEQUENTIAL_REVERSE:
			stream = soundTable[index]
			index = wrapi(index - 1, 0, soundTable.size())
		VoiceModes.PICK_RANDOM:
			stream = soundTable.pick_random()
	
	.play(from)
