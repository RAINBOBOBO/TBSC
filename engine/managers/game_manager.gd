class_name GameManager extends Node

var player_company_id: int = -1
var free_agent_pool: Array[int] = []

@export var entity_manager: EntityManager
@export var quest_system: QuestSystem
@export var company_system: CompanySystem
