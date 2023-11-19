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
		return true
	else:
		return false


func _parse(file: FileAccess):
	var parse_line = PARSE_LINE.None
	var remember_question_block: bool = false
	var alias: String = ""
	var question_text: String = ""
	
	while(true):
		var line: String = file.get_line()
		if line.is_empty():
			break
		
		var seeking_line_purpouse = true
		var recording_alias = false
		
		var temp_text = ""
		var is_from_player = false
		
		for c in line:
			if c == '\n' or c == '\r':
				remember_question_block = parse_line == PARSE_LINE.QuestionBlock
				if parse_line == PARSE_LINE.QuestionBlock or parse_line == PARSE_LINE.QuestionOutline:
					parsed_loaded_dialogue.create_new_dialogue(question_text, alias)
					if parse_line == PARSE_LINE.QuestionOutline:
						alias = ""
						question_text = ""
				elif parse_line == PARSE_LINE.Line:
					var output = [temp_text, is_from_player]
					parsed_loaded_dialogue.add_line_to(question_text, alias, output)
			
			if seeking_line_purpouse:
				if c == comment_char:
					continue
				
				elif c == question_char:
					if parse_line == PARSE_LINE.QuestionBlock:
						push_error("Detected 3 or more '&' characters. Ignoring line: " + line)
						break
					if parse_line == PARSE_LINE.QuestionOutline:
						parse_line = PARSE_LINE.QuestionBlock
						continue
					parse_line = PARSE_LINE.QuestionOutline
					continue
				elif c == player_line_char or c == character_line_char:
					is_from_player = (c == player_line_char)
					parse_line = PARSE_LINE.Line
					continue
				else:
					recording_alias = (c != ' ')
					seeking_line_purpouse = false
			
			if recording_alias:
				if c == ' ':
					recording_alias = false
					continue
				alias += c
			else:
				recording_alias = false
				if parse_line == PARSE_LINE.QuestionOutline or parse_line == PARSE_LINE.QuestionBlock:
					if question_text.is_empty():
						if c == ' ' or c == '\t':
							continue
					question_text += c
				elif parse_line == PARSE_LINE.Line:
					if temp_text.is_empty():
						if c == ' ' or c == '\t':
							continue
					temp_text += c

enum PARSE_LINE
{
	None,
	QuestionOutline,
	QuestionBlock,
	Line
}
