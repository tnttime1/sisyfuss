extends StaticBody2D

#manages the level mechanics, respawn points, which level you are on
@onready var level: Node2D =get_parent().get_parent();

#the system node is responcible for controling broad game mechanics, like saving, knowing what to load in etc
@onready var system:Node = level.get_parent();
var tile_size:int;

#how long it takes for object to move in seconds
@export var movement_delay = 0.5;
var is_moving = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = position.snapped(Vector2(tile_size,tile_size));
	#position += Vector2(tile_size/2.0,tile_size/2.0);
	system.register_interactible(self);
	tile_size = system.tile_size;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# tries to move object, if its already moving nothing else can move it
func try_move(direction: Vector2):
	
	if not is_moving:
		is_moving = true
		
		# checks if there is a valid place to move
		if await system.can_move(self, direction):
			var target = position + direction* tile_size
			
			# sliding animation for movement
			var walk_tween = create_tween()
			walk_tween.tween_property(self, "position", target, movement_delay)

			await walk_tween.finished
			is_moving = false
			return true
		is_moving = false
	return false
