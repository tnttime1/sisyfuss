extends CharacterBody2D

#the system node is responcible for controling broad game mechanics, like saving, knowing what to load in etc
@onready var system: Node = get_parent()

var tile_size:int;
var is_moving:bool = false;

#how long it takes for object to move in seconds
@export var movement_delay: float = 0.2;

func _ready() -> void:
	position = position.snapped(Vector2(tile_size,tile_size))
	# centers the character to grid, terrible solution
	position += Vector2(tile_size/2.0,tile_size/2.0);
	system.register_interactible(self)
	tile_size = system.tile_size

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("left","right","up","down").round(); # gets 8 directions moving 1, -1, or 0 spaces

	if not is_moving and direction != Vector2.ZERO:
		try_move(direction)

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
