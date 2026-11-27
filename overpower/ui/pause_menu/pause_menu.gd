extends Control

@onready var soundtrack: AudioStreamPlayer = %Soundtrack
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var pause_sfx: AudioStreamPlayer = $PauseSFX
@onready var unpause_sfx: AudioStreamPlayer = $UnpauseSFX

var state:bool = false

func _ready() -> void:
	state = visible
	update()
	visible = true
	soundtrack.play()
	
func _input(e: InputEvent) -> void:
	if e.is_action_pressed("pause"):
		toggle()

func toggle()->void:
	state = not state
	update()
	
func update()->void:
	var stream:AudioStreamSynchronized = soundtrack.stream
	if state:
		stream.set_sync_stream_volume(0, -40)
		stream.set_sync_stream_volume(1, -10)
		anim_player.play("open")
		pause_sfx.play()
	else:
		stream.set_sync_stream_volume(0, -10)
		stream.set_sync_stream_volume(1, -40)
		anim_player.play("close")
		unpause_sfx.play()
