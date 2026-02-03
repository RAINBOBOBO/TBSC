class_name ManagementHub extends Control

@onready var generate_quest_button: Button = %GenerateQuestButton
@onready var quest_list: VBoxContainer = %QuestList
@onready var company_gold_label: Label = %CompanyGoldLabel
@onready var active_quest_panel: PanelContainer = %ActiveQuestPanel
@onready var active_quest_label: Label = %ActiveQuestLabel
@onready var resolve_quest_button: Button = %ResolveQuestButton
@onready var roster_list: VBoxContainer = %RosterList

const ADVENTURER_CARD = preload(
	"res://ui/ui_components/adventurer_card.tscn"
)
const QUEST_CARD = preload("res://ui/ui_components/quest_card.tscn")

var entity_manager: EntityManager
var quest_system: QuestSystem
var company_system: CompanySystem
var game_manager: GameManager

signal quest_selected_for_assignment(quest_id: int)


func _ready() -> void:
	generate_quest_button.pressed.connect(_on_generate_quest_pressed)
	resolve_quest_button.pressed.connect(_on_resolve_quest_pressed)


func setup(
	p_entity_manager: EntityManager,
	p_quest_system: QuestSystem,
	p_company_system: CompanySystem,
	p_game_manager: GameManager
) -> void:
	entity_manager = p_entity_manager
	quest_system = p_quest_system
	company_system = p_company_system
	game_manager = p_game_manager

	quest_system.quest_assigned.connect(_on_quest_assigned)
	quest_system.quest_resolved.connect(_on_quest_resolved)

	update_display()


func update_display() -> void:
	_update_quest_list()
	_update_roster()
	_update_company_info()
	_update_active_quest_panel()

# ============================================================================
# Quest Board
# ============================================================================

func _update_quest_list() -> void:
	for child in quest_list.get_children():
		child.queue_free()

	var available_quests: Array[EntityData] = (
		quest_system.get_available_quests()
	)

	if available_quests.is_empty():
		var label: Label = Label.new()
		label.text = "No quests available. Generate some!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		quest_list.add_child(label)
		return

	for quest_entity in available_quests:
		var card = QUEST_CARD.instantiate()
		quest_list.add_child(card)
		card.setup(entity_manager, quest_entity.id)
		card.accept_pressed.connect(_on_quest_accept_pressed)


func _on_quest_accept_pressed(quest_id: int) -> void:
	quest_selected_for_assignment.emit(quest_id)


func _on_generate_quest_pressed() -> void:
	quest_system.generate_quest()
	update_display()


# ============================================================================
# Roster Display
# ============================================================================

func _update_roster() -> void:
	for child in roster_list.get_children():
		child.queue_free()

	var company: CompanyComponent = entity_manager.get_entity_component(
		game_manager.player_company_id,
		"CompanyComponent"
	)

	if not company or company.staff.is_empty():
		var label: Label = Label.new()
		label.text = "No staff hired yet"
		roster_list.add_child(label)
		return

	for staff_id in company.staff:
		var card = ADVENTURER_CARD.instantiate()
		roster_list.add_child(card)
		card.setup(entity_manager, staff_id, false)

		if staff_id in company.out_on_job:
			card.modulate = Color(0.7, 0.7, 0.7)  # Gray out


# ============================================================================
# Company Info
# ============================================================================

func _update_company_info() -> void:
	var company: CompanyComponent = entity_manager.get_entity_component(
		game_manager.player_company_id,
		"CompanyComponent"
	)

	if company:
		company_gold_label.text = "Gold: %d" % company.money
	else:
		company_gold_label.text = "Gold: 0"


# ============================================================================
# Active Quest Panel
# ============================================================================

func _update_active_quest_panel() -> void:
	var active_quests: Array[EntityData] = (
		quest_system.get_company_active_quests(game_manager.player_company_id)
	)

	if active_quests.is_empty():
		active_quest_panel.visible = false
		return

	active_quest_panel.visible = true
	resolve_quest_button.visible = true

	# For prototype, just show first active quest
	var quest_entity: EntityData = active_quests[0]
	var job: JobComponent = quest_entity.get_component("JobComponent")

	if job:
		active_quest_label.text = "Active: %s\n%d adventurers on mission" % [
			job.title,
			job.assigned_staff_ids.size()
		]


func _on_resolve_quest_pressed() -> void:
	var active_quests: Array[EntityData] = (
		quest_system.get_company_active_quests(game_manager.player_company_id)
	)

	if active_quests.is_empty():
		return

	# Resolve the first active quest
	var outcome: Dictionary = quest_system.resolve_quest(active_quests[0].id)

	if outcome.is_empty():
		push_error("Failed to resolve quest")
		return

	# Show results (for now, just print to console)
	# Later we'll make a proper results screen
	print("Quest Result: ", outcome["result"])
	print("Score: %d/%d" % [outcome["score"], outcome["required"]])
	print("Gold earned: ", outcome["gold_reward"])

	# TODO: Show quest results screen instead
	update_display()


# ============================================================================
# Signal Handlers
# ============================================================================

func _on_quest_assigned(
	_quest_id: int,
	_company_id: int,
	_staff_ids: Array[int],
) -> void:
	update_display()


func _on_quest_resolved(
	_quest_id: int,
	_company_id: int,
	_staff_ids: Array[int],
	_outcome: Dictionary,
) -> void:
	update_display()
