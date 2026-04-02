class_name GameManager extends Node

@export var entity_manager: EntityManager


# Raw pipeline — assembled in _ready, used everywhere else
var tag_registry: ComponentTagRegistry
var archetype_registry: ArchetypeRegistry
var entity_factory: EntityFactory

# Raw files to load at startup (add new .cfg paths here)
const RAW_FILES: Array[String] = [
	"res://data/raws/creatures.cfg",
]


func _ready() -> void:
	_init_raw_pipeline()


func _init_raw_pipeline() -> void:
	tag_registry = ComponentTagRegistry.new()
	archetype_registry = ArchetypeRegistry.new()

	var parser := RawParser.new(tag_registry)

	for path in RAW_FILES:
		var parsed := parser.parse_file(path)
		archetype_registry.load_archetypes(parsed)

	entity_factory = EntityFactory.new(archetype_registry, entity_manager)

	print("GameManager: loaded %d archetypes from %d raw file(s)" % [
		archetype_registry.count(), RAW_FILES.size()])


# Convenience: spawn by archetype id and return the new entity
func spawn_entity(archetype_id: String) -> EntityData:
	return entity_factory.spawn(archetype_id)
