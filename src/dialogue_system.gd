extends Node
class_name DialogueSystem

const dialogues_path: String = "res://dialogues"
const comment_char = '$'
const question_char = '&'
const player_line_char = '-'
const character_line_char = '~'


# @TODO remove this
"""
_start_dialogue
if started:
	get_questions() # this will return Array of questions

# somewhere in the process of when pressing the button
asked_question(index or text)
get_next_line() # this will print somewhere in the format [is_player:bool, text]
"""

var parsed_loaded_dialogue: ParsedDialogue

func _init():
	if(DirAccess.dir_exists_absolute(dialogues_path) == false):
		push_warning("Creating a new missing directory " + dialogues_path)
		DirAccess.make_dir_absolute(dialogues_path)


func _load_dialogue(dialogue_name: String):
	var file = FileAccess.open("res://dialogues/" + dialogue_name + ".txt", FileAccess.READ)
	if(file == null):
		print("Cannot find a dialogue with the name " + dialogue_name)
	return file


func _start_dialogue(dialogue_name: String) -> bool:
	var file = _load_dialogue(dialogue_name)
	if file != null:
		_parse(file)
		file.close()
		return true
	else:
		file.close()
		return false


func _parse(file: FileAccess):
	parsed_loaded_dialogue = ParsedDialogue.new()
	
	var alias = ""
	var question = ""
		
	while not file.eof_reached():
		var line: String = file.get_line()
		if line.begins_with("$"):
			continue
		
		var output = line.split(" ", false, 1)
		if output.size() == 0:
			continue
		
		if output[0].begins_with(question_char + question_char):
			if output[0].length() > 2: # has alias
				alias = output[0].substr(2)
			else:
				alias = ""
			if output.size() > 1:
				question = output[1]
			else:
				question = ""
		elif output[0].begins_with(question_char):
			if output[0].length() > 1: # has alias
				alias = output[0].substr(1)
			question = output[1]
			parsed_loaded_dialogue.create_new_dialogue(question, alias)
		elif output[0].begins_with(player_line_char) or output[0].begins_with(character_line_char):
			parsed_loaded_dialogue.add_line_to(question, alias, [output[1], output[0] == player_line_char])
		
