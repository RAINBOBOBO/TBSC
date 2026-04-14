class_name TestSpawnPipeline extends TestCase

var _entity_manager: EntityManager
var _factory: EntityFactory


func setUp() -> void:
	var tag_registry := ComponentTagRegistry.new()
	var archetype_registry := ArchetypeRegistry.new()
	var parser := RawParser.new(tag_registry)

	var parsed := parser.parse_text("""
[ARCHETYPE:BASIC_HUMAN]
[NAME:Human]
[STAT:max_health:100]
[STAT:max_condition:100]
[STAT:strength:5:15]
[STAT:dexterity:5:15]
[STAT:intelligence:5:15]
[STAT:magic:0:15]
[ARCHETYPE:END]
""")
	archetype_registry.load_archetypes(parsed)

	_entity_manager = EntityManager.new()
	_factory = EntityFactory.new(
		tag_registry, archetype_registry, _entity_manager)


func tearDown() -> void:
	_entity_manager = null
	_factory = null


# --- BASIC_HUMAN ---

func test_spawned_human_has_name_component() -> void:
	var entity := _factory.spawn("BASIC_HUMAN")
	assert_true(entity.has_component("name"))


func test_spawned_human_has_stats_component() -> void:
	var entity := _factory.spawn("BASIC_HUMAN")
	assert_true(entity.has_component("stats"))


func test_spawned_human_name_is_correct() -> void:
	var entity := _factory.spawn("BASIC_HUMAN")
	var name_comp := entity.get_component("name") as NameComponent
	assert_eq(name_comp.name, "Human")


func test_spawned_human_max_health_is_correct() -> void:
	var entity := _factory.spawn("BASIC_HUMAN")
	var stats := entity.get_component("stats") as StatsComponent
	assert_eq(stats.max_health, 100)


func test_spawned_human_health_equals_max_health() -> void:
	var entity := _factory.spawn("BASIC_HUMAN")
	var stats := entity.get_component("stats") as StatsComponent
	assert_eq(stats.health, stats.max_health)


func test_spawned_human_strength_within_range() -> void:
	var entity := _factory.spawn("BASIC_HUMAN")
	var stats := entity.get_component("stats") as StatsComponent
	assert_in_range(stats.strength, 5, 15)


func test_spawned_human_is_registered_in_entity_manager() -> void:
	var entity := _factory.spawn("BASIC_HUMAN")
	assert_true(_entity_manager.has_entity(entity.id))
