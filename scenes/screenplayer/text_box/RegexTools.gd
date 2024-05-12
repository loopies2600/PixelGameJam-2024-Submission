extends Node

const PATTERN_BBCODE := "\\[.+?\\]"
const PATTERN_COMMAND := "@(.*?)@"

const WAIT_TIME_TEMPLATE := {
	"char_position" : 0,
	"wait_frames" : 0
}

var objBind = get_parent()

func stripBBcode(source : String) -> String:
	var regex := RegEx.new()
	regex.compile(PATTERN_BBCODE)
	return regex.sub(source, "", true)
	
func stripCommands(source : String) -> String:
	var regex := RegEx.new()
	regex.compile(PATTERN_COMMAND)
	return regex.sub(source, "", true)
	
func parseCommands(source : String):
	var regex := RegEx.new()
	regex.compile(PATTERN_COMMAND)
	
	var matchCnt := regex.search_all(source).size()
	var reMatch := regex.search(source)
	
	if reMatch == null: return
	
	var stringMatch : String = reMatch.strings[1]
	
	var strSplit := stringMatch.split("=", false)
	
	match strSplit[0]:
		"wait":
			var waitTime := int(strSplit[1])
			var newDict := WAIT_TIME_TEMPLATE.duplicate()
			
			newDict.char_position = reMatch.get_start()
			newDict.wait_frames = int(strSplit[1])
			
			get_parent().waitTable.push_back(newDict)
		"basedelay":
			get_parent().baseCharacterDelay = strSplit[1]
		"skip":
			get_parent().autocompleteOn = reMatch.get_start()
		_:
			objBind.set(strSplit[0], str2var(strSplit[1]))
		
	if matchCnt != 1:
		var recursive := regex.sub(source, "", false)
		parseCommands(recursive)
		
	
