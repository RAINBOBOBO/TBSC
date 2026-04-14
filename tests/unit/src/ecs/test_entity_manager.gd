class_name TestEntityManager extends TestCase

var _manager: EntityManager


func setUp() -> void:
	_manager = EntityManager.new()


func tearDown() -> void:
	_manager = null


# --- get_next_id ---

func test_get_next_id_starts_at_one() -> void:
	assert_eq(_manager.get_next_id(), 1)


func test_get_next_id_increments_each_call() -> void:
	assert_eq(_manager.get_next_id(), 1)
	assert_eq(_manager.get_next_id(), 2)
	assert_eq(_manager.get_next_id(), 3)


func test_created_entities_have_unique_ids() -> void:
	var a := _manager.create_entity()
	var b := _manager.create_entity()
	var c := _manager.create_entity()
	assert_ne(a.id, b.id)
	assert_ne(b.id, c.id)
	assert_ne(a.id, c.id)


# --- get_entities_with ---

func test_get_entities_with_returns_matching_entity() -> void:
	var entity := _manager.create_entity()
	entity.add_component("stats", {})
	var result := _manager.get_entities_with("stats")
	assert_eq(result.size(), 1)
	assert_eq(result[0].id, entity.id)


func test_get_entities_with_returns_all_matching() -> void:
	var a := _manager.create_entity()
	var b := _manager.create_entity()
	var c := _manager.create_entity()
	a.add_component("stats", {})
	b.add_component("stats", {})
	c.add_component("name", {})
	var result := _manager.get_entities_with("stats")
	assert_eq(result.size(), 2)


func test_get_entities_with_excludes_non_matching() -> void:
	var entity := _manager.create_entity()
	entity.add_component("name", {})
	var result := _manager.get_entities_with("stats")
	assert_eq(result.size(), 0)


func test_get_entities_with_empty_manager_returns_none() -> void:
	var result := _manager.get_entities_with("stats")
	assert_eq(result.size(), 0)


func test_get_entities_with_deleted_entity_not_returned() -> void:
	var entity := _manager.create_entity()
	entity.add_component("stats", {})
	_manager.delete_entity(entity.id)
	var result := _manager.get_entities_with("stats")
	assert_eq(result.size(), 0)
