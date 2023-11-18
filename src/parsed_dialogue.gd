class_name ParsedDialogue

# dictionary of aliases -> array index
# dictionary of questions -> array index
# array of array of answers

var _aliases_dictionary: Dictionary = {}
var _questions_array: Array = []
var _lines_array: Array = []

func create_new_dialogue(question: String, alias: String):
	_lines_array.append([])
	_questions_array.append(question)
	
	if alias.is_empty() == false:
		_aliases_dictionary[alias] = _lines_array.size()


func add_answers_to(question: String, alias: String, lines: Array):
	var index: int = _get_index_for(question, alias)
	_lines_array[index].append_array(lines)


func _get_index_for(question: String, alias: String):
	if alias.is_empty() == false:
		return _aliases_dictionary[alias]
	else:
		for n in range(0, _questions_array.size()):
			if _questions_array[n] == question:
				return n
