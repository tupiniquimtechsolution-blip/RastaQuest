extends Control

## Each surface owns exactly one finger. Dragging outside does not steal another.
var action: StringName = &""
var analog := false
var finger := -1
var displacement := Vector2.ZERO
var icon: Texture2D
var deadzone := 0.18
var _up_armed := true
var _jump_pulse_frames := 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if get_tree().get_nodes_in_group("onboarding_active").size()>0 or (get_tree().paused and action != &"pause"):
		release()
		return
	if not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.pressed and finger == -1 and _contains(event.position):
			finger = event.index
			_press(event.position)
		elif not event.pressed and event.index == finger:
			release()
	elif event is InputEventScreenDrag and event.index == finger:
		if analog:
			_move(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.device != InputEvent.DEVICE_ID_EMULATION:
		if event.pressed and finger == -1 and _contains(event.position):
			finger = -2
			_press(event.position)
		elif not event.pressed and finger == -2:
			release()
	elif event is InputEventMouseMotion and finger == -2 and analog:
		_move(event.position)

func _physics_process(_delta: float) -> void:
	if _jump_pulse_frames>0:
		_jump_pulse_frames -= 1
		if _jump_pulse_frames==0:
			Input.action_release("jump_stick")

func _contains(point: Vector2) -> bool:
	return (point-(global_position+size*0.5)).length() <= size.x*0.5

func _press(point: Vector2) -> void:
	if analog:
		_move(point)
	elif action == &"pause":
		Input.action_press(action)
		Input.action_release(action)
	else:
		Input.action_press(action)
	queue_redraw()

func _move(point: Vector2) -> void:
	displacement = ((point-global_position-size*0.5)/(size.x*0.34)).limit_length(1.0)
	if displacement.y>-0.25:
		_up_armed = true
	elif displacement.y<=-0.58 and _up_armed:
		_up_armed = false
		_jump_pulse_frames = 2
		Input.action_press("jump_stick")
	var axis := displacement.x
	var strength := clampf((absf(axis)-deadzone)/(1.0-deadzone),0,1)
	Input.action_release("move_left")
	Input.action_release("move_right")
	if strength > 0:
		Input.action_press("move_left" if axis<0 else "move_right",strength)
	queue_redraw()

func release() -> void:
	if finger == -1:
		return
	finger = -1
	displacement = Vector2.ZERO
	_up_armed = true
	_jump_pulse_frames = 0
	if analog:
		Input.action_release("jump_stick")
		Input.action_release("move_left")
		Input.action_release("move_right")
	elif action != &"pause":
		Input.action_release(action)
	queue_redraw()

func _exit_tree() -> void:
	release()

func _draw() -> void:
	var center := size*0.5
	var radius := size.x*0.5-2.0
	draw_circle(center,radius,Color(.08,.12,.17,.22 if finger == -1 else .38))
	draw_arc(center,radius,0,TAU,64,Color(1,1,1,.32),2,true)
	if analog:
		draw_circle(center+displacement*size.x*.27,size.x*.20,Color(1,1,1,.33))
		draw_arc(center+displacement*size.x*.27,size.x*.20,0,TAU,40,Color(1,1,1,.42),1.5,true)
	elif icon != null:
		draw_texture_rect(icon,Rect2(size*.24,size*.52),false,Color(1,1,1,.68))
	elif action == &"pause":
		for x in [-1,1]:
			draw_line(center+Vector2(x*5,-9),center+Vector2(x*5,9),Color(1,1,1,.65),4,true)
