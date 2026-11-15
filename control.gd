
extends Control

const GAME_SCENE = "res://Game.tscn"

var title
var play_button
var quit_button


func _ready():
	make_menu()


func make_menu():

	# Background
	var bg = ColorRect.new()
	bg.color = Color("#100D10")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Red decoration
	var red_line = ColorRect.new()
	red_line.color = Color("#A31325")
	red_line.position = Vector2(0, 0)
	red_line.custom_minimum_size = Vector2(8, 900)
	red_line.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	add_child(red_line)

	# Center layout
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var layout = VBoxContainer.new()
	layout.custom_minimum_size = Vector2(350, 350)
	layout.add_theme_constant_override("separation", 22)
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(layout)

	# Small subtitle
	var subtitle = Label.new()
	subtitle.text = "THE BATTLE BEGINS"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("#B8A5A5"))
	layout.add_child(subtitle)

	# Main title
	title = Label.new()
	title.text = "BLOOD & STEEL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color.WHITE)
	layout.add_child(title)

	# Red line
	var line = ColorRect.new()
	line.color = Color("#A31325")
	line.custom_minimum_size = Vector2(250, 3)
	layout.add_child(line)

	# Play button
	play_button = Button.new()
	play_button.text = "PLAY"
	play_button.custom_minimum_size = Vector2(280, 60)
	style_button(play_button, "#A31325")
	layout.add_child(play_button)

	# Quit button
	quit_button = Button.new()
	quit_button.text = "QUIT"
	quit_button.custom_minimum_size = Vector2(280, 60)
	style_button(quit_button, "#292326")
	layout.add_child(quit_button)

	# Footer
	var footer = Label.new()
	footer.text = "FIGHT. SURVIVE. CONQUER."
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color("#887777"))
	layout.add_child(footer)

	# Button connections
	play_button.pressed.connect(play_game)
	quit_button.pressed.connect(quit_game)


func style_button(button, color):

	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.border_color = Color("#D13B4B")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)

	var hover = StyleBoxFlat.new()
	hover.bg_color = Color("#C21D32")
	hover.set_corner_radius_all(4)

	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color("#650D1B")
	pressed.set_corner_radius_all(4)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)

	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)


func play_game():

	if ResourceLoader.exists(GAME_SCENE):
		get_tree().change_scene_to_file(GAME_SCENE)
	else:
		print("ERROR: Game scene not found! Check GAME_SCENE filename.")


func quit_game():
	get_tree().call_deferred("quit")
