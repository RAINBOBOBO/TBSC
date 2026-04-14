class_name StatsComponent extends Component

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

const VALID_STATS := {
	"max_health":    { "min": 1, "max": 9999 },
	"max_condition": { "min": 1, "max": 9999 },
	"strength":      { "min": 1, "max": 20 },
	"dexterity":     { "min": 1, "max": 20 },
	"intelligence":  { "min": 1, "max": 20 },
	"magic":         { "min": 1, "max": 20 },
}


static func create_random() -> StatsComponent:
	var stats := StatsComponent.new()

	stats.max_health = 100
	stats.health = stats.max_health
	stats.max_condition = 100
	stats.condition = stats.max_condition

	stats.strength = randi_range(1, 20)
	stats.dexterity = randi_range(1, 20)
	stats.intelligence = randi_range(1, 20)
	stats.magic = randi_range(1, 20)

	return stats


static func build(
	entity: EntityData,
	blueprint: Dictionary,
	archetype_id: String
) -> void:
	assert(blueprint.has("stats"),
		"StatsComponent: archetype '%s' is missing [STAT] tags" \
		% archetype_id)

	var stat_list: Array = blueprint["stats"]
	var component := StatsComponent.new()

	for entry in stat_list:
		var key: String = entry["key"]
		var value: int = entry["value"]

		assert(VALID_STATS.has(key),
			"StatsComponent: archetype '%s' has unknown STAT key '%s'" \
			% [archetype_id, key])

		var bounds: Dictionary = VALID_STATS[key]
		assert(value >= bounds["min"] and value <= bounds["max"],
			("StatsComponent: archetype '%s' STAT '%s' value %d " \
			+ "is out of range [%d, %d]") \
			% [archetype_id, key, value, bounds["min"], bounds["max"]])

		component.set(key, value)

	# Derive current values from max values
	component.health = component.max_health
	component.condition = component.max_condition

	entity.add_component("stats", component)
