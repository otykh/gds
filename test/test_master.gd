@tool

extends Node

@export var test_initialize: bool = false : set = start_test_init
@export var test_load_func: bool = false : set = start_load_test
@export var test_dialogue_func: bool = false: set = start_dialogue_test
@export var test_bad_files_func: bool = false: set = start_bad_files_test

"""
NOTE: DO NOT FORGET TO SET FILTERS IN THE EXPORT FOLDER
IT SHOULD HAVE THE DIALOGUES FOLDER NOTES AS 'dialogues/*'
OTHERWISE THE FILES WILL NOT BE IMPORTED
"""

const test_dialogue_file: String = """$ This is a start of a file
$     This is comment

& Long line
& 1144
&1 385
&word 054644

$ This is the end of noting questions

&& Long line
- 1
~ 2 2
- 3 33 3

&& 1144
- 1
~ 2 2
~ 2 2 2
- word

&&1 bogus
~ w
- o
- r
~ ks

&&word
- A
~ B
-    C
- D 	D"""

const test_dialogue_file_questions = ["Long line", "1144", "385", "054644"]
const test_dialogue_file_lines = [
	[["1", true], ["2 2", false], ["3 33 3", true]],
	[["1", true], ["2 2", false], ["2 2 2", false], ["word", true]],
	[["w", false], ["o", true], ["r", true], ["ks", false]],
	[["A", true], ["B", false], ["C", true], ["D 	D", true]]
]


const bad_file: String = """$ bad file with mistake
&alias2 Another question?
alias Asked question?"""

const bad_file_two: String = """$ bad file with missing identifier
&& Word
- text
~ in
- undefined thing
"""

const bad_file_three: String = """$ bad file with no dialogue test
& Where is my text?
"""

const space_test: String = """$ bad file with missing space
& test

&& test
- 1
-2
- 3
- 4"""

const double_definition: String = """$ bad file with double & question definition
& test

&& test
- 1
- 2
- 3

& test

&& test
- 3
- 2
- 1
"""

const double_definition_two: String = """$ second bad file with double & question definition
& test
& test

&& test
- 1
- 2
- 3

&& test
- 3
- 2
- 1
"""

const spacing_test: String = """$ testing spacing in dialogue
& test

&& test
- 1
- 2
~ 3

~ 4
- 5
~ 6
"""

# This is not neceserally an error, just something that system needs to report as warning when validating
const only_player_talk: String = """$ file where the dialogue only the player talks
& test

&& test
- 1
- 2
- 3
"""

func write_text_to_test_file(text: String):
	var file = FileAccess.open("res://dialogues/test_dialogue.txt", FileAccess.WRITE_READ)
	file.store_string(text)
	file.close()


func test_init() -> bool:
	var dialogue_system: DialogueSystem = DialogueSystem.new()
	
	var output: bool = true
	
	if DirAccess.dir_exists_absolute("res://dialogues") == false:
		printerr("The dialogue directory does not exist or was not created")
		output = false
	
	var file = FileAccess.open("res://dialogues/test_dialogue.txt", FileAccess.READ)
	if file == null:
		push_warning("test_dialogue.txt does not exist, writing a new one...")
		write_text_to_test_file(test_dialogue_file)
	
	dialogue_system.queue_free()
	return output


func start_test_init(value: bool):
	test_initialize = test_init()


func test_load() -> bool:
	var dialogue_system: DialogueSystem = DialogueSystem.new()
	var output: bool = true
	
	if dialogue_system.start_dialogue("test_dialogue") == false:
		push_error("Cannot start test dialogue")
		output = false
	
	dialogue_system.queue_free()
	return output


func start_load_test(value: bool):
	test_load_func = test_load()


func test_dialogues() -> bool:
	var dialogue_system: DialogueSystem = DialogueSystem.new()
	var output: bool = true
	
	write_text_to_test_file(test_dialogue_file)
	dialogue_system.start_dialogue("test_dialogue")
	
	var questions = dialogue_system.get_questions()
	if test_dialogue_file_questions.size() != questions.size():
		push_error("Questions size do not match!")
		output = false
	else:
		for i in range(0, questions.size()):
			if questions[i] != test_dialogue_file_questions[i]:
				push_error("Questions do not match!")
				output = false
	
	for i in range(0, test_dialogue_file_lines.size()):
		dialogue_system.ask_question(i)
		for j in range(0, test_dialogue_file_lines[i].size()):
			var line_output = dialogue_system.get_next_line()
			if line_output == []:
				push_error("Returned line is empty, must be %s, %s" % test_dialogue_file_lines[i][j])
				output = false
				break
			if test_dialogue_file_lines[i][j][0] != line_output[0]:
				push_error("Dialogue lines do not match!")
				push_error("Line #%s must be: %s, is: %s" % [i, test_dialogue_file_lines[i][j][0], line_output[0]])
				output = false
			elif test_dialogue_file_lines[i][j][1] != line_output[1]:
				push_error("Dialogue lines do not match!")
				push_error("Line #%s must be: %s, is: %s" % [i, test_dialogue_file_lines[i][j][1], line_output[1]])
				output = false
	
	dialogue_system.queue_free()
	return output


func start_dialogue_test(value: bool):
	test_dialogue_func = test_dialogues()


func test_bad_files():
	var dialogue_system: DialogueSystem = DialogueSystem.new()
	var output: bool = true
	
	var file_names = ["bad_file", "bad_file_two", "bad_file_three", "space_test", "double_definition", "double_definition_two"]
	var wrong_output = []
	
	for fn in file_names:
		write_text_to_test_file(get(fn))
		var success = dialogue_system.start_dialogue("test_dialogue")
		if success == true:
			wrong_output.append("Dialogue %s with an error was wrongfully parsed" % fn)
			output = false
	
	print("Out of %s, %s passed" % [file_names.size(), file_names.size() - wrong_output.size()])
	for err in wrong_output:
		printerr(err)
	
	dialogue_system.queue_free()
	return output


func start_bad_files_test(value: bool):
	test_bad_files_func = test_bad_files()


func _ready():
	start_load_test(true)
