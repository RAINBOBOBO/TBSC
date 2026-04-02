class_name StatsComponent extends Resource

@export_category("Core Stats")
@export var health: int = 100
@export var max_health: int = 100
@export var condition: int = 100
@export var max_condition: int = 100

@export_category("Attributes")
@export_range(1, 20) var strength: int = 10
@export_range(1, 20) var dexterity: int = 10
@export_range(1, 20) var intelligence: int = 10
@export_range(1, 20) var magic: int = 10


static func create_random() -> StatsComponent:
	var stats = StatsComponent.new()

	stats.max_health = 100
	stats.health = stats.max_health
	stats.max_condition = 100
	stats.condition = stats.max_condition

	stats.strength = randi_range(1, 20)
	stats.dexterity = randi_range(1, 20)
	stats.intelligence = randi_range(1, 20)
	stats.magic = randi_range(1, 20)

	return stats
