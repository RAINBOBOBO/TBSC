class_name AdventurerCard extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var str_label: Label = %StrLabel
@onready var dex_label: Label = %DexLabel
@onready var int_label: Label = %IntLabel
@onready var mag_label: Label = %MagLabel
@onready var select_button: Button = %SelectButton

var entity_manager: EntityManager
var adventurer_id: int = -1
var is_selected: bool = false

signal selected(adventurer_id: int)
signal deselected(adventurer_id: int)


func _ready() -> void:
	if select_button:
		select_button.pressed.connect(_on_select_button_pressed)


func setup(
	p_entity_manager: EntityManager,
	p_adventurer_id: int,
	show_select_button: bool = false,
) -> void:
	entity_manager = p_entity_manager
	adventurer_id = p_adventurer_id
	select_button.visible = show_select_button

	update_display()


func set_selected(p_is_selected: bool) -> void:
	is_selected = p_is_selected
	update_display()

	if is_selected:
		modulate = Color(1.2, 1.2, 1.0)  # Slightly yellow tint
	else:
		modulate = Color.WHITE


func _on_select_button_pressed() -> void:
	is_selected = not is_selected

	if is_selected:
		selected.emit(adventurer_id)
	else:
		deselected.emit(adventurer_id)

	set_selected(is_selected)


func update_display() -> void:
	if not entity_manager or adventurer_id == -1:
		return

	var name_component: NameComponent = entity_manager.get_entity_component(
		adventurer_id,
		"NameComponent"
	)
	var stats: StatsComponent = entity_manager.get_entity_component(
		adventurer_id,
		"StatsComponent"
	)
	print(adventurer_id, name_component.display_name, stats.health)

	if not name_component or not stats:
		push_error("Adventurer missing required components")
		return

	name_label.text = name_component.display_name

	health_bar.max_value = stats.max_health
	health_bar.value = stats.health
	health_label.text = "%d/%d HP" % [stats.health, stats.max_health]

	var health_percent: float = float(stats.health) / float(stats.max_health)
	if health_percent > 0.6:
		health_bar.modulate = Color.GREEN
	elif health_percent > 0.3:
		health_bar.modulate = Color.YELLOW
	else:
		health_bar.modulate = Color.RED

	str_label.text = "STR: %d" % stats.strength
	dex_label.text = "DEX: %d" % stats.dexterity
	int_label.text = "INT: %d" % stats.intelligence
	mag_label.text = "MAG: %d" % stats.magic

	if select_button.visible:
		select_button.text = "Deselect" if is_selected else "Select"
