extends Control

## Presentation only: health remains authoritative, including fractional damage.
class HealthGauge extends Control:
	var max_value := 5.0
	var value := 5.0
	func _draw() -> void:
		var ratio := clampf(value/maxf(1.0,max_value),0.0,1.0)
		draw_rect(Rect2(0,0,110,10),Color(.04,.08,.1,.9))
		draw_rect(Rect2(1,1,108*ratio,8),Color(1,.70,.30,.95) if ratio<=.3 else Color(.4,.82,.64,.95))
		draw_rect(Rect2(0,0,110,10),Color(.55,.65,.65,.6),false,1.0)

var health: Node
var label: Label
var bar: HealthGauge
var restored: Label
var _last_health := -1.0
var _notice_remaining := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar = HealthGauge.new()
	bar.position = Vector2(0,7)
	bar.size = Vector2(110,10)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	label = Label.new()
	label.position = Vector2(122,0)
	add_child(label)
	restored = Label.new()
	restored.position = Vector2(295,0)
	restored.add_theme_color_override("font_color",Color(.65,1,.76))
	restored.text = tr("health_restored")
	restored.hide()
	add_child(restored)

func bind_health(component: Node) -> void:
	health = component
	_last_health = health.health
	health.health_changed.connect(refresh)
	refresh()

func refresh() -> void:
	if not is_instance_valid(health) or not is_instance_valid(label):
		return
	if _last_health>=0.0 and health.health>_last_health and not health.dead:
		_notice_remaining = 1.2
		restored.show()
	_last_health = health.health
	bar.max_value = health.max_health
	bar.value = health.health
	bar.queue_redraw()
	label.text = tr("health_status") % [health.health,health.max_health]
	restored.text = tr("health_restored")

func _process(delta: float) -> void:
	_notice_remaining = maxf(0.0,_notice_remaining-delta)
	restored.visible = _notice_remaining>0.0

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		refresh()
