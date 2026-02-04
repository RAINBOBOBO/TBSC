class_name GameManager extends Node

var player_company_id: int = -1
var free_agent_pool: Array[int] = []

@export var entity_manager: EntityManager
@export var quest_system: QuestSystem
@export var company_system: CompanySystem
@export var hiring_screen: HiringScreen
@export var management_hub: ManagementHub
@export var party_selection: PartySelectionScreen

func _ready() -> void:
	initialize_game()

	quest_system.quest_assigned.connect(company_system.on_quest_assigned)
	quest_system.quest_resolved.connect(company_system.on_quest_resolved)

	hiring_screen.setup(entity_manager, company_system, self, free_agent_pool)
	hiring_screen.hiring_complete.connect(_on_hiring_complete)

	management_hub.setup(entity_manager, quest_system, company_system, self)
	management_hub.quest_selected_for_assignment.connect(_on_quest_selected)

	party_selection.visible = false
	party_selection.selection_confirmed.connect(_on_party_selection_confirmed)
	party_selection.selection_cancelled.connect(_on_party_selection_cancelled)


func initialize_game() -> void:
	for i in range(50):
		var adventurer = entity_manager.create_entity()
		adventurer.add_component(
			"StatsComponent",
			StatsComponent.create_random(),
		)
		adventurer.add_component(
			"NameComponent",
			NameComponent.new(),
		)
		free_agent_pool.append(adventurer.id)

	var company_entity = entity_manager.create_entity()
	company_entity.add_component("CompanyComponent", CompanyComponent.new())
	player_company_id = company_entity.id


func _on_hiring_complete() -> void:
	hiring_screen.visible = false
	management_hub.visible = true

	for i in range(3):
		quest_system.generate_quest()


func _on_party_selection_confirmed() -> void:
	party_selection.visible = false
	management_hub.visible = true
	management_hub.refresh_display()


func _on_party_selection_cancelled() -> void:
	party_selection.visible = false
	management_hub.visible = true


func _on_quest_selected(quest_id: int) -> void:
	management_hub.visible = false
	party_selection.visible = true
	party_selection.setup(
		entity_manager,
		quest_system,
		company_system,
		self,
		quest_id,
	)
