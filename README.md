# gds
Simple Godot Dialogue System

## How to write dialogues?
1. Create folder `res://dialogues`
2. Create a new text file, name it as the name of the dialogue, this will be used to load the dialogue in
3. Use `$` to write a comment (Note: default characters can be changed in dialogue_system.gd)
4. Use `&` to define the question that player will ask
   1. Use `&&` to define the actual dialogue
   2. You can use aliases instead of questions, just put a word (without space) after `&`, which is recomended for larger files
   3. To use alias to match the dialogue, write alias after `&&` (without space)
5. This system only supports two characters speaking at the same time
   1. Use `-` for player's lines
   2. Use `~` for character's lines

**Example of the dialogue is available down below**

## Dialogue example
```
$ This is a comment, it will be ignored by the system

& How are you doing today?
$ ^ Question that player will be able to see and select

&alias Is it raining today?
$ ^ Question with aliases, where 'alias' can be anything you want, player will only see "Is it raining today?"

&& How are you doing today?
- How are you doing today?
~ I am doing quite well! Thank you for asking!
- That is nice to hear!
$ ^ Dialogue between player and character. Used "How are you doing today?" question to match the definition above

&&alias
- Is it raining today?
~ No, it never rains here!
  - Do you know why? That is kinda... weird?
  ~ Well, visual effects are kinda expensive these days.
- Gotcha!
$ ^ Example dialogue with alias. You can also use tabs or spaces to indent lines.
$ Alias dialogues can also be defined as `&&alias SOME TEXT` but SOME TEXT is going to be treated as a comment 
```

## How to use?
**Using the example dialogue from above**
1. Reference, or create a new DialogueSystem like this: `var dialogue_system: DialogueSystem = DialogueSystem.new()`
2. Use `start_dialogue("FILE")` where `FILE` is name of the file without the _.txt_ extension
   1. Note: `start_dialogue` will return false if dialogue cannot be loaded
3. Use `get_questions()` to get questions that player could ask, defined as `&`
   1. Function will return Array[String]
   2. Note: From the example, the return is going to be ["How are you doing today?", "Is it raining today?"]
4. Use `ask_question(int)` to ask a question
   1. Note: From the example, if passed int is going to be 0 the asked question will be "How are you doing today?"
5. Use `get_next_line()` to get the next line
   1. Function will return [string, bool], where the string is the line and bool is if player is speaking or the character
   2. Note: From the example, the first get_next_line() asking first question, will return ["How are you doing today?", true] and the second time calling the function will return ["I am doing quite well! Thank you for asking!", false]
