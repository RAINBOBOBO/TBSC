class_name GameManager extends Node

var player_company_id: int = -1
var free_agent_pool: Array[int] = []

@export var entity_manager: EntityManager
@export var quest_system: QuestSystem
@export var company_system: CompanySystem
@export var hiring_screen: HiringScreen
@export var management_hub: Control


func _ready() -> void:
	initialize_game()

	quest_system.quest_assigned.connect(company_system.on_quest_assigned)
	quest_system.quest_resolved.connect(company_system.on_quest_resolved)

	hiring_screen.setup(entity_manager, company_system, self, free_agent_pool)
	hiring_screen.hiring_complete.connect(_on_hiring_complete)


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
