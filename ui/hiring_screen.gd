class_name HiringScreen extends Control

@onready var selection_label: Label = %SelectionLabel
@onready var adventurer_list: VBoxContainer = %AdventurerList
@onready var confirm_button: Button = %ConfirmButton

const ADVENTURER_CARD_SCENE = preload(
	"res://ui/ui_components/adventurer_card.tscn"
)

var entity_manager: EntityManager
var company_system: CompanySystem
var game_manager: GameManager
var selected_adventurer_ids: Array[int] = []
var available_adventurer_ids: Array[int] = []
const MAX_SELECTION: int = 10

signal hiring_complete


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	_update_ui()


func setup(
	p_entity_manager: EntityManager,
	p_company_system: CompanySystem,
	p_game_manager: GameManager,
	p_available_adventurer_ids: Array[int],
) -> void:
	entity_manager = p_entity_manager
	company_system = p_company_system
	game_manager = p_game_manager
	available_adventurer_ids = p_available_adventurer_ids
	print(available_adventurer_ids)
	_populate_adventurer_list()
	_update_ui()


func _populate_adventurer_list() -> void:
	for child in adventurer_list.get_children():
		child.queue_free()

	print("Available adventurers: ", available_adventurer_ids.size())

	for adventurer_id in available_adventurer_ids:
		var adventurer_card: AdventurerCard = (
			ADVENTURER_CARD_SCENE.instantiate()
		)
		adventurer_list.add_child(adventurer_card)
		adventurer_card.setup(entity_manager, adventurer_id, true)

		adventurer_card.selected.connect(_on_adventurer_selected)
		adventurer_card.deselected.connect(_on_adventurer_deselected)

	print("Total cards created: ", adventurer_list.get_child_count())


func _on_adventurer_selected(adventurer_id: int) -> void:
	if selected_adventurer_ids.size() >= MAX_SELECTION:
		push_warning("Maximum selection reached")
		for adventurer_card in adventurer_list.get_children():
			if adventurer_card.adventurer_id == adventurer_id:
				adventurer_card.set_selected(false)
				break
		return

	selected_adventurer_ids.append(adventurer_id)
	_update_ui()


func _on_adventurer_deselected(adventurer_id: int) -> void:
	selected_adventurer_ids.erase(adventurer_id)
	_update_ui()


func _update_ui() -> void:
	selection_label.text = "Selected: %d/%d" % [
		selected_adventurer_ids.size(),
		MAX_SELECTION,
	]

	confirm_button.disabled = selected_adventurer_ids.size() != MAX_SELECTION


func _on_confirm_pressed() -> void:
	if selected_adventurer_ids.size() != MAX_SELECTION:
		return

	for adventurer_id in selected_adventurer_ids:
		var success: bool = company_system.hire_staff_member(
			game_manager.player_company_id,
			adventurer_id
		)
		if not success:
			push_error("Failed to hire adventurer %d" % adventurer_id)

	hiring_complete.emit()
