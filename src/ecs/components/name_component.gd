class_name NameComponent extends Resource

@export var name: String = "John Entity"
@export var title: String = ""
@export var display_name: String:
	get:
		if title.is_empty():
			return name
		return "%s, %s" % [name, title]


func _init(entity_name: String = "") -> void:
	if not entity_name.is_empty():
		name = entity_name
