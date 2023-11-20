extends Node
class_name DialogueSystem

const dialogues_path: String = "res://dialogues"
const comment_char = '$'
const question_char = '&'
const player_line_char = '-'
const character_line_char = '~'

var parsed_loaded_dialogue: ParsedDialogue

# runtime:
var asked_question_index: int
var dialogue_block_index: int = 0

func start_dialogue(dialogue_name: String) -> bool:
	var file = _load_dialogue(dialogue_name)
	if file != null:
		var success = _parse(file)
		file.close()
		if success:
			success = parsed_loaded_dialogue.verify()
		else:
			push_error("Dialogue '%s' could not be parsed" % dialogue_name)
		return success
	else:
		file.close()
		return false


func get_questions() -> Array:
	return parsed_loaded_dialogue._questions_array


func ask_question(index: int):
	asked_question_index = index
	dialogue_block_index = 0


func get_next_line() -> Array:
	if dialogue_block_index >= parsed_loaded_dialogue._lines_array[asked_question_index].size():
		return []
	dialogue_block_index += 1
	return parsed_loaded_dialogue._lines_array[asked_question_index][dialogue_block_index - 1]


func _init():
	if(DirAccess.dir_exists_absolute(dialogues_path) == false):
		push_warning("Creating a new missing directory " + dialogues_path)
		DirAccess.make_dir_absolute(dialogues_path)


func _load_dialogue(dialogue_name: String):
	var file = FileAccess.open("res://dialogues/" + dialogue_name + ".txt", FileAccess.READ)
	if(file == null):
		print("Cannot find a dialogue with the name " + dialogue_name)
	return file


func _parse(file: FileAccess):
	parsed_loaded_dialogue = ParsedDialogue.new()
	
	var alias = ""
	var question = ""
		
	while not file.eof_reached():
		var line: String = file.get_line()
		if line.begins_with("$"):
			continue
		
		var output = line.strip_edges(true, false).split(" ", false, 1)
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
		elif output[0] == player_line_char or output[0] == character_line_char:
			var success = parsed_loaded_dialogue.add_line_to(question, alias, [output[1], output[0] == player_line_char])
			if !success:
				return false
		else:
			push_error("Identifier " + output[0] + " is not defined")
			return false
	return true
