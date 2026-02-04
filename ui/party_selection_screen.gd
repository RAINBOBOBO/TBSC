class_name PartySelectionScreen extends Control

@onready var quest_info_panel: PanelContainer = %QuestInfoPanel
@onready var quest_title_label: Label = %QuestTitleLabel
@onready var quest_difficulty_label: Label = %QuestDifficultyLabel
@onready var quest_reward_label: Label = %QuestRewardLabel
@onready var stat_weights_label: Label = %StatWeightsLabel
@onready var selected_count_label: Label = %SelectedCountLabel
@onready var available_staff_list: VBoxContainer = %AvailableStaffList
@onready var cancel_button: Button = %CancelButton
@onready var confirm_button: Button = %ConfirmButton

const ADVENTURER_CARD = preload("res://ui/ui_components/adventurer_card.tscn")

var entity_manager: EntityManager
var quest_system: QuestSystem
var company_system: CompanySystem
var game_manager: GameManager
var current_quest_id: int = -1
var selected_staff_ids: Array[int] = []

signal selection_confirmed
signal selection_cancelled


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)


func setup(
		p_entity_manager: EntityManager,
		p_quest_system: QuestSystem,
		p_company_system: CompanySystem,
		p_game_manager: GameManager,
		quest_id: int
	) -> void:
	entity_manager = p_entity_manager
	quest_system = p_quest_system
	company_system = p_company_system
	game_manager = p_game_manager
	current_quest_id = quest_id

	selected_staff_ids.clear()
	_display_quest_info()
	_populate_available_staff()
	_update_ui()


# ============================================================================
# Quest Info Display
# ============================================================================

func _display_quest_info() -> void:
	var job: JobComponent = entity_manager.get_entity_component(
		current_quest_id,
		"JobComponent"
	)

	if not job:
		push_error("Quest not found")
		return

	quest_title_label.text = job.title
	quest_difficulty_label.text = "Difficulty: %d" % job.difficulty
	quest_reward_label.text = "Reward: %d gold, %d XP" % [
		job.reward_gold,
		job.reward_xp,
	]

	var weights_text: String = "Important Stats: "
	var important_stats: Array[String] = []

	for stat_name in job.attribute_weights:
		var weight: int = job.attribute_weights[stat_name]
		if weight == JobComponent.Relevance.CRITICAL:
			important_stats.append(stat_name.to_upper() + "★★★")
		elif weight == JobComponent.Relevance.IMPORTANT:
			important_stats.append(stat_name.to_upper() + "★★")

	if important_stats.is_empty():
		weights_text += "All stats equally important"
	else:
		weights_text += ", ".join(important_stats)

	stat_weights_label.text = weights_text


# ============================================================================
# Staff List
# ============================================================================

func _populate_available_staff() -> void:
	for child in available_staff_list.get_children():
		child.queue_free()

	var available_ids: Array[int] = company_system.get_available_for_job(
		game_manager.player_company_id
	)

	if available_ids.is_empty():
		var label: Label = Label.new()
		label.text = "No staff available!"
		available_staff_list.add_child(label)
		return

	for staff_id in available_ids:
		var card = ADVENTURER_CARD.instantiate()
		available_staff_list.add_child(card)
		card.setup(entity_manager, staff_id, true)

		card.selected.connect(_on_staff_selected)
		card.deselected.connect(_on_staff_deselected)


func _on_staff_selected(staff_id: int) -> void:
	if staff_id not in selected_staff_ids:
		selected_staff_ids.append(staff_id)
	_update_ui()


func _on_staff_deselected(staff_id: int) -> void:
	selected_staff_ids.erase(staff_id)
	_update_ui()


# ============================================================================
# UI Updates
# ============================================================================

func _update_ui() -> void:
	selected_count_label.text = "Selected: %d adventurer(s)" % (
		selected_staff_ids.size()
	)

	confirm_button.disabled = selected_staff_ids.is_empty()


# ============================================================================
# Confirmation
# ============================================================================

func _on_confirm_pressed() -> void:
	if selected_staff_ids.is_empty():
		return

	var success: bool = quest_system.assign_staff_to_quest(
		game_manager.player_company_id,
		current_quest_id,
		selected_staff_ids
	)

	if success:
		selection_confirmed.emit()
	else:
		push_error("Failed to assign staff to quest")


func _on_cancel_pressed() -> void:
	selection_cancelled.emit()
