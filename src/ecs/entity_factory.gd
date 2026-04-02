class_name EntityFactory extends RefCounted

# Turns an archetype blueprint into a fully constructed EntityData.
#
# Adding support for a new component:
#   1. Write the component class (e.g. EquipmentComponent)
#   2. Register its tags in ComponentTagRegistry
#   3. Add a _build_<component> method here and call it in spawn()

var _archetypes: ArchetypeRegistry
var _entity_manager: EntityManager


func _init(archetypes: ArchetypeRegistry, entity_manager: EntityManager) -> void:
	_archetypes = archetypes
	_entity_manager = entity_manager


# Spawn a new entity from an archetype id.
# Crashes loudly if the archetype is missing or malformed.
func spawn(archetype_id: String) -> EntityData:
	var blueprint := _archetypes.get_archetype(archetype_id)  # asserts internally
	var entity := _entity_manager.create_entity()

	_build_name_component(entity, blueprint, archetype_id)
	_build_stats_component(entity, blueprint, archetype_id)

	return entity


# --- Component builders ---
# Each builder reads its component key out of the blueprint and attaches
# a populated component to the entity. Assert on anything that must be present.

func _build_name_component(entity: EntityData, blueprint: Dictionary, archetype_id: String) -> void:
	assert(blueprint.has("name"),
		"EntityFactory: archetype '%s' is missing a [NAME] tag" % archetype_id)

	var name_data: Dictionary = blueprint["name"]
	var component := NameComponent.new()

	assert(name_data.has("value"),
		"EntityFactory: archetype '%s' [NAME] tag produced no value" % archetype_id)
	component.name = name_data["value"]

	if name_data.has("secondary"):
		component.title = name_data["secondary"]

	entity.add_component("name", component)


func _build_stats_component(entity: EntityData, blueprint: Dictionary, archetype_id: String) -> void:
	assert(blueprint.has("stats"),
		"EntityFactory: archetype '%s' is missing [STAT] tags" % archetype_id)

	var stat_list: Array = blueprint["stats"]
	var component := StatsComponent.new()

	# Valid stat keys and their allowed ranges for loud validation
	var valid_stats := {
		"max_health":    { "min": 1,  "max": 9999 },
		"max_condition": { "min": 1,  "max": 9999 },
		"strength":      { "min": 1,  "max": 20 },
		"dexterity":     { "min": 1,  "max": 20 },
		"intelligence":  { "min": 1,  "max": 20 },
		"magic":         { "min": 1,  "max": 20 },
	}

	for entry in stat_list:
		var key: String = entry["key"]
		var value: int = entry["value"]

		assert(valid_stats.has(key),
			"EntityFactory: archetype '%s' has unknown STAT key '%s'" % [archetype_id, key])

		var bounds: Dictionary = valid_stats[key]
		assert(value >= bounds["min"] and value <= bounds["max"],
			"EntityFactory: archetype '%s' STAT '%s' value %d is out of range [%d, %d]" % [
				archetype_id, key, value, bounds["min"], bounds["max"]])

		component.set(key, value)

	# Derive current values from max values
	component.health = component.max_health
	component.condition = component.max_condition

	entity.add_component("stats", component)
