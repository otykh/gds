@tool

extends Node

@export var test_initialize: bool = false : set = start_test_init
@export var test_load_func: bool = false : set = start_load_test

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

func test_init() -> bool:
	var dialogue_system: DialogueSystem = DialogueSystem.new()
	
	var output: bool = true
	
	if DirAccess.dir_exists_absolute("res://dialogues") == false:
		printerr("The dialogue directory does not exist or was not created")
		output = false
	
	var file = FileAccess.open("res://dialogues/test_dialogue.txt", FileAccess.READ)
	if file == null:
		push_warning("test_dialogue.txt does not exist, writing a new one...")
		file = FileAccess.open("res://dialogues/test_dialogue.txt", FileAccess.WRITE_READ)
		file.store_string(test_dialogue_file)
		file.close()
	
	dialogue_system.queue_free()
	return output


func start_test_init(value: bool):
	test_initialize = test_init()


func test_load() -> bool:
	var dialogue_system: DialogueSystem = DialogueSystem.new()
	var output: bool = true
	
	if dialogue_system._start_dialogue("test_dialogue") == false:
		push_error("Cannot start test dialogue")
		output = false
	else:
		dialogue_system.parsed_loaded_dialogue._TEMP_print_all_dialogues() #TODO remove
	
	dialogue_system.queue_free()
	return output


func start_load_test(value: bool):
	test_load_func = test_load()


func _ready():
	start_load_test(true)
