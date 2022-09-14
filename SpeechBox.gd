extends CanvasLayer

var face1 = preload("res://assets/Rufus Icon (1)/RufusIcons_0.png")
var face2 = preload("res://assets/Rufus Icon (1)/RufusIcons_1.png")
var face3 = preload("res://assets/Rufus Icon (1)/RufusIcons_2.png")

export(String, FILE, "*.json") var dialogue_file

var dialogues = []
var current_dialogue_id = 0
var maxChars = 0
onready var expressionChart = ["res://assets/Rufus Icon (1)/RufusIcons_0.png","res://assets/Rufus Icon (1)/RufusIcons_1.png","res://assets/Rufus Icon (1)/RufusIcons_2.png","res://assets/Dollar Bill-1.png.png"]

# Called when the node enters the scene tree for the first time.
func _ready():
	$NinePatchRect.visible = false


func play():
	dialogues = load_dialogue()
	
	#$NinePatchRect.visible = true
	$LitePlayer1.visible = true
	$LitePlayer2.visible = true
	$LitePlayer1.text = ''
	$LitePlayer2.text = ''
	current_dialogue_id = -1
	#next_line()
	next_lite()

func _input(event):
	if Input.is_action_just_pressed("press_z"):
		#next_line()
		next_lite()
		pass

func next_lite():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogues):
		$LitePlayer1.visible = false
		$LitePlayer2.visible = false
		return
	
	if dialogues[current_dialogue_id]['name'] == "Rufus":
		$LitePlayer1.text = dialogues[current_dialogue_id]['text']
		if current_dialogue_id - 2 < len(dialogues) and dialogues[current_dialogue_id - 1]['name'] != "Rufus":
			$LitePlayer2.text = ''
		$speechTween.interpolate_property($LitePlayer1, "percent_visible",0,1, 0.7,Tween.TRANS_LINEAR)	
		
	elif dialogues[current_dialogue_id]['name'] == "Bill the Sentient Sword":
		$LitePlayer2.text = dialogues[current_dialogue_id]['text']
		if current_dialogue_id - 2 < len(dialogues) and dialogues[current_dialogue_id - 1]['name'] != "Bill the Sentient Sword":
			$LitePlayer1.text = ''
		$speechTween2.interpolate_property($LitePlayer2, "percent_visible",0,1, 0.7,Tween.TRANS_LINEAR)
	
	$speechTween.start()
	$speechTween2.start()

	$liteTimer.start()
		
func next_line():
	
	current_dialogue_id += 1
	
	if current_dialogue_id >= len(dialogues):
		$NinePatchRect.visible = false
		return
	
	$NinePatchRect/Name.text = dialogues[current_dialogue_id]['name']
	$NinePatchRect/Message.text = dialogues[current_dialogue_id]['text']
	$NinePatchRect/SpeechIcon.texture = load(expressionChart[dialogues[current_dialogue_id]['Expresion']])
	
	maxChars = $NinePatchRect/Message.get_total_character_count()
	#$NinePatchRect/Message.set_visible_characters(5)
	
func load_dialogue():
	var file = File.new()
	if file.file_exists(dialogue_file):
		file.open(dialogue_file, file.READ)
		return parse_json(file.get_as_text())



func _on_Timer_timeout():
	next_lite()
	#if Input.is_action_just_pressed("press_z"):
		#$NinePatchRect/Message.set_visible_characters(maxChars) 
