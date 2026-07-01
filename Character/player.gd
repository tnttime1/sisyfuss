extends CharacterBody2D

#the system node is responcible for controling broad game mechanics, like saving, knowing what to load in etc
@onready var system: Node = get_parent()
@onready var sprite_2d: Sprite2D = $Sprite2D

var tile_size:int;
var is_moving:bool = false;

#how long it takes for object to move in seconds
@export var movement_delay: float = 0.1;

func _ready() -> void:
	tile_size = system.tile_size
	position = position.snapped(Vector2(tile_size,tile_size))
	# centers the character to grid, terrible solution
	position += Vector2(tile_size,tile_size)/2.0;
	system.register_interactible(self)


func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("left","right","up","down").round(); # gets 8 directions moving 1, -1, or 0 spaces

	if not is_moving and direction != Vector2.ZERO:
		try_move(direction)

# tries to move object, if its already moving nothing else can move it
func try_move(direction: Vector2):
	
	if not is_moving:
		is_moving = true
		
		if direction.x == -1:
			sprite_2d.flip_h = true
		elif direction.x == 1:
			sprite_2d.flip_h = false
		
		# checks if there is a valid place to move
		var tween_dur:float = await system.can_move(self, direction,movement_delay)
		
		if tween_dur != -1:
			var target = position + direction* tile_size;
			
			# sliding animation for movement
			var walk_tween = create_tween()
			walk_tween.tween_property(self, "position", target, tween_dur)

			walk_tween.finished.connect(finished_moving) 
			return tween_dur
		else:
			var shake_tween = create_tween()
			var original_pos = position
			var shake_intencity = 8
			var shake_duration = 0.05
			var shake_paused = 0.05
			
			shake_tween.tween_property(self, "position", original_pos + direction*shake_intencity, shake_duration)
			shake_tween.tween_property(self, "position", original_pos - direction*shake_intencity, shake_duration)
			shake_tween.tween_property(self, "position", original_pos + direction*shake_intencity, shake_duration)
			shake_tween.tween_property(self, "position", original_pos - direction*shake_intencity, shake_duration)
			
			shake_tween.tween_property(self, "position", original_pos,shake_paused )
			shake_tween.finished.connect(finished_moving)
	return -1

func finished_moving():
	await get_tree().create_timer(0.05).timeout
	is_moving = false
