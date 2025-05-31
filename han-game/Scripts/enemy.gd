extends CharacterBody2D


@onready var player = get_node("/root/game/Hancı") 
@onready var animation_player = $AnimatedSprite2D

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 100
	
	var distance = sqrt(pow(global_position.x - player.global_position.x,2)+pow(global_position.y - player.global_position.y,2))
	
	if(distance <= 25.0):
		velocity = Vector2(0,0)
		attack()
	
	move_and_slide()
	
	
func attack():
	animation_player.play("down_preparation")
