extends CharacterBody2D

var direction: Vector2
@export var speed:int = 100
@onready var system: Node = $".."
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var dim = sprite_2d.region_rect.size


func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("left","right","up","down")
	velocity = direction * speed
	move_and_slide()
