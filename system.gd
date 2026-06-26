extends Node
# in  game data you have all the info you want to save, can write it as
# {"player skin": link to player skin img, "rock skin": link to rock skin img }
var gamedata:Dictionary = {}

# dialogue layer handles dialogue and cutscenes ()
@onready var dialogue_layer: CanvasLayer = $DialogueLayer
enum SystemState {NEWGAME,CONTINUE,RUNNING}
@onready var settings: CanvasLayer = $Settings
var current_state = SystemState.NEWGAME
var save_adress = "user://savegame.save"
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	pass
	
func make_scene(scene, type):
	var new_scene = load(scene)
	var something = new_scene.instantiate()
	match (type):
		"Level":
			$Level.add_child(something)
			
func new_game():
	get_tree().paused = false
	settings.hide()
	await dialogue_layer.play_dialogue(
		load_file(
			"res://dialogue/misc/opening_cutscene_1.txt"))
func continue_game():
	var save_data = load_file(save_adress)
	player.position = Vector2(325,299.0)
	for key in save_data:
		gamedata[key] = save_data[key]
	settings.hide()
	get_tree().paused = false
func save_game():
	save_file(gamedata,save_adress)
	get_tree().paused = true
	settings.show()

func load_file(file_path:String):
	if !FileAccess.file_exists(file_path):
		print("file not found")
		return
	var file = FileAccess.open(file_path,FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_res = json.parse(json_string)
	if !(parse_res == OK):
		print("JSON parse error ", json.get_error_message()," on line ", json.get_error_line())
		return
	return json.get_data()
	
func save_file(save_data, save_path:String):
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	if file == null:
		print("ERROR CREATING SAVE FILE ", FileAccess.get_open_error())
		return
	var data = JSON.stringify(save_data)	
	file.store_string(data)
	file.close()
