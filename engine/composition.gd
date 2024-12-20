class_name Composition extends Node

var components: Array[Component]


func _ready() -> void:
	_get_components()


func add_component(new_component: Component) -> void:
	add_child(new_component)


func get_component(search: String) -> Component:
	for component in components:
		if component.class_as_string == search:
			return component

	return NullComponent.new()


func has(search: Component) -> bool:
	return components.has(search.class_as_string)


func print_composition() -> void:
	pass


func _get_components() -> void:
	var children: Array[Node] = get_children()

