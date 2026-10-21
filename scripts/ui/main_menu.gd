extends Control


func _on_single_player_pressed() -> void:
	GameManager.game_mode = GameManager.GameMode.SINGLE_PLAYER
	GameManager.go_setup()


func _on_multiplayer_pressed() -> void:
	GameManager.game_mode = GameManager.GameMode.LOCAL_MULTIPLAYER
	GameManager.go_setup()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _ready() -> void:
	%SinglePlayerButton.grab_focus()
