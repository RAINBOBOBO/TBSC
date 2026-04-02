class_name EntityManager extends Node

var entities: Dictionary = {} # id: EntityData
var next_id: int = 0


func get_next_id() -> int:
	next_id += 1
	return next_id


func create_entity() -> EntityData:
	var entity = EntityData.new()
	entity.id = get_next_id()
	entities[entity.id] = entity

	return entity


func delete_entity(entity_id: int) -> bool:
	if entity_id in entities:
		entities.erase(entity_id)
		return true

	return false


func get_entities_with(component_type: String) -> Array[EntityData]:
	var result: Array[EntityData]
	for entity in entities.values():
		if entity.has_component(component_type):
			result.append(entity)

	return result


func get_entity(entity_id: int) -> EntityData:
	return entities.get(entity_id)


func get_entity_component(entity_id: int, component_type: String) -> Resource:
	var entity = get_entity(entity_id)
	if not entity:
		return null
	return entity.get_component(component_type)


func has_entity(entity_id: int) -> bool:
	return entity_id in entities
