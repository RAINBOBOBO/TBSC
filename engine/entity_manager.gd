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
