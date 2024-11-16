extends Panel

func _on_mouse_entered() -> void:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color.BURLYWOOD
	stylebox.set_corner_radius_all(5)
	add_theme_stylebox_override("panel", stylebox)

func _on_mouse_exited() -> void:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color.TRANSPARENT
	stylebox.set_corner_radius_all(5)
	add_theme_stylebox_override("panel", stylebox)
