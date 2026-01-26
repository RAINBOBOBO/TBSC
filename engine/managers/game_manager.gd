class_name GameManager extends Node

var player_company_id: int = -1
var free_agent_pool: Array[int] = []

@export var entity_manager: EntityManager
@export var quest_system: QuestSystem
@export var company_system: CompanySystem


func _ready() -> void:
	quest_system.quest_assigned.connect(company_system.on_quest_assigned)
	quest_system.quest_resolved.connect(company_system.on_quest_resolved)


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
