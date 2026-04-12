class_name EntityFactory extends RefCounted

# Turns an archetype blueprint into a fully constructed EntityData.
# Construction is delegated to each Component subclass via build().
#
# Adding support for a new component:
#   1. Write the component class extending Component, implementing build()
#   2. Register its tags in ComponentTagRegistry

var _registry: ComponentTagRegistry
var _archetypes: ArchetypeRegistry
var _entity_manager: EntityManager


func _init(
	registry: ComponentTagRegistry,
	archetypes: ArchetypeRegistry,
	entity_manager: EntityManager
) -> void:
	_registry = registry
	_archetypes = archetypes
	_entity_manager = entity_manager


# Spawn a new entity from an archetype id.
# Crashes loudly if the archetype is missing or any build() fails.
func spawn(archetype_id: String) -> EntityData:
	var blueprint := _archetypes.get_archetype(archetype_id)
	var entity := _entity_manager.create_entity()

	for builder in _registry.get_builders_for(blueprint):
		builder["class"].build(entity, blueprint, archetype_id)

	return entity
