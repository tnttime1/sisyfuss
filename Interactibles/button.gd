extends StaticBody2D

#manages the level mechanics, respawn points, which level you are on
@onready var level: Node2D =get_parent().get_parent();
var obstructs: bool = false;
#the system node is responcible for controling broad game mechanics, like saving, knowing what to load in etc
@onready var system:Node = level.get_parent();
var tile_size:int;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_size = system.tile_size;
	position = position.snapped(Vector2(tile_size,tile_size));
	position += Vector2(tile_size,tile_size)/2.0;
	system.register_interactible(self);
