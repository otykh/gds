class_name ParsedDialogue

var _aliases_dictionary: Dictionary = {}
var _questions_array: Array = []
var _lines_array: Array = []

func create_new_dialogue(question: String, alias: String):
	_lines_array.append([])
	_questions_array.append(question)
	
	if alias.is_empty() == false:
		_aliases_dictionary[alias] = _lines_array.size() - 1


func verify() -> bool:
	for i in range(0, _lines_array.size()):
		if _lines_array[i].size() == 0:
			push_error("'%s' has been identified but never associated with dialogue" % _questions_array[i])
			return false
	return true


func add_line_to(question: String, alias: String, line: Array) -> bool:
	var index: int = _get_index_for(question, alias)
	if index == -1:
		push_error("Dialogue %s with alias '%s' was not identified" % [question, alias])
		return false
	_lines_array[index].append(line)
	return true


func _get_index_for(question: String, alias: String):
	if alias.is_empty() == false:
		return _aliases_dictionary.get(alias, -1)
	else:
		for n in range(0, _questions_array.size()):
			if _questions_array[n] == question:
				return n
	return -1
