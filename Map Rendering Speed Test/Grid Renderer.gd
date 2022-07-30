extends Control

enum SETUP_MODES {Basic, Dup}
export var setup_mode = 0

export var render_mode = 0
enum RENDER_MODES {If_For_Children, For_If_Children, If_For_Array, For_If_Array}

onready var grid = get_node("VBox/GridContainer")
onready var action = get_node("VBox/Buttons/Action")
onready var use_thread = get_node("VBox/Buttons/Thread/CheckBox")
onready var time_elapsed = get_node("VBox/Buttons/Time/Time")

func _ready():
	randomize()
	action.text = "Setup"
	use_thread.pressed = true
	time_elapsed.text = "0"
	
	print("Setup Mode: " + str(SETUP_MODES.keys()[setup_mode]))
	print("Render Mode: " + str(RENDER_MODES.keys()[render_mode]))

const GRID_DIMS = Vector2(100,100)
const COLOR_RECT_SIZE = 4
func setup():
	""" Setup """
	
	grid.columns = GRID_DIMS.y
	grid.rect_min_size = GRID_DIMS*COLOR_RECT_SIZE
	
	if setup_mode == SETUP_MODES.Basic:
		
		var obj
		for y in GRID_DIMS.y:
			for x in GRID_DIMS.x:
				obj = ColorRect.new()
				obj.rect_min_size = COLOR_RECT_SIZE*Vector2(1,1)
				obj.color = Color(get_min_max(x, 0, GRID_DIMS.x), 0, get_min_max(y, 0, GRID_DIMS.y))
				grid.add_child(obj)
	
	elif setup_mode == SETUP_MODES.Dup:
		
		var obj_scene = ColorRect.new()
		obj_scene.rect_min_size = COLOR_RECT_SIZE*Vector2(1,1)
		
		var obj
		for y in GRID_DIMS.y:
			for x in GRID_DIMS.x:
				obj = obj_scene.duplicate()
				obj.color = Color(get_min_max(x, 0, GRID_DIMS.x), 0, get_min_max(y, 0, GRID_DIMS.y))
				grid.add_child(obj)
	
	action_done()

func render_test():
	""" Render Test """
	
	for i in range(len(COLOR_SCHEMES.values())):
		color_scheme(i)
	
	action_done()

enum TEST_MODES {Setup, Render_Test, Rendering}
onready var current_test_mode = TEST_MODES.Setup
func _on_Action_pressed():
	""" Button Pressed """
	
	if current_test_mode != TEST_MODES.Rendering:
		
		var thread = Thread.new()
		if current_test_mode == TEST_MODES.Setup:
			action_start()
			
			if use_thread.pressed:
				thread.start(self, "setup", null, 1)
			else:
				setup()
		
		elif current_test_mode == TEST_MODES.Render_Test:
			action_start()
			
			if use_thread.pressed:
				thread.start(self, "render_test", null, 1)
			else:
				render_test()

var time_start
func action_start():
	current_test_mode = TEST_MODES.Rendering
	action.text = "Rendering"
	
	time_elapsed.text = "0"
	time_start = OS.get_ticks_msec()

var time_now
func action_done():
	
	time_now = OS.get_ticks_msec()
	time_elapsed.text = str((time_now - time_start)/1000.0)
	
	action.text = "Render Test"
	current_test_mode = TEST_MODES.Render_Test

enum COLOR_SCHEMES {X, Y, XY, Simplex}
func color_scheme(mode):
	""" Color Scheme """
	
	if render_mode == RENDER_MODES.If_For_Children:
		if mode == COLOR_SCHEMES.X:
			for child in grid.get_children():
				child.color = Color(get_min_max(i_to_loc(child.get_index()).x, 0, GRID_DIMS.x), 0, 0)
		
		elif mode == COLOR_SCHEMES.Y:
			for child in grid.get_children():
				child.color = Color(0, 0, get_min_max(i_to_loc(child.get_index()).y, 0, GRID_DIMS.y))
		
		elif mode == COLOR_SCHEMES.XY:
			for child in grid.get_children():
				child.color = Color(get_min_max(i_to_loc(child.get_index()).x, 0, GRID_DIMS.x), 0, get_min_max(i_to_loc(child.get_index()).y, 0, GRID_DIMS.y))
		
		elif mode == COLOR_SCHEMES.Simplex:
			var noise_map: OpenSimplexNoise = OpenSimplexNoise.new()
			noise_map.seed = randi()
			noise_map.period = 20
			
			var hold
			for child in grid.get_children():
				hold = get_min_max(noise_map.get_noise_2dv(i_to_loc(child.get_index())), -1, 1)
				child.color = Color(hold, 0, 1-hold)
	
	elif render_mode == RENDER_MODES.For_If_Children:
		
		var noise_map: OpenSimplexNoise
		var hold
		if mode == COLOR_SCHEMES.Simplex:
			noise_map = OpenSimplexNoise.new()
			noise_map.seed = randi()
			noise_map.period = 20
		
		for child in grid.get_children():
			if mode == COLOR_SCHEMES.X:
				child.color = Color(get_min_max(i_to_loc(child.get_index()).x, 0, GRID_DIMS.x), 0, 0)
		
			elif mode == COLOR_SCHEMES.Y:
				child.color = Color(0, 0, get_min_max(i_to_loc(child.get_index()).y, 0, GRID_DIMS.y))
		
			elif mode == COLOR_SCHEMES.XY:
				child.color = Color(get_min_max(i_to_loc(child.get_index()).x, 0, GRID_DIMS.x), 0, get_min_max(i_to_loc(child.get_index()).y, 0, GRID_DIMS.y))
		
			elif mode == COLOR_SCHEMES.Simplex:
				hold = get_min_max(noise_map.get_noise_2dv(i_to_loc(child.get_index())), -1, 1)
				child.color = Color(hold, 0, 1-hold)
	
	elif render_mode == RENDER_MODES.If_For_Array:
		var color_array = []
		if mode == COLOR_SCHEMES.X:
			for child in grid.get_children():
				color_array.append(Color(get_min_max(i_to_loc(child.get_index()).x, 0, GRID_DIMS.x), 0, 0))
		
		elif mode == COLOR_SCHEMES.Y:
			for child in grid.get_children():
				color_array.append(Color(0, 0, get_min_max(i_to_loc(child.get_index()).y, 0, GRID_DIMS.y)))
		
		elif mode == COLOR_SCHEMES.XY:
			for child in grid.get_children():
				color_array.append(Color(get_min_max(i_to_loc(child.get_index()).x, 0, GRID_DIMS.x), 0, get_min_max(i_to_loc(child.get_index()).y, 0, GRID_DIMS.y)))
		
		elif mode == COLOR_SCHEMES.Simplex:
			var noise_map: OpenSimplexNoise = OpenSimplexNoise.new()
			noise_map.seed = randi()
			noise_map.period = 20
			
			var hold
			for child in grid.get_children():
				hold = get_min_max(noise_map.get_noise_2dv(i_to_loc(child.get_index())), -1, 1)
				color_array.append(Color(hold, 0, 1-hold))
		
		for child in grid.get_children():
			child.color = color_array[child.get_index()]
	
	elif render_mode == RENDER_MODES.For_If_Array:
		var noise_map: OpenSimplexNoise
		var hold
		if mode == COLOR_SCHEMES.Simplex:
			noise_map = OpenSimplexNoise.new()
			noise_map.seed = randi()
			noise_map.period = 20
		
		var color_array = []
		for child in grid.get_children():
			
			if mode == COLOR_SCHEMES.X:
				color_array.append(Color(get_min_max(i_to_loc(child.get_index()).x, 0, GRID_DIMS.x), 0, 0))
		
			elif mode == COLOR_SCHEMES.Y:
				color_array.append(Color(0, 0, get_min_max(i_to_loc(child.get_index()).y, 0, GRID_DIMS.y)))
		
			elif mode == COLOR_SCHEMES.XY:
				color_array.append(Color(get_min_max(i_to_loc(child.get_index()).x, 0, GRID_DIMS.x), 0, get_min_max(i_to_loc(child.get_index()).y, 0, GRID_DIMS.y)))
		
			elif mode == COLOR_SCHEMES.Simplex:
				hold = get_min_max(noise_map.get_noise_2dv(i_to_loc(child.get_index())), -1, 1)
				color_array.append(Color(hold, 0, 1-hold))
		
		for child in grid.get_children():
			child.color = color_array[child.get_index()]

func get_min_max(value, minimum, maximum):
	if minimum == maximum:
		return 0
	return float(value - minimum)/(maximum - minimum)

func i_to_loc(i:int):
	return Vector2(i%int(GRID_DIMS.x), i/int(GRID_DIMS.x))



	







