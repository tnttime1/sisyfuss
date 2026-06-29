extends Node
# in  game data you have all the info you want to save, can write it as
# {"player skin": link to player skin img, "rock skin": link to rock skin img }
var gamedata:Dictionary = {}
#later relevant for saving and loading the game
enum SystemState {NEWGAME,CONTINUE,RUNNING}
var current_state = SystemState.NEWGAME
var save_adress = "user://savegame.save"

# all interactible things like players or bolders, saved by cell coordinate : interactible
var tile_occupied: Dictionary[Vector2i,Node] = {}
var object_at_tile: Dictionary[Node,Vector2i] = {}

@export var tile_size:int = 32;

# cutscenes layer handles dialogue and cutscenes
@onready var cutscenes: CanvasLayer = $Cutscenes
#handles main menu and settings
@onready var menu_settings: CanvasLayer = $"Menu settings"

@onready var player: CharacterBody2D = $Player
@onready var level: Node2D = $Level
@onready var walls: TileMapLayer = level.get_child(0).get_node("Walls");


func make_scene(scene, type):
	var new_scene = load(scene)
	var something = new_scene.instantiate()
	match (type):
		"Level":
			level.add_child(something)
			
func new_game():
	get_tree().paused = false
	menu_settings.hide()
	await cutscenes.play_dialogue(
		load_file(
			"res://dialogue/misc/opening_cutscene_1.txt"))
func continue_game():
	var save_data = load_file(save_adress)
	player.position = Vector2(325,299.0)
	for key in save_data:
		gamedata[key] = save_data[key]
	menu_settings.hide()
	get_tree().paused = false
func save_game():
	save_file(gamedata,save_adress)
	get_tree().paused = true
	menu_settings.show()

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

#checks where objects can move and if it pushes a different object with it
func can_move(interactible: Node2D, direction:Vector2) -> bool:
	if object_at_tile.get(interactible) == null:
		register_interactible(interactible)
		
	var current_cell = object_at_tile[interactible];
	var target_cell = current_cell + Vector2i(direction);
	var horizontal_cell =  current_cell + Vector2i(int(direction.x),0);
	var vertical_cell =  current_cell + Vector2i(0, int(direction.y));

	var valid_move = (walls.get_cell_source_id(target_cell) == -1 and # checking if the target tile we want to go to is empty
		(walls.get_cell_source_id(horizontal_cell) == -1 or # checking if there is a horizontal or vertical opening to it
		walls.get_cell_source_id(vertical_cell) == -1))
	
	if !valid_move:
		return false
	
	if tile_occupied.get(target_cell) !=null:
		if !await tile_occupied[target_cell].try_move(direction):
			return false

	tile_occupied.erase(object_at_tile[interactible])
	tile_occupied[target_cell] = interactible
	object_at_tile[interactible] = target_cell
	
	return true

#adds new interactible object to the system, such as players, bolders or chests and the coordinate of the object
func register_interactible(interactible: Node2D):
	var grid_coordinate = Vector2i( ((interactible.position - Vector2(tile_size/2.0,tile_size/2.0)) /tile_size).round())
	tile_occupied[grid_coordinate] = interactible
	object_at_tile[interactible] = grid_coordinate
